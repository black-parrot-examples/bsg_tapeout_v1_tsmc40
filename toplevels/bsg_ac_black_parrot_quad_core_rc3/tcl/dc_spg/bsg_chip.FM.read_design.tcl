puts "BSG-info: Running script [info script]\n"

foreach design $HIERARCHICAL_DESIGNS {
  set_app_var search_path "$::env(DC_INIT_RUN_DIR)/${design}/results ${search_path}"
}
source -echo -verbose fm.read_design.tcl

puts "BSG-info: Completed script [info script]\n"

