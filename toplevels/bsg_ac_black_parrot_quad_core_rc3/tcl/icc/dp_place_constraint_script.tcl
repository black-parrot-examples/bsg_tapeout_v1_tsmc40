puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

set macro_keepout $tile_height

set suffix 0
foreach_in_collection mim [get_plan_groups] {
  set mim_name [get_attribute $mim name]
  set mim_master_name [get_attribute $mim mim_master_name]
  if { $mim_master_name == "bp_tile_node" } {
    set macros [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*data_mem*"] name]
    set icache_data_mem_list ""
    for {set row 0} {$row<4} {incr row} { 
      set macro_row [index_collection $macros [expr 2 * $row] [expr 2 * $row + 1]]
      set_fp_macro_options [index_collection $macro_row 0] -legal_orientations FN
      set_fp_macro_options [index_collection $macro_row 1] -legal_orientations N
      lappend icache_data_mem_list $macro_row
    }
    set_fp_macro_array -name icache_data_mem_array_$suffix -elements $icache_data_mem_list -use_keepout_margin
    set_fp_relative_location -name icache_data_mem_array_rl_$suffix -target_cell icache_data_mem_array_$suffix -target_corner tl -anchor_corner tl -anchor_object [get_attribute $mim name]

    set icache_tag_mem_list [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*tag_mem*"] name]
    set_fp_macro_options $icache_tag_mem_list -legal_orientations N
    set_fp_macro_array -name icache_tag_mem_array_$suffix -elements $icache_tag_mem_list -use_keepout_margin -vertical
    set_fp_relative_location -name icache_tag_mem_array_rl_$suffix -target_cell icache_tag_mem_array_$suffix -target_corner tl -anchor_corner bl -anchor_object icache_data_mem_array_$suffix

    set icache_stat_mem [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*icache*stat_mem*"]
    set_fp_relative_location -name icache_stat_mem_rl_$suffix -target_cell [get_attribute $icache_stat_mem full_name] -target_corner tl -target_orientation N -anchor_corner tr -anchor_object icache_tag_mem_array_$suffix -x_offset $macro_keepout -y_offset -$macro_keepout

    set btb_mem [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*btb*"]
    set_fp_relative_location -name btb_mem_rl_$suffix -target_cell [get_attribute $btb_mem full_name] -target_corner tl -target_orientation N -anchor_corner bl -anchor_object icache_tag_mem_array_$suffix -x_offset $macro_keepout -y_offset -$macro_keepout

    set cce_dir_icache_mem_list [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*directory*icache*"] name]
    set_fp_macro_options $cce_dir_icache_mem_list -legal_orientations N
    set_fp_macro_array -name cce_dir_icache_mem_array_$suffix -elements $cce_dir_icache_mem_list -use_keepout_margin -vertical
    set_fp_relative_location -name cce_dir_icache_mem_array_rl_$suffix -target_cell cce_dir_icache_mem_array_$suffix -target_corner tl -anchor_corner bl -anchor_object [get_attribute $btb_mem full_name] -x_offset -$macro_keepout -y_offset -$macro_keepout

    set macros [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*data_mem*"] name]
    set dcache_data_mem_list ""
    for {set row 0} {$row<4} {incr row} { 
      set macro_row [index_collection $macros [expr 2 * $row] [expr 2 * $row + 1]]
      set_fp_macro_options [index_collection $macro_row 0] -legal_orientations FN
      set_fp_macro_options [index_collection $macro_row 1] -legal_orientations N
      lappend dcache_data_mem_list $macro_row
    }
    set_fp_macro_array -name dcache_data_mem_array_$suffix -elements $dcache_data_mem_list -use_keepout_margin
    set_fp_relative_location -name dcache_data_mem_array_rl_$suffix -target_cell dcache_data_mem_array_$suffix -target_corner tr -anchor_corner tr -anchor_object [get_attribute $mim name]

    set dcache_tag_mem_list [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*tag_mem*"] name]
    set_fp_macro_options $dcache_tag_mem_list -legal_orientations N
    set_fp_macro_array -name dcache_tag_mem_array_$suffix -elements $dcache_tag_mem_list -use_keepout_margin -vertical
    set_fp_relative_location -name dcache_tag_mem_array_rl_$suffix -target_cell dcache_tag_mem_array_$suffix -target_corner tr -anchor_corner br -anchor_object dcache_data_mem_array_$suffix

    set dcache_stat_mem [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*dcache*stat_mem*"]
    set_fp_relative_location -name dcache_stat_mem_rl_$suffix -target_cell [get_attribute $dcache_stat_mem full_name] -target_corner tr -target_orientation N -anchor_corner tl -anchor_object dcache_tag_mem_array_$suffix -x_offset -$macro_keepout -y_offset -$macro_keepout

    set int_rf_list [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*int_regfile*"] name]
    set_fp_macro_options $int_rf_list -legal_orientations N
    set_fp_macro_array -name int_rf_array_$suffix -elements $int_rf_list -use_keepout_margin -vertical
    set_fp_relative_location -name int_rf_array_rl_$suffix -target_cell int_rf_array_$suffix -target_corner tr -anchor_corner br -anchor_object dcache_tag_mem_array_$suffix

    set cce_dir_dcache_mem_list [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*directory*dcache*"] name]
    set_fp_macro_options $cce_dir_dcache_mem_list -legal_orientations FN
    set_fp_macro_array -name cce_dir_dcache_mem_array_$suffix -elements $cce_dir_dcache_mem_list -use_keepout_margin -vertical
    set_fp_relative_location -name cce_dir_dcache_mem_array_rl_$suffix -target_cell cce_dir_dcache_mem_array_$suffix -target_corner tr -anchor_corner br -anchor_object int_rf_array_$suffix

    set cce_inst_ram [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*cce*inst_ram*"]
    #set_fp_relative_location -name cce_inst_ram_rl_$suffix -target_cell [get_attribute $cce_inst_ram full_name] -target_orientation N -target_corner bl -anchor_corner br -anchor_object cce_dir_icache_mem_array_$suffix -x_offset [expr 250 * $tile_height]
    set_fp_relative_location -name cce_inst_ram_rl_$suffix -target_cell [get_attribute $cce_inst_ram full_name] -target_orientation N -anchor_object [get_attribute $mim name] -x_offset [expr 450 * $tile_height] -y_offset [expr 400 * $tile_height]

    set macros [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*data_mem*"] name]
    set l2s_data_mem_list ""
    for {set row 0} {$row<4} {incr row} { 
      set macro_row [index_collection $macros [expr 2 * $row] [expr 2 * $row + 1]]
      set_fp_macro_options [index_collection $macro_row 0] -legal_orientations S 
      set_fp_macro_options [index_collection $macro_row 1] -legal_orientations FS
      lappend l2s_data_mem_list $macro_row
    }
    set_fp_macro_array -name l2s_data_mem_array_l_$suffix -elements $l2s_data_mem_list -use_keepout_margin
    set_fp_relative_location -name l2s_data_mem_array_rl_l_$suffix -target_cell l2s_data_mem_array_l_$suffix -target_corner bl -anchor_corner bl -anchor_object [get_attribute $mim name]
    set l2s_data_mem_list ""
    for {set row 4} {$row<8} {incr row} { 
      set macro_row [index_collection $macros [expr 2 * $row] [expr 2 * $row + 1]]
      set_fp_macro_options [index_collection $macro_row 0] -legal_orientations S 
      set_fp_macro_options [index_collection $macro_row 1] -legal_orientations FS
      lappend l2s_data_mem_list $macro_row
    }
    set_fp_macro_array -name l2s_data_mem_array_r_$suffix -elements $l2s_data_mem_list -use_keepout_margin
    set_fp_relative_location -name l2s_data_mem_array_rl_r_$suffix -target_cell l2s_data_mem_array_r_$suffix -target_corner br -anchor_corner br -anchor_object [get_attribute $mim name]

    set l2s_tag_mem_list [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*tag_mem*"] name]
    set_fp_relative_location -name l2s_tag_mem_l_rl_$suffix -target_cell [get_attribute [index_collection $l2s_tag_mem_list 0] full_name] -target_orientation  S -target_corner bl -anchor_corner tl -anchor_object l2s_data_mem_array_l_$suffix -x_offset  $macro_keepout -y_offset $macro_keepout
    set_fp_relative_location -name l2s_tag_mem_r_rl_$suffix -target_cell [get_attribute [index_collection $l2s_tag_mem_list 1] full_name] -target_orientation FS -target_corner br -anchor_corner tr -anchor_object l2s_data_mem_array_r_$suffix -x_offset -$macro_keepout -y_offset $macro_keepout

    set l2s_stat_mem [get_fp_cells -of_objects $mim -filter "is_hard_macro&&full_name=~*l2s*stat_mem*"]
    set_fp_relative_location -name l2s_stat_mem_rl_$suffix -target_cell [get_attribute $l2s_stat_mem full_name] -target_corner bl -target_orientation S -anchor_corner br -anchor_object [get_attribute [index_collection $l2s_tag_mem_list 0] full_name] -x_offset [expr 2 * $macro_keepout]
  } elseif { $mim_master_name == "bsg_channel_tunnel" } {
    set mem_list [sort_collection -dictionary [get_fp_cells -of_objects $mim -filter "is_hard_macro"] name]
    set_fp_macro_options $mem_list -legal_orientations S
    set_fp_macro_array -name mem_array_$suffix -elements $mem_list -use_keepout_margin -vertical
    set_fp_relative_location -name mem_array_rl_$suffix -target_cell mem_array_$suffix -anchor_object [get_attribute $mim name]
  }
  incr suffix
}

foreach_in_collection mim [get_plan_groups $ICC_MIM_MASTER_LIST] {
  set mim_master_name [get_attribute $mim mim_master_name]
  set mim_cell [get_attribute $mim logic_cell]
  set mim_cell_name [get_attribute $mim_cell full_name]
  if { $mim_master_name == "bp_tile_node" } {
    set lce_cmd_in   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==in"] name]
    set lce_req_in   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==in"] name]
    set lce_resp_in  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_resp_link*&&direction==in"] name]
    set mem_cmd_in   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_cmd_link*&&direction==in"] name]
    set mem_resp_in  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_resp_link*&&direction==in"] name]
    set lce_cmd_out  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==out"] name]
    set lce_req_out  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==out"] name]
    set lce_resp_out [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_resp_link*&&direction==out"] name]
    set mem_cmd_out  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_cmd_link*&&direction==out"] name]
    set mem_resp_out [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_resp_link*&&direction==out"] name]

    foreach i [list 0 1 2 3] {
      if { $i == 0 } {
        set                  lce_cmd_pins  [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]   [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        append_to_collection lce_cmd_pins  [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        set                  lce_req_pins  [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]   [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        append_to_collection lce_req_pins  [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4]  [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        set                  lce_resp_pins [index_collection $lce_resp_in  [expr $i * [sizeof $lce_resp_in] / 4]  [expr ($i + 1) * [sizeof $lce_resp_in] / 4 - 1]]
        append_to_collection lce_resp_pins [index_collection $lce_resp_out [expr $i * [sizeof $lce_resp_out] / 4] [expr ($i + 1) * [sizeof $lce_resp_out] / 4 - 1]]
        create_fp_pins $lce_cmd_pins  -layer M2 -side 1 -step 4 -offset [expr 300 * $tile_height]
        create_fp_pins $lce_req_pins  -layer M4 -side 1 -step 4 -offset [expr 300 * $tile_height]
        create_fp_pins $lce_resp_pins -layer M6 -side 1 -step 4 -offset [expr 300 * $tile_height]
      } elseif { $i == 1 } {
        set                  lce_cmd_pins  [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        append_to_collection lce_cmd_pins  [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]   [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        set                  lce_req_pins  [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4]  [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        append_to_collection lce_req_pins  [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]   [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        set                  lce_resp_pins [index_collection $lce_resp_out [expr $i * [sizeof $lce_resp_out] / 4] [expr ($i + 1) * [sizeof $lce_resp_out] / 4 - 1]]
        append_to_collection lce_resp_pins [index_collection $lce_resp_in  [expr $i * [sizeof $lce_resp_in] / 4]  [expr ($i + 1) * [sizeof $lce_resp_in] / 4 - 1]]
        create_fp_pins $lce_cmd_pins  -layer M2 -side 3 -step 4 -offset [expr 300 * $tile_height]
        create_fp_pins $lce_req_pins  -layer M4 -side 3 -step 4 -offset [expr 300 * $tile_height]
        create_fp_pins $lce_resp_pins -layer M6 -side 3 -step 4 -offset [expr 300 * $tile_height]
      } elseif { $i == 2 } {
        set                  lce_cmd_pins  [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]   [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        append_to_collection lce_cmd_pins  [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        set                  lce_req_pins  [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]   [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        append_to_collection lce_req_pins  [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4]  [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        set                  lce_resp_pins [index_collection $lce_resp_in  [expr $i * [sizeof $lce_resp_in] / 4]  [expr ($i + 1) * [sizeof $lce_resp_in] / 4 - 1]]
        append_to_collection lce_resp_pins [index_collection $lce_resp_out [expr $i * [sizeof $lce_resp_out] / 4] [expr ($i + 1) * [sizeof $lce_resp_out] / 4 - 1]]
        create_fp_pins $lce_cmd_pins  -layer M3 -side 2 -step 4 -offset [expr 450 * $tile_height]
        create_fp_pins $lce_req_pins  -layer M5 -side 2 -step 4 -offset [expr 450 * $tile_height]
        create_fp_pins $lce_resp_pins -layer M7 -side 2 -step 4 -offset [expr 450 * $tile_height]
      } elseif { $i == 3 } {
        set                  lce_cmd_pins  [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        append_to_collection lce_cmd_pins  [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]   [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        set                  lce_req_pins  [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4]  [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        append_to_collection lce_req_pins  [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]   [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        set                  lce_resp_pins [index_collection $lce_resp_out [expr $i * [sizeof $lce_resp_out] / 4] [expr ($i + 1) * [sizeof $lce_resp_out] / 4 - 1]]
        append_to_collection lce_resp_pins [index_collection $lce_resp_in  [expr $i * [sizeof $lce_resp_in] / 4]  [expr ($i + 1) * [sizeof $lce_resp_in] / 4 - 1]]
        create_fp_pins $lce_cmd_pins  -layer M3 -side 4 -step 4 -offset [expr 450 * $tile_height]
        create_fp_pins $lce_req_pins  -layer M5 -side 4 -step 4 -offset [expr 450 * $tile_height]
        create_fp_pins $lce_resp_pins -layer M7 -side 4 -step 4 -offset [expr 450 * $tile_height]
      }
    }

    set pins $mem_cmd_in
    create_fp_pins $pins -layer M3 -side 2 -step 4 -offset [expr 400 * $tile_height]
    set pins $mem_resp_out
    create_fp_pins $pins -layer M5 -side 2 -step 4 -offset [expr 400 * $tile_height]

    set pins $mem_cmd_out
    create_fp_pins $pins -layer M3 -side 4 -step 4 -offset [expr 400 * $tile_height]
    set pins $mem_resp_in
    create_fp_pins $pins -layer M5 -side 4 -step 4 -offset [expr 400 * $tile_height]

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*cord_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*did_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*reset_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*clk_i*"] name]
    create_fp_pins $pins -layer M7 -side 2 -step 4 -offset [expr 400 * $tile_height]
  } elseif { $mim_master_name == "bp_io_tile_node" } {
    set lce_cmd_in  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==in"] name]
    set lce_req_in  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==in"] name]
    set io_cmd_in   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_cmd_link*&&direction==in"] name]
    set io_resp_in  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_resp_link*&&direction==in"] name]
    set lce_cmd_out [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==out"] name]
    set lce_req_out [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==out"] name]
    set io_cmd_out  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_cmd_link*&&direction==out"] name]
    set io_resp_out [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_resp_link*&&direction==out"] name]

    foreach i [list 0 1 2 3] {
      if { $i == 0 } {
        set                  lce_cmd_pins [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        append_to_collection lce_cmd_pins [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4] [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        set                  lce_req_pins [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]  [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        append_to_collection lce_req_pins [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4] [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        create_fp_pins $lce_cmd_pins -layer M2 -side 1 -step 4 -offset [expr 15 * $tile_height]
        create_fp_pins $lce_req_pins -layer M4 -side 1 -step 4 -offset [expr 15 * $tile_height]
      } elseif { $i == 1 } {
        set                  lce_cmd_pins [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4] [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        append_to_collection lce_cmd_pins [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        set                  lce_req_pins [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4] [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        append_to_collection lce_req_pins [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]  [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        create_fp_pins $lce_cmd_pins -layer M2 -side 3 -step 4 -offset [expr 15 * $tile_height]
        create_fp_pins $lce_req_pins -layer M4 -side 3 -step 4 -offset [expr 15 * $tile_height]
      } elseif { $i == 2 } {
        set                  lce_cmd_pins [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        append_to_collection lce_cmd_pins [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4] [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        set                  lce_req_pins [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]  [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        append_to_collection lce_req_pins [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4] [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        create_fp_pins $lce_cmd_pins -layer M3 -side 2 -step 4 -offset [expr 120 * $tile_height]
        create_fp_pins $lce_req_pins -layer M5 -side 2 -step 4 -offset [expr 120 * $tile_height]
      } elseif { $i == 3 } {
        set                  lce_cmd_pins [index_collection $lce_cmd_out  [expr $i * [sizeof $lce_cmd_out] / 4] [expr ($i + 1) * [sizeof $lce_cmd_out] / 4 - 1]]
        append_to_collection lce_cmd_pins [index_collection $lce_cmd_in   [expr $i * [sizeof $lce_cmd_in] / 4]  [expr ($i + 1) * [sizeof $lce_cmd_in] / 4 - 1]]
        set                  lce_req_pins [index_collection $lce_req_out  [expr $i * [sizeof $lce_req_out] / 4] [expr ($i + 1) * [sizeof $lce_req_out] / 4 - 1]]
        append_to_collection lce_req_pins [index_collection $lce_req_in   [expr $i * [sizeof $lce_req_in] / 4]  [expr ($i + 1) * [sizeof $lce_req_in] / 4 - 1]]
        create_fp_pins $lce_cmd_pins -layer M3 -side 4 -step 4 -offset [expr 120 * $tile_height]
        create_fp_pins $lce_req_pins -layer M5 -side 4 -step 4 -offset [expr 120 * $tile_height]
      }
    }

    foreach i [list 0 1] {
      if { $i == 0 } {
        set                  pins [index_collection $io_cmd_in  [expr $i * [sizeof $io_cmd_in] / 2] [expr ($i + 1) * [sizeof $io_cmd_in] / 2 - 1]]
        append_to_collection pins [index_collection $io_cmd_out [expr $i * [sizeof $io_cmd_in] / 2] [expr ($i + 1) * [sizeof $io_cmd_in] / 2 - 1]]
        create_fp_pins $pins -layer M6 -side 1 -step 4 -offset [expr 15 * $tile_height]
        set                  pins [index_collection $io_resp_in  [expr $i * [sizeof $io_resp_out] / 2] [expr ($i + 1) * [sizeof $io_resp_out] / 2 - 1]]
        append_to_collection pins [index_collection $io_resp_out [expr $i * [sizeof $io_resp_out] / 2] [expr ($i + 1) * [sizeof $io_resp_out] / 2 - 1]]
        create_fp_pins $pins -layer M8 -side 1 -step 4 -offset [expr 15 * $tile_height]
      } elseif { $i == 1 } {
        set                  pins [index_collection $io_cmd_out [expr $i * [sizeof $io_cmd_out] / 2] [expr ($i + 1) * [sizeof $io_cmd_out] / 2 - 1]]
        append_to_collection pins [index_collection $io_cmd_in  [expr $i * [sizeof $io_cmd_out] / 2] [expr ($i + 1) * [sizeof $io_cmd_out] / 2 - 1]]
        create_fp_pins $pins -layer M6 -side 3 -step 4 -offset [expr 15 * $tile_height]
        set                  pins [index_collection $io_resp_out [expr $i * [sizeof $io_resp_in] / 2] [expr ($i + 1) * [sizeof $io_resp_in] / 2 - 1]]
        append_to_collection pins [index_collection $io_resp_in  [expr $i * [sizeof $io_resp_in] / 2] [expr ($i + 1) * [sizeof $io_resp_in] / 2 - 1]]
        create_fp_pins $pins -layer M8 -side 3 -step 4 -offset [expr 15 * $tile_height]
      }
    }

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*cord_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*did_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*reset_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*clk_i*"] name]
    create_fp_pins $pins -layer M5 -side 2 -step 4 -offset [expr 300 * $tile_height]
  } elseif { $mim_master_name == "bsg_channel_tunnel" } {
    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_data_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_v_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_yumi_o*"] name]
    create_fp_pins $pins -layer M3 -side 2 -step 4 -offset [expr 10 * $tile_height]

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_data_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_v_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_yumi_i*"] name]
    create_fp_pins $pins -layer M5 -side 2 -step 4 -offset [expr 10 * $tile_height]

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~data_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~v_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~yumi_o*"] name]
    create_fp_pins $pins -layer M4 -side 3 -step 4 -offset [expr 10 * $tile_height]

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~data_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~v_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~yumi_i*"] name]
    create_fp_pins $pins -layer M6 -side 3 -step 4 -offset [expr 10 * $tile_height]

    set pins [get_pins -of_objects $mim_cell -filter "name==clk_i"]
    append_to_collection pins [get_pins -of_objects $mim_cell -filter "name==reset_i"]
    create_fp_pins $pins -layer M5 -side 2 -step 4 -offset [expr 100 * $tile_height]
  } elseif { $mim_master_name == "bsg_chip_io_complex_links_ct_fifo" } {
    set links_in  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~links_i*"] name]
    set links_out [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~links_o*"] name]
    create_fp_pins $links_in -layer M4 -side 3 -step 4 -offset [expr 10 * $tile_height]
    create_fp_pins $links_out -layer M6 -side 3 -step 4 -offset [expr 10 * $tile_height]
    set ci [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~ci_*"] name]
    create_fp_pins $ci -layer M5 -side 2 -step 4 -offset [expr 10 * $tile_height]
    set co [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~co_*"] name]
    create_fp_pins $co -layer M4 -side 1 -step 4 -offset [expr 10 * $tile_height]
    set misc [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*tag_lines_i*"] name]
    append_to_collection misc [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*clk_i*"] name]
    create_fp_pins $misc -layer M5 -side 2 -step 4 -offset [expr 550 * $tile_height]
  }
}

set cell [get_attribute [get_plan_groups dmc_controller] logic_cell]
set app_wr_pins  [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~app_wdf_*"] name]
set app_rd_pins  [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~app_rd_*"] name]
set app_cmd_pins [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~app_*&&name!~app_wdf_*&&name!~app_rd_*"] name]
append_to_collection app_cmd_pins [get_pins -of_objects $cell -filter "name==init_calib_complete_o"]
append_to_collection app_cmd_pins [get_pins -of_objects $cell -filter "name=~ui_*"]
create_fp_pins $app_wr_pins  -layer M2 -side 2 -step 3 -offset [expr 20 * $tile_height]
create_fp_pins $app_rd_pins  -layer M4 -side 2 -step 3 -offset [expr 20 * $tile_height]
create_fp_pins $app_cmd_pins -layer M6 -side 2 -step 3 -offset [expr 20 * $tile_height]
set dfi_pins [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~dfi_*"] name]
create_fp_pins $dfi_pins -layer M6 -side 4 -step 8 -offset [expr 50 * $tile_height]
set cfg_pins [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~dmc_p_i*"] name]
create_fp_pins $cfg_pins -layer M5 -side 3 -step 8 -offset [expr 40 * $tile_height]

source -echo -verbose block_pin_physical_constraints.tcl

set_fp_placement_strategy -plan_group_interface_net_weight 10.0
set_fp_placement_strategy -IO_net_weight 10.0

set_fp_placement_strategy -virtual_IPO true

set_app_var placer_max_cell_density_threshold 0.5

source hier_rp_groups.tcl

puts "Flow-Info: Completed script [info script]\n"
