puts "BSG-info: Running script [info script]\n"

source -echo -verbose clock_variables.tcl
source -echo -verbose bsg_async.constraints.tcl
source -echo -verbose bsg_generic.constraints.tcl

set coh_input_ports [remove_from_collection [get_ports coh_* -filter "direction==in"] [get_ports coh_clk_i]]

set io_input_ports [remove_from_collection [get_ports io_* -filter "direction==in"] [get_ports io_clk_i]]

set core_input_ports [remove_from_collection [all_inputs] [get_ports *clk_i]]
set core_input_ports [remove_from_collection $core_input_ports $io_input_ports]

set coh_output_ports  [get_ports coh_* -filter "direction==out"]

set io_output_ports  [get_ports io_* -filter "direction==out"]

set core_output_ports [remove_from_collection [all_outputs] $io_output_ports]

bsg_generic $CORE_CLK_NAME   [get_ports "core_clk_i coh_clk_i"] $CORE_CLK_PERIOD   0.1 $core_input_ports $core_output_ports 0.4 0.4 16 INVD1BWP 0.1
bsg_generic $ROUTER_CLK_NAME [get_ports io_clk_i]               $ROUTER_CLK_PERIOD 0.1 $io_input_ports   $io_output_ports   0.4 0.4 16 INVD1BWP 0.1

set_false_path -from [get_ports *cord_i*]
set_false_path -from [get_ports *did_i*]

set_clock_groups -asynchronous                      \
                 -group [get_clocks $CORE_CLK_NAME] \
                 -group [get_clocks $ROUTER_CLK_NAME]

bsg_async_cdc [all_clocks]

puts "BSG-info: Completed script [info script]\n"

