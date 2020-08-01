puts "Flow-Info: Running script [info script]\n"

# define plan groups for hierarchical cells
foreach_in_collection cell [get_cells $::env(HIERARCHICAL_CELLS)] {
  set cell_name [get_attribute $cell full_name]
  set va [get_voltage_area $cell_name]
  create_plan_groups $cell -cycle_color -polygon [get_attribute $va points] -is_fixed
}

flip_mim -direction X [get_plan_groups next_tunnel]

set padding [get_attribute [get_core_area] tile_height]
create_fp_plan_group_padding -internal_widths [list $padding $padding $padding $padding] -external_widths [list $padding $padding $padding $padding] [get_plan_groups]

#add_end_cap -respect_blockage -respect_keepout -lib_cell $ICC_H_CAP_CEL -at_plan_group_boundary

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
