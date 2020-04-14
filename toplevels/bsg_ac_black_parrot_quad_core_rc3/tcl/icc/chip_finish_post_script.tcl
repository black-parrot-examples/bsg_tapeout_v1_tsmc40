puts "RM-Info: Running script [info script]\n"

source add_io_text.tcl

if { $ICC_IMPLEMENTATION_PHASE == "block" } {

  foreach_in_collection port [get_ports *] {
    create_text_on_port $port
  }
  
  foreach_in_collection shape [get_net_shapes -filter {route_type=="P/G Strap"&&layer==M10}] {
    create_text_on_shape $shape
  }

} elseif { $ICC_IMPLEMENTATION_PHASE == "top" } {

  foreach_in_collection pin [get_pins -all -of_objects [get_fp_cells -filter "is_io"] -filter "name==PAD||name==VDD||name==VSS||name==VDDPST||name==VSSPST"] {
    set io_cell [get_fp_cells -of_objects $pin]
    set pin_shape [get_pin_shapes [get_attribute $pin full_name]]
    set pin_bbox [get_attribute $pin_shape bbox]
    set pin_bbox_llx [lindex [lindex $pin_bbox 0] 0]
    set pin_bbox_lly [lindex [lindex $pin_bbox 0] 1]
    set pin_bbox_urx [lindex [lindex $pin_bbox 1] 0]
    set pin_bbox_ury [lindex [lindex $pin_bbox 1] 1]
    set text_orientation [get_attribute $io_cell orientation]
    set text_height 1
    set text_origin [list [expr ($pin_bbox_urx + $pin_bbox_llx) / 2.0] [expr ($pin_bbox_ury + $pin_bbox_lly) / 2.0]]
    set text_layer [get_attribute $pin_shape layer]_PIN_TEXT
    set text_string [get_attribute [get_nets -all -of_objects $pin] name]
    create_text -orient $text_orientation -height $text_height -layer $text_layer -origin $text_origin $text_string
  }

  set pin_bbox [list [list 0 187.5] [list 30 188.5]]
  add_io_text_custom [get_cells -all -filter "ref_name==PVDD2POC"] M4_PIN_TEXT "POC" $pin_bbox

  insert_pad_filler -cell $IO_FILLER

  source createNplace_cup_bondpads.tcl

  createNplace_cup_bondpads -inline_pad_ref_name PAD60GU_DS -stagger true -stagger_pad_ref_name PAD60NU_DS

}

puts "RM-Info: Completed script [info script]\n"
