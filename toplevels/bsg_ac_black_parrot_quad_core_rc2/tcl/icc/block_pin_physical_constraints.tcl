puts "Flow-Info: Running script [info script]\n"

foreach_in_collection mim [get_plan_groups $ICC_MIM_MASTER_LIST] {
  set mim_master_name [get_attribute $mim mim_master_name]
  set mim_cell [get_attribute $mim logic_cell]
  set mim_cell_name [get_attribute $mim_cell full_name]
  if { $mim_master_name == "bp_tile_node" } {
    set misc 0
    set lce_req_width  [expr [sizeof [get_pins -of_objects $mim_cell -filter "name=~coh_lce_req_*"]] / 8]
    set lce_resp_width [expr [sizeof [get_pins -of_objects $mim_cell -filter "name=~coh_lce_resp_*"]] / 8]
    set lce_cmd_width  [expr [sizeof [get_pins -of_objects $mim_cell -filter "name=~coh_lce_cmd_*"]] / 8]
    set mem_cmd_width  [expr [sizeof [get_pins -of_objects $mim_cell -filter "name=~mem_cmd_*"]] / 8]
    set mem_resp_width [expr [sizeof [get_pins -of_objects $mim_cell -filter "name=~mem_resp_*"]] / 8]
    foreach_in_collection pin [get_pins -of_objects $mim_cell] {
      set pin_name [get_attribute [get_pins $pin] name]
      set pin_direction [get_attribute [get_pins $pin] direction]
      set index [regexp -all -inline -- {[0-9]+} $pin_name]
      if { [regexp "^coh_lce_req_.*" $pin_name match] } {
        set order [expr $index % $lce_req_width]
        set direction [expr $index / $lce_req_width]
        set keepout_tracks 50
        if { $direction == 0 } {
          set side 1
          if { $pin_direction == "in" } {
            set layer M2
          } elseif { $pin_direction == "out"} {
            set layer M4
          }
        } elseif { $direction == 1 } {
          set side 3
          if { $pin_direction == "in" } {
            set layer M4
          } elseif { $pin_direction == "out"} {
            set layer M2
          }
        } elseif { $direction == 2 } {
          set side 2
          if { $pin_direction == "in" } {
            set layer M3
          } elseif { $pin_direction == "out"} {
            set layer M5
          }
        } elseif { $direction == 3 } {
          set side 4
          if { $pin_direction == "in" } {
            set layer M5
          } elseif { $pin_direction == "out"} {
            set layer M3
          }
        }
      } elseif { [regexp "^coh_lce_resp_.*" $pin_name match] } {
        set order [expr $lce_req_width + $index % $lce_resp_width]
        set direction [expr $index / $lce_resp_width]
        set keepout_tracks 50
        if { $direction == 0 } {
          set side 1
          if { $pin_direction == "in" } {
            set layer M2
          } elseif { $pin_direction == "out"} {
            set layer M4
          }
        } elseif { $direction == 1 } {
          set side 3
          if { $pin_direction == "in" } {
            set layer M4
          } elseif { $pin_direction == "out"} {
            set layer M2
          }
        } elseif { $direction == 2 } {
          set side 2
          if { $pin_direction == "in" } {
            set layer M3
          } elseif { $pin_direction == "out"} {
            set layer M5
          }
        } elseif { $direction == 3 } {
          set side 4
          if { $pin_direction == "in" } {
            set layer M5
          } elseif { $pin_direction == "out"} {
            set layer M3
          }
        }
      } elseif { [regexp "^coh_lce_cmd_.*" $pin_name match] } {
        set direction [expr $index / $lce_cmd_width]
        set keepout_tracks 50
        if { $direction == 0 } {
          set side 1
          set order [expr $index % $lce_cmd_width]
          if { $pin_direction == "in" } {
            set layer M6
          } elseif { $pin_direction == "out"} {
            set layer M8
          }
        } elseif { $direction == 1 } {
          set side 3
          set order [expr $index % $lce_cmd_width]
          if { $pin_direction == "in" } {
            set layer M8
          } elseif { $pin_direction == "out"} {
            set layer M6
          }
        } elseif { $direction == 2 } {
          set side 2
          set order [expr $lce_req_width + $lce_resp_width + $index % $lce_cmd_width]
          if { $pin_direction == "in" } {
            set layer M3
          } elseif { $pin_direction == "out"} {
            set layer M5
          }
        } elseif { $direction == 3 } {
          set side 4
          set order [expr $lce_req_width + $lce_resp_width + $index % $lce_cmd_width]
          if { $pin_direction == "in" } {
            set layer M5
          } elseif { $pin_direction == "out"} {
            set layer M3
          }
        }
      } elseif { [regexp "^mem_cmd_.*" $pin_name match] } {
        set direction [expr $index / $mem_cmd_width]
        set keepout_tracks 50
        if { $direction == 0 } {
          set side 1
          set order [expr $lce_cmd_width + $index % $mem_cmd_width]
          if { $pin_direction == "in" } {
            set layer M6
          } elseif { $pin_direction == "out"} {
            set layer M8
          }
        } elseif { $direction == 1 } {
          set side 3
          set order [expr $lce_cmd_width + $index % $mem_cmd_width]
          if { $pin_direction == "in" } {
            set layer M8
          } elseif { $pin_direction == "out"} {
            set layer M6
          }
        } elseif { $direction == 2 } {
          set side 2
          set layer M7
          if { $pin_direction == "in" } {
            set order [expr $index % $mem_cmd_width]
          } elseif { $pin_direction == "out"} {
            set order [expr $mem_cmd_width + $index % $mem_cmd_width]
          }
        } elseif { $direction ==  3} {
          set side 4
          set layer M7
          if { $pin_direction == "in" } {
            set order [expr $mem_cmd_width + $index % $mem_cmd_width]
          } elseif { $pin_direction == "out"} {
            set order [expr $index % $mem_cmd_width]
          }
        }
      } elseif { [regexp "^mem_resp_.*" $pin_name match] } {
        set direction [expr $index / $mem_cmd_width]
        set keepout_tracks 50
        if { $direction == 0 } {
          set side 1
          set order [expr $lce_cmd_width + $mem_cmd_width + $index % $mem_resp_width]
          if { $pin_direction == "in" } {
            set layer M6
          } elseif { $pin_direction == "out"} {
            set layer M8
          }
        } elseif { $direction == 1 } {
          set side 3
          set order [expr $lce_cmd_width + $mem_cmd_width + $index % $mem_resp_width]
          if { $pin_direction == "in" } {
            set layer M8
          } elseif { $pin_direction == "out"} {
            set layer M6
          }
        } elseif { $direction == 2 } {
          set side 2
          set layer M7
          if { $pin_direction == "in" } {
            set order [expr $mem_cmd_width * 2 + $index % $mem_resp_width]
          } elseif { $pin_direction == "out"} {
            set order [expr $mem_cmd_width * 2 + $mem_resp_width + $index % $mem_resp_width]
          }
        } elseif { $direction ==  3} {
          set side 4
          set layer M7
          if { $pin_direction == "in" } {
            set order [expr $mem_cmd_width * 2 + $mem_resp_width + $index % $mem_resp_width]
          } elseif { $pin_direction == "out"} {
            set order [expr $mem_cmd_width * 2 + $index % $mem_resp_width]
          }
        }
      } else {
        set order $misc
        incr misc
        set keepout_tracks 4000
        set side 4
        set layer M5
      }
      set layer_pitch [get_attribute [get_layers $layer] pitch]
      set keepout [expr $keepout_tracks * $layer_pitch]
      set offset [expr $keepout + $order * $layer_pitch * 4]
      set_pin_physical_constraints -pin_name $pin_name -cell $mim_cell_name -layers $layer -side $side -offset $offset
    }

    #set layer M5
    #set side 4
    #set layer_pitch [get_attribute [get_layers $layer] pitch]
    #set keepout [expr 2000 * $layer_pitch]
    #set index 0
    #foreach_in_collection pin [get_pins -of_objects $mim_cell -filter "name=~my_*"] {
    #  set pin_name [get_attribute [get_pins $pin] name]
    #  incr index
    #  set offset [expr $keepout + $index * $layer_pitch * 4]
    #  set_pin_physical_constraints -pin_name $pin_name -cell $mim_cell_name -layers $layer -side $side -offset $offset
    #}
    #incr index
    #set offset [expr $keepout + $index * $layer_pitch * 4]
    #set_pin_physical_constraints -pin_name reset_i -cell $mim_cell_name -layers $layer -side $side -offset $offset
    #incr index
    #set offset [expr $keepout + $index * $layer_pitch * 4]
    #set_pin_physical_constraints -pin_name clk_i -cell $mim_cell_name -layers $layer -side $side -offset $offset
  } elseif { $mim_master_name == "vcache" } {
    set link_pins [get_pins -of_objects $mim_cell -filter "name=~link*"]
    set channel_width [expr [sizeof $link_pins] / 2]
    foreach_in_collection pin $link_pins {
      set pin_name [get_attribute [get_pins $pin] name]
      set pin_direction [get_attribute [get_pins $pin] direction]
      set index [regexp -all -inline -- {[0-9]+} $pin_name]
      set side 2
      if {$pin_direction == "in"} {
        set layer M3
      } elseif {$pin_direction == "out"} {
        set layer M5
      }
      set layer_pitch [get_attribute [get_layers $layer] pitch]
      set keepout [expr 20 * $layer_pitch]
      set offset [expr $keepout + $index * $layer_pitch * 4]
      set_pin_physical_constraints -pin_name $pin_name -cell $mim_cell_name -layers $layer -side $side -offset $offset
    }
    set layer M3
    set side 4
    set layer_pitch [get_attribute [get_layers $layer] pitch]
    set keepout [expr 1600 * $layer_pitch]
    set index 0
    foreach_in_collection pin [get_pins -of_objects $mim_cell -filter "name=~dma*"]  {
      set pin_name [get_attribute [get_pins $pin] name]
      incr index
      set offset [expr $keepout + $index * $layer_pitch * 4]
      set_pin_physical_constraints -pin_name $pin_name -cell $mim_cell_name -layers $layer -side $side -offset $offset
    }
    set layer M4
    set side 3
    set layer_pitch [get_attribute [get_layers $layer] pitch]
    set keepout [expr 20 * $layer_pitch]
    set index 0
    foreach_in_collection pin [get_pins -of_objects $mim_cell -filter "name=~my_*"] {
      set pin_name [get_attribute [get_pins $pin] name]
      incr index
      set offset [expr $keepout + $index * $layer_pitch * 4]
      set_pin_physical_constraints -pin_name $pin_name -cell $mim_cell_name -layers $layer -side $side -offset $offset
    }
    incr index
    set offset [expr $keepout + $index * $layer_pitch * 4]
    set_pin_physical_constraints -pin_name reset_i -cell $mim_cell_name -layers $layer -side $side -offset $offset
    incr index
    set offset [expr $keepout + $index * $layer_pitch * 4]
    set_pin_physical_constraints -pin_name clk_i -cell $mim_cell_name -layers $layer -side $side -offset $offset
  }
}

set_fp_pin_constraints -hard_constraints location

puts "Flow-Info: Completed script [info script]\n"
