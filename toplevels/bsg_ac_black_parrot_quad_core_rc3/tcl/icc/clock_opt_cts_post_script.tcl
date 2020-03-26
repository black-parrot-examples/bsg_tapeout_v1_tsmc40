puts "Flow-Info: Running script [info script]\n"

current_scenario

remove_propagated_clock [get_attribute [all_clocks] sources]
set_propagated_clock [remove_from_collection [all_clocks] [get_clocks *_cdc]]

puts "Flow-Info: Completed script [info script]\n"
