puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]
set_preroute_drc_strategy -max_layer M9

set va [get_voltage_areas PD_PLL]
set va_preroute_area_llx [expr [get_attribute $va bbox_llx] - [get_attribute $va guardband_x]]
set va_preroute_area_lly [expr [get_attribute $va bbox_lly] - 0.5 * $tile_height]
set va_preroute_area_urx [expr [get_attribute $va bbox_urx] + [get_attribute $va guardband_x]]
set va_preroute_area_ury [expr [get_attribute $va bbox_ury] + 0.5 * $tile_height]

#preroute_standard_cells -mode rail -connect both -nets "VDD_PLL VSS" -within [list [list $va_preroute_area_llx $va_preroute_area_lly] [list $va_preroute_area_urx $va_preroute_area_ury]] -no_routing_outside_working_area -skip_macro_pins -skip_pad_pins -remove_floating_pieces -do_not_route_over_macros -fill_empty_rows
preroute_standard_cells -mode rail -connect both -nets "VDD_PLL VSS" -within_voltage_area [get_voltage_area PD_PLL] -no_routing_outside_working_area -skip_macro_pins -skip_pad_pins -remove_floating_pieces -do_not_route_over_macros -fill_empty_rows

foreach_in_collection va [remove_from_collection [get_voltage_areas *] [get_voltage_areas "PD_PLL DEFAULT_VA"]] {
  foreach_in_collection macro [get_cells -of_objects $va -filter "is_hard_macro"] {
    set macro_bbox [get_attribute $macro bbox]
    set macro_bbox_llx [lindex [lindex $macro_bbox 0] 0]
    set macro_bbox_lly [lindex [lindex $macro_bbox 0] 1]
    set macro_bbox_urx [lindex [lindex $macro_bbox 1] 0]
    set macro_bbox_ury [lindex [lindex $macro_bbox 1] 1]
    set keepout [get_attribute $macro outer_keepout_margin]
    set keepout_lx [lindex [lindex $keepout 0] 0]
    set keepout_by [lindex [lindex $keepout 0] 1]
    set keepout_rx [lindex [lindex $keepout 1] 0]
    set keepout_uy [lindex [lindex $keepout 1] 1]
    set route_guide_llx [expr $macro_bbox_llx - $keepout_lx]
    set route_guide_lly [expr $macro_bbox_lly - $keepout_by]
    set route_guide_urx [expr $macro_bbox_urx + $keepout_rx]
    set route_guide_ury [expr $macro_bbox_ury + $keepout_uy]
    create_route_guide -coordinate "$route_guide_llx $route_guide_lly $route_guide_urx $route_guide_ury" -no_preroute_layers [get_object_name [get_layers -filter "is_routing_layer&&layer_type!=via"]]
  }
  set va_preroute_area_llx [expr [get_attribute $va bbox_llx] + [get_attribute $va guardband_x]]
  set va_preroute_area_lly [expr [get_attribute $va bbox_lly] + [get_attribute $va guardband_y] - 0.5 * $tile_height]
  set va_preroute_area_urx [expr [get_attribute $va bbox_urx] - [get_attribute $va guardband_x]]
  set va_preroute_area_ury [expr [get_attribute $va bbox_ury] - [get_attribute $va guardband_y] + 0.5 * $tile_height]
  #preroute_standard_cells -mode rail -connect both -nets "VDD VSS" -within_voltage_area $va -no_routing_outside_working_area -skip_macro_pins -skip_pad_pins -remove_floating_pieces -do_not_route_over_macros -fill_empty_rows
  preroute_standard_cells -mode rail -connect both -nets "VDD VSS" -within [list [list $va_preroute_area_llx $va_preroute_area_lly] [list $va_preroute_area_urx $va_preroute_area_ury]] -no_routing_outside_working_area -skip_macro_pins -skip_pad_pins -remove_floating_pieces -do_not_route_over_macros -fill_empty_rows
  remove_route_guide -all
}

foreach_in_collection va [remove_from_collection [get_voltage_areas *] [get_voltage_areas "DEFAULT_VA"]] {
  set va_bbox [get_attribute $va bbox]
  set va_bbox_llx [lindex [lindex $va_bbox 0] 0]
  set va_bbox_lly [lindex [lindex $va_bbox 0] 1]
  set va_bbox_urx [lindex [lindex $va_bbox 1] 0]
  set va_bbox_ury [lindex [lindex $va_bbox 1] 1]
  set va_guardband_x [get_attribute $va guardband_x]
  set va_guardband_y [get_attribute $va guardband_y]
  if { [get_attribute $va name] == "PD_PLL" } {
    set route_guide_llx [expr $va_bbox_llx - $va_guardband_x]
    set route_guide_lly [expr $va_bbox_lly - $va_guardband_y]
    set route_guide_urx [expr $va_bbox_urx + $va_guardband_x]
    set route_guide_ury [expr $va_bbox_ury + $va_guardband_y]
  } else {
    set route_guide_llx [expr $va_bbox_llx - $va_guardband_x]
    set route_guide_lly [expr $va_bbox_lly - $va_guardband_y + 0.5 * $tile_height]
    set route_guide_urx [expr $va_bbox_urx + $va_guardband_x]
    set route_guide_ury [expr $va_bbox_ury + $va_guardband_y - 0.5 * $tile_height]
  }
  create_route_guide -coordinate "$route_guide_llx $route_guide_lly $route_guide_urx $route_guide_ury" -no_preroute_layers [get_object_name [get_layers -filter "is_routing_layer&&layer_type!=via"]]
}

preroute_standard_cells -mode rail -connect both -nets "VDD VSS" -within_voltage_area [get_voltage_areas DEFAULT_VA] -no_routing_outside_working_area -skip_macro_pins -skip_pad_pins -remove_floating_pieces -do_not_route_over_macros -fill_empty_rows
remove_route_guide -all

puts "Flow-Info: Completed script [info script]\n"
