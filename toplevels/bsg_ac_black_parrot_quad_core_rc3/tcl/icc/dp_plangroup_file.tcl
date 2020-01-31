puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

# define plan groups for bp tiles
foreach_in_collection tile [get_cells $::env(BP_HIER_CELLS)] {
  set bp_tile_name [get_attribute $tile full_name]
  set va [get_voltage_area $bp_tile_name/PD]
  #set bp_tile_pg_llx [expr [get_attribute $va bbox_llx] - $tile_height]
  #set bp_tile_pg_lly [expr [get_attribute $va bbox_lly] - $tile_height]
  #set bp_tile_pg_urx [expr [get_attribute $va bbox_urx] + $tile_height]
  #set bp_tile_pg_ury [expr [get_attribute $va bbox_ury] + $tile_height]
  #create_plan_groups $tile -cycle_color -coordinate "$bp_tile_pg_llx $bp_tile_pg_lly $bp_tile_pg_urx $bp_tile_pg_ury"
  create_plan_groups $tile -cycle_color -coordinate [get_attribute $va bbox] -is_fixed
}

# define plan groups for cache
#foreach_in_collection cache [get_cells $::env(VC_HIER_CELLS)] {
#  set cache_name [get_attribute $cache full_name]
#  create_plan_groups $cache -cycle_color -coordinate [get_attribute [get_voltage_area $cache_name/PD] bbox]
#}

set idx 0
foreach_in_collection plan_group [get_plan_groups] {
  foreach_in_collection pin [get_pins -of_objects [get_attribute $plan_group logic_cell] -filter "name!~*_clk_i&&net_name!~SYNOPSYS_UNCONNECTED_*"] {
    set net [get_nets -all -of_objects $pin]
    #puts "net name is [get_attribute $net name]"
    if { [sizeof_collection $net] > 0 } {
      disconnect_net $net $pin
      create_cell guard_buffer_$idx [get_lib_cells tcbn45gsbwpwc/BUFFD1BWP]
      #connect_net $net guard_buffer_$idx/I
      #connect_pin -from guard_buffer_$idx/Z -to $pin
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
