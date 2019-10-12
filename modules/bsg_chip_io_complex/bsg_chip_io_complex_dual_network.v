////////////////////////////////////////////////////////////////////////////////
//
// bsg_chip_io_complex
//
// This is the chip's main IO logic. This IO complex has 2 router networks: network_a
// and network_b. Each network can have m number of channels and n number of router 
// groups.
// 
// definition of num_channel: stream of traffic coming out of channel tunnel
// definition of num_router_group: number of routers in "chain", from "prev" channel tunnel
// to "next" channel tunnel. Each router group has 1 tag_client and num_channel routers.
//
// This IO complex supports two networks that have different dimensions. For example, 
// network_a has 2 channels but 1 router group, while network_b has only 1 channel but
// 4 router groups in a chain. 
//

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                               //
// BSG CHIP IO COMPLEX DATAPATH                                                                                                  //
//                                    +-----+                                         +-----+                                    //
//        +-----------------+         |  C  |       +-----------+                     |  C  |         +-----------------+        //
//        |                 |         |  H  |       |           |                     |  H  |         |                 |        //
//  /---  |  PREV UPSTREAM  | <--+    |  A  | <===> W network_a E <=================> |  A  |    +--> |  NEXT UPSTREAM  |  ---\  //
//  \---  |    DDR LINK     |    |    |  N  |       |           |                     |  N  |    |    |    DDR LINK     |  ---/  //
//        |                 |    |    |  N  |       +-----P-----+                     |  N  |    |    |                 |        //
//        +-----------------+    +--- |  E  |             ^                           |  E  | ---+    +-----------------+        //
//                                    |  L  |             |       +-----------+       |  L  |                                    //
//        +-----------------+    +--> |     |             |       |           |       |     | <--+    +-----------------+        //
//        |                 |    |    |  T  | <=================> W network_b E <===> |  T  |    |    |                 |        //
//  ---\  | PREV DOWNSTREAM |    |    |  U  |             |       |           |       |  U  |    |    | NEXT DOWNSTREAM |  /---  //
//  ---/  |    DDR LINK     | ---+    |  N  |             |       +-----P-----+       |  N  |    +--- |    DDR LINK     |  \---  //
//        |                 |         |  N  |             |             ^             |  N  |         |                 |        //
//        +-----------------+         |  E  |             |             |             |  E  |         +-----------------+        //
//                                    |  L  |             |             |             |  L  |                                    //
//                                    +-----+             V             V             +-----+                                    //
//                                                                                                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Tag Reset Sequence
//
// We have 5 tag clients all required to get the io out of reset properly. It
// is important to follow the seqence:
//
//  1. Assert reset for all synchronous reset (ie. not the async_token_reset)
//    1a. You should set the router x and y at the same
//    1b. You should make sure all async_token_reset are low
//  time as you assert reset.
//  2. Assert all async_token_reset
//  3. Deassert all async_token_reset
//  4. Deassert all io up_link_reset*
//  5. Deassert all io down_link_reset
//  6. Deassert all core up_link_reset**
//  7. Deassert all core down_link_reset**
//  8. Deassert all routers reset
//
// Note: "all" means prev and next, however if there is nothing attached to the
// prev or next links, you should keep that link in reset.
//
// * - After you take the up links out of reset, there are some number of
// cycles for the comm link clocks to start generating. These comm link clocks
// are what the io_down_link_reset get's synchronized to so it may be required
// to wait a few cycles to make sure the clock start up.
//
// ** - The order of these shouldn't matter
//

module bsg_chip_io_complex_dual_network

import bsg_tag_pkg::*;
import bsg_noc_pkg::*;

#(parameter link_width_p                             = -1
, parameter link_channel_width_p                     = -1
, parameter link_num_channels_p                      = -1
, parameter link_lg_fifo_depth_p                     = -1
, parameter link_lg_credit_to_token_decimation_p     = -1
, parameter link_use_extra_data_bit_p                = -1

, parameter ct_width_p                               = -1
, parameter ct_num_in_p                              = -1
, parameter ct_remote_credits_p                      = -1
, parameter ct_use_pseudo_large_fifo_p               = -1
, parameter ct_lg_credit_decimation_p                = -1
, parameter prev_num_hops_p                          = 0
, parameter next_num_hops_p                          = 0

, parameter     network_a_num_router_groups_p        = -1
, parameter     network_a_num_in_p                   = -1
, parameter int network_a_wh_cord_markers_pos_p[1:0] = '{-1, -1}
, parameter     network_a_wh_len_width_p             = -1
, parameter     network_a_tag_cord_width_p           = -1
, parameter     network_a_wh_cord_width_lp           = network_a_wh_cord_markers_pos_p[1]
, parameter     network_a_num_repeater_nodes_p       = 0


, parameter     network_b_num_router_groups_p        = -1
, parameter     network_b_num_in_p                   = -1
, parameter int network_b_wh_cord_markers_pos_p[1:0] = '{-1, -1}
, parameter     network_b_wh_len_width_p             = -1
, parameter     network_b_tag_cord_width_p           = -1
, parameter     network_b_wh_cord_width_lp           = network_b_wh_cord_markers_pos_p[1]
, parameter     network_b_num_repeater_nodes_p       = 0

, parameter bsg_ready_and_link_sif_width_lp          = `bsg_ready_and_link_sif_width(ct_width_p)
)

( input  core_clk_i
, input  io_clk_i

, input bsg_tag_s  prev_link_io_tag_lines_i
, input bsg_tag_s  prev_link_core_tag_lines_i
, input bsg_tag_s  prev_ct_core_tag_lines_i

, input bsg_tag_s  next_link_io_tag_lines_i
, input bsg_tag_s  next_link_core_tag_lines_i
, input bsg_tag_s  next_ct_core_tag_lines_i

, input bsg_tag_s [network_a_num_router_groups_p-1:0] network_a_rtr_core_tag_lines_i
, input bsg_tag_s [network_b_num_router_groups_p-1:0] network_b_rtr_core_tag_lines_i

// comm link connection to next chip
, input  [link_num_channels_p-1:0]                           ci_clk_i
, input  [link_num_channels_p-1:0]                           ci_v_i
, input  [link_num_channels_p-1:0][link_channel_width_p-1:0] ci_data_i
, output [link_num_channels_p-1:0]                           ci_tkn_o

, output [link_num_channels_p-1:0]                           co_clk_o
, output [link_num_channels_p-1:0]                           co_v_o
, output [link_num_channels_p-1:0][link_channel_width_p-1:0] co_data_o
, input  [link_num_channels_p-1:0]                           co_tkn_i

// comm link connection to prev chip
, input  [link_num_channels_p-1:0]                           ci2_clk_i
, input  [link_num_channels_p-1:0]                           ci2_v_i
, input  [link_num_channels_p-1:0][link_channel_width_p-1:0] ci2_data_i
, output [link_num_channels_p-1:0]                           ci2_tkn_o

, output [link_num_channels_p-1:0]                           co2_clk_o
, output [link_num_channels_p-1:0]                           co2_v_o
, output [link_num_channels_p-1:0][link_channel_width_p-1:0] co2_data_o
, input  [link_num_channels_p-1:0]                           co2_tkn_i

, output logic [network_a_num_router_groups_p-1:0]                                 network_a_rtr_reset_o
, output logic [network_a_num_router_groups_p-1:0][network_a_wh_cord_width_lp-1:0] network_a_rtr_cord_o
, input        [network_a_num_router_groups_p-1:0][network_a_num_in_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] network_a_rtr_links_i
, output       [network_a_num_router_groups_p-1:0][network_a_num_in_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] network_a_rtr_links_o

, output logic [network_b_num_router_groups_p-1:0]                                 network_b_rtr_reset_o
, output logic [network_b_num_router_groups_p-1:0][network_b_wh_cord_width_lp-1:0] network_b_rtr_cord_o
, input        [network_b_num_router_groups_p-1:0][network_b_num_in_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] network_b_rtr_links_i
, output       [network_b_num_router_groups_p-1:0][network_b_num_in_p-1:0][bsg_ready_and_link_sif_width_lp-1:0] network_b_rtr_links_o
);

  genvar i,j;

  // declare the bsg_ready_and_link_sif_s struct
  `declare_bsg_ready_and_link_sif_s(ct_width_p, bsg_ready_and_link_sif_s);
  
  bsg_ready_and_link_sif_s [network_a_num_in_p-1:0] network_a_prev_ct_links_li;
  bsg_ready_and_link_sif_s [network_a_num_in_p-1:0] network_a_prev_ct_links_lo;
  bsg_ready_and_link_sif_s [network_a_num_in_p-1:0] network_a_next_ct_links_li;
  bsg_ready_and_link_sif_s [network_a_num_in_p-1:0] network_a_next_ct_links_lo;
  
  bsg_ready_and_link_sif_s [network_b_num_in_p-1:0] network_b_prev_ct_links_li;
  bsg_ready_and_link_sif_s [network_b_num_in_p-1:0] network_b_prev_ct_links_lo;
  bsg_ready_and_link_sif_s [network_b_num_in_p-1:0] network_b_next_ct_links_li;
  bsg_ready_and_link_sif_s [network_b_num_in_p-1:0] network_b_next_ct_links_lo;

  bsg_chip_io_complex_links_ct_fifo #(.link_width_p              ( link_width_p )
                                     ,.link_channel_width_p      ( link_channel_width_p )
                                     ,.link_num_channels_p       ( link_num_channels_p )
                                     ,.link_lg_fifo_depth_p      ( link_lg_fifo_depth_p )
                                     ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_p )
                                     ,.link_use_extra_data_bit_p ( link_use_extra_data_bit_p )
                                     ,.ct_width_p                ( ct_width_p )
                                     ,.ct_num_in_p               ( ct_num_in_p )
                                     ,.ct_remote_credits_p       ( ct_remote_credits_p )
                                     ,.ct_use_pseudo_large_fifo_p( ct_use_pseudo_large_fifo_p )
                                     ,.ct_lg_credit_decimation_p ( ct_lg_credit_decimation_p )
                                     ,.num_hops_p                ( prev_num_hops_p )
                                     )
    prev
      (.core_clk_i( core_clk_i )
      ,.io_clk_i  ( io_clk_i   )

      ,.link_io_tag_lines_i  ( prev_link_io_tag_lines_i   )
      ,.link_core_tag_lines_i( prev_link_core_tag_lines_i )
      ,.ct_core_tag_lines_i  ( prev_ct_core_tag_lines_i   )

      ,.ci_clk_i ( ci2_clk_i  )
      ,.ci_v_i   ( ci2_v_i    )
      ,.ci_data_i( ci2_data_i )
      ,.ci_tkn_o ( ci2_tkn_o  )

      ,.co_clk_o ( co2_clk_o  )
      ,.co_v_o   ( co2_v_o    )
      ,.co_data_o( co2_data_o )
      ,.co_tkn_i ( co2_tkn_i  )

      ,.links_i  ({ network_b_prev_ct_links_li, network_a_prev_ct_links_li })
      ,.links_o  ({ network_b_prev_ct_links_lo, network_a_prev_ct_links_lo })
      );
  
  bsg_chip_io_complex_router_network #(.ct_width_p( ct_width_p )
                                      ,.num_router_groups_p  ( network_a_num_router_groups_p )
                                      ,.num_in_p             ( network_a_num_in_p )
                                      ,.wh_cord_markers_pos_p( network_a_wh_cord_markers_pos_p )
                                      ,.wh_len_width_p       ( network_a_wh_len_width_p )
                                      ,.tag_cord_width_p     ( network_a_tag_cord_width_p )
                                      ,.num_repeater_nodes_p ( network_a_num_repeater_nodes_p )
                                      )
    network_a
      (.core_clk_i( core_clk_i )
      ,.rtr_core_tag_lines_i( network_a_rtr_core_tag_lines_i )
      
      ,.rtr_links_i ( network_a_rtr_links_i )
      ,.rtr_links_o ( network_a_rtr_links_o )
      ,.rtr_reset_o ( network_a_rtr_reset_o )
      ,.rtr_cord_o  ( network_a_rtr_cord_o  )
      
      ,.west_links_i( network_a_prev_ct_links_lo )
      ,.west_links_o( network_a_prev_ct_links_li )
      ,.east_links_i( network_a_next_ct_links_lo )
      ,.east_links_o( network_a_next_ct_links_li )
      );
      
  bsg_chip_io_complex_router_network #(.ct_width_p( ct_width_p )
                                      ,.num_router_groups_p  ( network_b_num_router_groups_p )
                                      ,.num_in_p             ( network_b_num_in_p )
                                      ,.wh_cord_markers_pos_p( network_b_wh_cord_markers_pos_p )
                                      ,.wh_len_width_p       ( network_b_wh_len_width_p )
                                      ,.tag_cord_width_p     ( network_b_tag_cord_width_p )
                                      ,.num_repeater_nodes_p ( network_b_num_repeater_nodes_p )
                                      )
    network_b
      (.core_clk_i( core_clk_i )
      ,.rtr_core_tag_lines_i( network_b_rtr_core_tag_lines_i )
      
      ,.rtr_links_i ( network_b_rtr_links_i )
      ,.rtr_links_o ( network_b_rtr_links_o )
      ,.rtr_reset_o ( network_b_rtr_reset_o )
      ,.rtr_cord_o  ( network_b_rtr_cord_o  )
      
      ,.west_links_i( network_b_prev_ct_links_lo )
      ,.west_links_o( network_b_prev_ct_links_li )
      ,.east_links_i( network_b_next_ct_links_lo )
      ,.east_links_o( network_b_next_ct_links_li )
      );

  bsg_chip_io_complex_links_ct_fifo #(.link_width_p              ( link_width_p )
                                     ,.link_channel_width_p      ( link_channel_width_p )
                                     ,.link_num_channels_p       ( link_num_channels_p )
                                     ,.link_lg_fifo_depth_p      ( link_lg_fifo_depth_p )
                                     ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_p )
                                     ,.link_use_extra_data_bit_p ( link_use_extra_data_bit_p )
                                     ,.ct_width_p                ( ct_width_p )
                                     ,.ct_num_in_p               ( ct_num_in_p )
                                     ,.ct_remote_credits_p       ( ct_remote_credits_p )
                                     ,.ct_use_pseudo_large_fifo_p( ct_use_pseudo_large_fifo_p )
                                     ,.ct_lg_credit_decimation_p ( ct_lg_credit_decimation_p )
                                     ,.num_hops_p                ( prev_num_hops_p )
                                     )
    next
      (.core_clk_i( core_clk_i )
      ,.io_clk_i  ( io_clk_i   )

      ,.link_io_tag_lines_i  ( next_link_io_tag_lines_i   )
      ,.link_core_tag_lines_i( next_link_core_tag_lines_i )
      ,.ct_core_tag_lines_i  ( next_ct_core_tag_lines_i   )

      ,.ci_clk_i ( ci_clk_i  )
      ,.ci_v_i   ( ci_v_i    )
      ,.ci_data_i( ci_data_i )
      ,.ci_tkn_o ( ci_tkn_o  )

      ,.co_clk_o ( co_clk_o  )
      ,.co_v_o   ( co_v_o    )
      ,.co_data_o( co_data_o )
      ,.co_tkn_i ( co_tkn_i  )

      ,.links_i ({ network_b_next_ct_links_li, network_a_next_ct_links_li })
      ,.links_o ({ network_b_next_ct_links_lo, network_a_next_ct_links_lo })
      );
    
endmodule