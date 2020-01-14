puts "RM-Info: Running script [info script]\n"

if { [file exists [which $ICC_IN_PHYSICAL_ONLY_CELLS_CREATION_FILE]]   } { source $ICC_IN_PHYSICAL_ONLY_CELLS_CREATION_FILE   }
if { [file exists [which $ICC_IN_PHYSICAL_ONLY_CELLS_CONNECTION_FILE]] } { source $ICC_IN_PHYSICAL_ONLY_CELLS_CONNECTION_FILE }

if { [file exists [which $ICC_IN_PIN_PAD_PHYSICAL_CONSTRAINTS_FILE]] } {
  read_pin_pad_physical_constraints $ICC_IN_PIN_PAD_PHYSICAL_CONSTRAINTS_FILE
}

set keepout 30.0

create_floorplan \
  -control_type aspect_ratio \
  -core_aspect_ratio 1 \
  -core_utilization  0.75 \
  -left_io2core   $keepout \
  -bottom_io2core $keepout \
  -right_io2core  $keepout \
  -top_io2core    $keepout \
  -start_first_row \
  -keep_io_place

move_mw_cel_origin -to {-29.0 -29.0}
#insert_pad_filler -cell "PFILLER20 PFILLER10 PFILLER5 PFILLER1 PFILLER05 PFILLER0005"

#source createNplace_bondpads.tcl
#source createNplace_cup_bondpads.tcl
#
#createNplace_cup_bondpads -inline_pad_ref_name PAD60GU_DS -stagger true -stagger_pad_ref_name PAD60NU_DS

#source -echo add_io_text.tcl
#
#add_io_text M1_PIN_TEXT 5 portName
#
#set pin_bbox [list [list 2.205 75.755] [list 27.795 80.255]]
#add_io_text_custom [get_cells -all -filter "ref_name==PVDD2DGZ"] M8_PIN_TEXT "VDDPST" $pin_bbox
#add_io_text_custom [get_cells -all -filter "ref_name==PVSS2DGZ"] M8_PIN_TEXT "VSSPST" $pin_bbox
#
#set pin_bbox [list [list 0 187.5] [list 30 188.5]]
#add_io_text_custom [get_cells -all -filter "ref_name==PVDD2POC"] M4_PIN_TEXT "POC" $pin_bbox

puts "RM-Info: Completed script [info script]\n"
