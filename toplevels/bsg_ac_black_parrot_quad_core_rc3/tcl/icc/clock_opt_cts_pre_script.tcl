puts "Flow-Info: Running script [info script]\n"

remove_propagated_clock [get_attribute [all_clocks] sources]
set_propagated_clock [remove_from_collection [all_clocks] [get_clocks *_cdc]]

set_clock_tree_exceptions -non_stop_pins [get_pins -of_objects [remove_from_collection [all_registers -include_icg] [all_registers]] -filter "name==CP"]

puts "Flow-Info: Completed script [info script]\n"
