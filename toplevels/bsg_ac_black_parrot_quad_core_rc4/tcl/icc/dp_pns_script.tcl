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
set pll_expand_x [get_attribute [get_voltage_areas PD_PLL] guardband_x]
set pll_expand_y [get_attribute [get_voltage_areas PD_PLL] guardband_y]

set m10_min_width   [get_attribute [get_layers M10] minWidth]
set m10_min_spacing [get_attribute [get_layers M10] minSpacing]
set m10_pitch       [get_attribute [get_layers M10] pitch]
set m9_min_width    [get_attribute [get_layers M9]  minWidth]
set m9_min_spacing  [get_attribute [get_layers M9]  minSpacing]
set m9_pitch        [get_attribute [get_layers M9]  pitch]
set m8_min_width    [get_attribute [get_layers M8]  minWidth]
set m8_min_spacing  [get_attribute [get_layers M8]  minSpacing]
set m8_pitch        [get_attribute [get_layers M8]  pitch]
set m7_min_width    [get_attribute [get_layers M7]  minWidth]
set m7_min_spacing  [get_attribute [get_layers M7]  minSpacing]
set m7_pitch        [get_attribute [get_layers M7]  pitch]

set m6_pitch        [get_attribute [get_layers M6]  pitch]
set m5_pitch        [get_attribute [get_layers M5]  pitch]
set m1_pitch        [get_attribute [get_layers M1]  pitch]

################################################################################
#
# POWER PLANNING REGIONS
#

foreach_in_collection va [get_voltage_areas] {
  set va_name [get_attribute $va name]
  if { $va_name == "PD_PLL" } {
    create_power_plan_regions pll_ppr -voltage_area $va -expand [list $pll_expand_x $pll_expand_y]
  } elseif { [regexp "dly_line" $va_name] } {
    set index [regexp -all -inline -- {[0-9]+} [get_attribute $va name]]
    if { [regexp "clk_gen_pd" $va_name] } {
      create_power_plan_regions osc_ppr_${index} -voltage_area $va -expand [list [expr 3.0 * $m9_pitch] [expr 16.0 * $m8_pitch]]
    } elseif { [regexp "dram_ctrl" $va_name] } {
      create_power_plan_regions dl_ppr_${index} -voltage_area $va -expand [list [expr 3.0 * $m9_pitch] [expr 16.0 * $m8_pitch]]
    }
  } elseif { [regexp "tile" $va_name] } {
    set index [regexp -all -inline -- {[0-9]+} [get_attribute $va name]]
    #create_power_plan_regions tile_ppr_${index} -voltage_area $va -expand [list [expr 20.0 * $m9_pitch] [expr 5.0 * $m10_pitch]]
    create_power_plan_regions tile_ppr_${index} -voltage_area $va -expand [list [expr 20.0 * $m9_pitch] [expr 11.0 * $tile_height - $m1_pitch]]
  } else {
    puts "No power plan regions created for voltage area $va_name"
  }
}


################################################################################
#
# POWER RINGS FOR PLL AREA
#

set m10_max_width 12.0
set m9_max_width  12.0

set pll_power_ring_h_width   $m10_max_width
set pll_power_ring_h_spacing [expr $m10_pitch * 0.5]
set pll_power_ring_h_offset  [expr $m10_pitch * 0.25]
set pll_power_ring_v_width   $m9_max_width
set pll_power_ring_v_spacing [expr $m9_pitch * 2.0]
set pll_power_ring_v_offset  [expr $m9_pitch * 0.75]

set_power_ring_strategy pll_ring_h10v9  \
  -nets $pll_power_nets \
  -voltage_areas [get_voltage_areas PD_PLL] \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:bsg_power_ring(M10,$pll_power_ring_h_width,$pll_power_ring_h_spacing,$pll_power_ring_h_offset,M9,$pll_power_ring_v_width,$pll_power_ring_v_spacing,$pll_power_ring_v_offset)

compile_power_plan -ring -strategy pll_ring_h10v9


################################################################################
#
# CONNECT PG IO PADS TO PLL RINGS
#
 
preroute_instances -ignore_macros \
                   -ignore_cover_cells \
                   -primary_routing_layer pin \
                   -connect_instances specified \
                   -cells [get_fp_cells "vdd_t_pll vss_t_pll"]


################################################################################
#
# POWER RINGS CORE AREA
#

set core_power_ring_h_width   [expr $m10_pitch * 2.0]
set core_power_ring_h_spacing [expr $m10_pitch * 0.5]
set core_power_ring_h_offset  [expr $m10_pitch * 0.25]
set core_power_ring_v_width   [expr $m9_pitch * 7.5]
set core_power_ring_v_spacing [expr $m9_pitch * 2.0]
set core_power_ring_v_offset  [expr $m9_pitch * 0.75]

set_power_ring_strategy core_ring_h10v9 \
  -nets "$core_power_nets $core_power_nets" \
  -core \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:bsg_power_ring(M10,$core_power_ring_h_width,$core_power_ring_h_spacing,$core_power_ring_h_offset,M9,$core_power_ring_v_width,$core_power_ring_v_spacing,$core_power_ring_v_offset)

compile_power_plan -ring -strategy core_ring_h10v9


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
# POWER RINGS FOR DELAY LINES
#

#set block_power_ring_h_width   [expr $m8_pitch * 4.0]
#set block_power_ring_h_spacing [expr $m8_pitch * 4.0]
#set block_power_ring_h_offset  [expr $m8_pitch * 0.0]
#set block_power_ring_v_width   [expr $m9_pitch * 1.0]
#set block_power_ring_v_spacing [expr $m9_pitch * 0.5]
#set block_power_ring_v_offset  [expr $m9_pitch * 0.0]
#
#set_power_ring_strategy osc_ring_h8v9 \
#  -nets "$pll_power_nets $pll_power_nets" \
#  -voltage_area [get_voltage_areas clk_gen_pd*dly_line*] \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:bsg_power_ring(M8,$block_power_ring_h_width,$block_power_ring_h_spacing,$block_power_ring_h_offset,M9,$block_power_ring_v_width,$block_power_ring_v_spacing,$block_power_ring_v_offset)
#
#compile_power_plan -ring -strategy osc_ring_h8v9
#
#set_power_ring_strategy dl_ring_h8v9 \
#  -nets "$core_power_nets $core_power_nets" \
#  -voltage_area [get_voltage_areas dram_ctrl*dly_line*] \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:bsg_power_ring(M8,$block_power_ring_h_width,$block_power_ring_h_spacing,$block_power_ring_h_offset,M9,$block_power_ring_v_width,$block_power_ring_v_spacing,$block_power_ring_v_offset)
#
#compile_power_plan -ring -strategy dl_ring_h8v9


################################################################################
#
# POWER RINGS FOR SUB-BLOCKS
#

#set block_power_ring_h_width   [expr $m10_pitch * 2.0]
#set block_power_ring_h_spacing [expr $m10_pitch * 0.5]
#set block_power_ring_h_offset  [expr $m10_pitch * 0.0]
set block_power_ring_h_width   [expr $tile_height * 4.0]
set block_power_ring_h_spacing [expr $tile_height * 2.0]
set block_power_ring_h_offset  [expr $tile_height * 0.0]
set block_power_ring_v_width   [expr $m9_pitch * 8.0]
set block_power_ring_v_spacing [expr $m9_pitch * 2.0]
set block_power_ring_v_offset  [expr $m9_pitch * 0.0]

set_power_ring_strategy block_ring_h10v9 \
  -nets "$core_power_nets $core_power_nets" \
  -voltage_area [get_voltage_areas *tile*] \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_ring.tpl:bsg_power_ring(M10,$block_power_ring_h_width,$block_power_ring_h_spacing,$block_power_ring_h_offset,M9,$block_power_ring_v_width,$block_power_ring_v_spacing,$block_power_ring_v_offset)

compile_power_plan -ring -strategy block_ring_h10v9


################################################################################
#
# POWER STRAPS FOR OSCILLATORS and DELAY LINES
#

#set block_power_h_strap_width   [expr $m8_pitch * 4.0]
#set block_power_h_strap_spacing [expr $m8_pitch * 4.0]
#set block_power_h_strap_pitch   [expr $m8_pitch * 16.0]
#set block_power_h_strap_offset  [expr $m8_pitch * 4.0]
#set block_power_v_strap_width   [expr $m7_pitch * 4.0]
#set block_power_v_strap_spacing [expr $m7_pitch * 4.0]
#set block_power_v_strap_pitch   [expr $m7_pitch * 16.0]
#set block_power_v_strap_offset  [expr $m7_pitch * 4.0]
#
#set_power_plan_strategy osc_mesh_h8v7 \
#  -nets "$pll_power_nets" \
#  -voltage_area [get_voltage_areas clk_gen_pd*dly_line*] \
#  -extension { {{nets:$pll_power_nets}{stop:innermost_ring}} } \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_mesh(M8,$block_power_h_strap_width,$block_power_h_strap_spacing,$block_power_h_strap_pitch,$block_power_h_strap_offset,M7,$block_power_v_strap_width,$block_power_v_strap_spacing,$block_power_v_strap_pitch,$block_power_v_strap_offset)
#
#compile_power_plan -strategy osc_mesh_h8v7
#
#set_power_plan_strategy dl_mesh_h8v7 \
#  -nets "$core_power_nets" \
#  -voltage_area [get_voltage_areas dram_ctrl*dly_line*] \
#  -extension { {{nets:$core_power_nets}{stop:innermost_ring}} } \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_mesh(M8,$block_power_h_strap_width,$block_power_h_strap_spacing,$block_power_h_strap_pitch,$block_power_h_strap_offset,M7,$block_power_v_strap_width,$block_power_v_strap_spacing,$block_power_v_strap_pitch,$block_power_v_strap_offset)
#
#compile_power_plan -strategy dl_mesh_h8v7


###############################################################################
#
# POWER STRAPS FOR PLL
#

set blockage_ppr_groups [get_power_plan_regions osc_ppr_*]
set blockage_ppr_names [get_attribute $blockage_ppr_groups name]
set blockage_value "{power_plan_regions:{$blockage_ppr_names}}"

set pll_power_h_strap_width   [expr $m10_pitch * 1.0]
set pll_power_h_strap_spacing [expr $m10_pitch * 1.0]
set pll_power_h_strap_pitch   [expr $m10_pitch * 4.0]
set pll_power_h_strap_offset  [expr $m10_pitch * 1.0]
set pll_power_v_strap_width   [expr $m9_pitch * 4.0]
set pll_power_v_strap_spacing [expr $m9_pitch * 4.0]
set pll_power_v_strap_pitch   [expr $m9_pitch * 16.0]
set pll_power_v_strap_offset  [expr $m9_pitch * 4.0]

set_power_plan_strategy pll_mesh_h10v9 \
  -nets $pll_power_nets \
  -voltage_areas [get_voltage_areas PD_PLL] \
  -blockage $blockage_value \
  -extension { {{nets:$pll_power_nets}{stop:innermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_mesh(M10,$pll_power_h_strap_width,$pll_power_h_strap_spacing,$pll_power_h_strap_pitch,$pll_power_h_strap_offset,M9,$pll_power_v_strap_width,$pll_power_v_strap_spacing,$pll_power_v_strap_pitch,$pll_power_v_strap_offset)

compile_power_plan -strategy pll_mesh_h10v9


################################################################################
#
# POWER STRAPS FOR SUB-BLOCKS
#

set block_power_h_strap_width   [expr $m10_pitch * 1.0]
set block_power_h_strap_spacing [expr $m10_pitch * 1.0]
set block_power_h_strap_pitch   [expr $m10_pitch * 8.0]
set block_power_h_strap_offset  [expr $m10_pitch * 1.0]
set block_power_v_strap_width   [expr $m9_pitch * 4.0]
set block_power_v_strap_spacing [expr $m9_pitch * 1.0]
set block_power_v_strap_pitch   [expr $m9_pitch * 32.0]
set block_power_v_strap_offset  [expr $m9_pitch * 4.0]
set block_power_v_strap_extension [expr $tile_height * 10.0 + $m1_pitch]

set_power_plan_strategy block_mesh_h10v9 \
  -nets $core_power_nets \
  -voltage_area [get_voltage_areas *tile*] \
  -extension { {{nets:$core_power_nets}{direction:LR}{stop:innermost_ring}} {{nets:$core_power_nets}{direction:TB}{stop:$block_power_v_strap_extension}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_mesh(M10,$block_power_h_strap_width,$block_power_h_strap_spacing,$block_power_h_strap_pitch,$block_power_h_strap_offset,M9,$block_power_v_strap_width,$block_power_v_strap_spacing,$block_power_v_strap_pitch,$block_power_v_strap_offset)

compile_power_plan -strategy block_mesh_h10v9


################################################################################
#
# POWER STRAPS FOR MACROS IN PLAN GROUPS
#

set macro_power_v_strap_width   [expr $m5_pitch * 8.0]
set macro_power_v_strap_spacing [expr $m5_pitch * 8.0]
set macro_power_v_strap_pitch   [expr $m5_pitch * 32.0]
set macro_power_v_strap_offset  [expr $m5_pitch * 8.0]
set macro_power_h_strap_width   [expr $m8_pitch * 8.0]
set macro_power_h_strap_spacing [expr $m8_pitch * 1.0]
set macro_power_h_strap_pitch   [expr $m8_pitch * 64.0]
set macro_power_h_strap_offset  [expr $m8_pitch * 8.0]

#set_power_plan_strategy macro_mesh_h6v5 \
#  -nets $core_power_nets \
#  -macros [get_attribute [get_fp_cells -filter "is_hard_macro&&(orientation==E||orientation==FE||orientation==W||orientation==FW)"] full_name] \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_mesh(M6,$macro_power_h_strap_width,$macro_power_h_strap_spacing,$macro_power_h_strap_pitch,$macro_power_h_strap_offset,M5,$macro_power_v_strap_width,$macro_power_v_strap_spacing,$macro_power_v_strap_pitch,$macro_power_v_strap_offset)
#
#compile_power_plan -strategy macro_mesh_h6v5

#set_power_plan_strategy macro_strap_h5 \
#  -nets $core_power_nets \
#  -macros [get_attribute [get_fp_cells -filter "is_hard_macro&&(orientation==N||orientation==FN||orientation==S||orientation==FS)"] full_name] \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:h5_strap_ppt($macro_power_h_strap_width,$macro_power_h_strap_spacing,$macro_power_h_strap_pitch,$macro_power_h_strap_offset)
#
#compile_power_plan -strategy macro_strap_h5

#set_power_plan_strategy macro_strap_h8 \
#  -nets $core_power_nets \
#  -macros [get_attribute [get_fp_cells -filter "is_hard_macro&&(orientation==E||orientation==FE||orientation==W||orientation==FW)"] full_name] \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_h8_strap($macro_power_h_strap_width,$macro_power_h_strap_spacing,$macro_power_h_strap_pitch,$macro_power_h_strap_offset)
#
#compile_power_plan -strategy macro_strap_h8
#
#set_power_plan_strategy macro_strap_v5 \
#  -nets $core_power_nets \
#  -macros [get_attribute [get_fp_cells -filter "is_hard_macro&&(orientation==E||orientation==FE||orientation==W||orientation==FW)"] full_name] \
#  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_v5_strap($macro_power_v_strap_width,$macro_power_v_strap_spacing,$macro_power_v_strap_pitch,$macro_power_v_strap_offset)
#
#compile_power_plan -strategy macro_strap_v5

set_power_plan_strategy macro_strap_h8v7 \
  -nets $core_power_nets \
  -macros [get_attribute [get_fp_cells -filter "is_hard_macro&&(orientation==N||orientation==FN||orientation==S||orientation==FS)"] full_name] \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_mesh(M8,$macro_power_h_strap_width,$macro_power_h_strap_spacing,$macro_power_h_strap_pitch,$macro_power_h_strap_offset,M7,$macro_power_v_strap_width,$macro_power_v_strap_spacing,$macro_power_v_strap_pitch,$macro_power_v_strap_offset)

compile_power_plan -strategy macro_strap_h8v7

set_power_plan_strategy macro_strap_h5 \
  -nets $core_power_nets \
  -macros [get_attribute [get_fp_cells -filter "is_hard_macro&&(orientation==N||orientation==FN||orientation==S||orientation==FS)"] full_name] \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_h5_strap($macro_power_h_strap_width,$macro_power_h_strap_spacing,$macro_power_h_strap_pitch,$macro_power_h_strap_offset)

compile_power_plan -strategy macro_strap_h5


###############################################################################
#
# POWER STRAPS FOR CORE
#

set blockage_ppr_groups [get_power_plan_regions]
set blockage_ppr_names [get_attribute $blockage_ppr_groups name]
set blockage_value "{power_plan_regions:{$blockage_ppr_names}}"

set core_power_h_strap_width   [expr $m10_pitch * 2.0]
set core_power_h_strap_spacing [expr $m10_pitch * 2.0]
set core_power_h_strap_pitch   [expr $m10_pitch * 8.0]
set core_power_h_strap_offset  [expr $m10_pitch * 2.0]
set core_power_v_strap_width   [expr $m9_pitch * 8.0]
set core_power_v_strap_spacing [expr $m9_pitch * 8.0]
set core_power_v_strap_pitch   [expr $m9_pitch * 32.0]
set core_power_v_strap_offset  [expr $m9_pitch * 8.0]

set_power_plan_strategy core_mesh_h10v9 \
  -nets $core_power_nets \
  -core \
  -blockage $blockage_value \
  -extension { {{nets:$core_power_nets}{stop:outermost_ring}} } \
  -template $::env(BSG_DESIGNS_TARGET_DIR)/tcl/icc/dp_pns_mesh.tpl:bsg_power_mesh(M10,$core_power_h_strap_width,$core_power_h_strap_spacing,$core_power_h_strap_pitch,$core_power_h_strap_offset,M9,$core_power_v_strap_width,$core_power_v_strap_spacing,$core_power_v_strap_pitch,$core_power_v_strap_offset)

compile_power_plan -strategy core_mesh_h10v9


###############################################################################
#
# CHECK POWER RAILS
#

check_fp_rail -nets $core_power_nets

puts "RM-Info: Completed script [info script]\n"
