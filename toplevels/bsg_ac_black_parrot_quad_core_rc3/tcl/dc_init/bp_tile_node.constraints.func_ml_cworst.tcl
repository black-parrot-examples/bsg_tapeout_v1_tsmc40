puts "BSG-info: Running script [info script]\n"

source clock_variables.tcl
source bsg_set_general_timing_constraints.tcl

set coh_input_ports  [remove_from_collection [get_ports coh* -filter "direction==in"] [get_ports coh_clk_i]]
set mem_input_ports  [remove_from_collection [get_ports mem* -filter "direction==in"] [get_ports mem_clk_i]]
set core_input_ports [remove_from_collection [all_inputs] [get_ports *clk_i]]
set core_input_ports [remove_from_collection $core_input_ports $mem_input_ports]

set coh_output_ports  [get_ports coh* -filter "direction==out"]
set mem_output_ports  [get_ports mem* -filter "direction==out"]
set core_output_ports [remove_from_collection [all_outputs] $mem_output_ports]

bsg_set_general_timing_constraints $CORE_CLK_NAME   [get_ports "core_clk_i coh_clk_i"] $CORE_CLK_PERIOD   0.1 $core_input_ports $core_output_ports 0.2 0.1 16 INVD1BWP 0.1
bsg_set_general_timing_constraints $ROUTER_CLK_NAME [get_ports mem_clk_i]              $ROUTER_CLK_PERIOD 0.1 $mem_input_ports  $mem_output_ports  0.2 0.1 16 INVD1BWP 0.1

set_false_path -from [get_ports *cord_i*]
set_false_path -from [get_ports *did_i*]

set_clock_groups -asynchronous                      \
                 -group [get_clocks $CORE_CLK_NAME] \
                 -group [get_clocks $ROUTER_CLK_NAME]

#source bsg_async.constraints.tcl
#update_timing
#bsg_async
source bsg_async_block.constraints.tcl
update_timing
bsg_async_block [get_clocks];

puts "BSG-info: Completed script [info script]\n"

