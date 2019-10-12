set core_width 2500
set core_height 2500

# Number of blackparrot tiles
set num_bp_tiles 4
set tile_rows 2
set tile_cols 2

set channel_width 10
set channel_height 10

set dcache_data_mems [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/data_mem_*"]
set dcache_tag_mems  [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*/dcache/tag_mem*" ]
set directory_mems   [get_cells -hier -filter "ref_name=~gf14_* && full_name=~*bp_cce/directory/directory/*"]

set data_mem_width         [lindex [get_attribute [get_cell -hier $dcache_data_mems] width ] 0]
set data_mem_height        [lindex [get_attribute [get_cell -hier $dcache_data_mems] height] 0]
set tag_mem_width          [lindex [get_attribute [get_cell -hier $dcache_tag_mems ] width ] 0]
set tag_mem_height         [lindex [get_attribute [get_cell -hier $dcache_tag_mems ] height] 0]
set directory_mem_width    [lindex [get_attribute [get_cell -hier $directory_mems  ] width ] 0]
set directory_mem_height   [lindex [get_attribute [get_cell -hier $directory_mems  ] height] 0]

#set tile_height [expr 2*$data_mem_height + 1*$tag_mem_height]
#set tile_height $tile_width
#set tile_width [expr 8*$data_mem_width + 4*$directory_mem_width]
set tile_width  [round_up_to_nearest 600.000 [unit_width ]]
set tile_height [round_up_to_nearest 360.000 [unit_height]]

foreach {y} {1 0} {
  foreach {x} {0 1} {
    append_to_collection bp_tile_cells [get_cells -hier y_${y}__x_${x}__tile_node]
  }
}

set core_width 2500
set core_height 2500

# Shape the BP tile blocks
bsg_create_block_array_grid $bp_tile_cells \
  -grid mib_placement_grid \
  -relative_to core \
  -x [expr $core_width/2 - $tile_width*$tile_cols/2 ] \
  -y [expr $core_height - $tile_height*$tile_rows - 50*$channel_height] \
  -rows $tile_rows \
  -cols [expr $tile_cols] \
  -min_channel [list $channel_width $channel_height] \
  -width $tile_width \
  -height $tile_height

