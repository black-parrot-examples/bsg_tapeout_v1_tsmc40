puts "Flow-Info: Running script [info script]\n"

set tile_height [get_attribute [get_core_area] tile_height]

# define plan groups for bp tiles
foreach_in_collection tile [get_cells $::env(BP_HIER_CELLS)] {
  set bp_tile_name [get_attribute $tile full_name]
  set va [get_voltage_area $bp_tile_name/PD]
  #set bp_tile_pg_llx [expr [get_attribute $va bbox_llx] - $tile_height]
  #set bp_tile_pg_lly [expr [get_attribute $va bbox_lly] - $tile_height]
  #set bp_tile_pg_urx [expr [get_attribute $va bbox_urx] + $tile_height]
  #set bp_tile_pg_ury [expr [get_attribute $va bbox_ury] + $tile_height]
  #create_plan_groups $tile -cycle_color -coordinate "$bp_tile_pg_llx $bp_tile_pg_lly $bp_tile_pg_urx $bp_tile_pg_ury"
  create_plan_groups $tile -cycle_color -coordinate [get_attribute $va bbox] -is_fixed
}

# define plan groups for cache
#foreach_in_collection cache [get_cells $::env(VC_HIER_CELLS)] {
#  set cache_name [get_attribute $cache full_name]
#  create_plan_groups $cache -cycle_color -coordinate [get_attribute [get_voltage_area $cache_name/PD] bbox]
#}

puts "Flow-Info: Completed script [info script]\n"
