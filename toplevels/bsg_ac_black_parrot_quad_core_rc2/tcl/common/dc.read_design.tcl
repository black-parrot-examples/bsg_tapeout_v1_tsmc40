#===============================================================================
# scripts/dc/bsg_target_design.dc.read_design.tcl
#
# This script is responsible for reading in the target design for design
# compiler. Most of the information for reading in the design comes from the
# target bsg_design directory. This script is responsible for performing
# analysis and elaboration as well as other constraints such as dont-touch and
# other attributes.
#===============================================================================

puts "BSG-info: Running script [info script]\n"

source -echo -verbose filelist.tcl
source -echo -verbose $::env(BSG_TARGET_PROCESS)/filelist_deltas.tcl

########################################
## Define WORK directory
########################################

if { ![file exists ${DESIGN_NAME}_WORK] } {
  file mkdir ${DESIGN_NAME}_WORK
}

define_design_lib WORK -path ./${DESIGN_NAME}_WORK

########################################
## Design's include path
########################################

set final_sverilog_include_paths [list]
foreach incdir $SVERILOG_INCLUDE_PATHS {
  # replace 'portable' directories with the target process
  if { $::env(BSG_TOPLEVEL_DESIGN_TYPE) != "block" } {
    lappend final_sverilog_include_paths [regsub -all portable $incdir $::env(BSG_PACKAGING_FOUNDRY)]
  } else {
    lappend final_sverilog_include_paths $incdir
  }
}

# finalized list of include dirs
set final_sverilog_include_paths [join "$final_sverilog_include_paths"]

if { ${final_sverilog_include_paths} != "" } {
  set_app_var search_path "${final_sverilog_include_paths} ${search_path}"
}

########################################
## Design's filelist(s)
########################################

# get names of all modules to hard-swap
set hard_swap_module_list [list]
foreach f $HARD_SWAP_FILELIST {
  lappend hard_swap_module_list [file rootname [file tail $f]]
}

# generate a new list of source files while performing hard-swapping
set sverilog_source_files [list]
foreach f $SVERILOG_SOURCE_FILES {
  set module_name [file rootname [file tail $f]]
  set idx [lsearch $hard_swap_module_list $module_name]
  if {$idx == -1} {
    lappend sverilog_source_files $f
  } else {
    lappend sverilog_source_files [lindex $HARD_SWAP_FILELIST $idx]
  }
}

# finalized list of pre-synthesized source files
set final_netlist_source_files $NETLIST_SOURCE_FILES

# finalized list of source files that need synthesizing
set final_sverilog_source_files [concat $sverilog_source_files $NEW_SVERILOG_SOURCE_FILES]

# all source files (including pre-synthesized netlist files)
set all_final_source_files [concat $final_netlist_source_files $final_sverilog_source_files]

########################################
## Read the design
########################################

# Do this before reading anything else... otherwise you might dont_touch a
# design that you don't want to set that attribute on.
if { $final_netlist_source_files != "" } {
  read_verilog -netlist $final_netlist_source_files
  #set_dont_touch [get_designs] true
  foreach_in_collection design [get_designs bsg_rp*] {
    current_design $design
    set_dont_touch [get_cells *]
  }
}

# Prevent constant propagation on hardened tielo and tiehi cells
#set bsg_tie_lo_designs [get_designs -quiet bsg_rp_tsmc_*_TIELO_b*]
#set bsg_tie_hi_designs [get_designs -quiet bsg_rp_tsmc_*_TIEHI_b*]
#if { [sizeof_collection $bsg_tie_lo_designs] > 0 } { set_compile_directives -constant_propagation false $bsg_tie_lo_designs }
#if { [sizeof_collection $bsg_tie_hi_designs] > 0 } { set_compile_directives -constant_propagation false $bsg_tie_hi_designs }

# Performa analysis on all of the files
if { $final_sverilog_source_files != "" } {
  if { ![analyze -define {SYNTHESIS} -format sverilog $final_sverilog_source_files] } {
    exit -1
  }
}

########################################
## Elaborate the design
########################################

# Performa elaboration on the top block
if { ![elaborate $::env(TOP_HIER_BLOCK)] } {
  exit -1
}

########################################
## Rename and set design
########################################

# Check if the design name is found in the collection of designs. If not, then
# it either doesn't exist or it has been renamed (from parameters)

foreach design_name $HIERARCHICAL_DESIGNS {
  if { [sizeof_collection [get_designs -quiet $design_name]] == 0 } {
    set designs [get_designs -quiet -filter "hdl_template==${design_name}"]
    if { [sizeof_collection $designs] > 1 } {
      puts "BSG-error: Toplevel design has multiple instances post-elaboration. This"
      puts "usually indicates that there are multiple parameterizations of the design."
      puts "This flow does not support different parameterizations of the top-level"
      puts "compile target, consider using a wrapper to uniqify the hierarchy for each"
      puts "parameter."
      exit -1
    }
    rename_design $designs $design_name
  }
}

current_design ${DESIGN_NAME}

# BSG-STD: The typical way we go about hierarchical parameters is to elaborate
# the chip-top (usually called bsg_chip) which will elaborate (or "push") all
# the parameters for sub-modules. Therefore, we don't really have the raw
# parameter list for all sub-blocks that we might be synthesizing. This appears
# to be a problem particularly for Formality so we query the tool for the
# parameters and dump them to a file for the Formality flow. This info can also
# just be useful on its own.

set param_list [list]
foreach {name arrow value} [lsearch -all -inline -not -exact [split [get_attribute [current_design] hdl_parameters] {, }] {}] {
  lappend param_list "${name}=${value}"
}

set fid [open "${RESULTS_DIR}/${DESIGN_NAME}.parameters.tcl" "w"]
puts $fid "set bsg_parameter_str {[join ${param_list} {,}]}"
close $fid

if { $::env(BSG_BLOCK_HIER_LEVEL) == "top" } {
  set_dont_touch [get_cells -of_objects [get_ports *]]
  if { [sizeof_collection [get_designs -filter "hdl_template==bsg_launch_sync_sync"]] > 0 } {
    set_boundary_optimization [get_designs -filter "hdl_template==bsg_launch_sync_sync"] false
  }
  #current_design [get_designs -filter "hdl_template==bsg_clk_gen_power_domain"]
  #set_ungroup [remove_from_collection [all_designs] [current_design]]
  #current_design $DESIGN_NAME
} else {
  set_ungroup [remove_from_collection [all_designs] [current_design]]
}

########################################
## TLU+ Setup (if needed)
########################################

# BSG-STD: GF14 specific, most other processes this will be done in the
# dc_setup.tcl file. We had to defer loading the TLU+ files until now because
# we needed to set a reference direction which failed unless a design was
# loaded.
if { $::env(BSG_TARGET_PROCESS) == "gf_14" } {
  if {[shell_is_in_topographical_mode]} {
    set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE -min_tluplus $TLUPLUS_MIN_FILE -tech2itf_map $MAP_FILE
    set_extraction_options -reference_direction vertical
    check_tlu_plus_files
  }
}

define_name_rule verilog -preserve_struct_port
change_names -rules verilog -hierarchy

set_app_var case_analysis_propagate_through_icg true

puts "BSG-info: Completed script [info script]\n"

