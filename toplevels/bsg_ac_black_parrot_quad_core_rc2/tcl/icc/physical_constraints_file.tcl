puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

set macro_keepout $tile_height
set_keepout_margin -all_macros -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout]

set_attribute [get_cells -all -filter "mask_layout_type==io_pad"] is_fixed true
set_attribute [get_cells -all -filter "mask_layout_type==corner_pad"] is_fixed true

puts "Flow-Info: Completed script [info script]\n"
