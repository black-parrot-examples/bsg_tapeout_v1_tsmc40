puts "Info: Start script [info script]\n"

proc bsg_comm_link_timing_constraints { \
  iom_clk_name                          \
  ch_idx                                \
  ch_in_clk_port                        \
  ch_in_dv_port                         \
  ch_in_tkn_port                        \
  ch_out_clk_port                       \
  ch_out_dv_port                        \
  ch_out_tkn_port                       \
  input_cell_rise_fall_difference       \
  output_cell_rise_fall_difference      \
  uncertainty                           \
} {
  set iom_clk_period [get_attribute [get_clocks $iom_clk_name] period]
  set io_clk_period  [expr $iom_clk_period * 2.0]
  set tkn_clk_period $io_clk_period

  set max_io_skew_percent 2.5
  set max_io_skew_time [expr $max_io_skew_percent * $io_clk_period / 100.0]

  set sdi_clk sdi_${ch_idx}_clk
  create_clock -period $io_clk_period -name $sdi_clk $ch_in_clk_port
  set_clock_uncertainty $uncertainty [get_clocks $sdi_clk]
  #set_clock_latency 600 [get_clocks $sdi_clk]

  set sdo_tkn_clk sdo_${ch_idx}_tkn_clk
  create_clock -period $tkn_clk_period -name $sdo_tkn_clk $ch_out_tkn_port
  set_clock_uncertainty $uncertainty [get_clocks $sdo_tkn_clk]

  set max_input_delay [expr ($io_clk_period / 2.0) - $max_io_skew_time]
  set min_input_delay $max_io_skew_time

  set_input_delay -clock $sdi_clk -max $max_input_delay $ch_in_dv_port 
  set_input_delay -clock $sdi_clk -max $max_input_delay $ch_in_dv_port -add_delay -clock_fall
  set_input_delay -clock $sdi_clk -min $min_input_delay $ch_in_dv_port
  set_input_delay -clock $sdi_clk -min $min_input_delay $ch_in_dv_port -add_delay -clock_fall

set USE_GENERATED_CLOCK 0
if { $USE_GENERATED_CLOCK } {
  set sdo_clk sdo_${ch_idx}_clk
  create_generated_clock -edges {2 4 6} -master_clock $iom_clk_name -source [get_attribute [get_clocks $iom_clk_name] sources] -name $sdo_clk $ch_out_clk_port
  #set_clock_latency 1300 [get_clocks $sdo_clk]

  set max_output_delay [expr ($io_clk_period / 4.0) - $max_io_skew_time]
  set min_output_delay [expr $max_io_skew_time - ($io_clk_period / 4.0)]

  set_output_delay -clock $sdo_clk -max $max_output_delay $ch_out_dv_port 
  set_output_delay -clock $sdo_clk -max $max_output_delay $ch_out_dv_port -add_delay -clock_fall
  set_output_delay -clock $sdo_clk -min $min_output_delay $ch_out_dv_port 
  set_output_delay -clock $sdo_clk -min $min_output_delay $ch_out_dv_port -add_delay -clock_fall
} else {
  foreach_in_collection obj $ch_out_dv_port {
    set_data_check -from $ch_out_clk_port -to $obj -setup [expr $io_clk_period / 4.0 - $max_io_skew_time]
    set_data_check -from $ch_out_clk_port -to $obj -hold  [expr $io_clk_period / 4.0 - $max_io_skew_time]
    set_multicycle_path -end   -setup 1 -to $obj
    set_multicycle_path -start -hold  0 -to $obj
  }
}
}

puts "Info: Completed script [info script]\n"
