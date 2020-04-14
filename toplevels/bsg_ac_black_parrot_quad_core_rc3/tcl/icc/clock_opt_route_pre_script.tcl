puts "Flow-Info: Running script [info script]\n"

create_route_guide -coordinate [get_attribute [get_die_area] bbox] -no_signal_layers "M9 M10"

puts "Flow-Info: Completed script [info script]\n"
