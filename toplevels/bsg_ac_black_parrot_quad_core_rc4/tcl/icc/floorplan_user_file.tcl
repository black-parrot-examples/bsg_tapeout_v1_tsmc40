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

puts "RM-Info: Completed script [info script]\n"
