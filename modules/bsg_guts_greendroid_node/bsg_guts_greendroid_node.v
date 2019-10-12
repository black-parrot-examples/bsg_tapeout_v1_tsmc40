module bsg_guts_greendroid_node #(
                                  parameter   tile_x_max_p      = `TILE_MAX_X
                                  , parameter tile_y_max_p      = `TILE_MAX_Y
                                  , parameter  lg_imem_words_p  = `LG_IMEM_WORDS
                                  , parameter  icache_enable_p  = 1
				  , parameter  ec_enable_p = 1
                                  , parameter south_side_only_p = 1
                                  , parameter num_ports_lp = (south_side_only_p == 0)
                                  ? (tile_x_max_p*2 + tile_y_max_p*2) : tile_x_max_p

                                  // standard comm link items
                                  , parameter num_channels_p=4
                                  , parameter channel_width_p=8
                                  , parameter enabled_at_start_vec_p=0
                                  , parameter master_p=0
                                  , parameter master_to_slave_speedup_p=100
                                  , parameter master_bypass_test_p=5'b00000
                                  , parameter nodes_lp=num_ports_lp
                                  , parameter uniqueness_p=0
                                  )
   (
    input core_clk_i
    , input async_reset_i
    , input io_master_clk_i

    // input from i/o
    , input  [num_channels_p-1:0]  io_clk_tline_i       // clk
    , input  [num_channels_p-1:0]  io_valid_tline_i
    , input  [channel_width_p-1:0] io_data_tline_i  [num_channels_p-1:0]
    , output [num_channels_p-1:0]  io_token_clk_tline_o // clk

    // out to i/o
    , output [num_channels_p-1:0]  im_clk_tline_o       // clk
    , output [num_channels_p-1:0]  im_valid_tline_o
    , output [channel_width_p-1:0] im_data_tline_o  [num_channels_p-1:0]
    , input  [num_channels_p-1:0]  token_clk_tline_i    // clk

    // note: generate by the master (FPGA) and sent to the slave (ASIC)
    // not used by slave (ASIC).
    , output reg im_slave_reset_tline_r_o

    // this signal is the post-calibration reset signal
    // synchronous to the core clock
    , output core_reset_o
    );

   // size of RingPacketType, in bytes
   localparam ring_bytes_lp  = 10;
   localparam ring_width_lp  = ring_bytes_lp*channel_width_p;

   // into nodes (fsb interface)
   wire [nodes_lp-1:0]       core_node_v_A;
   wire [ring_width_lp-1:0]  core_node_data_A   [nodes_lp-1:0];
   wire [ring_width_lp-1:0]  core_node_data_A_2 [nodes_lp-1:0];
   wire [nodes_lp-1:0]       core_node_ready_A;

    // into nodes (control)
   wire [nodes_lp-1:0]      core_node_en_r_lo;
   wire [nodes_lp-1:0]      core_node_reset_r_lo;

    // out of nodes (fsb interface)
   wire [nodes_lp-1:0]       core_node_v_B;
   wire [ring_width_lp-1:0]  core_node_data_B   [nodes_lp-1:0];
   wire [ring_width_lp-1:0]  core_node_data_B_2 [nodes_lp-1:0];
   wire [nodes_lp-1:0]       core_node_yumi_B;

   wire [nodes_lp-1:0]       core_node_reset_lo;

   if (master_p == 0)
     begin : z

        // ***********************************************************`
        // BEGIN BSG <--> MURN ADAPTER CODE

        logic [nodes_lp-1:0]       switch_2_blockValid;
        logic [nodes_lp-1:0]       switch_2_blockRetry;

        logic [nodes_lp-1:0]       block_2_switchValid;
        logic [nodes_lp-1:0]       block_2_switchRetry;

        bsg_murn_converter #(.nodes_p(nodes_lp)
                             ,.ring_width_p(ring_width_lp))
        bmc (.clk_i   (core_clk_i)
             ,.reset_i(core_node_reset_lo)
             ,.v_i    (core_node_v_A)
             ,.ready_o(core_node_ready_A)
             ,.data_i (core_node_data_A)

             ,.switch_2_blockValid(switch_2_blockValid) // o
             ,.switch_2_blockRetry(switch_2_blockRetry) // i
             ,.switch_2_blockData(core_node_data_A_2)

             ,.block_2_switchValid(block_2_switchValid) // i
             ,.block_2_switchRetry(block_2_switchRetry) // o
             ,.block_2_switchData(core_node_data_B_2)
             ,.v_o(core_node_v_B)
             ,.yumi_i(core_node_yumi_B)
             ,.data_o(core_node_data_B)
             );

        // END BSG <--> MURN ADAPTER CODE
        // ***********************************************************

        greendroid_node     #( .tile_x_max_p      (tile_x_max_p)
                               , .tile_y_max_p    (tile_y_max_p)
                               , .sys_type        (!south_side_only_p)
                               , .num_ports_lp    (nodes_lp)
                               , .lg_imem_words_p (lg_imem_words_p)
                               , .icache_enable_p (icache_enable_p)
			       , .ec_enable_p     (ec_enable_p)
			       , .last_node_pos_p (tile_x_max_p-1) // align position on network to 0
			       , .use_1R1W_pseudo_p(1) // use 1RW rams instead of 1R1W rams
                               )
        gd       ( .clk(core_clk_i)
          // one uniform reset for all of the tiles is necessary
                      , .reset_ext          (core_node_reset_lo[0])
                      , .switch_2_block     (core_node_data_A_2 [nodes_lp-1:0])
                      , .switch_2_blockValid(switch_2_blockValid[nodes_lp-1:0])
                      , .switch_2_blockRetry(switch_2_blockRetry[nodes_lp-1:0])
                      , .block_2_switch     (core_node_data_B_2 [nodes_lp-1:0])
                      , .block_2_switchValid(block_2_switchValid[nodes_lp-1:0])
                      , .block_2_switchRetry(block_2_switchRetry[nodes_lp-1:0])
                      , .enabled            (core_node_en_r_lo  [nodes_lp-1:0])
                      );

     end // block: slave
   else
     begin
        genvar                   i;
        for (i = 0; i < nodes_lp; i=i+1)
          begin : repl
             bsg_nonsynth_fsb_node_trace_replay #(.master_id_p(i)
                                                 ,.slave_id_p(i)
                                                 ) replay
             (.clk_i   (core_clk_i)
              ,.reset_i(core_node_reset_lo[i])
              ,.en_i   (core_node_en_r_lo [i])

              ,.v_i    (core_node_v_A     [i])
              ,.data_i (core_node_data_A  [i])
              ,.ready_o(core_node_ready_A [i])

              ,.v_o    (core_node_v_B     [i])
              ,.data_o (core_node_data_B  [i])
              ,.yumi_i (core_node_yumi_B  [i])
              ,.done_o ()
              );

          end
     end

   // should be unchanged
   bsg_comm_link #(.channel_width_p   (channel_width_p)
                   , .core_channels_p (ring_bytes_lp   )
                   , .link_channels_p (num_channels_p  )
                   , .nodes_p         (nodes_lp)
                   , .master_p        (master_p)
                   , .master_to_slave_speedup_p(master_to_slave_speedup_p)
                   , .snoop_vec_p( { nodes_lp { 1'b0 } })
                   // if master, enable at startup so that
                   // it can drive things
                   , .enabled_at_start_vec_p   (enabled_at_start_vec_p)
                   , .master_bypass_test_p     (master_bypass_test_p)
                   ) comm_link
     (.core_clk_i           (core_clk_i       )
      , .async_reset_i      (async_reset_i    )

      , .io_master_clk_i    (io_master_clk_i  )

      // into nodes (control)
      , .core_node_reset_r_o(core_node_reset_lo)
      , .core_node_en_r_o   (core_node_en_r_lo )

      // into nodes (fsb interface)
      , .core_node_v_o      (core_node_v_A    )
      , .core_node_data_o   (core_node_data_A )
      , .core_node_ready_i  (core_node_ready_A)

      // out of nodes (fsb interface)
      , .core_node_v_i   (core_node_v_B   )
      , .core_node_data_i(core_node_data_B)
      , .core_node_yumi_o(core_node_yumi_B)

      // in from i/o
      , .io_valid_tline_i    (io_valid_tline_i    )
      , .io_data_tline_i     (io_data_tline_i     )
      , .io_clk_tline_i      (io_clk_tline_i      )  // clk
      , .io_token_clk_tline_o(io_token_clk_tline_o)  // clk

      // out to i/o
      , .im_valid_tline_o(im_valid_tline_o)
      , .im_data_tline_o ( im_data_tline_o)
      , .im_clk_tline_o  (  im_clk_tline_o)        // clk

      , .im_slave_reset_tline_r_o (im_slave_reset_tline_r_o)
      , .token_clk_tline_i        (token_clk_tline_i       ) // clk

      ,.core_calib_reset_r_o(core_reset_o)

      // don't use
      , .core_async_reset_danger_o()
      );

endmodule
