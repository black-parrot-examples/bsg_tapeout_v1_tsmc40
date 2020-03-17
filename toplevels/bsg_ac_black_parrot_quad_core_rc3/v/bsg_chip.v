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
 import bp_me_pkg::*;
 import bp_cce_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_wormhole_router_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_dmc_pkg::*;
 import bsg_chip_pkg::*;
 #(localparam bp_params_e bp_params_p = e_bp_quad_core_cfg `declare_bp_proc_params(bp_params_p))
`include "bsg_pinout.v"
`include "bsg_iopads.v"

  localparam flit_width_p = mem_noc_flit_width_p;
  `declare_bsg_ready_and_link_sif_s(mem_noc_flit_width_p, bsg_ready_and_link_sif_s);
  `declare_bsg_ready_and_link_sif_s(link_width_gp-2, ct_link_sif_s);

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_lo;

  // Tag lines for clock generators
  bsg_tag_s       async_reset_tag_lines_lo;
  bsg_tag_s [3:0] osc_tag_lines_lo;
  bsg_tag_s [3:0] osc_trigger_tag_lines_lo;
  bsg_tag_s [3:0] ds_tag_lines_lo;
  bsg_tag_s [3:0] sel_tag_lines_lo;

  assign async_reset_tag_lines_lo = tag_lines_lo[0];
  assign osc_tag_lines_lo[2:0]         = tag_lines_lo[3:1];
  assign osc_trigger_tag_lines_lo[2:0] = tag_lines_lo[6:4];
  assign ds_tag_lines_lo[2:0]          = tag_lines_lo[9:7];
  assign sel_tag_lines_lo[2:0]         = tag_lines_lo[12:10];

  // Tag lines for io complex
  wire bsg_tag_s prev_link_io_tag_lines_lo   = tag_lines_lo[13];
  wire bsg_tag_s prev_link_core_tag_lines_lo = tag_lines_lo[14];
  wire bsg_tag_s prev_ct_core_tag_lines_lo   = tag_lines_lo[15];
  wire bsg_tag_s next_link_io_tag_lines_lo   = tag_lines_lo[16];
  wire bsg_tag_s next_link_core_tag_lines_lo = tag_lines_lo[17];
  wire bsg_tag_s next_ct_core_tag_lines_lo   = tag_lines_lo[18];
  wire bsg_tag_s bp_core_tag_lines_lo        = tag_lines_lo[19];
  wire bsg_tag_s host_core_tag_lines_lo      = tag_lines_lo[20];
  wire bsg_tag_s router_tag_lines_lo         = tag_lines_lo[21];

  // Tag lines for dmc
  assign osc_tag_lines_lo[3]                         = tag_lines_lo[22];
  assign osc_trigger_tag_lines_lo[3]                 = tag_lines_lo[23];
  assign ds_tag_lines_lo[3]                          = tag_lines_lo[24];
  assign sel_tag_lines_lo[3]                         = tag_lines_lo[25];

  wire bsg_tag_s        dmc_reset_tag_lines_lo       = tag_lines_lo[26];
  wire bsg_tag_s  [3:0] dmc_dly_tag_lines_lo         = tag_lines_lo[27+:4];
  wire bsg_tag_s  [3:0] dmc_dly_trigger_tag_lines_lo = tag_lines_lo[31+:4];
  wire bsg_tag_s        dmc_ds_tag_lines_lo          = tag_lines_lo[35];

  wire bsg_tag_s [11:0] dmc_cfg_tag_lines_lo         = tag_lines_lo[36+:12];

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
  logic dfi_clk_2x_lo, dfi_clk_1x_lo;

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

      ,.ext_clk_i({ clk_C_i_int, clk_C_i_int, clk_B_i_int, clk_A_i_int })

      ,.clk_o({ dfi_clk_2x_lo, router_clk_lo, io_master_clk_lo, bp_clk_lo })
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
      (.data_i( {dfi_clk_2x_lo, bp_clk_lo, io_master_clk_lo, router_clk_lo} )
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
      logic [wh_did_width_gp-1:0] did;
  } bp_tag_payload_s;

  // Tag payload for bp control signals
  bp_tag_payload_s core_tag_data_lo;
  logic            core_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_bp
      (.bsg_tag_i     ( bp_core_tag_lines_lo )
      ,.recv_clk_i    ( bp_clk_lo )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( core_tag_new_data_lo )
      ,.recv_data_r_o ( core_tag_data_lo )
      );
  wire core_reset_lo = core_tag_data_lo.reset;
  wire [wh_did_width_gp-1:0] core_did_lo = core_tag_data_lo.did;

  // Tag payload for bp control signals
  bp_tag_payload_s host_tag_data_lo;
  logic            host_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_host
      (.bsg_tag_i     ( host_core_tag_lines_lo )
      ,.recv_clk_i    ( bp_clk_lo )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( host_tag_new_data_lo )
      ,.recv_data_r_o ( host_tag_data_lo )
      );
  wire host_reset_lo = host_tag_data_lo.reset;
  wire [wh_did_width_gp-1:0] host_did_lo = host_tag_data_lo.did;

  bp_tag_payload_s router_tag_data_lo;
  logic            router_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(bp_tag_payload_s) ), .default_p( 0 ))
    btc_router
      (.bsg_tag_i     ( router_tag_lines_lo )
      ,.recv_clk_i    ( router_clk_lo )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( router_tag_new_data_lo )
      ,.recv_data_r_o ( router_tag_data_lo )
      );
  wire router_reset_lo = router_tag_data_lo.reset;
  wire [wh_did_width_gp-1:0] router_did_lo = router_tag_data_lo.did;

  // Tag payload for bsg_dmc control signals
  logic [11:0][7:0] dmc_cfg_tag_data_lo;
  logic [11:0]      dmc_cfg_tag_new_data_lo;

  genvar idx;
  generate
    for(idx=0;idx<12;idx++) begin: dmc_cfg
      bsg_tag_client #(.width_p( 8 ), .default_p( 0 ))
        btc
          (.bsg_tag_i     ( dmc_cfg_tag_lines_lo[idx] )
          ,.recv_clk_i    ( dfi_clk_1x_lo )
          ,.recv_reset_i  ( 1'b0 )
          ,.recv_new_r_o  ( dmc_cfg_tag_new_data_lo[idx] )
          ,.recv_data_r_o ( dmc_cfg_tag_data_lo[idx] )
          );
    end
  endgenerate
      

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

  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0]        repeated_prev_router_links_li, repeated_prev_router_links_lo;
  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0]        repeated_next_router_links_li, repeated_next_router_links_lo;

  ct_link_sif_s [ct_num_in_gp-1:0] next_ct_links_li, next_ct_links_lo;
  ct_link_sif_s [ct_num_in_gp-1:0] prev_ct_links_li, prev_ct_links_lo;

  bsg_chip_io_complex_links_ct_fifo #(.link_width_p                        ( link_width_gp         )
                                     ,.link_channel_width_p                ( link_channel_width_gp )
                                     ,.link_num_channels_p                 ( link_num_channels_gp  )
                                     ,.link_lg_fifo_depth_p                ( link_lg_fifo_depth_gp )
                                     ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_gp )
                                     ,.link_use_extra_data_bit_p           ( 1 )
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

      ,.links_i  ( prev_ct_links_li ) 
      ,.links_o  ( prev_ct_links_lo )
      );

  assign prev_ct_links_li[0] = {repeated_prev_router_links_li[0][flit_width_p+:2], 2'b00, repeated_prev_router_links_li[0][0+:flit_width_p]};
  assign prev_ct_links_li[1] = {repeated_prev_router_links_li[1][flit_width_p+:2], 2'b00, repeated_prev_router_links_li[1][0+:flit_width_p]};
  assign prev_ct_links_li[2] = {repeated_prev_router_links_li[2][flit_width_p+:2], 2'b00, repeated_prev_router_links_li[2][0+:flit_width_p]};

  assign repeated_prev_router_links_lo[0] = {prev_ct_links_lo[0][flit_width_p+2+:2], prev_ct_links_lo[0][0+:flit_width_p]};
  assign repeated_prev_router_links_lo[1] = {prev_ct_links_lo[1][flit_width_p+2+:2], prev_ct_links_lo[1][0+:flit_width_p]};
  assign repeated_prev_router_links_lo[2] = {prev_ct_links_lo[2][flit_width_p+2+:2], prev_ct_links_lo[2][0+:flit_width_p]};

  bsg_chip_io_complex_links_ct_fifo #(.link_width_p                        ( link_width_gp         )
                                     ,.link_channel_width_p                ( link_channel_width_gp )
                                     ,.link_num_channels_p                 ( link_num_channels_gp  )
                                     ,.link_lg_fifo_depth_p                ( link_lg_fifo_depth_gp )
                                     ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_gp )
                                     ,.link_use_extra_data_bit_p           ( 1 )
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

      ,.links_i  ( next_ct_links_li )
      ,.links_o  ( next_ct_links_lo )
      );

  assign next_ct_links_li[0] = {repeated_next_router_links_li[0][flit_width_p+:2], 2'b00, repeated_next_router_links_li[0][0+:flit_width_p]};
  assign next_ct_links_li[1] = {repeated_next_router_links_li[1][flit_width_p+:2], 2'b00, repeated_next_router_links_li[1][0+:flit_width_p]};
  assign next_ct_links_li[2] = {repeated_next_router_links_li[2][flit_width_p+:2], 2'b00, repeated_next_router_links_li[2][0+:flit_width_p]};

  assign repeated_next_router_links_lo[0] = {next_ct_links_lo[0][flit_width_p+2+:2], next_ct_links_lo[0][0+:flit_width_p]};
  assign repeated_next_router_links_lo[1] = {next_ct_links_lo[1][flit_width_p+2+:2], next_ct_links_lo[1][0+:flit_width_p]};
  assign repeated_next_router_links_lo[2] = {next_ct_links_lo[2][flit_width_p+2+:2], next_ct_links_lo[2][0+:flit_width_p]};

  //////////////////////////////////////////////////
  //
  // BSG Chip BlackParrot
  //

  bsg_ready_and_link_sif_s bp_prev_cmd_link_li, bp_prev_cmd_link_lo;
  bsg_ready_and_link_sif_s bp_prev_resp_link_li, bp_prev_resp_link_lo;

  bsg_ready_and_link_sif_s bp_next_cmd_link_li, bp_next_cmd_link_lo;
  bsg_ready_and_link_sif_s bp_next_resp_link_li, bp_next_resp_link_lo;

  bsg_ready_and_link_sif_s dram_cmd_link_lo, dram_resp_link_li;
  bp_multicore #(.bp_params_p(bp_cfg_gp))
    bp_processor
      (.core_clk_i  ( bp_clk_lo )
      ,.core_reset_i( core_reset_lo )

      // Currently synced to core clock
      ,.coh_clk_i  ( bp_clk_lo )
      ,.coh_reset_i( core_reset_lo )

      // Currently synced to mem clock
      ,.io_clk_i    ( router_clk_lo)
      ,.io_reset_i  ( router_reset_lo )

      ,.mem_clk_i   ( router_clk_lo )
      ,.mem_reset_i ( router_reset_lo )

      ,.my_did_i   ( core_did_lo[0+:io_noc_did_width_p] )
      ,.host_did_i ( host_did_lo[0+:io_noc_did_width_p] )

      ,.io_cmd_link_i({bp_next_cmd_link_li, bp_prev_cmd_link_li})
      ,.io_cmd_link_o({bp_next_cmd_link_lo, bp_prev_cmd_link_lo})

      ,.io_resp_link_i({bp_next_resp_link_li, bp_prev_resp_link_li})
      ,.io_resp_link_o({bp_next_resp_link_lo, bp_prev_resp_link_lo})

      ,.dram_cmd_link_o(dram_cmd_link_lo)
      ,.dram_resp_link_i(dram_resp_link_li)
      );

  `declare_bp_me_if(paddr_width_p, cce_block_width_p, lce_id_width_p, lce_assoc_p)
  bp_cce_mem_msg_s dram_cmd_lo;
  logic            dram_cmd_v_lo, dram_cmd_ready_li;
  bp_cce_mem_msg_s dram_resp_li;
  logic            dram_resp_v_li, dram_resp_ready_lo;

  bp_cce_mem_msg_s bypass_cmd_li;
  logic            bypass_cmd_v_li, bypass_cmd_ready_lo;
  bp_cce_mem_msg_s bypass_resp_lo;
  logic            bypass_resp_v_lo, bypass_resp_ready_li;

  bp_cce_mem_msg_s dmc_cmd_li;
  logic            dmc_cmd_v_li, dmc_cmd_ready_lo;
  bp_cce_mem_msg_s dmc_resp_lo;
  logic            dmc_resp_v_lo, dmc_resp_ready_li;

  logic dmc_bypass;

  bp_me_cce_to_mem_link_client
   #(.bp_params_p(bp_params_p)
     ,.num_outstanding_req_p(mem_noc_max_credits_p)
     ,.flit_width_p(mem_noc_flit_width_p)
     ,.cord_width_p(mem_noc_cord_width_p)
     ,.cid_width_p(mem_noc_cid_width_p)
     ,.len_width_p(mem_noc_len_width_p)
     )
   dram_link
    (.clk_i(router_clk_lo)
     ,.reset_i(router_reset_lo)
  
     ,.mem_cmd_o(dram_cmd_lo)
     ,.mem_cmd_v_o(dram_cmd_v_lo)
     ,.mem_cmd_yumi_i(dram_cmd_ready_li & dram_cmd_v_lo)
  
     ,.mem_resp_i(dram_resp_li)
     ,.mem_resp_v_i(dram_resp_v_li)
     ,.mem_resp_ready_o(dram_resp_ready_lo)
  
     ,.cmd_link_i(dram_cmd_link_lo)
     ,.resp_link_o(dram_resp_link_li)
     );

  always_comb
  begin
    if (dmc_bypass)
      begin
        bypass_cmd_li        = dram_cmd_lo;
        bypass_cmd_v_li      = dram_cmd_v_lo;
        dram_cmd_ready_li    = bypass_cmd_ready_lo;

        dram_resp_li         = bypass_resp_lo;
        dram_resp_v_li       = bypass_resp_v_lo;
        bypass_resp_ready_li = dram_resp_ready_lo;

        dmc_cmd_li           = '0;
        dmc_cmd_v_li         = 1'b0;
        dmc_resp_ready_li    = 1'b1;
      end
    else
      begin
        dmc_cmd_li           = dram_cmd_lo;
        dmc_cmd_v_li         = dram_cmd_v_lo;
        dram_cmd_ready_li    = dmc_cmd_ready_lo;

        dram_resp_li         = dmc_resp_lo;
        dram_resp_v_li       = dmc_resp_v_lo;
        dmc_resp_ready_li    = dram_resp_ready_lo;

        bypass_cmd_li        = '0;
        bypass_cmd_v_li      = 1'b0;
        bypass_resp_ready_li = 1'b1;
      end
  end

  bsg_ready_and_link_sif_s [E:P] bypass_link_li, bypass_link_lo;
  bp_me_cce_to_mem_link_master
   #(.bp_params_p(bp_params_p)
     ,.flit_width_p(mem_noc_flit_width_p)
     ,.cord_width_p(mem_noc_cord_width_p)
     ,.cid_width_p(mem_noc_cid_width_p)
     ,.len_width_p(mem_noc_len_width_p)
     )
   bypass_link
    (.clk_i(router_clk_lo)
     ,.reset_i(router_reset_lo)

     ,.mem_cmd_i(bypass_cmd_li)
     ,.mem_cmd_v_i(bypass_cmd_v_li)
     ,.mem_cmd_ready_o(bypass_cmd_ready_lo)

     ,.mem_resp_o(bypass_resp_lo)
     ,.mem_resp_v_o(bypass_resp_v_lo)
     ,.mem_resp_yumi_i(bypass_resp_ready_li & bypass_resp_v_lo)

     ,.my_cord_i(core_did_lo[0+:io_noc_did_width_p])
     ,.my_cid_i('0)
     ,.dst_cord_i(host_did_lo[0+:io_noc_did_width_p])
     ,.dst_cid_i('0)

     ,.cmd_link_o(bypass_link_li[P])
     ,.resp_link_i(bypass_link_lo[P])
     );

  bsg_wormhole_router #(.flit_width_p(mem_noc_flit_width_p)
                        ,.dims_p(mem_noc_dims_p)
                        ,.cord_dims_p(mem_noc_cord_dims_p)
                        ,.cord_markers_pos_p(mem_noc_cord_markers_pos_p)
                        ,.len_width_p(mem_noc_len_width_p)
                        ,.reverse_order_p(1)
                        ,.routing_matrix_p(StrictX)
                        ) bypass_router
    (.clk_i(router_clk_lo)
    ,.reset_i(router_reset_lo)

    ,.my_cord_i(router_did_lo[0+:io_noc_did_width_p])

    ,.link_i(bypass_link_li)
    ,.link_o(bypass_link_lo)
    );

  for (i = 0; i < 3; i++)
    begin : repeater
      bsg_noc_repeater_node
       #(.width_p(flit_width_p))
       prev_bypass_repeater
        (.clk_i(router_clk_lo)
         ,.reset_i(router_reset_lo)

         ,.side_A_links_i(prev_router_links_li[i])
         ,.side_A_links_o(prev_router_links_lo[i])

         ,.side_B_links_i(repeated_prev_router_links_lo[i])
         ,.side_B_links_o(repeated_prev_router_links_li[i])
         );

      bsg_noc_repeater_node
       #(.width_p(flit_width_p))
       next_bypass_repeater
        (.clk_i(router_clk_lo)
         ,.reset_i(router_reset_lo)

         ,.side_A_links_i(next_router_links_li[i])
         ,.side_A_links_o(next_router_links_lo[i])

         ,.side_B_links_i(repeated_next_router_links_lo[i])
         ,.side_B_links_o(repeated_next_router_links_li[i])
         );
    end

  assign prev_router_links_li[0] = bp_prev_cmd_link_lo;
  assign prev_router_links_li[1] = bp_prev_resp_link_lo;
  assign prev_router_links_li[2] = bypass_link_lo[W];

  assign bp_prev_cmd_link_li  = prev_router_links_lo[0];
  assign bp_prev_resp_link_li = prev_router_links_lo[1];
  assign bypass_link_li[W]    = prev_router_links_lo[2];

  assign next_router_links_li[0] = bp_next_cmd_link_lo;
  assign next_router_links_li[1] = bp_next_resp_link_lo;
  assign next_router_links_li[2] = bypass_link_lo[E];

  assign bp_next_cmd_link_li  = next_router_links_lo[0];
  assign bp_next_resp_link_li = next_router_links_lo[1];
  assign bypass_link_li[E]    = next_router_links_lo[2];

  // DMC
  //localparam ui_addr_width_p = paddr_width_p; // word address (1 TB)
  //localparam ui_data_width_p = dword_width_p;
  //localparam burst_data_width_p = cce_block_width_p;
  localparam dq_data_width_p = 32;
  //localparam dq_group_lp = dq_data_width_p >> 3;

  wire                              app_en_lo;
  wire                              app_rdy_li;
  wire                        [2:0] app_cmd_lo;
  wire          [paddr_width_p-1:0] app_addr_lo;
  wire      [dmc_addr_width_gp-1:0] app_addr_li = app_addr_lo[2+:dmc_addr_width_gp];

  wire                              app_wdf_wren_lo;
  wire                              app_wdf_rdy_li;
  wire      [cce_block_width_p-1:0] app_wdf_data_lo;
  wire [(cce_block_width_p>>3)-1:0] app_wdf_mask_lo;
  wire                              app_wdf_end_lo;

  wire                              app_rd_data_valid_li;
  wire      [cce_block_width_p-1:0] app_rd_data_li;
  wire                              app_rd_data_end_li;

  wire                        [2:0] ddr_ba_lo;
  wire                       [15:0] ddr_addr_lo;

  wire   [(dq_data_width_p>>3)-1:0] ddr_dm_lo;
  wire   [(dq_data_width_p>>3)-1:0] ddr_dm_oen_lo;

  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_p_oen_lo;
  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_p_ien_lo;
  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_p_lo;
  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_p_li;

  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_n_oen_lo;
  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_n_ien_lo;
  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_n_lo;
  wire   [(dq_data_width_p>>3)-1:0] ddr_dqs_n_li;

  wire        [dq_data_width_p-1:0] ddr_dq_li;
  wire        [dq_data_width_p-1:0] ddr_dq_lo;
  wire        [dq_data_width_p-1:0] ddr_dq_oen_lo;
  

  bp_me_cce_to_xui
   #(.bp_params_p(bp_params_p)
     ,.flit_width_p(mem_noc_flit_width_p)
     ,.cord_width_p(mem_noc_cord_width_p)
     ,.cid_width_p(mem_noc_cid_width_p)
     ,.len_width_p(mem_noc_len_width_p)
     )
   dmc_link
    (.clk_i(router_clk_lo)
     ,.reset_i(router_reset_lo)

     ,.mem_cmd_i(dmc_cmd_li)
     ,.mem_cmd_v_i(dmc_cmd_v_li)
     ,.mem_cmd_ready_o(dmc_cmd_ready_lo)

     ,.mem_resp_o(dmc_resp_lo)
     ,.mem_resp_v_o(dmc_resp_v_lo)
     ,.mem_resp_yumi_i(dmc_resp_ready_li & dmc_resp_v_lo)

     ,.app_addr_o(app_addr_lo)
     ,.app_cmd_o(app_cmd_lo)
     ,.app_en_o(app_en_lo)
     ,.app_rdy_i(app_rdy_li)
     ,.app_wdf_wren_o(app_wdf_wren_lo)
     ,.app_wdf_data_o(app_wdf_data_lo)
     ,.app_wdf_mask_o(app_wdf_mask_lo)
     ,.app_wdf_end_o(app_wdf_end_lo)
     ,.app_wdf_rdy_i(app_wdf_rdy_li)
     ,.app_rd_data_valid_i(app_rd_data_valid_li)
     ,.app_rd_data_i(app_rd_data_li)
     ,.app_rd_data_end_i(app_rd_data_end_li)
     );

  bsg_dmc_s dmc_p;

  //initial begin
  //  dmc_p.trefi = 1023;
  //  dmc_p.tmrd = 1;
  //  dmc_p.trfc = 15;
  //  dmc_p.trc = 10;
  //  dmc_p.trp = 2;
  //  dmc_p.tras = 7;
  //  dmc_p.trrd = 1;
  //  dmc_p.trcd = 2;
  //  dmc_p.twr = 7;
  //  dmc_p.twtr = 7;
  //  dmc_p.trtp = 3;
  //  dmc_p.tcas = 3;
  //  dmc_p.col_width = 11;
  //  dmc_p.row_width = 14;
  //  dmc_p.bank_width = 2;
  //  dmc_p.dqs_sel_cal = 0;
  //  dmc_p.init_cmd_cnt = 5;
  //  dmc_p.bank_pos = 25;
  //end
  assign dmc_p.trefi        = {dmc_cfg_tag_data_lo[1], dmc_cfg_tag_data_lo[0]};
  assign dmc_p.tmrd         = dmc_cfg_tag_data_lo[2][3:0];
  assign dmc_p.trfc         = dmc_cfg_tag_data_lo[2][7:4];
  assign dmc_p.trc          = dmc_cfg_tag_data_lo[3][3:0];
  assign dmc_p.trp          = dmc_cfg_tag_data_lo[3][7:4];
  assign dmc_p.tras         = dmc_cfg_tag_data_lo[4][3:0];
  assign dmc_p.trrd         = dmc_cfg_tag_data_lo[4][7:4];
  assign dmc_p.trcd         = dmc_cfg_tag_data_lo[5][3:0];
  assign dmc_p.twr          = dmc_cfg_tag_data_lo[5][7:4];
  assign dmc_p.twtr         = dmc_cfg_tag_data_lo[6][3:0];
  assign dmc_p.trtp         = dmc_cfg_tag_data_lo[6][7:4];
  assign dmc_p.tcas         = dmc_cfg_tag_data_lo[7][3:0];
  assign dmc_p.col_width    = dmc_cfg_tag_data_lo[8][3:0];
  assign dmc_p.row_width    = dmc_cfg_tag_data_lo[8][7:4];
  assign dmc_p.bank_width   = dmc_cfg_tag_data_lo[9][1:0];
  assign dmc_p.bank_pos     = dmc_cfg_tag_data_lo[9][7:2];
  assign dmc_p.dqs_sel_cal  = dmc_cfg_tag_data_lo[10][1:0];
  assign dmc_p.init_cmd_cnt = dmc_cfg_tag_data_lo[10][5:2];
  assign dmc_bypass         = dmc_cfg_tag_data_lo[10][6];
  wire   dmc_sys_reset_li   = dmc_cfg_tag_data_lo[11][0];

  bsg_dmc #
    (.num_adgs_p            ( clk_gen_num_adgs_gp )
    ,.ui_addr_width_p       ( dmc_addr_width_gp   )
    ,.ui_data_width_p       ( cce_block_width_p   )
    ,.burst_data_width_p    ( cce_block_width_p   )
    ,.dq_data_width_p       ( dmc_data_width_gp   ))
  dmc
    (.async_reset_tag_i     ( dmc_reset_tag_lines_lo       )
    ,.bsg_dly_tag_i         ( dmc_dly_tag_lines_lo         )
    ,.bsg_dly_trigger_tag_i ( dmc_dly_trigger_tag_lines_lo )
    ,.bsg_ds_tag_i          ( dmc_ds_tag_lines_lo          )

    ,.dmc_p_i               ( dmc_p                        )

    ,.sys_reset_i           ( dmc_sys_reset_li     )

    // Application interface
    ,.app_addr_i            ( app_addr_li          )
    ,.app_cmd_i             ( app_cmd_lo           )
    ,.app_en_i              ( app_en_lo            )
    ,.app_rdy_o             ( app_rdy_li           )

    ,.app_wdf_wren_i        ( app_wdf_wren_lo      )
    ,.app_wdf_data_i        ( app_wdf_data_lo      )
    ,.app_wdf_mask_i        ( app_wdf_mask_lo      )
    ,.app_wdf_end_i         ( app_wdf_end_lo       )
    ,.app_wdf_rdy_o         ( app_wdf_rdy_li       )

    ,.app_rd_data_valid_o   ( app_rd_data_valid_li )
    ,.app_rd_data_o         ( app_rd_data_li       )
    ,.app_rd_data_end_o     ( app_rd_data_end_li   )

    // Stubbed compatibility ports
    ,.app_ref_req_i         ( 1'b0 )
    ,.app_ref_ack_o         ()
    ,.app_zq_req_i          ( 1'b0 )
    ,.app_zq_ack_o          ()
    ,.app_sr_req_i          ( 1'b0 )
    ,.app_sr_active_o       ()

    ,.init_calib_complete_o ()

    ,.ddr_ck_p_o            ( ddr_ck_p_o_int       )
    ,.ddr_ck_n_o            ( ddr_ck_n_o_int       )
    ,.ddr_cke_o             ( ddr_cke_o_int        )
    ,.ddr_ba_o              ( ddr_ba_lo            )
    ,.ddr_addr_o            ( ddr_addr_lo          )
    ,.ddr_cs_n_o            ( ddr_cs_n_o_int       )
    ,.ddr_ras_n_o           ( ddr_ras_n_o_int      )
    ,.ddr_cas_n_o           ( ddr_cas_n_o_int      )
    ,.ddr_we_n_o            ( ddr_we_n_o_int       )
    ,.ddr_reset_n_o         ( ddr_reset_n_o_int    )
    ,.ddr_odt_o             ( ddr_odt_o_int        )

    ,.ddr_dm_oen_o          ( ddr_dm_oen_lo        )
    ,.ddr_dm_o              ( ddr_dm_lo            )
    ,.ddr_dqs_p_oen_o       ( ddr_dqs_p_oen_lo     )
    ,.ddr_dqs_p_ien_o       ( ddr_dqs_p_ien_lo     )
    ,.ddr_dqs_p_o           ( ddr_dqs_p_lo         )
    ,.ddr_dqs_p_i           ( ddr_dqs_p_li         )
    ,.ddr_dqs_n_oen_o       ( ddr_dqs_n_oen_lo     )
    ,.ddr_dqs_n_ien_o       ( ddr_dqs_n_ien_lo     )
    ,.ddr_dqs_n_o           ( ddr_dqs_n_lo         )
    ,.ddr_dqs_n_i           ( ddr_dqs_n_li         )
    ,.ddr_dq_oen_o          ( ddr_dq_oen_lo        )
    ,.ddr_dq_o              ( ddr_dq_lo            )
    ,.ddr_dq_i              ( ddr_dq_li            )

    ,.ui_clk_i              ( router_clk_lo        )
    ,.dfi_clk_2x_i          ( dfi_clk_2x_lo        )
    ,.dfi_clk_1x_o          ( dfi_clk_1x_lo        )

    ,.ui_clk_sync_rst_o     (                      )

    ,.device_temp_o         (                      ));

  assign ddr_ba_0_o_int = ddr_ba_lo[0];
  assign ddr_ba_1_o_int = ddr_ba_lo[1];
  assign ddr_ba_2_o_int = ddr_ba_lo[2];

  assign ddr_addr_0_o_int  = ddr_addr_lo[0];
  assign ddr_addr_1_o_int  = ddr_addr_lo[1];
  assign ddr_addr_2_o_int  = ddr_addr_lo[2];
  assign ddr_addr_3_o_int  = ddr_addr_lo[3];
  assign ddr_addr_4_o_int  = ddr_addr_lo[4];
  assign ddr_addr_5_o_int  = ddr_addr_lo[5];
  assign ddr_addr_6_o_int  = ddr_addr_lo[6];
  assign ddr_addr_7_o_int  = ddr_addr_lo[7];
  assign ddr_addr_8_o_int  = ddr_addr_lo[8];
  assign ddr_addr_9_o_int  = ddr_addr_lo[9];
  assign ddr_addr_10_o_int = ddr_addr_lo[10];
  assign ddr_addr_11_o_int = ddr_addr_lo[11];
  assign ddr_addr_12_o_int = ddr_addr_lo[12];
  assign ddr_addr_13_o_int = ddr_addr_lo[13];
  assign ddr_addr_14_o_int = ddr_addr_lo[14];
  assign ddr_addr_15_o_int = ddr_addr_lo[15];

  assign ddr_dm_0_o_int = ddr_dm_lo[0]; assign ddr_dm_0_oen_int = ddr_dm_oen_lo[0];
  assign ddr_dm_1_o_int = ddr_dm_lo[1]; assign ddr_dm_1_oen_int = ddr_dm_oen_lo[1];
  assign ddr_dm_2_o_int = ddr_dm_lo[2]; assign ddr_dm_2_oen_int = ddr_dm_oen_lo[2];
  assign ddr_dm_3_o_int = ddr_dm_lo[3]; assign ddr_dm_3_oen_int = ddr_dm_oen_lo[3];

  assign ddr_dqs_p_0_o_io_int = ddr_dqs_p_lo[0]; assign ddr_dqs_p_0_oen_int = ddr_dqs_p_oen_lo[0];
  assign ddr_dqs_p_1_o_io_int = ddr_dqs_p_lo[1]; assign ddr_dqs_p_1_oen_int = ddr_dqs_p_oen_lo[1];
  assign ddr_dqs_p_2_o_io_int = ddr_dqs_p_lo[2]; assign ddr_dqs_p_2_oen_int = ddr_dqs_p_oen_lo[2];
  assign ddr_dqs_p_3_o_io_int = ddr_dqs_p_lo[3]; assign ddr_dqs_p_3_oen_int = ddr_dqs_p_oen_lo[3];
  assign ddr_dqs_n_0_o_io_int = ddr_dqs_n_lo[0]; assign ddr_dqs_n_0_oen_int = ddr_dqs_n_oen_lo[0];
  assign ddr_dqs_n_1_o_io_int = ddr_dqs_n_lo[1]; assign ddr_dqs_n_1_oen_int = ddr_dqs_n_oen_lo[1];
  assign ddr_dqs_n_2_o_io_int = ddr_dqs_n_lo[2]; assign ddr_dqs_n_2_oen_int = ddr_dqs_n_oen_lo[2];
  assign ddr_dqs_n_3_o_io_int = ddr_dqs_n_lo[3]; assign ddr_dqs_n_3_oen_int = ddr_dqs_n_oen_lo[3];

  assign ddr_dqs_p_li[0] = ddr_dqs_p_0_i_io_int;
  assign ddr_dqs_p_li[1] = ddr_dqs_p_1_i_io_int;
  assign ddr_dqs_p_li[2] = ddr_dqs_p_2_i_io_int;
  assign ddr_dqs_p_li[3] = ddr_dqs_p_3_i_io_int;
  assign ddr_dqs_n_li[0] = ddr_dqs_n_0_i_io_int;
  assign ddr_dqs_n_li[1] = ddr_dqs_n_1_i_io_int;
  assign ddr_dqs_n_li[2] = ddr_dqs_n_2_i_io_int;
  assign ddr_dqs_n_li[3] = ddr_dqs_n_3_i_io_int;

  assign ddr_dq_li[0]  = ddr_dq_0_i_io_int;  assign ddr_dq_0_o_io_int  = ddr_dq_lo[0];  assign ddr_dq_0_oen_int  = ddr_dq_oen_lo[0];
  assign ddr_dq_li[1]  = ddr_dq_1_i_io_int;  assign ddr_dq_1_o_io_int  = ddr_dq_lo[1];  assign ddr_dq_1_oen_int  = ddr_dq_oen_lo[1];
  assign ddr_dq_li[2]  = ddr_dq_2_i_io_int;  assign ddr_dq_2_o_io_int  = ddr_dq_lo[2];  assign ddr_dq_2_oen_int  = ddr_dq_oen_lo[2];
  assign ddr_dq_li[3]  = ddr_dq_3_i_io_int;  assign ddr_dq_3_o_io_int  = ddr_dq_lo[3];  assign ddr_dq_3_oen_int  = ddr_dq_oen_lo[3];
  assign ddr_dq_li[4]  = ddr_dq_4_i_io_int;  assign ddr_dq_4_o_io_int  = ddr_dq_lo[4];  assign ddr_dq_4_oen_int  = ddr_dq_oen_lo[4];
  assign ddr_dq_li[5]  = ddr_dq_5_i_io_int;  assign ddr_dq_5_o_io_int  = ddr_dq_lo[5];  assign ddr_dq_5_oen_int  = ddr_dq_oen_lo[5];
  assign ddr_dq_li[6]  = ddr_dq_6_i_io_int;  assign ddr_dq_6_o_io_int  = ddr_dq_lo[6];  assign ddr_dq_6_oen_int  = ddr_dq_oen_lo[6];
  assign ddr_dq_li[7]  = ddr_dq_7_i_io_int;  assign ddr_dq_7_o_io_int  = ddr_dq_lo[7];  assign ddr_dq_7_oen_int  = ddr_dq_oen_lo[7];
  assign ddr_dq_li[8]  = ddr_dq_8_i_io_int;  assign ddr_dq_8_o_io_int  = ddr_dq_lo[8];  assign ddr_dq_8_oen_int  = ddr_dq_oen_lo[8];
  assign ddr_dq_li[9]  = ddr_dq_9_i_io_int;  assign ddr_dq_9_o_io_int  = ddr_dq_lo[9];  assign ddr_dq_9_oen_int  = ddr_dq_oen_lo[9];
  assign ddr_dq_li[10] = ddr_dq_10_i_io_int; assign ddr_dq_10_o_io_int = ddr_dq_lo[10]; assign ddr_dq_10_oen_int = ddr_dq_oen_lo[10];
  assign ddr_dq_li[11] = ddr_dq_11_i_io_int; assign ddr_dq_11_o_io_int = ddr_dq_lo[11]; assign ddr_dq_11_oen_int = ddr_dq_oen_lo[11];
  assign ddr_dq_li[12] = ddr_dq_12_i_io_int; assign ddr_dq_12_o_io_int = ddr_dq_lo[12]; assign ddr_dq_12_oen_int = ddr_dq_oen_lo[12];
  assign ddr_dq_li[13] = ddr_dq_13_i_io_int; assign ddr_dq_13_o_io_int = ddr_dq_lo[13]; assign ddr_dq_13_oen_int = ddr_dq_oen_lo[13];
  assign ddr_dq_li[14] = ddr_dq_14_i_io_int; assign ddr_dq_14_o_io_int = ddr_dq_lo[14]; assign ddr_dq_14_oen_int = ddr_dq_oen_lo[14];
  assign ddr_dq_li[15] = ddr_dq_15_i_io_int; assign ddr_dq_15_o_io_int = ddr_dq_lo[15]; assign ddr_dq_15_oen_int = ddr_dq_oen_lo[15];
  assign ddr_dq_li[16] = ddr_dq_16_i_io_int; assign ddr_dq_16_o_io_int = ddr_dq_lo[16]; assign ddr_dq_16_oen_int = ddr_dq_oen_lo[16];
  assign ddr_dq_li[17] = ddr_dq_17_i_io_int; assign ddr_dq_17_o_io_int = ddr_dq_lo[17]; assign ddr_dq_17_oen_int = ddr_dq_oen_lo[17];
  assign ddr_dq_li[18] = ddr_dq_18_i_io_int; assign ddr_dq_18_o_io_int = ddr_dq_lo[18]; assign ddr_dq_18_oen_int = ddr_dq_oen_lo[18];
  assign ddr_dq_li[19] = ddr_dq_19_i_io_int; assign ddr_dq_19_o_io_int = ddr_dq_lo[19]; assign ddr_dq_19_oen_int = ddr_dq_oen_lo[19];
  assign ddr_dq_li[20] = ddr_dq_20_i_io_int; assign ddr_dq_20_o_io_int = ddr_dq_lo[20]; assign ddr_dq_20_oen_int = ddr_dq_oen_lo[20];
  assign ddr_dq_li[21] = ddr_dq_21_i_io_int; assign ddr_dq_21_o_io_int = ddr_dq_lo[21]; assign ddr_dq_21_oen_int = ddr_dq_oen_lo[21];
  assign ddr_dq_li[22] = ddr_dq_22_i_io_int; assign ddr_dq_22_o_io_int = ddr_dq_lo[22]; assign ddr_dq_22_oen_int = ddr_dq_oen_lo[22];
  assign ddr_dq_li[23] = ddr_dq_23_i_io_int; assign ddr_dq_23_o_io_int = ddr_dq_lo[23]; assign ddr_dq_23_oen_int = ddr_dq_oen_lo[23];
  assign ddr_dq_li[24] = ddr_dq_24_i_io_int; assign ddr_dq_24_o_io_int = ddr_dq_lo[24]; assign ddr_dq_24_oen_int = ddr_dq_oen_lo[24];
  assign ddr_dq_li[25] = ddr_dq_25_i_io_int; assign ddr_dq_25_o_io_int = ddr_dq_lo[25]; assign ddr_dq_25_oen_int = ddr_dq_oen_lo[25];
  assign ddr_dq_li[26] = ddr_dq_26_i_io_int; assign ddr_dq_26_o_io_int = ddr_dq_lo[26]; assign ddr_dq_26_oen_int = ddr_dq_oen_lo[26];
  assign ddr_dq_li[27] = ddr_dq_27_i_io_int; assign ddr_dq_27_o_io_int = ddr_dq_lo[27]; assign ddr_dq_27_oen_int = ddr_dq_oen_lo[27];
  assign ddr_dq_li[28] = ddr_dq_28_i_io_int; assign ddr_dq_28_o_io_int = ddr_dq_lo[28]; assign ddr_dq_28_oen_int = ddr_dq_oen_lo[28];
  assign ddr_dq_li[29] = ddr_dq_29_i_io_int; assign ddr_dq_29_o_io_int = ddr_dq_lo[29]; assign ddr_dq_29_oen_int = ddr_dq_oen_lo[29];
  assign ddr_dq_li[30] = ddr_dq_30_i_io_int; assign ddr_dq_30_o_io_int = ddr_dq_lo[30]; assign ddr_dq_30_oen_int = ddr_dq_oen_lo[30];
  assign ddr_dq_li[31] = ddr_dq_31_i_io_int; assign ddr_dq_31_o_io_int = ddr_dq_lo[31]; assign ddr_dq_31_oen_int = ddr_dq_oen_lo[31];

endmodule

