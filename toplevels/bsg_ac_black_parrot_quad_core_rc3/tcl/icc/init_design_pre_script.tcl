puts "Flow-Info: Running script [info script]\n"

if { $ICC_IMPLEMENTATION_PHASE == "default" } {
  set_false_path -to [get_pins -of_objects [get_fp_cells -filter "is_hard_macro"] -filter "name==CLKR||name==CLKW"]
}

redirect -file $REPORTS_DIR_INIT_DESIGN/init_design_icc.check_timing.rpt {check_timing}

puts "Flow-Info: Completed script [info script]\n"
