puts "Flow-Info: Running script [info script]\n"

if { $ICC_IMPLEMENTATION_PHASE != "block" } {
  set tile_height [get_attribute [get_core_area] tile_height]
  
  set core_bbox [get_attribute [get_core_area] bbox]
  
  if { [sizeof [get_designs -filter "name=~bsg_clk_gen_power_domain*"]] > 0 } {
    set osc_adt [get_rp_groups *adt -filter "design=~bsg_clk_gen_osc*"]
    set clk_gen_design_name [get_attribute [get_designs -filter "name=~bsg_clk_gen_power_domain*"] name]
    create_rp_group osc -design $clk_gen_design_name -rows 1 -columns [sizeof $osc_adt] -group_orient N -utilization 0.6
    set column 0
    
    foreach_in_collection adt [get_rp_groups *adt -filter "design=~bsg_clk_gen_osc*"] {
      set design_name [get_attribute $adt design]
      create_rp_group dly_tuners -design $design_name -rows 3 -columns 1 -group_orient N
      add_to_rp_group ${design_name}::dly_tuners -hierarchy ${design_name}::*adt -row 0
      set_rp_group_options [get_rp_groups ${design_name}::*adt] -disable_buffering
      add_to_rp_group ${design_name}::dly_tuners -hierarchy ${design_name}::*cdt -row 1
      set_rp_group_options [get_rp_groups ${design_name}::*cdt] -disable_buffering
      add_to_rp_group ${design_name}::dly_tuners -hierarchy ${design_name}::*fdt -row 2
      set_rp_group_options [get_rp_groups ${design_name}::*fdt] -disable_buffering
      add_to_rp_group ${clk_gen_design_name}::osc -hierarchy ${design_name}::dly_tuners -column $column
      incr column
    }
  
    #set ls_cells [sort_collection [get_cells -of_objects [get_voltage_area PD_PLL] -filter "is_level_shifter"] name]
    #set column [expr round([sizeof $ls_cells] / 2.0)]
    #create_rp_group ls_rp -design $clk_gen_design_name -rows 2 -columns $column -group_orient N -utilization 0.8
    #set idx 0 
    #foreach_in_collection ls_cell $ls_cells {
    #  add_to_rp_group ${clk_gen_design_name}::ls_rp -leaf $ls_cell -row [expr $idx / $column] -column [expr $idx % $column]
    #  incr idx
    #}
  }
  
  foreach_in_collection dqs_io [get_cells *dqs_p_* -filter "is_io"] {
    set io_bbox [get_attribute $dqs_io bbox]
    set adt [filter_collection [get_rp_groups -of_objects [all_fanout -from [get_nets -of_objects [get_pins -of_objects $dqs_io -filter "name==C"]] -flat -only_cells]] "name=~*adt"]
    set design_name [get_attribute $adt design]
    create_rp_group dly_tuners -design $design_name -rows 3 -columns 1 -group_orient N
    add_to_rp_group ${design_name}::dly_tuners -hierarchy ${design_name}::*adt -row 0
    set_rp_group_options [get_rp_groups ${design_name}::*adt] -disable_buffering
    add_to_rp_group ${design_name}::dly_tuners -hierarchy ${design_name}::*cdt -row 1
    set_rp_group_options [get_rp_groups ${design_name}::*cdt] -disable_buffering
    add_to_rp_group ${design_name}::dly_tuners -hierarchy ${design_name}::*fdt -row 2
    set_rp_group_options [get_rp_groups ${design_name}::*fdt] -disable_buffering
    set orientation [get_attribute $dqs_io orientation]
    if { $orientation == "N" } {
      set_rp_group_options ${design_name}::dly_tuners -x_offset [expr [lindex [lindex $io_bbox 0] 0] - [lindex [lindex $core_bbox 0] 0]] -y_offset $tile_height
    } elseif { $orientation == "E" } {
      set_rp_group_options ${design_name}::dly_tuners -x_offset $tile_height -y_offset [expr int([expr ([lindex [lindex $io_bbox 0] 1] - [lindex [lindex $core_bbox 0] 1]) / $tile_height]) * $tile_height]
    } elseif { $orientation == "W" } {
      set_rp_group_options ${design_name}::dly_tuners -x_offset [expr [lindex [lindex $core_bbox 1] 0] - [lindex [lindex $core_bbox 0] 0] - $tile_height] -y_offset [expr int([expr ([lindex [lindex $io_bbox 0] 1] - [lindex [lindex $core_bbox 0] 1]) / $tile_height]) * $tile_height] -anchor_corner bottom-right
    }
  }
  
  foreach_in_collection dq_io [get_cells *dq_* -filter "is_io"] {
    set io_bbox [get_attribute $dq_io bbox]
    set rp_grp [all_rp_hierarchicals [get_rp_groups -of_objects [all_fanout -from [get_nets -of_objects [get_pins -of_objects $dq_io -filter "name==C"]] -flat -only_cells]]]
    set rp_grp_name [get_attribute $rp_grp name]
    set orientation [get_attribute $dq_io orientation]
    if { $orientation == "N" } {
      set_rp_group_options $rp_grp_name -x_offset [expr [lindex [lindex $io_bbox 0] 0] - [lindex [lindex $core_bbox 0] 0]] -y_offset $tile_height
    } elseif { $orientation == "E" } {
      set_rp_group_options $rp_grp_name -x_offset $tile_height -y_offset [expr int([expr ([lindex [lindex $io_bbox 0] 1] - [lindex [lindex $core_bbox 0] 1]) / $tile_height]) * $tile_height]
    } elseif { $orientation == "W" } {
      set_rp_group_options $rp_grp_name -x_offset [expr [lindex [lindex $core_bbox 1] 0] - [lindex [lindex $core_bbox 0] 0] - $tile_height] -y_offset [expr int([expr ([lindex [lindex $io_bbox 0] 1] - [lindex [lindex $core_bbox 0] 1]) / $tile_height]) * $tile_height] -anchor_corner bottom-right
    }
  }
}

puts "Flow-Info: Completed script [info script]\n"
