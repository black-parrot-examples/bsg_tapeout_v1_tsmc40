// simple example of a frame-award loopback node
//
// it uses a simple two element FIFO
//

module bsg_frame_loopback
  import bsg_fsb_pkg::*;

 #(ring_width_p="inv"
   ,bsg_fsb_in_s_width_lp      = `bsg_fsb_in_s_width (ring_width_lp)
   ,bsg_fsb_out_s_width_lp     = `bsg_fsb_out_s_width(ring_width_lp)
   )
   (input clk_i
    ,input  [bsg_fsb_in_s_width_lp -1:0] fsb_i
    ,output [bsg_fsb_out_s_width_lp-1:0] fsb_o
    );

   `declare_bsg_fsb_in_s(ring_width_lp);
   `declare_bsg_fsb_out_s(ring_width_lp);

   bsg_fsb_in_s  fsb_i_cast;
   bsg_fsb_out_s fsb_o_cast;

   assign bsg_fsb_i_cast = bsg_fsb_i;
   assign bsg_fsb_o      = bsg_fsb_o_cast;

   wire reset_i = fsb_i.reset_r;

   initial assert (ring_width_lp == $bits(bsg_fsb_pkt_s))
     else $error("ring_width_lp(%d) and bsg_fsb_pkt_s(%d) size mismatch",ring_width_lp,$bits(bsg_fsb_pkt_s));

   bsg_fsb_pkt_s fifo_data, out_pkt;

   bsg_two_fifo #(.width_p(ring_width_p))
   (.clk_i
    ,.reset_i
    ,.v_i    (fsb_i_cast.v        )
    ,.data_i (fsb_i_cast.data     )
    ,.ready_o(fsb_o_cast.ready_rev)

    ,.v_o   (fsb_o_cast.v       )
    ,.data_o(fifo_data          )
    ,.yumi_i(fsb_i_cast.yumi_rev)
    );

   // flip srcid and destid
   always_comb
     begin
        out_pkt        = fifo_data;
        out_pkt.destid = fifo_data.srcid;
        out_pkt.srcid  = fifo_data.destid;
     end

   assign fsb_o_cast.data = out_pkt;

endmodule
