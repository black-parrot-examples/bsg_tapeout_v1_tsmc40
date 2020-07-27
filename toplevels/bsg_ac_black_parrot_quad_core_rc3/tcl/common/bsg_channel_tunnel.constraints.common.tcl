puts "BSG-info: Running script [info script]\n"

source -echo -verbose clock_variables.tcl
source -echo -verbose bsg_generic.constraints.tcl

set core_input_ports [remove_from_collection [all_inputs] [get_ports clk_i]]

set core_output_ports [all_outputs]

bsg_generic $CORE_CLK_NAME [get_ports clk_i] $CORE_CLK_PERIOD 0.1 $core_input_ports $core_output_ports 0.4 0.4 16 INVD1BWP 0.1

puts "BSG-info: Completed script [info script]\n"

