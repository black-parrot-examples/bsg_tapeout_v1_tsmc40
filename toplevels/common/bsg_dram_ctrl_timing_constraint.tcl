puts "Info: Start script [info script]\n"

proc bsg_dram_ctrl_timing_constraint {   \
                dram_io_skew            \
                ui_clk_name           \
                dfi_clk_name            \
                dfi_2x_clk_name          \
                ck_p_port           \
                ck_n_port           \
                dqs0_port               \
                dqs1_port               \
                dm0_port               \
                dm1_port               \
                dq0_ports               \
                dq1_ports               \
                ctrl_ports             \
} {
       ##################################################################
        #     THE CLOCKS INSIDED DRAM CONTROLLER
        set dfi_clock_period [ expr ( [get_attribute [get_clocks $dfi_2x_clk_name] period]*2 )]
        set dfi_clock_source [get_attribute [get_clocks $dfi_clk_name] sources ] 
        #this is the lataency from the PAD to the register pin, will be ignored after clock tree synthesis
        set dq_clock_latency 2.89

        create_clock            -period    $dfi_clock_period \
                                -name      DQS0                                              \
                                $dqs0_port 
        
        create_clock            -period    $dfi_clock_period\
                                -name      DQS1                                              \
                                $dqs1_port
                     
        create_generated_clock -name            DDR_CK_P      \
                               -divide_by       1             \
                               -source          $dfi_clock_source\
                                                $ck_p_port

        create_generated_clock -name            DDR_CK_N      \
                               -divide_by       1             \
                               -source          $dfi_clock_source \
                               -invert                          \
                                                $ck_n_port 
        
        set_clock_latency 3.0                   -source -early [get_clocks DDR_CK*]
        set_clock_latency 1.5                   -source -late  [get_clocks DDR_CK*]
        set_clock_latency $dq_clock_latency     [get_clocks DQS*]
       
        ######### MOVED TO THE CHIP TIMING CONSTRAINS 
        #set_clock_groups -asynchronous -group [get_clocks $ui_clk_name]
        #set_clock_groups -asynchronous -group [get_clocks DQS*]


        #############################################################################################
        # INPUT/OUTPUT DELAY
        set_output_delay $dram_io_skew             \
                        $ctrl_ports      \
                        -clock [get_clocks DDR_CK_P] \
                        -max

        set_output_delay 0.0             \
                        $ctrl_ports      \
                        -clock [get_clocks DDR_CK_P] \
                        -min
        
        set_input_delay $dram_io_skew   $dq0_ports  -clock [get_clocks DQS0] -max
        set_input_delay 0.0             $dq0_ports  -clock [get_clocks DQS0] -min
        set_input_delay $dram_io_skew   $dq1_ports  -clock [get_clocks DQS1] -max
        set_input_delay 0.0             $dq1_ports  -clock [get_clocks DQS1] -min
        
        ##############################################################################################
        # set strobe signal constrains

        foreach_in_collection from_obj $dqs0_port {
          foreach_in_collection to_obj [concat $dq0_ports $dm0_port] {
            set_data_check -from $from_obj -to $to_obj 1.0
            set_multicycle_path -end -setup 1 -to $to_obj
            set_multicycle_path -start -hold 0 -to $to_obj
          }
        }
       
        foreach_in_collection from_obj $dqs1_port {
          foreach_in_collection to_obj [concat $dq1_ports $dm1_port] {
            set_data_check -from $from_obj -to $to_obj 0.75
            set_multicycle_path -end -setup 1 -to $to_obj
            set_multicycle_path -start -hold 0 -to $to_obj
          }
        }
        
        #############################################################################################
        # set strobe signal constrains
#        set_register_merging [get_cells -hier tx_byte_slice] false
        #set_dont_touch [get_cells -filter "ref_name==PDB08DGZ"]
}
puts "Info: Completed script [info script]\n"
