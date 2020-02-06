puts "BSG-info: Running script [info script]\n"

set_voltage $PDK_CORE_VOLTAGE(min) -object_list VDD
set_voltage 0.00 -object_list VSS

puts "BSG-info: Completed script [info script]\n"

