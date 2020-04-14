puts "Flow-Info: Running script [info script]\n"

set cur_scenario [current_scenario]

if { $ICC_IMPLEMENTATION_PHASE == "default" } {
  foreach scenario [all_active_scenarios] {
    current_scenario $scenario
    set_false_path -to [get_pins -of_objects [get_fp_cells -filter "is_hard_macro"] -filter "name==CLKR||name==CLKW"]
  }
}

# setup scenario check_timing
foreach scenario [get_scenarios -setup true] {
  current_scenario $scenario
  redirect -tee -file $REPORTS_DIR_INIT_DESIGN/init_design_icc.check_timing.$scenario.rpt {check_timing -exclude partial_input_delay}
}

# hold scenario check_timing
foreach scenario [get_scenario -hold true] {
  current_scenario $scenario
  redirect -tee -file $REPORTS_DIR_INIT_DESIGN/init_design_icc.check_timing.$scenario.rpt \
    {check_timing -exclude [list unconstrained_endpoints partial_input_delay]}
}

current_scenario $cur_scenario

puts "Flow-Info: Completed script [info script]\n"
