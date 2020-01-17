puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

set macro_keepout $tile_height

foreach_in_collection mim [get_plan_groups $ICC_MIM_MASTER_LIST] {
  set mim_master_name [get_attribute $mim mim_master_name]
  if { $mim_master_name == "bp_tile_node" } {
    set icache_data_mem_list ""
    for {set row 0} {$row<2} {incr row} { 
      set macro_row ""
      for {set column 0} {$column<4} {incr column} { 
        set idx [expr $row*4+$column]
        append_to_collection macro_row [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*data_mems*$idx*"]
      }
      lappend icache_data_mem_list $macro_row
    }
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*data_mems*"] -legal_orientations E
    set_fp_macro_array -name icache_data_mem_array -elements $icache_data_mem_list -use_keepout_margin
    set_fp_relative_location -name icache_data_mem_array_rl -target_cell icache_data_mem_array -target_corner tr -anchor_corner tr -anchor_object [get_attribute $mim name]

    set icache_tag_mem_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*tag_mem*"]
    set_fp_macro_options $icache_tag_mem_list -legal_orientations E
    set_fp_macro_array -name icache_tag_mem_array -elements $icache_tag_mem_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name icache_tag_mem_array_rl -target_cell icache_tag_mem_array -target_corner tr -anchor_corner tl -anchor_object icache_data_mem_array

    set dcache_data_mem_list ""
    for {set row 0} {$row<2} {incr row} { 
      set macro_row ""
      for {set column 0} {$column<4} {incr column} { 
        set idx [expr $row*4+$column]
        append_to_collection macro_row [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*data_mem*$idx*"]
      }
      lappend dcache_data_mem_list $macro_row
    }
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*data_mem*"] -legal_orientations W
    set_fp_macro_array -name dcache_data_mem_array -elements $dcache_data_mem_list -use_keepout_margin
    set_fp_relative_location -name dcache_data_mem_array_rl -target_cell dcache_data_mem_array -target_corner tr -anchor_corner tl -anchor_object [get_attribute $mim name]

    set dcache_tag_mem_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*tag_mem*"]
    set_fp_macro_options $dcache_tag_mem_list -legal_orientations W
    set_fp_macro_array -name dcache_tag_mem_array -elements $dcache_tag_mem_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name dcache_tag_mem_array_rl -target_cell dcache_tag_mem_array -target_corner tr -anchor_corner tl -anchor_object dcache_data_mem_array

    set cce_dir_mem_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*directory*"]
    set_fp_macro_options $cce_dir_mem_list -legal_orientations E
    set_fp_macro_array -name cce_dir_mem_array -elements $cce_dir_mem_list -use_keepout_margin
    set_fp_relative_location -name cce_dir_mem_array_rl -target_cell cce_dir_mem_array -target_corner tr -anchor_corner tl -anchor_object dcache_data_mem_array

    set cce_inst_ram [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*inst_ram*"]
    set_fp_relative_location -name cce_inst_ram_rl -target_cell [get_attribute $cce_inst_ram full_name] -target_orientation E -target_corner tr -anchor_corner br -anchor_object cce_dir_mem_array -x_offset -$macro_keepout -y_offset -$macro_keepout

    set l2s_data_mem_west_list ""
    for {set row 0} {$row<2} {incr row} {
      set macro_row ""
      for {set column 0} {$column<4} {incr column} {
        set idx [expr $row*4+$column]
        append_to_collection macro_row [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*data_mem*wb_${idx}*db_0*"]
      }
      lappend l2s_data_mem_west_list $macro_row
    }
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*data_mem*db_0*"] -legal_orientations W
    set_fp_macro_array -name l2s_data_mem_west_array -elements $l2s_data_mem_west_list -use_keepout_margin
    set_fp_relative_location -name l2s_data_mem_west_array_rl -target_cell l2s_data_mem_west_array -target_corner tr -anchor_corner tl -anchor_object [get_attribute $mim name]

    set l2s_data_mem_east_list ""
    for {set row 0} {$row<2} {incr row} {
      set macro_row ""
      for {set column 0} {$column<4} {incr column} {
        set idx [expr $row*4+$column]
        append_to_collection macro_row [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*data_mem*wb_${idx}*db_1*"]
      }
      lappend l2s_data_mem_east_list $macro_row
    }
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*data_mem*db_1*"] -legal_orientations W
    set_fp_macro_array -name l2s_data_mem_east_array -elements $l2s_data_mem_east_list -use_keepout_margin
    set_fp_relative_location -name l2s_data_mem_east_array_rl -target_cell l2s_data_mem_east_array -target_corner tr -anchor_corner tl -anchor_object [get_attribute $mim name]

    set l2s_tag_mem_west_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*tag_mem*wb_0*"]
    set_fp_macro_options $l2s_tag_mem_west_list -legal_orientations W
    set_fp_macro_array -name l2s_tag_mem_west_array -elements $l2s_tag_mem_west_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name l2s_tag_mem_west_array_rl -target_cell l2s_tag_mem_west_array -target_corner tr -anchor_corner tl -anchor_object l2s_data_mem_west_array

    set l2s_tag_mem_east_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*tag_mem*wb_1*"]
    set_fp_macro_options $l2s_tag_mem_east_list -legal_orientations W
    set_fp_macro_array -name l2s_tag_mem_east_array -elements $l2s_tag_mem_east_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name l2s_tag_mem_east_array_rl -target_cell l2s_tag_mem_east_array -target_corner tr -anchor_corner tl -anchor_object l2s_data_mem_east_array
  }
}

error_info

source -echo -verbose block_pin_physical_constraints.tcl

#set_fp_placement_strategy -plan_group_interface_net_weight 10.0
#set_fp_placement_strategy -IO_net_weight 10.0
#
#set_app_var placer_max_cell_density_threshold 0.75

puts "Flow-Info: Completed script [info script]\n"
