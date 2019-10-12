puts "Info: Start script [info script]\n"

proc bsg_dmc_timing_constraints { \
  ui_clk_name                     \
  dfi_clk_1x_name                 \
  dfi_clk_2x_name                 \
  ck_p_port                       \
  ck_n_port                       \
  dqs0_port                       \
  dqs1_port                       \
  dqs2_port                       \
  dqs3_port                       \
  dm0_port                        \
  dm1_port                        \
  dm2_port                        \
  dm3_port                        \
  dq0_ports                       \
  dq1_ports                       \
  dq2_ports                       \
  dq3_ports                       \
  ctrl_ports                      \
} {
  ##################################################################
  #     THE CLOCKS INSIDED DRAM CONTROLLER
  set dfi_clk_period [expr [get_attribute [get_clocks $dfi_clk_2x_name] period] * 2.0]
  set dfi_clk_source [get_attribute [get_clocks $dfi_clk_1x_name] sources]

  create_clock -period $dfi_clk_period \
               -name dqs0              \
               $dqs0_port

  create_clock -period $dfi_clk_period \
               -name dqs1              \
               $dqs1_port

  create_clock -period $dfi_clk_period \
               -name dqs2              \
               $dqs2_port

  create_clock -period $dfi_clk_period \
               -name dqs3              \
               $dqs3_port

  set quarter_cycle [expr [get_attribute [get_clocks dqs0] period] / 4.0]

  create_generated_clock -name dqs0_dly \
                         -edges {1 2 3} \
                         -edge_shift [list $quarter_cycle $quarter_cycle $quarter_cycle] \
                         -source [get_pins -of_objects [get_cells -of_objects [get_nets -of_objects [get_attribute [get_clocks dqs0] sources]]] -filter "direction==out"]  \
                         [get_pins -leaf -of_objects [get_nets -hierarchical dly_clk_o[0]] -filter "direction==out"]

  create_generated_clock -name dqs1_dly \
                         -edges {1 2 3} \
                         -edge_shift [list $quarter_cycle $quarter_cycle $quarter_cycle] \
                         -source [get_pins -of_objects [get_cells -of_objects [get_nets -of_objects [get_attribute [get_clocks dqs1] sources]]] -filter "direction==out"]  \
                         [get_pins -leaf -of_objects [get_nets -hierarchical dly_clk_o[1]] -filter "direction==out"]

  create_generated_clock -name dqs2_dly \
                         -edges {1 2 3} \
                         -edge_shift [list $quarter_cycle $quarter_cycle $quarter_cycle] \
                         -source [get_pins -of_objects [get_cells -of_objects [get_nets -of_objects [get_attribute [get_clocks dqs2] sources]]] -filter "direction==out"]  \
                         [get_pins -leaf -of_objects [get_nets -hierarchical dly_clk_o[2]] -filter "direction==out"]

  create_generated_clock -name dqs3_dly \
                         -edges {1 2 3} \
                         -edge_shift [list $quarter_cycle $quarter_cycle $quarter_cycle] \
                         -source [get_pins -of_objects [get_cells -of_objects [get_nets -of_objects [get_attribute [get_clocks dqs3] sources]]] -filter "direction==out"]  \
                         [get_pins -leaf -of_objects [get_nets -hierarchical dly_clk_o[3]] -filter "direction==out"]

  create_generated_clock -name ddr_ck_p -divide_by 1         -source $dfi_clk_source -master_clock [get_clocks $dfi_clk_1x_name] $ck_p_port
  create_generated_clock -name ddr_ck_n -divide_by 1 -invert -source $dfi_clk_source -master_clock [get_clocks $dfi_clk_1x_name] $ck_n_port

  set_clock_latency 2.5 [get_clocks ddr_ck*]
  set_clock_latency 1.1 -source [get_clocks dqs0_dly]
  set_clock_latency 1.1 -source [get_clocks dqs1_dly]
  set_clock_latency 1.1 -source [get_clocks dqs2_dly]
  set_clock_latency 1.1 -source [get_clocks dqs3_dly]

  #############################################################################################
  ## address and command interface constraints
  set_output_delay [expr  $dfi_clk_period * 0.1]                          $ctrl_ports -clock [get_clocks ddr_ck_p] -max
  set_output_delay [expr -$dfi_clk_period * 0.1]                          $ctrl_ports -clock [get_clocks ddr_ck_p] -min
  ## input constraints
  set_input_delay  [expr  [get_attribute [get_clocks dqs0] period] * 0.1] $dq0_ports  -clock [get_clocks dqs0]     -max
  set_input_delay  [expr -[get_attribute [get_clocks dqs0] period] * 0.1] $dq0_ports  -clock [get_clocks dqs0]     -min
  set_input_delay  [expr  [get_attribute [get_clocks dqs1] period] * 0.1] $dq1_ports  -clock [get_clocks dqs1]     -max
  set_input_delay  [expr -[get_attribute [get_clocks dqs1] period] * 0.1] $dq1_ports  -clock [get_clocks dqs1]     -min
  set_input_delay  [expr  [get_attribute [get_clocks dqs2] period] * 0.1] $dq0_ports  -clock [get_clocks dqs2]     -max
  set_input_delay  [expr -[get_attribute [get_clocks dqs2] period] * 0.1] $dq0_ports  -clock [get_clocks dqs2]     -min
  set_input_delay  [expr  [get_attribute [get_clocks dqs3] period] * 0.1] $dq1_ports  -clock [get_clocks dqs3]     -max
  set_input_delay  [expr -[get_attribute [get_clocks dqs3] period] * 0.1] $dq1_ports  -clock [get_clocks dqs3]     -min
  ## output constraints
  foreach_in_collection from_obj $dqs0_port {
    foreach_in_collection to_obj [concat $dq0_ports $dm0_port] {
      set_data_check -from $from_obj -to $to_obj [expr $dfi_clk_period * 0.2]
      set_multicycle_path -end -setup 1 -to $to_obj
      set_multicycle_path -start -hold 0 -to $to_obj
    }
  }

  foreach_in_collection from_obj $dqs1_port {
    foreach_in_collection to_obj [concat $dq1_ports $dm1_port] {
      set_data_check -from $from_obj -to $to_obj [expr $dfi_clk_period * 0.2]
      set_multicycle_path -end -setup 1 -to $to_obj
      set_multicycle_path -start -hold 0 -to $to_obj
    }
  }

  foreach_in_collection from_obj $dqs2_port {
    foreach_in_collection to_obj [concat $dq2_ports $dm2_port] {
      set_data_check -from $from_obj -to $to_obj [expr $dfi_clk_period * 0.2]
      set_multicycle_path -end -setup 1 -to $to_obj
      set_multicycle_path -start -hold 0 -to $to_obj
    }
  }

  foreach_in_collection from_obj $dqs3_port {
    foreach_in_collection to_obj [concat $dq3_ports $dm3_port] {
      set_data_check -from $from_obj -to $to_obj [expr $dfi_clk_period * 0.2]
      set_multicycle_path -end -setup 1 -to $to_obj
      set_multicycle_path -start -hold 0 -to $to_obj
    }
  }
}

puts "Info: Completed script [info script]\n"
