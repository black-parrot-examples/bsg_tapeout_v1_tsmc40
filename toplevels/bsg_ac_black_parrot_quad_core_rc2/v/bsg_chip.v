`include "bsg_padmapping.v"
`include "bsg_iopad_macros.v"

//==============================================================================
//
// BSG CHIP
//
// This is the toplevel for the ASIC. This chip uses the UW BGA package found
// inside bsg_packaging/uw_bga. For physical design reasons, the input pins
// have been swizzled (ie. re-arranged) from their original meaning. We use the
// bsg_chip_swizzle_adapter in every ASIC to abstract away detail.
//

module bsg_chip
 import bp_common_pkg::*;
 import bp_common_aviary_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_chip_pkg::*;
 #(localparam bp_cfg_e cfg_p = e_bp_quad_core_cfg `declare_bp_proc_params(cfg_p))
`include "bsg_pinout.v"
`include "bsg_iopads.v"

  `declare_bsg_ready_and_link_sif_s(ct_width_gp, bsg_ready_and_link_sif_s);

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_lo;

  // Tag lines for clock generators
  bsg_tag_s       async_reset_tag_lines_lo;
  bsg_tag_s [2:0] osc_tag_lines_lo;
  bsg_tag_s [2:0] osc_trigger_tag_lines_lo;
  bsg_tag_s [2:0] ds_tag_lines_lo;
  bsg_tag_s [2:0] sel_tag_lines_lo;

  bsg_tag_s [bp_num_router_gp-1:0] router_core_tag_lines_lo;

  assign async_reset_tag_lines_lo = tag_lines_lo[0];
  assign osc_tag_lines_lo         = tag_lines_lo[3:1];
  assign osc_trigger_tag_lines_lo = tag_lines_lo[6:4];
  assign ds_tag_lines_lo          = tag_lines_lo[9:7];
  assign sel_tag_lines_lo         = tag_lines_lo[12:10];

  // Tag lines for io complex
  wire bsg_tag_s prev_link_io_tag_lines_lo   = tag_lines_lo[13];
  wire bsg_tag_s prev_link_core_tag_lines_lo = tag_lines_lo[14];
  wire bsg_tag_s prev_ct_core_tag_lines_lo   = tag_lines_lo[15];
  wire bsg_tag_s next_link_io_tag_lines_lo   = tag_lines_lo[16];
  wire bsg_tag_s next_link_core_tag_lines_lo = tag_lines_lo[17];
  wire bsg_tag_s next_ct_core_tag_lines_lo   = tag_lines_lo[18];
  assign router_core_tag_lines_lo            = tag_lines_lo[19+:bp_num_router_gp];
  //wire bsg_tag_s cfg_tag_line_lo             = tag_lines_lo[tag_num_clients_gp-2];
  wire bsg_tag_s bp_core_tag_line_lo         = tag_lines_lo[tag_num_clients_gp-1];

  // BSG tag master instance
  bsg_tag_master #(.els_p( tag_num_clients_gp )
                  ,.lg_width_p( tag_lg_max_payload_width_gp )
                  )
    btm
      (.clk_i      ( bsg_tag_clk_i_int )
      ,.data_i     ( bsg_tag_en_i_int ? bsg_tag_data_i_int : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines_lo )
      );

  //////////////////////////////////////////////////
  //
  // BSG Clock Generator Power Domain
  //

  logic bp_clk_lo;
  logic io_master_clk_lo;
  logic router_clk_lo;

  bsg_clk_gen_power_domain #(.num_clk_endpoint_p( clk_gen_num_endpoints_gp )
                            ,.ds_width_p( clk_gen_ds_width_gp )
                            ,.num_adgs_p( clk_gen_num_adgs_gp )
                            )
    clk_gen_pd
      (.async_reset_tag_lines_i ( async_reset_tag_lines_lo )
      ,.osc_tag_lines_i         ( osc_tag_lines_lo )
      ,.osc_trigger_tag_lines_i ( osc_trigger_tag_lines_lo )
      ,.ds_tag_lines_i          ( ds_tag_lines_lo )
      ,.sel_tag_lines_i         ( sel_tag_lines_lo )

      ,.ext_clk_i({ clk_C_i_int, clk_B_i_int, clk_A_i_int })

      ,.clk_o({ router_clk_lo, io_master_clk_lo, bp_clk_lo })
      );

  // Route the clock signals off chip
  logic [1:0]  clk_out_sel;
  logic        clk_out;

  assign clk_out_sel[0] = sel_0_i_int;
  assign clk_out_sel[1] = sel_1_i_int;
  assign clk_o_int      = clk_out;

  bsg_mux #(.width_p   ( 1 )
           ,.els_p     ( 4 )
           ,.balanced_p( 1 )
           ,.harden_p  ( 1 )
           )
    clk_out_mux
      (.data_i( {1'b0, bp_clk_lo, io_master_clk_lo, router_clk_lo} )
      ,.sel_i ( clk_out_sel )
      ,.data_o( clk_out )
      );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance
  //

  // Tag payload for bp control signals
  typedef struct packed { 
      logic reset;
      logic [wh_cord_width_gp-1:0] cord;
  } bp_tag_payload_s;

  // Tag payload for bp control signals
  bp_tag_payload_s bp_tag_data_lo;
  logic            bp_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_bp
      (.bsg_tag_i     ( bp_core_tag_line_lo )
      ,.recv_clk_i    ( bp_clk_lo )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( bp_tag_new_data_lo )
      ,.recv_data_r_o ( bp_tag_data_lo )
      );

  // Join the resets and cords
  logic [bp_num_router_gp-1:0]                       router_tag_reset_lo;
  logic [bp_num_router_gp-1:0][wh_cord_width_gp-1:0] router_tag_cord_lo;
  for (i = 0; i < bp_num_router_gp; i++)
    begin : router_tag_clients
      bp_tag_payload_s router_tag_data_lo;
      logic            router_tag_new_data_lo;
      bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
       btc_rtr
        (.bsg_tag_i      ( router_core_tag_lines_lo[i] )
         ,.recv_clk_i    ( router_clk_lo )
         ,.recv_reset_i  ( 1'b0 )
         ,.recv_new_r_o  ( router_tag_new_data_lo )
         ,.recv_data_r_o ( router_tag_data_lo )
         );
      assign router_tag_reset_lo[i] = router_tag_data_lo.reset;
      assign router_tag_cord_lo[i]  = router_tag_data_lo.cord;
    end
  wire router_reset_lo = |router_tag_reset_lo;
  wire [bp_num_mem_gp-1:0][wh_cord_width_gp-1:0]  mem_router_cord_lo  = router_tag_cord_lo[0+:bp_num_mem_gp];
  wire [bp_num_core_gp-1:0][wh_cord_width_gp-1:0] tile_router_cord_lo = router_tag_cord_lo[bp_num_mem_gp+:bp_num_core_gp];

  //////////////////////////////////////////////////
  //
  // Swizzle Adapter for Comm Link IO Signals
  //

  logic         ci_clk_li;
  logic         ci_v_li;
  logic [8:0]   ci_data_li;
  logic         ci_tkn_lo;

  logic         co_clk_lo;
  logic         co_v_lo;
  logic [8:0]   co_data_lo;
  logic         co_tkn_li;

  logic         ci2_clk_li;
  logic         ci2_v_li;
  logic [8:0]   ci2_data_li;
  logic         ci2_tkn_lo;

  logic         co2_clk_lo;
  logic         co2_v_lo;
  logic [8:0]   co2_data_lo;
  logic         co2_tkn_li;

  bsg_chip_swizzle_adapter
    swizzle
      ( // IO Port Side
       .port_ci_clk_i   (ci_clk_i_int)
      ,.port_ci_v_i     (ci_v_i_int)
      ,.port_ci_data_i  ({ci_8_i_int, ci_7_i_int, ci_6_i_int, ci_5_i_int, ci_4_i_int, ci_3_i_int, ci_2_i_int, ci_1_i_int, ci_0_i_int})
      ,.port_ci_tkn_o   (ci_tkn_o_int)

      ,.port_ci2_clk_o  (ci2_clk_o_int)
      ,.port_ci2_v_o    (ci2_v_o_int)
      ,.port_ci2_data_o ({ci2_8_o_int, ci2_7_o_int, ci2_6_o_int, ci2_5_o_int, ci2_4_o_int, ci2_3_o_int, ci2_2_o_int, ci2_1_o_int, ci2_0_o_int})
      ,.port_ci2_tkn_i  (ci2_tkn_i_int)

      ,.port_co_clk_i   (co_clk_i_int)
      ,.port_co_v_i     (co_v_i_int)
      ,.port_co_data_i  ({co_8_i_int, co_7_i_int, co_6_i_int, co_5_i_int, co_4_i_int, co_3_i_int, co_2_i_int, co_1_i_int, co_0_i_int})
      ,.port_co_tkn_o   (co_tkn_o_int)

      ,.port_co2_clk_o  (co2_clk_o_int)
      ,.port_co2_v_o    (co2_v_o_int)
      ,.port_co2_data_o ({co2_8_o_int, co2_7_o_int, co2_6_o_int, co2_5_o_int, co2_4_o_int, co2_3_o_int, co2_2_o_int, co2_1_o_int, co2_0_o_int})
      ,.port_co2_tkn_i  (co2_tkn_i_int)

      // Chip (Guts) Side
      ,.guts_ci_clk_o  (ci_clk_li)
      ,.guts_ci_v_o    (ci_v_li)
      ,.guts_ci_data_o (ci_data_li)
      ,.guts_ci_tkn_i  (ci_tkn_lo)

      ,.guts_co_clk_i  (co_clk_lo)
      ,.guts_co_v_i    (co_v_lo)
      ,.guts_co_data_i (co_data_lo)
      ,.guts_co_tkn_o  (co_tkn_li)

      ,.guts_ci2_clk_o (ci2_clk_li)
      ,.guts_ci2_v_o   (ci2_v_li)
      ,.guts_ci2_data_o(ci2_data_li)
      ,.guts_ci2_tkn_i (ci2_tkn_lo)

      ,.guts_co2_clk_i (co2_clk_lo)
      ,.guts_co2_v_i   (co2_v_lo)
      ,.guts_co2_data_i(co2_data_lo)
      ,.guts_co2_tkn_o (co2_tkn_li)
      );

  //////////////////////////////////////////////////
  //
  // BSG Chip IO Complex
  //

  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0]        prev_router_links_li, prev_router_links_lo;
  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0]        next_router_links_li, next_router_links_lo;

  bsg_chip_io_complex_links_ct_fifo #(.link_width_p                        ( link_width_gp         )
                                     ,.link_channel_width_p                ( link_channel_width_gp )
                                     ,.link_num_channels_p                 ( link_num_channels_gp  )
                                     ,.link_lg_fifo_depth_p                ( link_lg_fifo_depth_gp )
                                     ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_gp )
                                     ,.ct_width_p                          ( ct_width_gp )
                                     ,.ct_num_in_p                         ( ct_num_in_gp )
                                     ,.ct_remote_credits_p                 ( ct_remote_credits_gp )
                                     ,.ct_use_pseudo_large_fifo_p          ( ct_use_pseudo_large_fifo_gp )
                                     ,.ct_lg_credit_decimation_p           ( ct_lg_credit_decimation_gp )
                                     ,.num_hops_p                          (1)
                                     )
   prev
     (.core_clk_i ( router_clk_lo )
      ,.io_clk_i  ( io_master_clk_lo )

      ,.link_io_tag_lines_i   ( prev_link_io_tag_lines_lo )
      ,.link_core_tag_lines_i ( prev_link_core_tag_lines_lo )
      ,.ct_core_tag_lines_i   ( prev_ct_core_tag_lines_lo )

      ,.ci_clk_i ( ci2_clk_li )
      ,.ci_v_i   ( ci2_v_li )
      ,.ci_data_i( ci2_data_li[link_channel_width_gp-1:0] )
      ,.ci_tkn_o ( ci2_tkn_lo )

      ,.co_clk_o ( co2_clk_lo )
      ,.co_v_o   ( co2_v_lo )
      ,.co_data_o( co2_data_lo[link_channel_width_gp-1:0] )
      ,.co_tkn_i ( co2_tkn_li )

      ,.links_i  ( prev_router_links_li ) 
      ,.links_o  ( prev_router_links_lo )
      );

  bsg_chip_io_complex_links_ct_fifo #(.link_width_p                        ( link_width_gp         )
                                     ,.link_channel_width_p                ( link_channel_width_gp )
                                     ,.link_num_channels_p                 ( link_num_channels_gp  )
                                     ,.link_lg_fifo_depth_p                ( link_lg_fifo_depth_gp )
                                     ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_gp )
                                     ,.ct_width_p                          ( ct_width_gp )
                                     ,.ct_num_in_p                         ( ct_num_in_gp )
                                     ,.ct_remote_credits_p                 ( ct_remote_credits_gp )
                                     ,.ct_use_pseudo_large_fifo_p          ( ct_use_pseudo_large_fifo_gp )
                                     ,.ct_lg_credit_decimation_p           ( ct_lg_credit_decimation_gp )
                                     ,.num_hops_p                          (1)
                                     )
   next
     (.core_clk_i ( router_clk_lo )
      ,.io_clk_i  ( io_master_clk_lo )

      ,.link_io_tag_lines_i   ( next_link_io_tag_lines_lo )
      ,.link_core_tag_lines_i ( next_link_core_tag_lines_lo )
      ,.ct_core_tag_lines_i   ( next_ct_core_tag_lines_lo )

      ,.ci_clk_i ( ci_clk_li )
      ,.ci_v_i   ( ci_v_li )
      ,.ci_data_i( ci_data_li[link_channel_width_gp-1:0] )
      ,.ci_tkn_o ( ci_tkn_lo )

      ,.co_clk_o ( co_clk_lo )
      ,.co_v_o   ( co_v_lo )
      ,.co_data_o( co_data_lo[link_channel_width_gp-1:0] )
      ,.co_tkn_i ( co_tkn_li )

      ,.links_i  ( next_router_links_li )
      ,.links_o  ( next_router_links_lo )
      );

  //////////////////////////////////////////////////
  //
  // BSG Chip BlackParrot
  //

  bsg_ready_and_link_sif_s bp_prev_cmd_link_li, bp_prev_cmd_link_lo;
  bsg_ready_and_link_sif_s bp_prev_resp_link_li, bp_prev_resp_link_lo;

  bsg_ready_and_link_sif_s bp_next_cmd_link_li, bp_next_cmd_link_lo;
  bsg_ready_and_link_sif_s bp_next_resp_link_li, bp_next_resp_link_lo;
  bp_chip #(.cfg_p(bp_cfg_gp))
    bp_chip
      (.core_clk_i  ( bp_clk_lo )
      ,.core_reset_i( bp_tag_data_lo.reset )

      // Currently synced to core clock
      ,.coh_clk_i  ( bp_clk_lo )
      ,.coh_reset_i( bp_tag_data_lo.reset )

      ,.mem_clk_i   ( router_clk_lo )
      ,.mem_reset_i ( router_reset_lo )

      ,.mem_cord_i ( mem_router_cord_lo )
      ,.tile_cord_i( tile_router_cord_lo )
      ,.mmio_cord_i( mem_router_cord_lo[mmio_x_pos_p] )
      ,.dram_cord_i( bp_tag_data_lo.cord )
      ,.host_cord_i( bp_tag_data_lo.cord )

      ,.prev_cmd_link_i( bp_prev_cmd_link_li )
      ,.prev_cmd_link_o( bp_prev_cmd_link_lo )

      ,.prev_resp_link_i( bp_prev_resp_link_li )
      ,.prev_resp_link_o( bp_prev_resp_link_lo )

      ,.next_cmd_link_i( bp_next_cmd_link_li )
      ,.next_cmd_link_o( bp_next_cmd_link_lo )

      ,.next_resp_link_i( bp_next_resp_link_li )
      ,.next_resp_link_o( bp_next_resp_link_lo )
      );

  assign prev_router_links_li[0] = bp_prev_cmd_link_lo;
  assign prev_router_links_li[1] = bp_prev_resp_link_lo;

  assign bp_prev_cmd_link_li  = prev_router_links_lo[0];
  assign bp_prev_resp_link_li = prev_router_links_lo[1];

  assign next_router_links_li[0] = bp_next_cmd_link_lo;
  assign next_router_links_li[1] = bp_next_resp_link_lo;

  assign bp_next_cmd_link_li  = next_router_links_lo[0];
  assign bp_next_resp_link_li = next_router_links_lo[1];

endmodule

