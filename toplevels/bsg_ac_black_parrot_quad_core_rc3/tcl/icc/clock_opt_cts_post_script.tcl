puts "Flow-Info: Running script [info script]\n"

foreach scenario [all_active_scenarios] {
  current_scenario $scenario

  remove_propagated_clock [get_attribute [all_clocks] sources]

  set_propagated_clock [remove_from_collection [remove_from_collection [all_clocks] [get_clocks -filter !defined(sources)]] [get_clocks *_cdc]]
}

puts "Flow-Info: Completed script [info script]\n"
