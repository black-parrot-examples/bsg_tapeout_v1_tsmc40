puts "BSG-info: Running script [info script]\n"

source bsg_set_general_timing_constraints.tcl

set coh_input_ports  [remove_from_collection [get_ports coh* -filter "direction==in"] [get_ports coh_clk_i]]
set mem_input_ports  [remove_from_collection [get_ports mem* -filter "direction==in"] [get_ports mem_clk_i]]
set core_input_ports [remove_from_collection [all_inputs] [get_ports *clk_i]]
set core_input_ports [remove_from_collection $core_input_ports $mem_input_ports]

set coh_output_ports  [get_ports coh* -filter "direction==out"]
set mem_output_ports  [get_ports mem* -filter "direction==out"]
set core_output_ports [remove_from_collection [all_outputs] $mem_output_ports]

bsg_set_general_timing_constraints bp_clk [get_ports "core_clk_i coh_clk_i"] 2.0 0.1 $core_input_ports $core_output_ports 0.2 16 INVD1BWP INVD8BWP
bsg_set_general_timing_constraints mem_clk [get_ports mem_clk_i] 2.0 0.1 $mem_input_ports $mem_output_ports 0.2 16 INVD1BWP INVD8BWP

#set_false_path -from [get_ports *cord_i*]
#set_disable_timing   [get_ports *cord_i*]
#set_false_path -from [get_ports my_cid_i*]
#set_disable_timing   [get_ports my_cid_i*]
#set_false_path -from [get_ports proc_cfg_i*]
#set_disable_timing   [get_ports proc_cfg_i*]

source bsg_async.constraints.tcl
update_timing
bsg_async

set_voltage $PDK_CORE_VOLTAGE(max) -object_list VDD
set_voltage 0.00 -object_list VSS

puts "BSG-info: Completed script [info script]\n"

