puts "BSG-info: Running script [info script]\n"

source -echo -verbose clock_variables.tcl
source -echo -verbose bsg_async.constraints.tcl
source -echo -verbose bsg_set_general_timing_constraints.tcl

set ui_input_ports [get_ports app_* -filter "direction==in"]
append_to_collection ui_input_ports [get_ports ui_clk_sync_rst_i]

set dfi_input_ports [remove_from_collection [get_ports dfi_* -filter "direction==in"] [get_ports dfi_clk_i]]
append_to_collection dfi_input_ports [get_ports dmc_p_i*]

set ui_output_ports [get_ports app_* -filter "direction==out"]

set dfi_output_ports [get_ports dfi_* -filter "direction==out"]
append_to_collection dfi_output_ports [get_ports init_calib_complete_o]

bsg_set_general_timing_constraints $ROUTER_CLK_NAME [get_ports ui_clk_i]  $ROUTER_CLK_PERIOD              0.1 $ui_input_ports  $ui_output_ports  0.4 0.4 16 INVD1BWP 0.1
bsg_set_general_timing_constraints $DFI_CLK_1X_NAME [get_ports dfi_clk_i] [expr $DFI_CLK_2X_PERIOD * 2.0] 0.1 $dfi_input_ports $dfi_output_ports 0.4 0.4 16 INVD1BWP 0.1

set_clock_groups -asynchronous                        \
                 -group [get_clocks $ROUTER_CLK_NAME] \
                 -group [get_clocks $DFI_CLK_1X_NAME]

bsg_async_cdc [all_clocks]

puts "BSG-info: Completed script [info script]\n"

