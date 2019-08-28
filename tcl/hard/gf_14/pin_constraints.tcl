# STD: TODO -- explain
set bad_c_locations {}
proc next_c_track { init } {
  set bad_c_locations {12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30}
  set new [expr $init + 0.08]
  while {[lsearch $bad_c_locations [expr int($new/0.08)%42]] != -1} {
    set new [expr $new + 0.08]
  }
  return $new
}

proc next_k_track { init } {
  set bad_k_locations {9 10 11 12 13 14 15 16 17 18 34 35 36 37 38 39 40 41 42 43 44 61 62 63 64 65 66 67 68 69 70 87 88 89 90 91 92 93 94 95 96}
  set new [expr $init + 0.128]
  while {[lsearch $bad_k_locations [expr int($new/0.128)%105]] != -1} {
    set new [expr $new + 0.128]
  }
  return $new
}

remove_individual_pin_constraints
remove_block_pin_constraints

### Just make sure that other layers are not used.

set_block_pin_constraints -allowed_layers { C4 C5 K1 K2 K3 K4 }

### Master BP Tile MIB setup
#
set layers {C4 C5 K1 K2 K3 K4}
set hlayers {C4 K1 K3}
set vlayers {C5 K2 K4}
set cspace 0.160
set kspace [expr .256]

# Master instance of the BP tile mibs
set master_tile "y_0__x_0__tile_node"

# Useful numbers for the master tile
set tile_llx    [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 0]
set tile_lly    [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 1]
set tile_width  [get_attribute [get_cell -hier $master_tile] width]
set tile_height [get_attribute [get_cell -hier $master_tile] height]
set tile_left   $tile_llx
set tile_right  [expr $tile_llx+$tile_width]
set tile_bottom $tile_lly
set tile_top    [expr $tile_lly+$tile_height]

set tile_req_pins_o       [get_pins -hier $master_tile/* -filter "name=~lce_req_link_o*"]
set tile_req_pins_i       [get_pins -hier $master_tile/* -filter "name=~lce_req_link_i*"]
set tile_cmd_pins_o       [get_pins -hier $master_tile/* -filter "name=~lce_cmd_link_o*"]
set tile_cmd_pins_i       [get_pins -hier $master_tile/* -filter "name=~lce_cmd_link_i*"]
set tile_resp_pins_o      [get_pins -hier $master_tile/* -filter "name=~lce_resp_link_o*"]
set tile_resp_pins_i      [get_pins -hier $master_tile/* -filter "name=~lce_resp_link_i*"]

set tile_mem_cmd_pins_o   [get_pins -hier $master_tile/* -filter "name=~mem_cmd_link_o*"]
set tile_mem_cmd_pins_i   [get_pins -hier $master_tile/* -filter "name=~mem_cmd_link_i*"]
set tile_mem_resp_pins_o  [get_pins -hier $master_tile/* -filter "name=~mem_resp_link_o*"]
set tile_mem_resp_pins_i  [get_pins -hier $master_tile/* -filter "name=~mem_resp_link_i*"]

set tile_req_pin_len       [expr [sizeof_collection $tile_req_pins_o] / 4]
set tile_cmd_pin_len       [expr [sizeof_collection $tile_cmd_pins_o] / 4]
set tile_resp_pin_len      [expr [sizeof_collection $tile_resp_pins_o] / 4]
set tile_mem_cmd_pin_len   [expr [sizeof_collection $tile_mem_cmd_pins_o] / 4]
set tile_mem_resp_pin_len  [expr [sizeof_collection $tile_mem_resp_pins_o] / 4]

set tile_req_pins_o_S      [index_collection $tile_req_pins_o       [expr 0*$tile_req_pin_len]        [expr 1*$tile_req_pin_len-1]]
set tile_req_pins_i_S      [index_collection $tile_req_pins_i       [expr 0*$tile_req_pin_len]        [expr 1*$tile_req_pin_len-1]]
set tile_cmd_pins_o_S      [index_collection $tile_cmd_pins_o       [expr 0*$tile_cmd_pin_len]        [expr 1*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_S      [index_collection $tile_cmd_pins_i       [expr 0*$tile_cmd_pin_len]        [expr 1*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_S     [index_collection $tile_resp_pins_o      [expr 0*$tile_resp_pin_len]       [expr 1*$tile_resp_pin_len-1]]
set tile_resp_pins_i_S     [index_collection $tile_resp_pins_i      [expr 0*$tile_resp_pin_len]       [expr 1*$tile_resp_pin_len-1]]
set tile_mem_cmd_pins_o_S  [index_collection $tile_mem_cmd_pins_o   [expr 0*$tile_mem_cmd_pin_len]    [expr 1*$tile_mem_cmd_pin_len-1]]
set tile_mem_cmd_pins_i_S  [index_collection $tile_mem_cmd_pins_i   [expr 0*$tile_mem_cmd_pin_len]    [expr 1*$tile_mem_cmd_pin_len-1]]
set tile_mem_resp_pins_o_S [index_collection $tile_mem_resp_pins_o  [expr 0*$tile_mem_resp_pin_len]   [expr 1*$tile_mem_resp_pin_len-1]]
set tile_mem_resp_pins_i_S [index_collection $tile_mem_resp_pins_i  [expr 0*$tile_mem_resp_pin_len]   [expr 1*$tile_mem_resp_pin_len-1]]

set tile_req_pins_o_N      [index_collection $tile_req_pins_o       [expr 1*$tile_req_pin_len]        [expr 2*$tile_req_pin_len-1]]
set tile_req_pins_i_N      [index_collection $tile_req_pins_i       [expr 1*$tile_req_pin_len]        [expr 2*$tile_req_pin_len-1]]
set tile_cmd_pins_o_N      [index_collection $tile_cmd_pins_o       [expr 1*$tile_cmd_pin_len]        [expr 2*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_N      [index_collection $tile_cmd_pins_i       [expr 1*$tile_cmd_pin_len]        [expr 2*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_N     [index_collection $tile_resp_pins_o      [expr 1*$tile_resp_pin_len]       [expr 2*$tile_resp_pin_len-1]]
set tile_resp_pins_i_N     [index_collection $tile_resp_pins_i      [expr 1*$tile_resp_pin_len]       [expr 2*$tile_resp_pin_len-1]]
set tile_mem_cmd_pins_o_N  [index_collection $tile_mem_cmd_pins_o   [expr 1*$tile_mem_cmd_pin_len]    [expr 2*$tile_mem_cmd_pin_len-1]]
set tile_mem_cmd_pins_i_N  [index_collection $tile_mem_cmd_pins_i   [expr 1*$tile_mem_cmd_pin_len]    [expr 2*$tile_mem_cmd_pin_len-1]]
set tile_mem_resp_pins_o_N [index_collection $tile_mem_resp_pins_o  [expr 1*$tile_mem_resp_pin_len]   [expr 2*$tile_mem_resp_pin_len-1]]
set tile_mem_resp_pins_i_N [index_collection $tile_mem_resp_pins_i  [expr 1*$tile_mem_resp_pin_len]   [expr 2*$tile_mem_resp_pin_len-1]]

set tile_req_pins_o_E      [index_collection $tile_req_pins_o       [expr 2*$tile_req_pin_len]        [expr 3*$tile_req_pin_len-1]]
set tile_req_pins_i_E      [index_collection $tile_req_pins_i       [expr 2*$tile_req_pin_len]        [expr 3*$tile_req_pin_len-1]]
set tile_cmd_pins_o_E      [index_collection $tile_cmd_pins_o       [expr 2*$tile_cmd_pin_len]        [expr 3*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_E      [index_collection $tile_cmd_pins_i       [expr 2*$tile_cmd_pin_len]        [expr 3*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_E     [index_collection $tile_resp_pins_o      [expr 2*$tile_resp_pin_len]       [expr 3*$tile_resp_pin_len-1]]
set tile_resp_pins_i_E     [index_collection $tile_resp_pins_i      [expr 2*$tile_resp_pin_len]       [expr 3*$tile_resp_pin_len-1]]
set tile_mem_cmd_pins_o_E  [index_collection $tile_mem_cmd_pins_o   [expr 2*$tile_mem_cmd_pin_len]    [expr 3*$tile_mem_cmd_pin_len-1]]
set tile_mem_cmd_pins_i_E  [index_collection $tile_mem_cmd_pins_i   [expr 2*$tile_mem_cmd_pin_len]    [expr 3*$tile_mem_cmd_pin_len-1]]
set tile_mem_resp_pins_o_E [index_collection $tile_mem_resp_pins_o  [expr 2*$tile_mem_resp_pin_len]   [expr 3*$tile_mem_resp_pin_len-1]]
set tile_mem_resp_pins_i_E [index_collection $tile_mem_resp_pins_i  [expr 2*$tile_mem_resp_pin_len]   [expr 3*$tile_mem_resp_pin_len-1]]

set tile_req_pins_o_W      [index_collection $tile_req_pins_o       [expr 3*$tile_req_pin_len]        [expr 4*$tile_req_pin_len-1]]
set tile_req_pins_i_W      [index_collection $tile_req_pins_i       [expr 3*$tile_req_pin_len]        [expr 4*$tile_req_pin_len-1]]
set tile_cmd_pins_o_W      [index_collection $tile_cmd_pins_o       [expr 3*$tile_cmd_pin_len]        [expr 4*$tile_cmd_pin_len-1]]
set tile_cmd_pins_i_W      [index_collection $tile_cmd_pins_i       [expr 3*$tile_cmd_pin_len]        [expr 4*$tile_cmd_pin_len-1]]
set tile_resp_pins_o_W     [index_collection $tile_resp_pins_o      [expr 3*$tile_resp_pin_len]       [expr 4*$tile_resp_pin_len-1]]
set tile_resp_pins_i_W     [index_collection $tile_resp_pins_i      [expr 3*$tile_resp_pin_len]       [expr 4*$tile_resp_pin_len-1]]
set tile_mem_cmd_pins_o_W  [index_collection $tile_mem_cmd_pins_o   [expr 3*$tile_mem_cmd_pin_len]    [expr 4*$tile_mem_cmd_pin_len-1]]
set tile_mem_cmd_pins_i_W  [index_collection $tile_mem_cmd_pins_i   [expr 3*$tile_mem_cmd_pin_len]    [expr 4*$tile_mem_cmd_pin_len-1]]
set tile_mem_resp_pins_o_W [index_collection $tile_mem_resp_pins_o  [expr 3*$tile_mem_resp_pin_len]   [expr 4*$tile_mem_resp_pin_len-1]]
set tile_mem_resp_pins_i_W [index_collection $tile_mem_resp_pins_i  [expr 3*$tile_mem_resp_pin_len]   [expr 4*$tile_mem_resp_pin_len-1]]

# 0.04 = tile_height to track spacing
# 0.08*12 = 12 tracks of space
set start_y [expr $tile_height - 0.04 - 0.08*40]
set layer "C4"
for {set i 0} {$i < $tile_req_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_req_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]
}
for {set i 0} {$i < $tile_resp_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_resp_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$cspace]
}

set start_y [expr $tile_height - 0.104 - 0.128*40]
set layer "K1"
for {set i 0} {$i < $tile_cmd_pin_len} {incr i} {
  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_i_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_o_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]

  set real_y [expr $tile_lly + $start_y]
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_o_E $i] -allowed_layers "${layer}" -location "${tile_right} ${real_y}"
  set_individual_pin_constraints -pins [index_collection $tile_cmd_pins_i_W $i] -allowed_layers "${layer}" -location "${tile_left}  ${real_y}"
  set start_y [expr $start_y - 2*$kspace]
}

### North Pins

set x_location [next_c_track [expr 0.160 * 750]]
foreach_in_collection pin $cmd_i_resp_o_pins {
  set_individual_pin_constraints -pins $pin -allowed_layers "C5" -location "[expr ${tile_llx}+${x_location}] ${tile_top}"
  set x_location [next_c_track [next_c_track [next_c_track $x_location]]]
}

set                  cmd_o_resp_i_pins [get_pins -hier $master_tile/* -filter "name=~cmd_link_o*"]
append_to_collection cmd_o_resp_i_pins [get_pins -hier $master_tile/* -filter "name=~resp_link_i*"]

set x_location [next_c_track [expr 0.160 * 3000]]
foreach_in_collection pin $cmd_o_resp_i_pins {
  set_individual_pin_constraints -pins $pin -allowed_layers "C5" -location "[expr ${tile_llx}+${x_location}] ${tile_top}"
  set x_location [next_c_track [next_c_track [next_c_track $x_location]]]
}

### South pins



################################################################################
###
### MISC Pins. Slow signals in the center on the top
###

set                  misc_pins [get_pins -hier $master_tile/* -filter "name=~clk_i"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~reset_i"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~proc_cfg_i*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~cfg*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~my*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~*cord*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~*int_i*"]

set x_location [next_c_track [expr 0.160 * 1800]]
foreach_in_collection pin $misc_pins {
  set_individual_pin_constraints -pins $pin -allowed_layers "C5" -location "[expr ${tile_llx}+${x_location}] ${tile_top}"
  set x_location [next_c_track [next_c_track [next_c_track $x_location]]]
}

