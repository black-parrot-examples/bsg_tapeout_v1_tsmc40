puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

set macro_keepout $tile_height
set_keepout_margin -all_macros -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout]

if { $ICC_IMPLEMENTATION_PHASE == "default" } {
  set_attribute [get_cells -all -filter "mask_layout_type==io_pad"] is_fixed true
  set_attribute [get_cells -all -filter "mask_layout_type==corner_pad"] is_fixed true
} elseif { $ICC_IMPLEMENTATION_PHASE == "top" } {
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

  create_plan_groups [get_cells clk_gen_pd] -cycle_color -coordinate [list $pll_llx $pll_lly $pll_urx $pll_ury] -is_fixed
  create_fp_plan_group_padding -internal_widths [list 0 0 0 0] -external_widths [list $pll_guard $pll_guard $pll_guard $pll_guard] [get_plan_groups clk_gen_pd]
}

puts "Flow-Info: Completed script [info script]\n"
