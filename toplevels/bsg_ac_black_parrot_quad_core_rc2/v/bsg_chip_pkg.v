`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"

  import bp_common_aviary_pkg::*;

  //////////////////////////////////////////////////
  //
  // BSG CLOCK GENERATOR PARAMETERS
  //

  localparam clk_gen_num_endpoints_gp = 3;
  localparam clk_gen_ds_width_gp      = 6;
  localparam clk_gen_num_adgs_gp      = 1;

  //////////////////////////////////////////////////
  //
  // BSG BLACKPARROT PARAMETERS
  //
  
  localparam bp_num_core_gp     = 4;
  localparam bp_num_mem_gp      = 4;
  localparam bp_num_router_gp   = bp_num_core_gp + bp_num_mem_gp;
  localparam bp_params_e bp_cfg_gp = e_bp_quad_core_cfg;

  //////////////////////////////////////////////////
  //
  // BSG CHIP IO COMPLEX PARAMETERS
  //

  localparam link_channel_width_gp = 8;
  localparam link_num_channels_gp = 1;
  localparam link_width_gp = 32;
  localparam link_lg_fifo_depth_gp = 6;
  localparam link_lg_credit_to_token_decimation_gp = 3;

  localparam ct_num_in_gp = 2;
  localparam ct_tag_width_gp = `BSG_SAFE_CLOG2(ct_num_in_gp + 1);
  localparam ct_width_gp = link_width_gp - ct_tag_width_gp;

  localparam ct_remote_credits_gp = 64;
  localparam ct_credit_decimation_gp = ct_remote_credits_gp/4;
  localparam ct_lg_credit_decimation_gp = `BSG_SAFE_CLOG2(ct_credit_decimation_gp/2+1);
  localparam ct_use_pseudo_large_fifo_gp = 1;

  localparam wh_len_width_gp = 5;
  localparam wh_cord_markers_pos_a_gp = 0;
  localparam wh_cord_markers_pos_b_gp = 8;
  localparam wh_cord_width_gp = wh_cord_markers_pos_b_gp - wh_cord_markers_pos_a_gp;

  //////////////////////////////////////////////////
  //
  // BSG CHIP TAG PARAMETERS AND STRUCTS
  //

  // Total number of clients the master will be driving.
  localparam tag_num_clients_gp = 38;

  localparam tag_max_payload_width_in_io_complex_gp = (wh_cord_width_gp + 1);
  localparam tag_max_payload_width_in_bp_complex_gp = (wh_cord_width_gp + 1);
  localparam tag_max_payload_width_in_clk_gen_pd_gp = `BSG_MAX(clk_gen_ds_width_gp+1, clk_gen_num_adgs_gp+4);

  localparam tag_max_payload_width_gp = `BSG_MAX(tag_max_payload_width_in_io_complex_gp
                                        , `BSG_MAX(tag_max_payload_width_in_bp_complex_gp
                                        , `BSG_MAX(tag_max_payload_width_in_clk_gen_pd_gp
                                        , 0)));

  // The number of bits required to represent the max payload width
  localparam tag_lg_max_payload_width_gp = `BSG_SAFE_CLOG2(tag_max_payload_width_gp + 1);

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V

