set core_width 2500
set core_height 2500

# Number of blackparrot tiles
set num_bp_tiles 4
set tile_rows 2
set tile_cols 2

set channel_width 5
set channel_height 5
set tile_width [round_up_to_nearest [expr $core_width/4 - 10*$channel_width] [unit_width]]
#set tile_height [round_up_to_nearest [expr $core_height/4 - 10*$channel_height] [unit_height]]
set tile_height [expr 360]

foreach {y} {1 0} {
  foreach {x} {0 1} {
    append_to_collection bp_tile_cells [get_cells -hier y_${y}__x_${x}__tile_node]
  }
}

# Shape the BP tile blocks
bsg_create_block_array_grid $bp_tile_cells \
  -grid mib_placement_grid \
  -relative_to core \
  -x [expr $tile_width + 15*$channel_width] \
  -y [expr $core_height - $tile_height*$tile_rows - 50*$channel_height] \
  -rows $tile_rows \
  -cols [expr $tile_cols] \
  -min_channel [list $channel_width $channel_height] \
  -width $tile_width \
  -height $tile_height

