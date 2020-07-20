puts "BSG-info: Running script [info script]\n"

set_voltage $PDK_CORE_VOLTAGE(min) -object_list VDD
set_voltage $PDK_CORE_VOLTAGE(min) -object_list VDD_PLL
set_voltage 0.00 -object_list VSS
set_voltage $PDK_IO_VOLTAGE(min) -object_list VDDPST
set_voltage 0.00 -object_list VSSPST

puts "BSG-info: Completed script [info script]\n"

