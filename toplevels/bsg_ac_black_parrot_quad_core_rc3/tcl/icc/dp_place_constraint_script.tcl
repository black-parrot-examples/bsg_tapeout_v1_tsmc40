puts "Flow-Info: Running script [info script]\n"

remove_bounds -all
remove_edit_groups -all

set tile_height [get_attribute [get_core_area] tile_height]

set macro_keepout $tile_height

set tile0 [lindex [get_attribute [get_plan_groups] bbox] 0]
set tile1 [lindex [get_attribute [get_plan_groups] bbox] 1]
set tile2 [lindex [get_attribute [get_plan_groups] bbox] 2]
set tile3 [lindex [get_attribute [get_plan_groups] bbox] 3]

# Surrounding boxes
# llx lly urx ury
set top_box [list [expr [lindex $tile0 0 0]] [expr [lindex $tile0 1 1] + 10] [expr [lindex $tile1 1 0]] [expr [lindex $tile1 1 1] + 50]]
set bot_box [list [expr [lindex $tile2 0 0] - 100] [expr [lindex $tile2 0 0] - 100] [expr [lindex $tile3 1 0] + 100] [expr [lindex $tile3 0 1] - 10]]
set left_box [list [expr [lindex $tile0 0 0] - 100] [expr [lindex $tile2 0 1]] [expr [lindex $tile0 0 0] - 10] [expr [lindex $tile0 1 1] + 100]]
set right_box [list [expr [lindex $tile1 1 0] + 10] [expr [lindex $tile3 0 1]] [expr [lindex $tile1 1 0] + 100] [expr [lindex $tile1 1 1] + 100]]

set bypass_bound [create_bounds -name "bypass_bound" -type soft -coordinate [list $left_box $right_box]]
update_bounds -name "bypass_bound" -add [get_cells -hier -filter "full_name=~*repeater*"]

# fixme: This has to be low because otherwise it intersects with the PD_PLL -- could make a u-shaped boundary instead
set io_complex_llx [expr [lindex $tile0 0 0]]
set io_complex_lly [expr [lindex $tile0 1 1] + 10]
set io_complex_urx [expr [lindex $tile1 1 0]]
set io_complex_ury [expr [lindex $tile1 1 1] + 50]

set io_complex_bound [create_bounds -name "io_complex" -type soft -coordinate [list $io_complex_llx $io_complex_lly $io_complex_urx $io_complex_ury]]
update_bounds -name "io_complex" -add [get_cells -hier -filter "full_name=~*_ic_*"]

set mem_complex_llx [expr [lindex $tile2 0 0]]
set mem_complex_lly [expr [lindex $tile2 0 0] - 100]
set mem_complex_urx [expr [lindex $tile3 1 0]]
set mem_complex_ury [expr [lindex $tile3 0 1] - 10]

set mem_complex_bound [create_bounds -name "mem_complex" -type soft -coordinate [list $mem_complex_llx $mem_complex_lly $mem_complex_urx $mem_complex_ury]]
update_bounds -name "mem_complex" -add [get_cells -hier -filter "full_name=~*_mc_*"]
update_bounds -name "mem_complex" -add [get_cells *bypass_link*]
update_bounds -name "mem_complex" -add [get_cells *bypass_router*]

set next_ct_llx [expr [lindex $tile1 1 0] + 10]
set next_ct_lly [expr [lindex $tile1 0 1]]
set next_ct_urx [expr [lindex $tile1 1 0] + 100]
set next_ct_ury [expr [lindex $tile1 1 1] + 100]

set next_ct_bound [create_bounds -name "next_ct" -type soft -coordinate [list $next_ct_llx $next_ct_lly $next_ct_urx $next_ct_ury]]
update_bounds -name "next_ct" -add [get_cells -hier -filter "full_name=~*next*"]

set prev_ct_llx [expr [lindex $tile0 0 0] - 100]
set prev_ct_lly [expr [lindex $tile0 0 1]]
set prev_ct_urx [expr [lindex $tile0 0 0] - 10]
set prev_ct_ury [expr [lindex $tile0 1 1] + 100]

set prev_ct_bound [create_bounds -name "prev_ct" -type soft -coordinate [list $prev_ct_llx $prev_ct_lly $prev_ct_urx $prev_ct_ury]]
update_bounds -name "prev_ct" -add [get_cells -hier -filter "full_name=~*prev*"]

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
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*data_mems*"] -legal_orientations W
    set_fp_macro_array -name icache_data_mem_array -elements $icache_data_mem_list -use_keepout_margin
    set_fp_relative_location -name icache_data_mem_array_rl -target_cell icache_data_mem_array -target_corner bl -anchor_corner bl -anchor_object [get_attribute $mim name]
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] icache_data_mem_list

    set icache_tag_mem_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*tag_mem*"]
    set_fp_macro_options $icache_tag_mem_list -legal_orientations W
    set_fp_macro_array -name icache_tag_mem_array -elements $icache_tag_mem_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name icache_tag_mem_array_rl -target_cell icache_tag_mem_array -target_corner bl -anchor_corner br -anchor_object icache_data_mem_array
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] icache_tag_mem_list

    set dcache_data_mem_list ""
    for {set row 0} {$row<2} {incr row} { 
      set macro_row ""
      for {set column 0} {$column<4} {incr column} { 
        set idx [expr $row*4+$column]
        append_to_collection macro_row [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*data_mem*$idx*"]
      }
      lappend dcache_data_mem_list $macro_row
    }
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*data_mem*"] -legal_orientations E
    set_fp_macro_array -name dcache_data_mem_array -elements $dcache_data_mem_list -use_keepout_margin
    set_fp_relative_location -name dcache_data_mem_array_rl -target_cell dcache_data_mem_array -target_corner br -anchor_corner br -anchor_object [get_attribute $mim name]
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] dcache_data_mem_list

    set dcache_tag_mem_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*tag_mem*"]
    set_fp_macro_options $dcache_tag_mem_list -legal_orientations E
    set_fp_macro_array -name dcache_tag_mem_array -elements $dcache_tag_mem_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name dcache_tag_mem_array_rl -target_cell dcache_tag_mem_array -target_corner br -anchor_corner bl -anchor_object dcache_data_mem_array
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] dcache_tag_mem_list

    set cce_dir_mem_list ""
    for {set row 0} {$row<4} {incr row} {
      set macro_row ""
      for {set column 0} {$column<2} {incr column} {
        set idx [expr $row*2+$column]
        append_to_collection macro_row [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*directory*mem_db1_wb_${idx}*"]
      }
      lappend cce_dir_mem_list $macro_row
    }
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*directory*"] -legal_orientations E
    set_fp_macro_array -name cce_dir_mem_array -elements $cce_dir_mem_list -use_keepout_margin
    # TODO: get half of CCE memory width
    set_fp_relative_location -name cce_dir_mem_array_rl -target_cell cce_dir_mem_array -target_corner bl -anchor_corner bl -anchor_object [get_attribute $mim name] -x_offset [expr 1200/2 - 30]
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] cce_dir_mem_list

    set cce_inst_ram_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*inst_ram*"]
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*inst_ram*"] -legal_orientations E
    set_fp_macro_array -name cce_inst_ram_array -elements $cce_inst_ram_list -use_keepout_margin
    set_fp_relative_location -name cce_inst_ram_rl -target_cell cce_inst_ram_array -target_corner br -anchor_corner bl -anchor_object cce_dir_mem_array 
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] cce_inst_ram


    set regfile_mem0_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*regfile*mem0"]
    set_fp_macro_options $regfile_mem0_list -legal_orientations W
    set_fp_macro_array -name regfile_mem0_array -elements $regfile_mem0_list -use_keepout_margin
    set_fp_relative_location -name regfile_mem0_array_rl -target_cell regfile_mem0_array -target_corner bl -anchor_corner br -anchor_object cce_dir_mem_array
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] cce_dir_mem_array

    set regfile_mem1_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*regfile*mem1"]
    set_fp_macro_options $regfile_mem1_list -legal_orientations W
    set_fp_macro_array -name regfile_mem1_array -elements $regfile_mem1_list -use_keepout_margin
    set_fp_relative_location -name regfile_mem1_array_rl -target_cell regfile_mem1_array -target_corner bl -anchor_corner tl -anchor_object regfile_mem0_array
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] regfile_mem0_array

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
    set_fp_relative_location -name l2s_data_mem_west_array_rl -target_cell l2s_data_mem_west_array -target_corner tl -anchor_corner tl -anchor_object [get_attribute $mim name]
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] l2s_data_mem_west_list

    set l2s_data_mem_east_list ""
    for {set row 0} {$row<2} {incr row} {
      set macro_row ""
      for {set column 0} {$column<4} {incr column} {
        set idx [expr $row*4+$column]
        append_to_collection macro_row [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*data_mem*wb_${idx}*db_1*"]
      }
      lappend l2s_data_mem_east_list $macro_row
    }
    set_fp_macro_options [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*data_mem*db_1*"] -legal_orientations E
    set_fp_macro_array -name l2s_data_mem_east_array -elements $l2s_data_mem_east_list -use_keepout_margin
    set_fp_relative_location -name l2s_data_mem_east_array_rl -target_cell l2s_data_mem_east_array -target_corner tr -anchor_corner tr -anchor_object [get_attribute $mim name]
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] l2s_data_mem_east_list

    set l2s_tag_mem_west_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*tag_mem*wb_0*"]
    set_fp_macro_options $l2s_tag_mem_west_list -legal_orientations W
    set_fp_macro_array -name l2s_tag_mem_west_array -elements $l2s_tag_mem_west_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name l2s_tag_mem_west_array_rl -target_cell l2s_tag_mem_west_array -target_corner tl -anchor_corner tr -anchor_object l2s_data_mem_west_array
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] l2s_tag_mem_west_list

    set l2s_tag_mem_east_list [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*tag_mem*wb_1*"]
    set_fp_macro_options $l2s_tag_mem_east_list -legal_orientations E
    set_fp_macro_array -name l2s_tag_mem_east_array -elements $l2s_tag_mem_east_list -align_edge t -use_keepout_margin
    set_fp_relative_location -name l2s_tag_mem_east_array_rl -target_cell l2s_tag_mem_east_array -target_corner tr -anchor_corner tl -anchor_object l2s_data_mem_east_array
    set_keepout_margin -type hard -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout] l2s_tag_mem_east_list
  }
}

source -echo -verbose block_pin_physical_constraints.tcl

#set_fp_placement_strategy -plan_group_interface_net_weight 10.0
#set_fp_placement_strategy -IO_net_weight 10.0
#
#set_app_var placer_max_cell_density_threshold 0.75

puts "Flow-Info: Completed script [info script]\n"
