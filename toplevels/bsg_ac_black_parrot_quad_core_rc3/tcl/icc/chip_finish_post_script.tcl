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

  ## Add text labels on I/O ports for LVS
  foreach_in_collection pin [get_pins -all -of_objects [get_fp_cells -filter "is_io"] -filter "name==PAD||name==VDD||name==VSS||name==VDDPST||name==VSSPST"] {
    create_text_on_pin $pin
  }

  set pin_bbox [list [list 0 187.5] [list 30 188.5]]
  add_io_text_custom [get_cells -all -filter "ref_name==PVDD2POC"] M4_PIN_TEXT "POC" $pin_bbox

  ## Fill gaps between I/O cells
  insert_pad_filler -cell $IO_FILLER

  ## Add bond pads
  source createNplace_cup_bondpads.tcl

  createNplace_cup_bondpads -inline_pad_ref_name PAD60GU_DS -stagger true -stagger_pad_ref_name PAD60NU_DS

}

puts "RM-Info: Completed script [info script]\n"
