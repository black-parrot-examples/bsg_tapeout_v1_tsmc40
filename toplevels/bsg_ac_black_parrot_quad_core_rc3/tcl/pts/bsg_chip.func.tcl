puts "BSG-info: Running script [info script]\n"

read_sdc -echo $DESIGN_NAME.${signoff_mode}_wc_cworst.output.sdc
remove_clock_uncertainty [all_clocks]
remove_max_transition [current_design]
remove_max_capacitance [current_design]
remove_max_fanout [current_design]
reset_timing_derate

puts "BSG-info: Completed script [info script]\n"

