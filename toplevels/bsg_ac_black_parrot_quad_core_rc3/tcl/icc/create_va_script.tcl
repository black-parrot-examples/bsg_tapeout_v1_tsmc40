puts "RM-Info: Running script [info script]\n"

remove_voltage_area -all

set tile_height [get_attribute [get_core_area] tile_height]
set tile_width  [get_attribute [get_core_area] tile_width]

set pll_guard [expr 22 * $tile_height]
set pll_height [expr 46 * $tile_height]

set core_bbox [get_attribute [get_core_area] bbox]
set core_llx [lindex [lindex $core_bbox 0] 0]
set core_lly [lindex [lindex $core_bbox 0] 1]
set core_urx [lindex [lindex $core_bbox 1] 0]
set core_ury [lindex [lindex $core_bbox 1] 1]

set breaker_cell [get_fp_cells breaker_t_0]
set breaker_bbox [get_attribute $breaker_cell bbox]
set pll_llx [expr $core_llx + int([expr ([lindex [lindex $breaker_bbox 0] 0] - $core_llx) / $tile_height]) * $tile_height + $pll_guard]
set pll_lly [expr $core_ury - $pll_guard - $pll_height]
set breaker_cell [get_fp_cells breaker_t_1]
set breaker_bbox [get_attribute $breaker_cell bbox]
set pll_urx [expr $core_llx + int([expr ([lindex [lindex $breaker_bbox 1] 0] - $core_llx) / $tile_height]) * $tile_height - $pll_guard]
set pll_ury [expr $core_ury - $pll_guard]

create_voltage_area clk_gen_pd -name PLL -guard_band_x $pll_guard -guard_band_y $pll_guard -is_fixed -coordinate "$pll_llx $pll_lly $pll_urx $pll_ury"

# the shape of hierarchical blocks
# Core area: 2835 x 2835 
# top-left corner of core area as origin
set bp_tile_x_offset 150
set bp_tile_y_offset 200

set bp_tile_width   950
set bp_tile_height  850
set bp_tile_x_space 50
set bp_tile_y_space 50

# define voltage areas for bp_tile_node instances
foreach_in_collection cell [get_cells $::env(BP_TILES)] {
  set coordinate [regexp -all -inline -- {[0-9]+} [get_attribute $cell name]]
  set x [lindex $coordinate 1]
  set y [lindex $coordinate 0]
  set bp_tile_llx [expr $core_llx + ($bp_tile_x_offset + $x * ($bp_tile_width  + $bp_tile_x_space)) * $tile_height]
  set bp_tile_lly [expr $core_ury - ($bp_tile_y_offset + ($y + 1) * ($bp_tile_height + $bp_tile_y_space)) * $tile_height]
  set bp_tile_urx [expr $bp_tile_llx + $bp_tile_width * $tile_height]
  set bp_tile_ury [expr $bp_tile_lly + $bp_tile_height * $tile_height]
  set cell_name [get_attribute $cell full_name]
  create_voltage_area $cell -name $cell_name -guard_band_x $tile_height -guard_band_y $tile_height -is_fixed -coordinate "$bp_tile_llx $bp_tile_lly $bp_tile_urx $bp_tile_ury"
}

# top-left corner of core area as origin
set bp_io_tile_x_offset 400
set bp_io_tile_y_offset 50

set bp_io_tile_width   450
set bp_io_tile_height  150
set bp_io_tile_x_space 550
set bp_io_tile_y_space 50

# define voltage areas for bp_io_tile_node instances
foreach_in_collection cell [get_cells $::env(BP_IO_TILES)] {
  set index [regexp -all -inline -- {[0-9]+} [get_attribute $cell name]]
  set bp_io_tile_llx [expr $core_llx + ($bp_io_tile_x_offset + $index * ($bp_io_tile_width  + $bp_io_tile_x_space)) * $tile_height]
  set bp_io_tile_lly [expr $core_ury - ($bp_io_tile_y_offset + $bp_io_tile_height) * $tile_height]
  set bp_io_tile_urx [expr $bp_io_tile_llx + $bp_io_tile_width * $tile_height]
  set bp_io_tile_ury [expr $bp_io_tile_lly + $bp_io_tile_height * $tile_height]
  set cell_name [get_attribute $cell full_name]
  create_voltage_area $cell -name $cell_name -guard_band_x $tile_height -guard_band_y $tile_height -is_fixed -coordinate "$bp_io_tile_llx $bp_io_tile_lly $bp_io_tile_urx $bp_io_tile_ury"
}

# top-left corner of core area as origin
set ct_x_offset 50
set ct_y_offset 50

set ct_width   150
set ct_height  120
set ct_x_space 1850
set ct_y_space 50

# define voltage areas for bsg_channel_tunnel instances
foreach_in_collection cell [get_cells $::env(CHANNEL_TUNNELS)] {
  if { [regexp prev [get_attribute $cell name]] } {
    set index 0
  } elseif { [regexp next [get_attribute $cell name]] } {
    set index 1
  }
  set ct_llx [expr $core_llx + ($ct_x_offset + $index * ($ct_width  + $ct_x_space)) * $tile_height]
  set ct_lly [expr $core_ury - ($ct_y_offset + $ct_height) * $tile_height]
  set ct_urx [expr $ct_llx + $ct_width * $tile_height]
  set ct_ury [expr $ct_lly + $ct_height * $tile_height]
  set cell_name [get_attribute $cell full_name]
  create_voltage_area $cell -name $cell_name -guard_band_x $tile_height -guard_band_y $tile_height -is_fixed -coordinate "$ct_llx $ct_lly $ct_urx $ct_ury"
}

#
set dmc_pg_width  250
set dmc_pg_height 150

set dmc_x_offset 1000
set dmc_y_offset 50

set llx [expr $core_llx + $dmc_x_offset * $tile_height]
set lly [expr $core_lly + $dmc_y_offset * $tile_height]
set urx [expr $llx + $dmc_pg_width * $tile_height]
set ury [expr $lly + $dmc_pg_height * $tile_height]
create_voltage_area [get_cells dmc_controller] -name dmc_controller -guard_band_x $tile_height -guard_band_y $tile_height -is_fixed -coordinate "$llx $lly $urx $ury"

puts "RM-Info: Completed script [info script]\n"
