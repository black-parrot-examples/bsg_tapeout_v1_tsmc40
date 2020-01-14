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

source $::env(BSG_CHIP_DIR)/cad/setup/common_setup.tcl

# chip source (rtl) files and include paths list
source $::env(BSG_CHIP_DIR)/cad/flow/dc/bsg_dc_scripts/target_design.filelist.tcl
source $::env(BSG_CHIP_DIR)/cad/flow/dc/bsg_dc_scripts/target_design.include.tcl

foreach lib [array name VERILOG_FILES] {
  if { $VERILOG_FILES($lib) != "" } {
    set all_final_source_files [concat $all_final_source_files [join $VERILOG_FILES($lib)]]
  }
}

# chip filelist
bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $all_final_source_files

# chip library
bsg_create_library $::env(BSG_CHIP_LIBRARY_NAME) \
                   $::env(BSG_CHIP_LIBRARY)      \
                   $all_final_source_files       \
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
