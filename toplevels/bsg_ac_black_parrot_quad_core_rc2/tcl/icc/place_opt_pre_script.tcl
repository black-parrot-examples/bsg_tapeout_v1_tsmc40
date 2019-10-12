puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

set macro_keepout $tile_height
set_keepout_margin -all_macros -outer [list $macro_keepout $macro_keepout $macro_keepout $macro_keepout]

add_tap_cell_array -master_cell_name TAPCELLBWP -pattern stagger_every_other_row -distance 40 -tap_cell_identifier {subcnt} -tap_cell_separator {_} -respect_keepout

set physopt_new_fix_constants true
foreach_in_collection lib [get_libs tcbn*] {
  set lib_name [get_attribute $lib name]
  set dont_use_lib_cells [get_lib_cells $lib_name/TIE*]
  remove_attribute $dont_use_lib_cells dont_use
  remove_attribute $dont_use_lib_cells dont_touch
  set_attribute [get_lib_pins -of_objects $dont_use_lib_cells] max_fanout 8
}

set_lib_cell_spacing_label -names {X} -left_lib_cells {*} -right_lib_cells {*}
set_spacing_label_rule -labels {X X} {1 1}

puts "Flow-Info: Completed script [info script]\n"
