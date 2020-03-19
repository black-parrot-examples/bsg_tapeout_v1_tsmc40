puts "Flow-Info: Running script [info script]\n"

set cur_scenario [current_scenario] 

foreach scenario [all_active_scenarios] {
  current_scenario $scenario
  if { $ICC_IMPLEMENTATION_PHASE == "default" } {
    set_false_path -to [get_pins -of_objects [get_fp_cells -filter "is_hard_macro"] -filter "name==CLKR||name==CLKW"]
  } elseif {$ICC_IMPLEMENTATION_PHASE == "block"} {
    set_false_path -to [get_pins -of_objects [get_fp_cells -filter "is_hard_macro"] -filter "name==CLKR||name==CLKW"]
  
    foreach_in_collection launch_clk [all_clocks] {
      foreach_in_collection latch_clk [remove_from_collection [all_clocks] $launch_clk] {
        set_max_delay [get_attribute $launch_clk period] -from $launch_clk -to $latch_clk -ignore_clock_latency
        set_false_path -hold                             -from $launch_clk -to $latch_clk
      }  
    }
  }
}

current_scenario $cur_scenario

puts "Flow-Info: Completed script [info script]\n"
