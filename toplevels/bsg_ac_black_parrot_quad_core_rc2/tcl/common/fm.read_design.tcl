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

if { $final_netlist_source_files != "" } {
  read_sverilog -r -define {SYNTHESIS ASIC SYNTHESIS_HARDWARE NO_DUMMY} $final_netlist_source_files
}

if { $final_sverilog_source_files != "" } {
  read_sverilog -r -define {SYNTHESIS ASIC SYNTHESIS_HARDWARE NO_DUMMY} $final_sverilog_source_files
}

puts "BSG-info: Completed script [info script]\n"

