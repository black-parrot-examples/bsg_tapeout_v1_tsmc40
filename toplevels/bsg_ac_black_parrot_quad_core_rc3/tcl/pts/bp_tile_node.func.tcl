puts "BSG-info: Running script [info script]\n"

set opcond [lindex [split $corner _] 0] 

if {$opcond == "bc"} {
  read_sdc -echo $DESIGN_NAME.${signoff_mode}_bc_cbest.output.sdc
} elseif {$opcond == "wc"} {
  read_sdc -echo $DESIGN_NAME.${signoff_mode}_wc_cworst.output.sdc
} else {
  puts "Error: unexpected operating condition."
  exit 1
}

remove_clock_uncertainty [all_clocks]
reset_timing_derate
remove_max_transition  [current_design]
remove_max_capacitance [current_design]
remove_max_fanout      [current_design]

puts "BSG-info: Completed script [info script]\n"

