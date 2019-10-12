puts "RM-Info: Running script [info script]\n"

set all_pg_cells [get_fp_cells vdd_*]
append_to_collection all_pg_cells [get_fp_cells vss_*]
set pll_pg_cells [get_fp_cells "vdd_t_pll vss_t_pll"]

derive_pg_connection -power_net VDD_PLL -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -cells $pll_pg_cells
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -cells [remove_from_collection $all_pg_cells $pll_pg_cells]

#create_supply_net VDDPST
#create_supply_net VSSPST

set all_pg_cells [get_fp_cells v18_*]
append_to_collection all_pg_cells [get_fp_cells vzz_*]

derive_pg_connection -power_net VDDPST -power_pin VDDPST -ground_net VSSPST -ground_pin VSSPST -cells [get_fp_cells $all_pg_cells]

puts "RM-Info: Completed script [info script]\n"
