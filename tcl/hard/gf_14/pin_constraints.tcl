remove_individual_pin_constraints
remove_block_pin_constraints

### Just make sure that other layers are not used.

set_block_pin_constraints -allowed_layers { C4 C5 K1 K2 K3 K4 }

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

set tile_req_pins_o       [get_pins -hier $master_tile/* -filter "name=~coh_lce_req_link_o*"]
set tile_req_pins_i       [get_pins -hier $master_tile/* -filter "name=~coh_lce_req_link_i*"]
set tile_cmd_pins_o       [get_pins -hier $master_tile/* -filter "name=~coh_lce_cmd_link_o*"]
set tile_cmd_pins_i       [get_pins -hier $master_tile/* -filter "name=~coh_lce_cmd_link_i*"]
set tile_resp_pins_o      [get_pins -hier $master_tile/* -filter "name=~coh_lce_resp_link_o*"]
set tile_resp_pins_i      [get_pins -hier $master_tile/* -filter "name=~coh_lce_resp_link_i*"]

set tile_mem_cmd_pins_o   [get_pins -hier $master_tile/* -filter "name=~mem_cmd_link_o*"]
set tile_mem_cmd_pins_i   [get_pins -hier $master_tile/* -filter "name=~mem_cmd_link_i*"]
set tile_mem_resp_pins_o  [get_pins -hier $master_tile/* -filter "name=~mem_resp_link_o*"]
set tile_mem_resp_pins_i  [get_pins -hier $master_tile/* -filter "name=~mem_resp_link_i*"]

set tile_req_pin_len       [expr [sizeof_collection $tile_req_pins_o] / 4]
set tile_cmd_pin_len       [expr [sizeof_collection $tile_cmd_pins_o] / 4]
set tile_resp_pin_len      [expr [sizeof_collection $tile_resp_pins_o] / 4]
set tile_mem_cmd_pin_len   [expr [sizeof_collection $tile_mem_cmd_pins_o] / 4]
set tile_mem_resp_pin_len  [expr [sizeof_collection $tile_mem_resp_pins_o] / 4]

# TODO: Refactor make list indexed by NSEW
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
# 0.08*N = N tracks of space
# East/West pins - C4, K1
set start_y [expr 0.04 + 0.8*40]
set last_loc [bsg_pins_line_constraint $tile_req_pins_i_E      "C4" right $start_y               $master_tile $tile_req_pins_o_W      1 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_i_E     "C4" right [expr $last_loc+0.160] $master_tile $tile_resp_pins_o_W     1 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_i_E      "C4" right [expr $last_loc+0.160] $master_tile $tile_cmd_pins_o_W      1 0]

set last_loc [bsg_pins_line_constraint $tile_req_pins_o_E      "C4" right [expr $last_loc+0.160] $master_tile $tile_req_pins_i_W      1 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_o_E     "C4" right [expr $last_loc+0.160] $master_tile $tile_resp_pins_i_W     1 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_o_E      "C4" right [expr $last_loc+0.160] $master_tile $tile_cmd_pins_i_W      1 0]

set start_y [expr 0.104 + 0.128*40]
set last_loc [bsg_pins_line_constraint $tile_mem_cmd_pins_i_E  "K1" right $start_y               $master_tile $tile_mem_cmd_pins_o_W  1 0]
set last_loc [bsg_pins_line_constraint $tile_mem_resp_pins_i_E "K1" right [expr $last_loc+0.256] $master_tile $tile_mem_resp_pins_o_W 1 0]

set last_loc [bsg_pins_line_constraint $tile_mem_cmd_pins_o_E  "K1" right [expr $last_loc+0.256] $master_tile $tile_mem_cmd_pins_i_W  1 0]
set last_loc [bsg_pins_line_constraint $tile_mem_resp_pins_o_E "K1" right [expr $last_loc+0.256] $master_tile $tile_mem_resp_pins_i_W 1 0]

# North/South pins - C5, K2
set start_x  [expr 0.04 + 0.8*40]
set last_loc [bsg_pins_line_constraint $tile_req_pins_i_N      "C5" top   $start_y               $master_tile $tile_req_pins_o_S      1 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_i_N     "C5" top   [expr $last_loc+0.160] $master_tile $tile_resp_pins_o_S     1 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_i_N      "C5" top   [expr $last_loc+0.160] $master_tile $tile_cmd_pins_o_S      1 0]

set last_loc [bsg_pins_line_constraint $tile_req_pins_o_N      "C5" top   [expr $last_loc+0.160] $master_tile $tile_req_pins_i_S      1 0]
set last_loc [bsg_pins_line_constraint $tile_resp_pins_o_N     "C5" top   [expr $last_loc+0.160] $master_tile $tile_resp_pins_i_S     1 0]
set last_loc [bsg_pins_line_constraint $tile_cmd_pins_o_N      "C5" top   [expr $last_loc+0.160] $master_tile $tile_cmd_pins_i_S      1 0]

set start_x [expr 0.104 + 0.128*40]
set last_loc [bsg_pins_line_constraint $tile_mem_cmd_pins_i_N  "K2" top   $start_y               $master_tile $tile_mem_cmd_pins_o_S  1 0]
set last_loc [bsg_pins_line_constraint $tile_mem_resp_pins_i_N "K2" top   [expr $last_loc+0.256] $master_tile $tile_mem_resp_pins_o_S 1 0]

set last_loc [bsg_pins_line_constraint $tile_mem_cmd_pins_o_N  "K2" top   [expr $last_loc+0.256] $master_tile $tile_mem_cmd_pins_i_S  1 0]
set last_loc [bsg_pins_line_constraint $tile_mem_resp_pins_o_N "K2" top   [expr $last_loc+0.256] $master_tile $tile_mem_resp_pins_i_S 1 0]

################################################################################
###
### MISC Pins. Slow signals in the center on the top, K4
###

set                  misc_pins [get_pins -hier $master_tile/* -filter "name=~*clk_i"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~*reset_i"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~proc_cfg_i*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~cfg*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~my*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~*cord*"]
append_to_collection misc_pins [get_pins -hier $master_tile/* -filter "name=~*int_i*"]

set start_x [expr 0.128 * 1800]
set last_loc [bsg_pins_line_constraint $misc_pins "K4" top $start_x $master_tile {} 2 0]

