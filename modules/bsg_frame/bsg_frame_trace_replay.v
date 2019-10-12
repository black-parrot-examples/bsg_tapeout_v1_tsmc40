//
// trace replay node
//
// mostly just a wrapper around bsg_fsb_node_trace_replay
//

module bsg_frame_trace_replay
  import bsg_fsb_pkg::*;

 #(ring_width_p="inv"
   ,rom_addr_width_p           = "inv"
   ,bsg_fsb_in_s_width_lp      = `bsg_fsb_in_s_width (ring_width_lp)
   ,bsg_fsb_out_s_width_lp     = `bsg_fsb_out_s_width(ring_width_lp)

   )
   (input clk_i
    ,input  [bsg_fsb_in_s_width_lp -1:0] fsb_i
    ,output [bsg_fsb_out_s_width_lp-1:0] fsb_o

    ,output [rom_addr_width_p-1:0] rom_addr_o
    ,input  [ring_width_p+4-1:0] rom_data_i

    ,output logic done_o
    ,output logic error_o
    );

   `declare_bsg_fsb_in_s(ring_width_lp);
   `declare_bsg_fsb_out_s(ring_width_lp);

   bsg_fsb_in_s  fsb_i_cast;
   bsg_fsb_out_s fsb_o_cast;

   assign fsb_i_cast = fsb_i;
   assign fsb_o      = fsb_o_cast;

   initial assert (ring_width_lp == $bits(bsg_fsb_pkt_s))
     else $error("ring_width_lp(%d) and bsg_fsb_pkt_s(%d) size mismatch",ring_width_lp,$bits(bsg_fsb_pkt_s));

   wire reset_i = fsb_i_cast.reset_r;

   bsg_fsb_node_trace_replay
     #(.ring_width_p     (ring_width_p    )
       ,.rom_addr_width_p(rom_addr_width_p)
       ) tr
   (.clk_i
    ,.reset_i
    ,.en_i    (fsb_i_cast.en_r)

    ,.v_i     (fsb_i_cast.v        )
    ,.data_i  (fsb_i_cast.data     )
    ,.ready_o (fsb_o_cast.ready_rev)

    ,.v_o     (fsb_o_cast.v       )
    ,.data_o  (fsb_o_cast.data    )
    ,.yumi_i  (fsb_i_cast.yumi_rev)

    ,.rom_addr_o
    ,.rom_data_i

    ,.done_o
    ,.error_o
    );

endmodule

