puts "BSG-info: Running script [info script]\n"

set_dont_use [get_lib_cells */* -filter "name=~TIE*"]
set_dont_use [get_lib_cells */* -filter "name=~LH*"]
set_dont_use [get_lib_cells */* -filter "name=~LN*"]
set_dont_use [get_lib_cells */* -filter "name=~DEL*"]
set_dont_use [get_lib_cells */* -filter "name=~BUFTD*"]
set_dont_use [get_lib_cells */* -filter "name=~BHD*"]
set_dont_use [get_lib_cells */* -filter "name=~DFKCSND*"]

puts "BSG-info: Completed script [info script]\n"
