################################################################################
## Create Bounds
################################################################################

current_design ${DESIGN_NAME}

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_bounds -all
remove_edit_groups -all

#set core_height 2500
#set core_width 2500

set keepout_margin_x 2
set keepout_margin_y 2
set keepout_margins [list $keepout_margin_x $keepout_margin_y $keepout_margin_x $keepout_margin_y]

set master_tile "y_0__x_0__tile_node"
set tile_llx [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 0]
set tile_lly [lindex [get_attribute [get_cell -hier $master_tile] boundary_bbox] 0 1]
set tile_width [get_attribute [get_cell -hier $master_tile] width]
set tile_height [get_attribute [get_cell -hier $master_tile] height]

set end_tile "y_0__x_1__tile_node"
set end_tile_llx [lindex [get_attribute [get_cell -hier $end_tile] boundary_bbox] 0 0]
set end_tile_lly [lindex [get_attribute [get_cell -hier $end_tile] boundary_bbox] 0 1]
set end_tile_width [get_attribute [get_cell -hier $end_tile] width]
set end_tile_height [get_attribute [get_cell -hier $end_tile] height]

set tile_left       $tile_llx                            
set tile_right      [expr $tile_llx+$tile_width]         
set tile_bottom     $tile_lly                            
set tile_top        [expr $tile_lly+$tile_height]        

set end_tile_left   $end_tile_llx                        
set end_tile_right  [expr $end_tile_llx+$end_tile_width] 
set end_tile_bottom $end_tile_lly                        
set end_tile_top    [expr $end_tile_lly+$end_tile_height]

set mem_complex_llx [expr $tile_left]
set mem_complex_lly [expr $tile_top]
set mem_complex_urx [expr $end_tile_llx + $tile_width]
set mem_complex_ury [round_up_to_nearest [expr $tile_top + 200] [unit_height]]

set mem_complex_bound [create_bound -name "mem_complex" -type soft -boundary [list [list $mem_complex_llx $mem_complex_lly] [list $mem_complex_urx $mem_complex_ury]]]
add_to_bound $mem_complex_bound [get_cells -hier -filter "full_name=~*/mc/*"]

set prev_uplink_bound [create_bound -name "prev_uplink" -type soft -boundary {{237.0180 2014.3200} {307.1580 2763.1200}}]
add_to_bound ${prev_uplink_bound} [get_cells -hier -filter "full_name=~prev/uplink/*"]

set prev_downlink_bound [create_bound -name "prev_downlink" -type soft -boundary {{307.1580 2697.3600} {1040.0580 2763.1200}}]
add_to_bound ${prev_downlink_bound} [get_cells -hier -filter "full_name=~prev/downlink/*"]

set next_downlink_bound [create_bound -name "next_downlink" -type soft -boundary {{2692.8420 2014.3200} {2762.9820 2763.1200}}]
add_to_bound ${next_downlink_bound} [get_cells -hier -filter "full_name=~next/downlink/*"]

set next_uplink_bound [create_bound -name "next_uplink" -type soft -boundary {{1959.9420 2697.3600} {2692.8420 2763.1200}}]
add_to_bound ${next_uplink_bound} [get_cells -hier -filter "full_name=~next/uplink/*"]

## BP Tile bounds
current_design bp_tile_node

# Start script fresh
set_locked_objects -unlock [get_cells -hier]
remove_bounds -all
remove_edit_groups -all

#set core_bound [create_bound -name "CORE" -type soft -boundary {{0.0000 0.0000} {575.0640 345.1200}}]
#add_to_bound ${core_bound} [get_cells -hier -filter "full_name=~*core*"]
#add_to_bound ${core_bound} [get_cells -hier -filter "full_name=~*rof3_*__lce_data_cmd_pkt_encode*"]
#add_to_bound ${core_bound} [get_cells -hier -filter "full_name=~*rof3_*__data_cmd_adapter_in*"]
#add_to_bound ${core_bound} [get_cells -hier -filter "full_name=~*rof3_*__data_cmd_adapter_out*"]
#add_to_bound ${core_bound} [get_cells -hier -filter "full_name=~*rof3_*__lce_data_resp_pkt_encode*"]
#add_to_bound ${core_bound} [get_cells -hier -filter "full_name=~*rof3_*__data_resp_adapter_in*"]
#
#set router_0_bound [create_bound -name "RTR0" -type soft -boundary {{0.0000 345.1200} {291.2950 575.0400}}]
#add_to_bound ${router_0_bound} [get_cells -hier -filter "full_name=~rof3_0__req_router"]
#add_to_bound ${router_0_bound} [get_cells -hier -filter "full_name=~rof3_0__resp_router"]
#add_to_bound ${router_0_bound} [get_cells -hier -filter "full_name=~rof3_0__cmd_router"]
#add_to_bound ${router_0_bound} [get_cells -hier -filter "full_name=~rof3_0__data_cmd_router"]
#add_to_bound ${router_0_bound} [get_cells -hier -filter "full_name=~rof3_0__data_resp_router"]
#
#set router_1_bound [create_bound -name "RTR1" -type soft -boundary {{291.2950 345.1200} {575.0640 575.0400}}]
#add_to_bound ${router_1_bound} [get_cells -hier -filter "full_name=~rof3_1__req_router"]
#add_to_bound ${router_1_bound} [get_cells -hier -filter "full_name=~rof3_1__resp_router"]
#add_to_bound ${router_1_bound} [get_cells -hier -filter "full_name=~rof3_1__cmd_router"]
#add_to_bound ${router_1_bound} [get_cells -hier -filter "full_name=~rof3_1__data_cmd_router"]
#add_to_bound ${router_1_bound} [get_cells -hier -filter "full_name=~rof3_1__data_resp_router"]

#####################################
### I CACHE DATA
###

set icache_data_mems [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/icache/data_mems_*"]
set icache_data_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 4 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $icache_data_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_data_mems

set_macro_relative_location \
  -target_object $icache_data_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_corner bl \
  -offset [list 0 0]


#####################################
### I CACHE TAG
###

set icache_tag_mems [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/icache/tag_mem*"]
set icache_tag_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $icache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $icache_tag_mems

set icache_tag_margin 0
set_macro_relative_location \
  -target_object $icache_tag_ma \
  -target_corner bl \
  -target_orientation R0 \
  -anchor_object $icache_data_ma \
  -anchor_corner tl \
  -offset [list $icache_tag_margin 0]

#####################################
### I CACHE STAT
###

#set icache_stat_mem [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/icache/stat_mem/*"]
#set icache_stat_margin 0
#set_macro_relative_location \
#  -target_object $icache_stat_mem \
#  -target_corner bl \
#  -target_orientation MY \
#  -anchor_object $icache_tag_ma \
#  -anchor_corner br \
#  -offset [list $icache_stat_margin $keepout_margin_y]
#
#create_keepout_margin -type hard -outer $keepout_margins $icache_stat_mem

#####################################
### D CACHE DATA
###

set dcache_data_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/data_mem_*"]
set dcache_data_ma [create_macro_array \
  -num_rows 2 \
  -num_cols 4 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation N \
  $dcache_data_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_data_mems

set_macro_relative_location \
  -target_object $dcache_data_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_corner br \
  -offset [list 0 0]

#####################################
### D CACHE TAG
###

set dcache_tag_mems [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/tag_mem*"]
set dcache_tag_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 2 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation N \
  $dcache_tag_mems]

create_keepout_margin -type hard -outer $keepout_margins $dcache_tag_mems

set dcache_tag_margin 0
set_macro_relative_location \
  -target_object $dcache_tag_ma \
  -target_corner br \
  -target_orientation R0 \
  -anchor_object $dcache_data_ma \
  -anchor_corner tr \
  -offset [list -$dcache_tag_margin 0]

#####################################
### D CACHE STAT
###

#set dcache_stat_mem [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/stat_mem*"]
#set dcache_stat_margin 0
#set_macro_relative_location \
#  -target_object $dcache_stat_mem \
#  -target_corner br \
#  -target_orientation R0 \
#  -anchor_object $dcache_tag_ma \
#  -anchor_corner bl \
#  -offset [list -$dcache_stat_margin $keepout_margin_y]
#
#create_keepout_margin -type hard -outer $keepout_margins $dcache_stat_mem

#####################################
### CCE Directory
###

set directory_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*bp_cce/directory/directory/*"]
set directory_mem_height [get_attribute -objects [index_collection $directory_mems 0] -name height]
set directory_mem_width [get_attribute -objects [index_collection $directory_mems 0] -name width]
set directory_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 8 \
  -align bottom \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation [list N N N N N N N N] \
  $directory_mems]

# Should put this in the middle by relative location
set_macro_relative_location \
  -target_object $directory_ma \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_corner tl \
  -offset [list [expr $tile_width/2 - 4*$directory_mem_width] 0]

create_keepout_margin -type hard -outer $keepout_margins $directory_mems

#####################################
### CCE Instance
###

set cce_instr_ram [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/bp_cce/*inst_ram*"]
set cce_instr_width [get_attribute -objects $cce_instr_ram -name width]
set cce_instr_height [get_attribute -objects $cce_instr_ram -name height]
set_macro_relative_location \
  -target_object $cce_instr_ram \
  -target_corner tr \
  -target_orientation R0 \
  -anchor_object $directory_ma \
  -anchor_corner tl \
  -offset [list -$keepout_margin_x -$keepout_margin_y]

create_keepout_margin -type hard -outer $keepout_margins $cce_instr_ram

#####################################
### BTB Memory
###

#set btb_mem [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/btb/*"]
#set_macro_relative_location \
#  -target_object $btb_mem \
#  -target_corner br \
#  -target_orientation R0 \
#  -anchor_corner br \
#  -offset [list [expr -$tile_width/2-$keepout_margin_x] $keepout_margin_y]
#
#create_keepout_margin -type hard -outer $keepout_margins $btb_mem

#####################################
### INT RF
###

set int_regfile_mems [get_cells -design bp_tile_node -hier -filter "ref_name=~gf14_* && full_name=~*/int_regfile/*"]
set int_regfile_ma [create_macro_array \
  -num_rows 1 \
  -num_cols 2 \
  -align left \
  -horizontal_channel_height [expr 2*$keepout_margin_y] \
  -vertical_channel_width [expr 2*$keepout_margin_x] \
  -orientation FN \
  $int_regfile_mems]

set_macro_relative_location \
  -target_object $int_regfile_ma \
  -target_corner tl \
  -target_orientation R0 \
  -anchor_object $directory_ma \
  -anchor_corner tr \
  -offset [list 0 0]

create_keepout_margin -type hard -outer $keepout_margins $int_regfile_mems

current_design bsg_chip
