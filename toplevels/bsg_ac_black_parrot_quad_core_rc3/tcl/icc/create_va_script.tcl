puts "RM-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]
set tile_width  [get_attribute [get_core_area] tile_width]

set pll_va_guard [expr 22 * $tile_height]
set pll_va_height [expr 46 * $tile_height]

set core_bbox [get_attribute [get_core_area] bbox]
set core_llx [lindex [lindex $core_bbox 0] 0]
set core_lly [lindex [lindex $core_bbox 0] 1]
set core_urx [lindex [lindex $core_bbox 1] 0]
set core_ury [lindex [lindex $core_bbox 1] 1]

set breaker_cell [get_fp_cells breaker_t_0]
set breaker_bbox [get_attribute $breaker_cell bbox]
set pll_va_llx [expr $core_llx + int([expr ([lindex [lindex $breaker_bbox 0] 0] - $core_llx) / $tile_height]) * $tile_height + $pll_va_guard]
set pll_va_lly [expr $core_ury - $pll_va_guard - $pll_va_height]
set breaker_cell [get_fp_cells breaker_t_1]
set breaker_bbox [get_attribute $breaker_cell bbox]
set pll_va_urx [expr $core_llx + int([expr ([lindex [lindex $breaker_bbox 1] 0] - $core_llx) / $tile_height]) * $tile_height - $pll_va_guard]
set pll_va_ury [expr $core_ury - $pll_va_guard]

create_voltage_area -power_domain PD_PLL -guard_band_x $pll_va_guard -guard_band_y $pll_va_guard -is_fixed -coordinate "$pll_va_llx $pll_va_lly $pll_va_urx $pll_va_ury"

# distance from core origin to manycore origin
set bp_array_x_offset 80
set bp_array_y_offset [expr ($pll_va_height + 2 * $pll_va_guard) / $tile_height]

# the shape of bp tile
#  Die area: 2835 x 2835 
set bp_tile_pg_width  1000
set bp_tile_pg_height 850
set bp_tile_pg_space  90

# define plan groups for bp_tile_node array
foreach_in_collection tile [get_cells $::env(BP_HIER_CELLS)] {
  set coordinate [regexp -all -inline -- {[0-9]+} [get_attribute $tile name]]
  set x [lindex $coordinate 1]
  set y [expr 1 + [lindex $coordinate 0]]
  set bp_tile_pg_llx [expr $core_llx + ($bp_array_x_offset + $x * ($bp_tile_pg_width  + $bp_tile_pg_space)) * $tile_height]
  set bp_tile_pg_lly [expr $core_ury - ($bp_array_y_offset + $y * ($bp_tile_pg_height + $bp_tile_pg_space)) * $tile_height]
  set bp_tile_pg_urx [expr $bp_tile_pg_llx + $bp_tile_pg_width * $tile_height]
  set bp_tile_pg_ury [expr $bp_tile_pg_lly + $bp_tile_pg_height * $tile_height]
  set tile_name [get_attribute $tile full_name]
  create_voltage_area -power_domain $tile_name/PD -guard_band_x $tile_height -guard_band_y $tile_height -is_fixed -coordinate "$bp_tile_pg_llx $bp_tile_pg_lly $bp_tile_pg_urx $bp_tile_pg_ury"
}

puts "RM-Info: Completed script [info script]\n"
