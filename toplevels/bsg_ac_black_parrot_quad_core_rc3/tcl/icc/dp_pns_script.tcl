puts "RM-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

# Remove all existing power regions and strategies.
remove_power_plan_strategy -all
remove_power_plan_regions  -all

# Power net names for core and pll regions
set core_power_nets      "VDD VSS"
set core_power_flip_nets "VSS VDD"
set pll_power_nets       "VDD_PLL VSS"

# Expansion beyond power planning regions
set core_expand_x 0.0
set core_expand_y 0.0
set pll_expand_x [get_attribute [get_voltage_area PD_PLL] guardband_x]
set pll_expand_y [get_attribute [get_voltage_area PD_PLL] guardband_y]

set m10_min_width   [get_attribute [get_layers M10] minWidth]
set m10_min_spacing [get_attribute [get_layers M10] minSpacing]
set m10_pitch       [get_attribute [get_layers M10] pitch]
set m9_min_width    [get_attribute [get_layers M9]  minWidth]
set m9_min_spacing  [get_attribute [get_layers M9]  minSpacing]
set m9_pitch        [get_attribute [get_layers M9]  pitch]

set m5_pitch        [get_attribute [get_layers M5]  pitch]

################################################################################
#
# POWER PLANNING REGIONS
#

foreach_in_collection va [get_voltage_areas] {
  set va_name [get_attribute $va name]
  if { $va_name == "DEFAULT_VA" } {
    create_power_plan_regions core_ppr -core -expand [list $core_expand_x $core_expand_y]
  } elseif { $va_name == "PD_PLL" } {
    create_power_plan_regions pll_ppr           -voltage_area $va 
    create_power_plan_regions pll_with_ring_ppr -voltage_area $va -expand [list $pll_expand_x $pll_expand_y]
  } elseif { [regexp "tile" $va_name] } {
    set index [regexp -all -inline -- {[0-9]+} [get_attribute $va name]]
    create_power_plan_regions tile_ppr_${index} -voltage_area $va
    #set coordinate [regexp -all -inline -- {[0-9]+} [get_attribute $va name]]
    #set x [lindex $coordinate 1]
    #set y [lindex $coordinate 0]
    #create_power_plan_regions tile_ppr_${x}_${y} -voltage_area $va
  } elseif { [regexp "vc" $va_name] } {
    set index [regexp -all -inline -- {[0-9]+} [get_attribute $va name]]
    create_power_plan_regions vcache_ppr_${index} -voltage_area $va
  } else {
    puts "No power plan regions created for voltage area $va_name"
  }
}

set index 0
foreach_in_collection pg [get_plan_groups] {
  set mim_master_name [get_attribute $pg mim_master_name]
  if { $mim_master_name == "bp_tile_node" } {
    foreach_in_collection macro [get_cells -of_objects $pg -filter "is_hard_macro"] {
      create_power_plan_regions macro_ppr_$index -group_of_macros $macro
      incr index
    }
  } elseif { $mim_master_name == "vcache" } {
    create_power_plan_regions macro_ppr_$index -group_of_macros [get_cells -of_objects $pg -filter "is_hard_macro&&(full_name=~*tag_mem*||full_name=~*stat_mem*)"]
    incr index
    create_power_plan_regions macro_ppr_$index -group_of_macros [get_cells -of_objects $pg -filter "is_hard_macro&&full_name=~*data_mem*"]
    incr index
  }
}

set array_ppr_llx [expr [lindex [lsort -real [get_attribute [get_plan_groups] bbox_llx]] 0] - $tile_height]
set array_ppr_lly [expr [lindex [lsort -real [get_attribute [get_plan_groups] bbox_lly]] 0] - $tile_height]
set array_ppr_urx [expr [lindex [lsort -real -decreasing [get_attribute [get_plan_groups] bbox_urx]] 0] + $tile_height]
set array_ppr_ury [expr [lindex [lsort -real -decreasing [get_attribute [get_plan_groups] bbox_ury]] 0] + $tile_height]
create_power_plan_regions array_ppr -polygon [list $array_ppr_llx $array_ppr_lly $array_ppr_urx $array_ppr_lly $array_ppr_urx $array_ppr_ury $array_ppr_llx $array_ppr_ury]


################################################################################
#
# PLL POWER RING
#

set m10_max_width 12.0
set m9_max_width  12.0

set pll_power_ring_h_width   $m10_max_width
set pll_power_ring_h_offset  [expr $m10_pitch * 0.25]
set pll_power_ring_h_spacing [expr $m10_pitch * 0.5]
set pll_power_ring_v_width   $m9_max_width
set pll_power_ring_v_offset  [expr $m9_pitch * 0.75]
set pll_power_ring_v_spacing [expr $m9_pitch * 2.0]

set_power_ring_strategy pll_prs_h10v9  \
  -nets $pll_power_nets \
  -power_plan_regions pll_ppr \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:core_h10v9_prt($pll_power_ring_h_width,$pll_power_ring_h_offset,$pll_power_ring_h_spacing,$pll_power_ring_v_width,$pll_power_ring_v_offset,$pll_power_ring_v_spacing)

compile_power_plan -ring -strategy pll_prs_h10v9


################################################################################
#
# CONNECT PG IO PADS TO PLL RINGS
#
 
preroute_instances -ignore_macros \
                   -ignore_cover_cells \
                   -primary_routing_layer pin \
                   -connect_instances specified \
                   -cells [get_fp_cells "vdd_t_pll vss_t_pll"]


###############################################################################
#
# POWER STRAPS FOR PLL
#

set pll_power_h_strap_width   [expr $m10_pitch * 1.0]
set pll_power_h_strap_spacing [expr $m10_pitch * 1.0]
set pll_power_h_strap_pitch   [expr $m10_pitch * 4.0]
set pll_power_h_strap_offset  [expr $m10_pitch * 1.0]

set_power_plan_strategy pll_m10_pps \
  -nets $pll_power_nets \
  -power_plan_regions [get_power_plan_regions "pll_ppr"] \
  -extension { {{nets:$pll_power_nets}{stop:innermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m10_strap_ppt($pll_power_h_strap_width,$pll_power_h_strap_spacing,$pll_power_h_strap_pitch,$pll_power_h_strap_offset)

compile_power_plan -strategy pll_m10_pps

set pll_power_v_strap_width   [expr $m9_pitch * 4.0]
set pll_power_v_strap_spacing [expr $m9_pitch * 4.0]
set pll_power_v_strap_pitch   [expr $m9_pitch * 16.0]
set pll_power_v_strap_offset  [expr $m9_pitch * 4.0]

set_power_plan_strategy pll_m9_pps \
  -nets $pll_power_nets \
  -power_plan_regions [get_power_plan_regions "pll_ppr"] \
  -extension { {{nets:$pll_power_nets}{stop:innermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m9_strap_ppt($pll_power_v_strap_width,$pll_power_v_strap_spacing,$pll_power_v_strap_pitch,$pll_power_v_strap_offset)

compile_power_plan -strategy pll_m9_pps


################################################################################
#
# CORE POWER RING
#

set core_power_ring_h_width   [expr $m10_pitch * 2.0]
set core_power_ring_h_offset  [expr $m10_pitch * 0.25]
set core_power_ring_h_spacing [expr $m10_pitch * 0.5]
set core_power_ring_v_width   [expr $m9_pitch * 7.5]
set core_power_ring_v_offset  [expr $m9_pitch * 0.75]
set core_power_ring_v_spacing [expr $m9_pitch * 2.0]

set_power_ring_strategy core_prs_h10v9 \
  -nets "$core_power_nets $core_power_nets" \
  -power_plan_regions core_ppr \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:core_h10v9_prt($core_power_ring_h_width,$core_power_ring_h_offset,$core_power_ring_h_spacing,$core_power_ring_v_width,$core_power_ring_v_offset,$core_power_ring_v_spacing)

compile_power_plan -ring -strategy core_prs_h10v9


################################################################################
#
# CONNECT PG IO PADS TO CORE RINGS
#

set all_pg_cells [get_fp_cells vdd_*]
append_to_collection all_pg_cells [get_fp_cells vss_*]
set pll_pg_cells [get_fp_cells vdd_*_pll]
append_to_collection pll_pg_cells [get_fp_cells vss_*_pll]

preroute_instances -ignore_macros \
                   -ignore_cover_cells \
                   -primary_routing_layer pin \
                   -connect_instances specified \
                   -cells [remove_from_collection $all_pg_cells $pll_pg_cells]


################################################################################
#
# POWER RING FOR MANYCORE ARRAY
#

set array_power_ring_h_width   [expr $m10_pitch * 2.0]
set array_power_ring_h_offset  [expr $m10_pitch * 0.0]
set array_power_ring_h_spacing [expr $m10_pitch * 0.5]
set array_power_ring_v_width   [expr $m9_pitch * 8.0]
set array_power_ring_v_offset  [expr $m9_pitch * 0.0]
set array_power_ring_v_spacing [expr $m9_pitch * 2.0]

set_power_ring_strategy array_prs_h10v9 \
  -nets "$core_power_nets $core_power_nets" \
  -power_plan_regions [get_power_plan_regions array_ppr] \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:core_h10v9_prt($array_power_ring_h_width,$array_power_ring_h_offset,$array_power_ring_h_spacing,$array_power_ring_v_width,$array_power_ring_v_offset,$array_power_ring_v_spacing)

compile_power_plan -ring -strategy array_prs_h10v9


################################################################################
#
# POWER STRAPS FOR MANYCORE ARRAY
#

set array_power_h_strap_width   [expr $m10_pitch * 1.0]
set array_power_h_strap_spacing [expr $m10_pitch * 0.5]
set array_power_h_strap_pitch   [expr $tile_height * 500]
set array_power_h_strap_offset  [expr $tile_height * 452]
set array_power_v_strap_width   [expr $m9_pitch * 8.0]
set array_power_v_strap_spacing [expr $m9_pitch * 2.0]
set array_power_v_strap_pitch   [expr $tile_height * 1000]
set array_power_v_strap_offset  [expr $tile_height * 952]

set_power_plan_strategy array_m10_pps \
  -nets "$core_power_nets $core_power_flip_nets"\
  -power_plan_regions [get_power_plan_regions array_ppr] \
  -extension { {{nets:$core_power_nets}{stop:outermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m10_strap_ppt($array_power_h_strap_width,$array_power_h_strap_spacing,$array_power_h_strap_pitch,$array_power_h_strap_offset)

compile_power_plan -strategy array_m10_pps

set_power_plan_strategy array_m9_pps \
  -nets "$core_power_nets $core_power_flip_nets"\
  -power_plan_regions [get_power_plan_regions array_ppr] \
  -extension { {{nets:$core_power_nets}{stop:innermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m9_strap_ppt($array_power_v_strap_width,$array_power_v_strap_spacing,$array_power_v_strap_pitch,$array_power_v_strap_offset)

compile_power_plan -strategy array_m9_pps



################################################################################
#
# POWER STRAPS FOR MACRO IN PLAN GROUPS
#

set macro_power_v_strap_width   [expr $m5_pitch * 8.0]
set macro_power_v_strap_spacing [expr $m5_pitch * 8.0]
set macro_power_v_strap_pitch   [expr $m5_pitch * 32.0]
set macro_power_v_strap_offset  [expr $m5_pitch * 8.0]

set blockage_ppr_groups [get_power_plan_regions macro_ppr_*]
set blockage_ppr_names [get_attribute $blockage_ppr_groups name]
set blockage_value "{power_plan_region:{$blockage_ppr_names}}"

set_power_plan_strategy macro_m5_pps \
  -nets $core_power_nets \
  -power_plan_regions [get_power_plan_regions macro_ppr_*] \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m5_strap_ppt($macro_power_v_strap_width,$macro_power_v_strap_spacing,$macro_power_v_strap_pitch,$macro_power_v_strap_offset)

compile_power_plan -strategy macro_m5_pps


################################################################################
#
# POWER STRAPS FOR SUB-BLOCKS
#

set block_power_h_strap_width   [expr $m10_pitch * 1.0]
set block_power_h_strap_spacing [expr $m10_pitch * 1.0]
set block_power_h_strap_pitch   [expr $m10_pitch * 4.0]
set block_power_h_strap_offset  [expr $m10_pitch * 1.0]

set blockage_ppr_groups [get_power_plan_regions macro_ppr_*]
set blockage_ppr_names [get_attribute $blockage_ppr_groups name]
set blockage_value "{power_plan_region:{$blockage_ppr_names}}"

set_power_plan_strategy block_m10_pps \
  -nets $core_power_nets \
  -power_plan_regions [get_power_plan_regions "tile_ppr_* vcache_ppr_*"] \
  -extension { {{nets:$core_power_nets}{stop:first_target}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m10_strap_ppt($block_power_h_strap_width,$block_power_h_strap_spacing,$block_power_h_strap_pitch,$block_power_h_strap_offset)

compile_power_plan -strategy block_m10_pps

set block_power_v_strap_width   [expr $m9_pitch * 4.0]
set block_power_v_strap_spacing [expr $m9_pitch * 4.0]
set block_power_v_strap_pitch   [expr $m9_pitch * 16.0]
set block_power_v_strap_offset  [expr $m9_pitch * 4.0]

set_power_plan_strategy block_m9_pps \
  -nets $core_power_nets \
  -power_plan_regions [get_power_plan_regions "tile_ppr_* vcache_ppr_*"] \
  -blockage $blockage_value \
  -extension { {{nets:$core_power_nets}{stop:first_target}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m9_strap_ppt($block_power_v_strap_width,$block_power_v_strap_spacing,$block_power_v_strap_pitch,$block_power_v_strap_offset)

compile_power_plan -strategy block_m9_pps


###############################################################################
#
# POWER STRAPS FOR CORE
#

set array_with_inner_ring_ppr_llx [expr $array_ppr_llx - $array_power_ring_v_offset - 2.0 * ($array_power_ring_v_width + $array_power_ring_v_spacing)]
set array_with_inner_ring_ppr_lly [expr $array_ppr_lly - $array_power_ring_h_offset - 2.0 * ($array_power_ring_h_width + $array_power_ring_h_spacing)]
set array_with_inner_ring_ppr_urx [expr $array_ppr_urx + $array_power_ring_v_offset + 2.0 * ($array_power_ring_v_width + $array_power_ring_v_spacing)]
set array_with_inner_ring_ppr_ury [expr $array_ppr_ury + $array_power_ring_h_offset + 2.0 * ($array_power_ring_h_width + $array_power_ring_h_spacing)]
create_power_plan_regions array_with_inner_ring_ppr -polygon [list $array_with_inner_ring_ppr_llx $array_with_inner_ring_ppr_lly $array_with_inner_ring_ppr_urx $array_with_inner_ring_ppr_lly $array_with_inner_ring_ppr_urx $array_with_inner_ring_ppr_ury $array_with_inner_ring_ppr_llx $array_with_inner_ring_ppr_ury]

set core_power_h_strap_width   [expr $m10_pitch * 1.0]
set core_power_h_strap_spacing [expr $m10_pitch * 1.0]
set core_power_h_strap_pitch   [expr $m10_pitch * 6.0]
set core_power_h_strap_offset  [expr $m10_pitch * 1.0]

set blockage_ppr_groups [get_power_plan_regions array_with_inner_ring_ppr]
append_to_collection blockage_ppr_groups [get_power_plan_regions pll_with_ring_ppr]
set blockage_ppr_names [get_attribute $blockage_ppr_groups name]
set blockage_value "{power_plan_region:{$blockage_ppr_names}}"

set_power_plan_strategy core_m10_pps \
  -nets $core_power_nets \
  -core \
  -blockage $blockage_value \
  -extension { {{nets:$core_power_nets}{stop:outermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m10_strap_ppt($core_power_h_strap_width,$core_power_h_strap_spacing,$core_power_h_strap_pitch,$core_power_h_strap_offset)

compile_power_plan -strategy core_m10_pps

set core_power_v_strap_width   [expr $m9_pitch * 4.0]
set core_power_v_strap_spacing [expr $m9_pitch * 4.0]
set core_power_v_strap_pitch   [expr $m9_pitch * 16.0]
set core_power_v_strap_offset  [expr $m9_pitch * 4.0]

set_power_plan_strategy core_m9_pps \
  -nets $core_power_nets \
  -core \
  -blockage $blockage_value \
  -extension { {{nets:$core_power_nets}{stop:innermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:m9_strap_ppt($core_power_v_strap_width,$core_power_v_strap_spacing,$core_power_v_strap_pitch,$core_power_v_strap_offset)

compile_power_plan -strategy core_m9_pps

check_fp_rail -nets $core_power_nets -ring
check_fp_rail -nets $core_power_nets

puts "RM-Info: Completed script [info script]\n"
