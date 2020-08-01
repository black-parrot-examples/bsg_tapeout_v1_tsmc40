puts "Flow-Info: Running script [info script]\n"

#if { [file exists [which legal.rpt]] } {
#  file delete legal.rpt
#}
#redirect legal.rpt {echo "[check_legality -verbose]"}
#set fid_r [open legal.rpt r]
#set instance_name ""
#while {[gets $fid_r line] >= 0} {
#    if { [ regexp "Cell .* overlaps with a blockage" $line ] } {
#        lappend instance_names [lindex [split $line] 4]
#    }
#}
#close $fid_r
#remove_cell [get_cells -all $instance_names -filter "ref_name==$ICC_H_CAP_CEL"]

set tile_height [get_attribute [get_core_area] tile_height]
set_preroute_drc_strategy -max_layer M9

set va [get_voltage_areas PLL]
set va_preroute_area_llx [get_attribute $va bbox_llx]
set va_preroute_area_lly [expr [get_attribute $va bbox_lly] - 0.5 * $tile_height]
set va_preroute_area_urx [get_attribute $va bbox_urx]
set va_preroute_area_ury [expr [get_attribute $va bbox_ury] + 0.5 * $tile_height]
set va_route_guide_llx [expr [get_attribute $va bbox_llx] - [get_attribute $va guardband_x]]
set va_route_guide_lly [expr [get_attribute $va bbox_lly] - [get_attribute $va guardband_y] + 0.5 * $tile_height]
set va_route_guide_urx [expr [get_attribute $va bbox_urx] + [get_attribute $va guardband_x]]
set va_route_guide_ury [expr [get_attribute $va bbox_ury] + [get_attribute $va guardband_y]]

preroute_standard_cells -mode rail -connect both -nets "VDD VSS" -within [list [list $va_preroute_area_llx $va_preroute_area_lly] [list $va_preroute_area_urx $va_preroute_area_ury]] -no_routing_outside_working_area -fill_empty_rows
create_route_guide -coordinate "$va_route_guide_llx $va_route_guide_lly $va_route_guide_urx $va_route_guide_ury" -no_preroute_layers [get_object_name [get_layers -filter "is_routing_layer&&layer_type!=via"]]

foreach_in_collection va [remove_from_collection [get_voltage_areas *] [get_voltage_areas "PLL DEFAULT_VA"]] {
  set va_preroute_area_llx [expr [get_attribute $va bbox_llx] + [get_attribute $va guardband_x]]
  set va_preroute_area_lly [expr [get_attribute $va bbox_lly] + [get_attribute $va guardband_y] - 0.5 * $tile_height]
  set va_preroute_area_urx [expr [get_attribute $va bbox_urx] - [get_attribute $va guardband_x]]
  set va_preroute_area_ury [expr [get_attribute $va bbox_ury] - [get_attribute $va guardband_y] + 0.5 * $tile_height]
  set va_route_guide_llx [expr [get_attribute $va bbox_llx] - [get_attribute $va guardband_x]]
  set va_route_guide_lly [expr [get_attribute $va bbox_lly] - [get_attribute $va guardband_y] + 0.5 * $tile_height]
  set va_route_guide_urx [expr [get_attribute $va bbox_urx] + [get_attribute $va guardband_x]]
  set va_route_guide_ury [expr [get_attribute $va bbox_ury] + [get_attribute $va guardband_y] - 0.5 * $tile_height]
  preroute_standard_cells -mode rail -connect both -nets "VDD VSS" -within [list [list $va_preroute_area_llx $va_preroute_area_lly] [list $va_preroute_area_urx $va_preroute_area_ury]] -no_routing_outside_working_area -do_not_route_over_macros -fill_empty_rows
  create_route_guide -coordinate "$va_route_guide_llx $va_route_guide_lly $va_route_guide_urx $va_route_guide_ury" -no_preroute_layers [get_object_name [get_layers -filter "is_routing_layer&&layer_type!=via"]]
}

preroute_standard_cells -mode rail -connect both -nets "VDD VSS" -within_voltage_area [get_voltage_areas DEFAULT_VA] -no_routing_outside_working_area -fill_empty_rows

remove_route_guide -all

puts "Flow-Info: Completed script [info script]\n"
