puts "BSG-info: Running script [info script]\n"

proc bsg_set_general_timing_constraints { clk_name clk_source clk_period clk_uncertainty input_ports output_ports max_transition max_fanout driving_inv loading_inv } {

  create_clock -period $clk_period -name $clk_name $clk_source
  set_clock_uncertainty $clk_uncertainty [get_clocks $clk_name]
  
  set_input_delay [expr $clk_period / 2.0] $input_ports -clock [get_clocks $clk_name] -max
  set_input_delay 0.0 $input_ports -clock [get_clocks $clk_name] -min
  
  set_output_delay [expr $clk_period / 2.0] $output_ports -clock [get_clocks $clk_name] -max
  set_output_delay 0.0 $output_ports -clock [get_clocks $clk_name] -min
  
  set_max_transition $max_transition [current_design]
  set_max_fanout $max_fanout [current_design]
  
  set_driving_cell -no_design_rule -lib_cell $driving_inv $input_ports
  set_load [load_of [get_lib_pins -of_objects [get_lib_cells -scenarios [current_scenario] */$loading_inv] -filter "direction==in"]] $output_ports

}

puts "BSG-info: Completed script [info script]\n"

