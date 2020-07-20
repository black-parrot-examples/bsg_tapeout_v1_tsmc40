# bsg_write_file
proc bsg_write_file {floc flist} {
  set f $floc
  set fid [open $f "w"]
  foreach item $flist {
    puts $fid $item
  }
  close $fid
}

# bsg_get_length
proc bsg_get_length {flist} {
  if {[info exists flist]} {
    return [llength $flist]
  }
}

# bsg_create_filelist
proc bsg_create_filelist {filelist source_files} {
  bsg_write_file $filelist $source_files
}

# bsg_create_library, include_paths arg is optional
proc bsg_create_library {library_name library_file source_files {include_paths ""}} {

  # header
  lappend library_list "library $library_name"

  # source files
  set len [bsg_get_length $source_files]
  set i 0
  foreach f $source_files {
    if {$i == [expr $len - 1]} {
      lappend library_list "$f"
    } else {
      lappend library_list "$f,"
    }
    incr i
  }

  # include paths
  set len [bsg_get_length $include_paths]
  if {$len > 0} {
    lappend library_list "-incdir"
  }
  set i 0
  foreach f $include_paths {
    if {$i == [expr $len - 1]} {
      lappend library_list "$f"
    } else {
      lappend library_list "$f,"
    }
    incr i
  }

  # footer
  lappend library_list ";"

  # write library
  bsg_write_file $library_file $library_list

}

# scripts for creating filelist and library
#source $::env(BSG_TESTING_COMMON_DIR)/bsg_vcs_create_filelist_library.tcl
#
source $::env(BSG_CHIP_DIR)/cad/pdk_setup/pdk_setup.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/common/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/tcl/common/$::env(BSG_TARGET_PROCESS)/filelist_deltas.tcl

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
foreach lib [array name VERILOG_FILE] {
  if { $VERILOG_FILE($lib) != "" } {
    set all_final_source_files [concat $all_final_source_files [join $VERILOG_FILE($lib)]]
  }
}

# chip filelist
bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $all_final_source_files

# chip library
bsg_create_library $::env(BSG_CHIP_LIBRARY_NAME) \
                   $::env(BSG_CHIP_LIBRARY)      \
                   $all_final_source_files  \
                   $final_sverilog_include_paths

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/include.tcl

# testing filelist
bsg_create_filelist $::env(BSG_DESIGNS_TESTING_FILELIST) \
                    $TESTING_SOURCE_FILES

# testing library
bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   $TESTING_SOURCE_FILES                    \
                   $TESTING_INCLUDE_PATHS
