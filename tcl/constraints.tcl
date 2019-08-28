source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_tag.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_comm_link.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_clk_gen.constraints.tcl

########################################
##
## Clock Setup
##

set router_clk_name    "router_clk"     ;# core clock (everything that isn't a part of another clock is on this domain)
set io_master_clk_name "io_master_clk"  ;# 2x clock for DDR IO paths (1x clock generated from this clock)
set bp_clk_name        "bp_clk"         ;# main clock running block parrot
set tag_clk_name       "tag_clk"

set router_clk_period_ps       1666.0 ;# 600 MHz
set router_clk_uncertainty_per 3.0
## For clock uncertainty, we set it as the minimum of 3% of the clock period and 50 ps in 14nm
#set router_clk_uncertainty_ps  [expr min([expr ${router_clk_period_ps}*(${router_clk_uncertainty_per}/100.0)], 50)]
set router_clk_uncertainty_ps 20

set io_master_clk_period_ps       1666.0 ;# 600MHz
set io_master_clk_uncertainty_per 3.0
set io_master_clk_uncertainty_ps  [expr min([expr ${io_master_clk_period_ps}*(${io_master_clk_uncertainty_per}/100.0)], 50)]
set io_master_clk_uncertainty_ps  20
#set io_clk_uncertainty_ps         [expr min([expr 2*${io_master_clk_period_ps}*(${io_master_clk_uncertainty_per}/100.0)], 50)]
set io_clk_uncertainty_ps         20

set bp_clk_period_ps       1200
set bp_clk_uncertainty_per 3.0
#set bp_clk_uncertainty_ps  [expr min([expr ${bp_clk_period_ps}*(${bp_clk_uncertainty_per}/100.0)], 50)]
set bp_clk_uncertainty_ps 20

set oscillator_period_ps       250.0 ;# Raw oscillator frequency
set oscillator_uncertainty_per 3.0
#set oscillator_uncertainty_ps  [expr min([expr ${oscillator_period_ps}*(${oscillator_uncertainty_per}/100.0)], 50)]
set oscillator_uncertainty_ps  20
set ds_uncertainty_per         3.0
#set ds_uncertainty_ps          [expr min([expr 2*${oscillator_period_ps}*(${ds_uncertainty_per}/100.0)], 50)]
set ds_uncertainty_ps          20

set tag_clk_period_ps          6666.0 ;# 150 MHz
set tag_clk_uncertainty_per    3.0
#set tag_clk_uncertainty_ps     [expr min([expr ${tag_clk_period_ps}*(${tag_clk_uncertainty_per}/100.0)], 50)]
set tag_clk_uncertainty_ps     20

########################################
##
## BP Tile Constraints
##

if { ${DESIGN_NAME} == "bp_tile" } {

  set clk_name           ${bp_clk_name}
  set clk_period_ps      ${bp_clk_period_ps}
  set clk_uncertainty_ps ${bp_clk_uncertainty_ps}

  set input_delay_per  20.0
  set output_delay_per 20.0

  set input_delay_ps  [expr ${clk_period_ps}*(${input_delay_per}/100.0)]
  set output_delay_ps [expr ${clk_period_ps}*(${output_delay_per}/100.0)]

  set driving_lib_cell "SC7P5T_INVX2_SSC14SL"
  set load_lib_pin     "SC7P5T_INVX8_SSC14SL/A"

  # Reg2Reg
  create_clock -period ${clk_period_ps} -name ${clk_name} [get_ports clk_i]
  set_clock_uncertainty ${clk_uncertainty_ps} [get_clocks ${clk_name}]

  # In2Reg
  set all_input_pins [remove_from_collection [all_inputs] [get_ports clk_i]]
  set_driving_cell -no_design_rule -lib_cell ${driving_lib_cell} ${all_input_pins}
  set_input_delay ${input_delay_ps} -clock ${clk_name} ${all_input_pins}

  # Reg2Out
  set all_output_pins [all_outputs]
  set_load [load_of [get_lib_pin */${load_lib_pin}]] ${all_output_pins}
  set_output_delay ${output_delay_ps} -clock ${clk_name} ${all_output_pins}

  #  Do not constrain unused regfile write-read same address behavior
  #set_false_path -from [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem0"] -filter "name=~CLKA"] \
  #               -to   [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem0"] -filter "name=~CLKB"]
  #set_false_path -from [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem0"] -filter "name=~CLKB"] \
  #               -to   [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem0"] -filter "name=~CLKA"]
  #set_false_path -from [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem1"] -filter "name=~CLKA"] \
  #               -to   [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem1"] -filter "name=~CLKB"]
  #set_false_path -from [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem1"] -filter "name=~CLKB"] \
  #               -to   [get_pins -of_objects [get_cells -hier -filter "ref_name=~gf14_*1r1w* && full_name=~*mem1"] -filter "name=~CLKA"]
  set_false_path -from [get_ports my_*]

  # Derate
  set cells_to_derate [list]
  append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~gf14_*"]
  append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~IN12LP_*"]
  if { [sizeof $cells_to_derate] > 0 } {
    foreach_in_collection cell $cells_to_derate {
      set_timing_derate -cell_delay -early 0.97 $cell
      set_timing_derate -cell_delay -late  1.03 $cell
      set_timing_derate -cell_check -early 0.97 $cell
      set_timing_derate -cell_check -late  1.03 $cell
    }
  }
  #report_timing_derate


########################################
##
## Top-level Constraints
##

} elseif { ${DESIGN_NAME} == "bsg_chip" } {

  set_app_var timing_enable_multiple_clocks_per_reg true

  #set_register_merging [get_cells -of [get_nets bp_complex/vc_reset_r]]   false
  #set_register_merging [get_cells -of [get_nets bp_complex/mc/reset_i_r]] false

  bsg_tag_clock_create ${tag_clk_name} bsg_tag_clk_i/Y bsg_tag_data_i/Y bsg_tag_en_i/Y ${tag_clk_period_ps} ${tag_clk_uncertainty_ps}

  bsg_clk_gen_clock_create clk_gen_pd/clk_gen[0].clk_gen_inst/ ${bp_clk_name}        ${oscillator_period_ps} ${bp_clk_period_ps}        ${oscillator_uncertainty_ps} ${ds_uncertainty_ps} ${bp_clk_uncertainty_ps}
  bsg_clk_gen_clock_create clk_gen_pd/clk_gen[1].clk_gen_inst/ ${io_master_clk_name} ${oscillator_period_ps} ${io_master_clk_period_ps} ${oscillator_uncertainty_ps} ${ds_uncertainty_ps} ${io_master_clk_uncertainty_ps}
  bsg_clk_gen_clock_create clk_gen_pd/clk_gen[2].clk_gen_inst/ ${router_clk_name}    ${oscillator_period_ps} ${router_clk_period_ps}    ${oscillator_uncertainty_ps} ${ds_uncertainty_ps} ${router_clk_uncertainty_ps}

  create_clock -period ${oscillator_period_ps} -name bp_clk_ext [get_ports p_clk_A_i]
  set_clock_uncertainty $oscillator_uncertainty_ps [get_clocks bp_clk_ext]

  create_clock -period ${oscillator_period_ps} -name io_master_clk_ext [get_ports p_clk_B_i]
  set_clock_uncertainty $oscillator_uncertainty_ps [get_clocks io_master_clk_ext]

  create_clock -period ${oscillator_period_ps} -name router_clk_ext [get_ports p_clk_C_i]
  set_clock_uncertainty $oscillator_uncertainty_ps [get_clocks router_clk_ext]

  # Comm Link CH0
  #=================
  set ch0_in_clk_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_clk_i]] -filter "name==Y"]
  set ch0_in_dv_port   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_*_i]] -filter "name==Y"] $ch0_in_clk_port]
  set ch0_in_tkn_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_tkn_o]] -filter "name==DATA"]
  set ch0_out_clk_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_clk_o]] -filter "name==DATA"]
  set ch0_out_dv_port  [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_*_o]] -filter "name==DATA"] $ch0_out_clk_port]
  set ch0_out_tkn_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_tkn_i]] -filter "name==Y"]
  
  bsg_comm_link_timing_constraints \
    ${io_master_clk_name}          \
    "a"                            \
    $ch0_in_clk_port               \
    $ch0_in_dv_port                \
    $ch0_in_tkn_port               \
    $ch0_out_clk_port              \
    $ch0_out_dv_port               \
    $ch0_out_tkn_port              \
    100                            \
    100                            \
    $io_clk_uncertainty_ps

  # Comm Link CH1
  #=================
  set ch1_in_clk_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_co_clk_i]] -filter "name==Y"]
  set ch1_in_dv_port   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co_*_i]] -filter "name==Y"] $ch1_in_clk_port]
  set ch1_in_tkn_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_co_tkn_o]] -filter "name==DATA"]
  set ch1_out_clk_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_clk_o]] -filter "name==DATA"]
  set ch1_out_dv_port  [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_*_o]] -filter "name==DATA"] $ch1_out_clk_port]
  set ch1_out_tkn_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_tkn_i]] -filter "name==Y"]
  
  bsg_comm_link_timing_constraints \
    ${io_master_clk_name}          \
    "b"                            \
    $ch1_in_clk_port               \
    $ch1_in_dv_port                \
    $ch1_in_tkn_port               \
    $ch1_out_clk_port              \
    $ch1_out_dv_port               \
    $ch1_out_tkn_port              \
    100                            \
    100                           \
    $io_clk_uncertainty_ps

  # CDC Paths
  #=================
  update_timing
  set clocks [all_clocks]
  foreach_in_collection launch_clk $clocks {
    if { [get_attribute $launch_clk is_generated] } {
      set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk master_clock_name]"]
      append_to_collection launch_group [get_attribute $launch_clk master_clock]
    } else {
      set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk name]"]
      append_to_collection launch_group $launch_clk
    }
    foreach_in_collection latch_clk [remove_from_collection $clocks $launch_group] {
      set launch_period [get_attribute $launch_clk period]
      set latch_period [get_attribute $latch_clk period]
      set max_delay_ps [expr min($launch_period,$latch_period)/2]
      set_max_delay $max_delay_ps -from $launch_clk -to $latch_clk -ignore_clock_latency
      set_min_delay 0             -from $launch_clk -to $latch_clk -ignore_clock_latency
    }
  }

  # Ungrouping
  #=================
  set_ungroup [get_cells swizzle]

  set cells_to_derate [list]
  append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~gf14_*"]
  #append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~IN12LP_*"]
  if { [sizeof $cells_to_derate] > 0 } {
    foreach_in_collection cell $cells_to_derate {
      set_timing_derate -cell_delay -early 0.97 $cell
      set_timing_derate -cell_delay -late  1.03 $cell
      set_timing_derate -cell_check -early 0.97 $cell
      set_timing_derate -cell_check -late  1.03 $cell
    }
  }
  #report_timing_derate

  set_dont_touch [get_nets pwrok_lo*]
  set_dont_touch [get_nets iopwrok_lo*]
  set_dont_touch [get_nets retc_lo*]

########################################
##
## Unknown design...
##
} else {

  puts "BSG-error: No constraints found for design (${DESIGN_NAME})!"

}

