puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

set_fp_pin_constraints -allowed_layers {M1 M2 M3 M4 M5 M6 M7 M8}

foreach_in_collection mim [get_plan_groups $ICC_MIM_MASTER_LIST] {
  set mim_master_name [get_attribute $mim mim_master_name]
  set mim_cell [get_attribute $mim logic_cell]
  set mim_cell_name [get_attribute $mim_cell full_name]
  if { $mim_master_name == "bp_tile_node" } {
    set p_in(lce_cmd)   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==in"] name]
    set p_in(lce_req)   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==in"] name]
    set p_in(lce_resp)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_resp_link*&&direction==in"] name]
    set p_in(mem_cmd)   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_cmd_link*&&direction==in"] name]
    set p_in(mem_resp)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_resp_link*&&direction==in"] name]
    set p_out(lce_cmd)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==out"] name]
    set p_out(lce_req)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==out"] name]
    set p_out(lce_resp) [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_resp_link*&&direction==out"] name]
    set p_out(mem_cmd)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_cmd_link*&&direction==out"] name]
    set p_out(mem_resp) [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~mem_resp_link*&&direction==out"] name]

    foreach pin_name [list lce_cmd lce_req lce_resp] {
      foreach i [list 0 1 2 3] {
        if { $i == 0 || $i == 2} {
          set                  pins [index_collection $p_in($pin_name)  [expr $i * [sizeof $p_in($pin_name)] / 4]  [expr ($i + 1) * [sizeof $p_in($pin_name)] / 4 - 1]]
          append_to_collection pins [index_collection $p_out($pin_name) [expr $i * [sizeof $p_out($pin_name)] / 4] [expr ($i + 1) * [sizeof $p_out($pin_name)] / 4 - 1]]
        } else {
          set                  pins [index_collection $p_out($pin_name) [expr $i * [sizeof $p_out($pin_name)] / 4] [expr ($i + 1) * [sizeof $p_out($pin_name)] / 4 - 1]]
          append_to_collection pins [index_collection $p_in($pin_name)  [expr $i * [sizeof $p_in($pin_name)] / 4]  [expr ($i + 1) * [sizeof $p_in($pin_name)] / 4 - 1]]
        }
        if { $i == 0 || $i == 1} {
          switch -glob $pin_name {
            "lce_cmd"  { set layer M2 }
            "lce_req"  { set layer M4 }
            "lce_resp" { set layer M6 }
          }
          set side [expr $i * 2 + 1]
          set offset [expr 300 * $tile_height]
        } else {
          switch -glob $pin_name {
            "lce_cmd"  { set layer M3 }
            "lce_req"  { set layer M5 }
            "lce_resp" { set layer M7 }
           }
          set side [expr $i * 2 - 2]
          set offset [expr 450 * $tile_height]
        }
        set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
        set idx 0
        foreach_in_collection pin $pins {
          set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
          incr idx
        }
      }
    }

    set pins $p_in(mem_cmd)
    set layer M3
    set side 2
    set offset [expr 400 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }
    set pins $p_out(mem_resp)
    set layer M5
    set side 2
    set offset [expr 400 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }

    set pins $p_out(mem_cmd)
    set layer M3
    set side 4
    set offset [expr 400 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }
    set pins $p_in(mem_resp)
    set layer M5
    set side 4
    set offset [expr 400 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*cord_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*did_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*reset_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*clk_i*"] name]
    set layer M7
    set side 2
    set offset [expr 400 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }
  } elseif { $mim_master_name == "bp_io_tile_node" } {
    set p_in(lce_cmd)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==in"] name]
    set p_in(lce_req)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==in"] name]
    set p_in(io_cmd)   [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_cmd_link*&&direction==in"] name]
    set p_in(io_resp)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_resp_link*&&direction==in"] name]
    set p_out(lce_cmd) [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_link*&&direction==out"] name]
    set p_out(lce_req) [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_link*&&direction==out"] name]
    set p_out(io_cmd)  [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_cmd_link*&&direction==out"] name]
    set p_out(io_resp) [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~io_resp_link*&&direction==out"] name]

    foreach pin_name [list lce_cmd lce_req] {
      foreach i [list 0 1 2 3] {
        if { $i == 0 || $i == 2} {
          set                  pins [index_collection $p_in($pin_name)  [expr $i * [sizeof $p_in($pin_name)] / 4]  [expr ($i + 1) * [sizeof $p_in($pin_name)] / 4 - 1]]
          append_to_collection pins [index_collection $p_out($pin_name) [expr $i * [sizeof $p_out($pin_name)] / 4] [expr ($i + 1) * [sizeof $p_out($pin_name)] / 4 - 1]]
        } else {
          set                  pins [index_collection $p_out($pin_name) [expr $i * [sizeof $p_out($pin_name)] / 4] [expr ($i + 1) * [sizeof $p_out($pin_name)] / 4 - 1]]
          append_to_collection pins [index_collection $p_in($pin_name)  [expr $i * [sizeof $p_in($pin_name)] / 4]  [expr ($i + 1) * [sizeof $p_in($pin_name)] / 4 - 1]]
        }
        if { $i == 0 || $i == 1} {
          switch -glob $pin_name {
            "lce_cmd"  { set layer M2 }
            "lce_req"  { set layer M4 }
          }
          set side [expr $i * 2 + 1]
          set offset [expr 15 * $tile_height]
        } else {
          switch -glob $pin_name {
            "lce_cmd"  { set layer M3 }
            "lce_req"  { set layer M5 }
           }
          set side [expr $i * 2 - 2]
          set offset [expr 120 * $tile_height]
        }
        set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
        set idx 0
        foreach_in_collection pin $pins {
          set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
          incr idx
        }
      }
    }

    foreach pin_name [list io_cmd io_resp] {
      foreach i [list 0 1] {
        if { $i == 0} {
          set                  pins [index_collection $p_in($pin_name)  [expr $i * [sizeof $p_in($pin_name)] / 2]  [expr ($i + 1) * [sizeof $p_in($pin_name)] / 2 - 1]]
          append_to_collection pins [index_collection $p_out($pin_name) [expr $i * [sizeof $p_out($pin_name)] / 2] [expr ($i + 1) * [sizeof $p_out($pin_name)] / 2 - 1]]
        } else {
          set                  pins [index_collection $p_out($pin_name) [expr $i * [sizeof $p_out($pin_name)] / 2] [expr ($i + 1) * [sizeof $p_out($pin_name)] / 2 - 1]]
          append_to_collection pins [index_collection $p_in($pin_name)  [expr $i * [sizeof $p_in($pin_name)] / 2]  [expr ($i + 1) * [sizeof $p_in($pin_name)] / 2 - 1]]
        }
        switch -glob $pin_name {
          "io_cmd"  { set layer M6 }
          "io_resp" { set layer M8 }
        }
        set side [expr $i * 2 + 1]
        set offset [expr 15 * $tile_height]
        set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
        set idx 0
        foreach_in_collection pin $pins {
          set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
          incr idx
        }
      }
    }

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*cord_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*did_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*reset_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*clk_i*"] name]
    set layer M5
    set side 2
    set offset [expr 300 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }
  } elseif { $mim_master_name == "bsg_channel_tunnel" } {
    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_data_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_v_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_yumi_o*"] name]
    set layer M3
    set side 2
    set offset [expr 10 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_data_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_v_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~multi_yumi_i*"] name]
    set layer M5
    set side 2
    set offset [expr 10 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~data_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~v_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~yumi_o*"] name]
    set layer M4
    set side 3
    set offset [expr 10 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }

    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~data_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~v_o*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~yumi_i*"] name]
    set layer M6
    set side 3
    set offset [expr 10 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }

    set pins [get_pins -of_objects $mim_cell -filter "name==clk_i"]
    append_to_collection pins [get_pins -of_objects $mim_cell -filter "name==reset_i"]
    set layer M5
    set side 2
    set offset [expr 100 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }
  } elseif { $mim_master_name == "bsg_chip_io_complex_links_ct_fifo" } {
    foreach_in_collection pin [get_pins -of_objects $mim_cell -filter "name=~links_*"] {
      set idx [regexp -all -inline -- {[0-9]+} [get_attribute $pin name]]
      if { [get_attribute $pin direction] == "in" } {
        set pitch [expr [get_attribute [get_layers M4] pitch] * 4]
        set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers M4 -side 3 -offset [expr 10 * $tile_height + $idx * $pitch]
      } else {
        set pitch [expr [get_attribute [get_layers M6] pitch] * 4]
        set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers M6 -side 3 -offset [expr 10 * $tile_height + $idx * $pitch]
      }
    }
    set idx 0
    foreach_in_collection pin [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~ci_*"] name] {
      set pitch [expr [get_attribute [get_layers M5] pitch] * 4]
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers M5 -side 2 -offset [expr 10 * $tile_height + $idx * $pitch]
      incr idx
    }
    set idx 0
    foreach_in_collection pin [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~co_*"] name] {
      set pitch [expr [get_attribute [get_layers M4] pitch] * 4]
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers M4 -side 1 -offset [expr 10 * $tile_height + $idx * $pitch]
      incr idx
    }
    set pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*tag_lines_i*"] name]
    append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $mim_cell -filter "name=~*clk_i*"] name]
    set layer M5
    set side 2
    set offset [expr 550 * $tile_height]
    set pitch [expr [get_attribute [get_layers $layer] pitch] * 4]
    set idx 0
    foreach_in_collection pin $pins {
      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $mim_cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
      incr idx
    }
  }
}

#set cell [get_attribute [get_plan_groups bp_processor_ic] logic_cell]
#set cell_name [get_attribute $cell full_name]
#set p_in(io_cmd)   [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~io_cmd_link*&&direction==in"] name]
#set p_in(io_resp)  [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~io_resp_link*&&direction==in"] name]
#set p_out(io_cmd)  [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~io_cmd_link*&&direction==out"] name]
#set p_out(io_resp) [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~io_resp_link*&&direction==out"] name]
#set p_in(coh_cmd)  [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~coh_cmd_link*&&direction==in"] name]
#set p_in(coh_req)  [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~coh_req_link*&&direction==in"] name]
#set p_out(coh_cmd) [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~coh_cmd_link*&&direction==out"] name]
#set p_out(coh_req) [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~coh_req_link*&&direction==out"] name]
#foreach grp [list io_cmd io_resp coh_cmd coh_req] {
#  foreach i [list 0 1] {
#    set                  pins [index_collection $p_in($grp)  [expr $i * [sizeof $p_in($grp)] / 2]  [expr ($i + 1) * [sizeof $p_in($grp)] / 2 - 1]]
#    append_to_collection pins [index_collection $p_out($grp) [expr $i * [sizeof $p_out($grp)] / 2] [expr ($i + 1) * [sizeof $p_out($grp)] / 2 - 1]]
#    switch -glob $grp {
#      "io_cmd" {
#        set layer M4
#        set pitch [expr [get_attribute [get_layers $layer] pitch] * 8]
#        if { $i == 0 } {
#          set side 1
#        } else {
#          set side 7
#        }
#        set offset [expr 20 * $tile_height]
#      }
#      "io_resp" {
#        set layer M6
#        set pitch [expr [get_attribute [get_layers $layer] pitch] * 8]
#        if { $i == 0 } {
#          set side 1
#        } else {
#          set side 7
#        }
#        set offset [expr 20 * $tile_height]
#      }
#      "coh_cmd" {
#        set layer M3
#        set pitch [expr [get_attribute [get_layers $layer] pitch] * 8]
#        if { $i == 0 } {
#          set side 8
#          set offset [expr 20 * $tile_height]
#        } else {
#          set side 8
#          set offset [expr 600 * $tile_height]
#        }
#      }
#      "coh_req" {
#        set layer M5
#        set pitch [expr [get_attribute [get_layers $layer] pitch] * 8]
#        if { $i == 0 } {
#          set side 8
#          set offset [expr 20 * $tile_height]
#        } else {
#          set side 8
#          set offset [expr 600 * $tile_height]
#        }
#      }
#    }
#    set idx 0
#    foreach_in_collection pin $pins {
#      set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
#      incr idx
#    }
#  }
#}
#set pins [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~*did_i*"] name]
#append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~*reset_i*"] name]
#append_to_collection pins [sort_collection -dictionary [get_pins -of_objects $cell -filter "name=~*clk_i*"] name]
#set layer M5
#set side 6
#set offset [expr 100 * $tile_height]
#set pitch [expr [get_attribute [get_layers $layer] pitch] * 8]
#set idx 0
#foreach_in_collection pin $pins {
#  set_pin_physical_constraints -pin_name [get_attribute $pin name] -cell $cell_name -layers $layer -side $side -offset [expr $offset + $idx * $pitch]
#  incr idx
#}

puts "Flow-Info: Completed script [info script]\n"
