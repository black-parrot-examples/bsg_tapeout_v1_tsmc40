puts "Flow-Info: Running script [info script]\n"

source proc_auto_weights.tcl

set cur_scenario [current_scenario]
foreach scenario [all_active_scenarios] {
  current_scenario $scenario
  if { $ICC_IMPLEMENTATION_PHASE != "default" } {
    proc_auto_weights -exclude_groups "REGIN REGOUT"
  }
}
current_scenario $cur_scenario

#if { $ICC_IMPLEMENTATION_PHASE == "top" } {
#  set va [get_voltage_areas PLL]
#  
#  set va_llx [get_attribute $va bbox_llx]
#  set va_lly [get_attribute $va bbox_lly]
#  set va_urx [get_attribute $va bbox_urx]
#  set va_ury [get_attribute $va bbox_ury]
#  
#  set va_guardband_x [get_attribute $va guardband_x]
#  set va_guardband_y [get_attribute $va guardband_y]
#  
#  set va_guard_llx [expr $va_llx - $va_guardband_x]
#  set va_guard_lly [expr $va_lly - $va_guardband_y]
#  set va_guard_urx [expr $va_urx + $va_guardband_x]
#  set va_guard_ury [expr $va_ury + $va_guardband_y]
#  
#  create_placement_blockage -bbox [list $va_guard_llx $va_guard_lly $va_urx $va_lly] -type hard -name pb_0
#  create_placement_blockage -bbox [list $va_urx $va_guard_lly $va_guard_urx $va_ury] -type hard -name pb_1
#  create_placement_blockage -bbox [list $va_llx $va_ury $va_guard_urx $va_guard_ury] -type hard -name pb_2
#  create_placement_blockage -bbox [list $va_guard_llx $va_lly $va_llx $va_guard_ury] -type hard -name pb_3
#}

puts "Flow-Info: Completed script [info script]\n"
