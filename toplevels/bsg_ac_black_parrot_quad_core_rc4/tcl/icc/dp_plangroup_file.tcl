puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

set core_bbox [get_attribute [get_core_area] bbox]
set core_llx  [lindex [lindex $core_bbox 0] 0]
set core_lly  [lindex [lindex $core_bbox 0] 1]
set core_urx  [lindex [lindex $core_bbox 1] 0]
set core_ury  [lindex [lindex $core_bbox 1] 1]

# define plan groups for bp tiles
foreach_in_collection tile [get_cells $::env(BP_HIER_CELLS)] {
  set bp_tile_name [get_attribute $tile full_name]
  set va [get_voltage_area $bp_tile_name/PD]
  create_plan_groups $tile -cycle_color -coordinate [get_attribute $va bbox] -is_fixed
}

set idx 0
foreach_in_collection plan_group [get_plan_groups] {
  foreach_in_collection pin [get_pins -of_objects [get_attribute $plan_group logic_cell] -filter "name!~*_clk_i&&net_name!~SYNOPSYS_UNCONNECTED_*"] {
    set net [get_nets -all -of_objects $pin]
    if { [sizeof_collection $net] > 0 } {
      disconnect_net $net $pin
      create_cell guard_buffer_$idx [get_lib_cells tcbn45gsbwpwc/BUFFD1BWP]
      set pin_direction [get_attribute $pin pin_direction]
      if { $pin_direction == "in" } {
        connect_net $net guard_buffer_$idx/I
        connect_pin -from guard_buffer_$idx/Z -to $pin
      } else {
        connect_net $net guard_buffer_$idx/Z
        connect_pin -from $pin -to guard_buffer_$idx/I
      }
      set_dont_touch [get_cells guard_buffer_$idx]
      incr idx
    }
  }
}

puts "Flow-Info: Completed script [info script]\n"
