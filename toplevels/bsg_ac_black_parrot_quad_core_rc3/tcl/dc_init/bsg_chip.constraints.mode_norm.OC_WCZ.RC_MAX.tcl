puts "BSG-info: Running script [info script]\n"

source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_tag.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_clk_gen.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_comm_link.constraints.tcl

source clock_variables.tcl

bsg_tag_clock_create $TAG_CLK_NAME bsg_tag_clk_i/C bsg_tag_data_i/C bsg_tag_en_i/C $TAG_CLK_PERIOD

bsg_clk_gen_clock_create clk_gen_pd/clk_gen_0__clk_gen_inst/ $CORE_CLK_NAME ${OSC_PERIOD} $CORE_CLK_PERIOD
bsg_clk_gen_clock_create clk_gen_pd/clk_gen_1__clk_gen_inst/ $IOM_CLK_NAME      ${OSC_PERIOD} $IOM_CLK_PERIOD
bsg_clk_gen_clock_create clk_gen_pd/clk_gen_2__clk_gen_inst/ $ROUTER_CLK_NAME   ${OSC_PERIOD} $ROUTER_CLK_PERIOD

create_clock -period $OSC_PERIOD -name ${CORE_CLK_NAME}_ext [get_ports p_clk_A_i]
create_clock -period $OSC_PERIOD -name ${IOM_CLK_NAME}_ext      [get_ports p_clk_B_i]
create_clock -period $OSC_PERIOD -name ${ROUTER_CLK_NAME}_ext   [get_ports p_clk_C_i]

set ch0_in_clk_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_clk_i]] -filter "name==C"]
set ch0_in_dv_port   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_*_i]] -filter "name==C"] $ch0_in_clk_port]
set ch0_in_tkn_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_tkn_o]] -filter "name==I"]
set ch0_out_clk_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_clk_o]] -filter "name==I"]
set ch0_out_dv_port  [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_*_o]] -filter "name==I"] $ch0_out_clk_port]
set ch0_out_tkn_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_tkn_i]] -filter "name==C"]

bsg_comm_link_timing_constraints \
  iom_clk                        \
  "a"                            \
  $ch0_in_clk_port               \
  $ch0_in_dv_port                \
  $ch0_in_tkn_port               \
  $ch0_out_clk_port              \
  $ch0_out_dv_port               \
  $ch0_out_tkn_port

set ch1_in_clk_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_co_clk_i]] -filter "name==C"]
set ch1_in_dv_port   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co_*_i]] -filter "name==C"] $ch1_in_clk_port]
set ch1_in_tkn_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_co_tkn_o]] -filter "name==I"]
set ch1_out_clk_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_clk_o]] -filter "name==I"]
set ch1_out_dv_port  [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_*_o]] -filter "name==I"] $ch1_out_clk_port]
set ch1_out_tkn_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_tkn_i]] -filter "name==C"]

bsg_comm_link_timing_constraints \
  iom_clk                        \
  "b"                            \
  $ch1_in_clk_port               \
  $ch1_in_dv_port                \
  $ch1_in_tkn_port               \
  $ch1_out_clk_port              \
  $ch1_out_dv_port               \
  $ch1_out_tkn_port

set_app_var case_analysis_propagate_through_icg true 
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

foreach_in_collection adt [get_cells -hier adt] {
  set path [get_attribute $adt full_name]
  set_disable_timing [get_cells $path/M1]
  set_disable_timing [get_cells $path/sel_r_reg_0]
}

foreach_in_collection cdt [get_cells -hier cdt] {
  set path [get_attribute $cdt full_name]
  set_disable_timing [get_cells $path/M1]
}

foreach_in_collection fdt [get_cells -hier fdt] {
  set path [get_attribute $fdt full_name]
  set_disable_timing [get_cells $path/M2]
}

foreach_in_collection clk [all_clocks] {
  set clock_uncertainty 0.1
  set_clock_uncertainty $clock_uncertainty $clk
}

set_voltage $PDK_CORE_VOLTAGE(min) -object_list VDD
set_voltage $PDK_CORE_VOLTAGE(min) -object_list VDD_PLL
set_voltage 0.00 -object_list VSS
set_voltage $PDK_IO_VOLTAGE(min) -object_list VDDPST
set_voltage 0.00 -object_list VSSPST

puts "BSG-info: Completed script [info script]\n"

