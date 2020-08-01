puts "Flow-Info: Running script [info script]\n"

foreach_in_collection mim_master [get_plan_groups $ICC_MIM_MASTER_LIST] {
  copy_mim $mim_master
}

puts "Flow-Info: Completed script [info script]\n"
