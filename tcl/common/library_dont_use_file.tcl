puts "BSG-info: Running script [info script]\n"

foreach_in_collection lib [get_libs tcbn*] {
  set lib_name [get_attribute $lib name]
  set dont_use_lib_cells [get_lib_cells $lib_name/TIE*]
  if { [sizeof $dont_use_lib_cells] > 0 } { set_dont_use $dont_use_lib_cells }
  set dont_use_lib_cells [get_lib_cells $lib_name/L*]
  if { [sizeof $dont_use_lib_cells] > 0 } { set_dont_use $dont_use_lib_cells }
  set dont_use_lib_cells [get_lib_cells $lib_name/DEL*]
  if { [sizeof $dont_use_lib_cells] > 0 } { set_dont_use $dont_use_lib_cells }
  set dont_use_lib_cells [get_lib_cells $lib_name/BUFTD*]
  if { [sizeof $dont_use_lib_cells] > 0 } { set_dont_use $dont_use_lib_cells }
  set dont_use_lib_cells [get_lib_cells $lib_name/BHD*]
  if { [sizeof $dont_use_lib_cells] > 0 } { set_dont_use $dont_use_lib_cells }
}    

puts "BSG-info: Completed script [info script]\n"
