// this is an example of a test node master that is paired with bsg_guts

module  bsg_test_node_master
   import bsg_fsb_pkg::*;
  #(parameter ring_width_p="inv"
    , parameter master_id_p="inv"
    , parameter client_id_p="inv"
    )

  (input clk_i
   , input reset_i

   // control
   , input en_i

   // input channel
   , input  v_i
   , input [ring_width_p-1:0] data_i
   , output ready_o

   // output channel
   , output v_o
   , output [ring_width_p-1:0] data_o
   , input yumi_i   // late

   );

   localparam debug_lp=0;

   // the default interface gives all design
   // control to the switch: you have to say
   // ahead of time if you can receive data
   // and it won't tell you until the last minute
   // if it took your data.

   // we reverse the situation by having an
   // input and output fifo. these
   // are not required, but make the hw
   // design easier at the cost of some
   // area and latency.

   wire                    in_fifo_v;
   bsg_fsb_pkt_s           in_fifo_data;
   wire                    in_fifo_yumi;

   wire                    out_fifo_ready;
   bsg_fsb_pkt_s           out_fifo_data;
   wire                    out_fifo_v;

   bsg_two_fifo #( .width_p(ring_width_p)) fifo_in
     (.clk_i(clk_i)

      ,.reset_i(reset_i)

      ,.ready_o(ready_o)
      ,.v_i    (v_i    )
      ,.data_i (data_i )

      ,.v_o   (in_fifo_v)
      ,.data_o(in_fifo_data)
      ,.yumi_i(in_fifo_yumi)
      );

   /* your code here */

   logic [1:0] 		   state_r, state_n;

   always @(posedge clk_i)
     if (reset_i)
       state_r <= 0;
     else
       state_r <= state_n;


   if (debug_lp)
     always @(negedge clk_i)
       if (~reset_i && (state_r != state_n))
	 $display("## bsg_test_node_master transitioning from state %x to state %x",state_r,state_n);

   always_comb
     begin
        state_n = state_r;
        unique case (state_r)
          2'b00:
            if (out_fifo_ready)
              state_n = 2'b01;
          2'b01:
            if (out_fifo_ready)
              state_n = 2'b10;
          default:
            begin
            end

        endcase // unique case (state_r)
     end

   wire [8*8-1:0] data_gen;

   // mbt: first step is to
   // reset the remote node.
   // second step is to
   // enable it.

   // send data to client node
   test_bsg_data_gen
     #(.channel_width_p(8)
       ,.num_channels_p(8)
       ,.debug_p(debug_lp)
       ) gen_out
       (.clk_i   (clk_i)
        ,.reset_i(reset_i)
        ,.yumi_i (out_fifo_ready && (state_r == 2'b10))
        ,.o      (data_gen)
        );

   // shouldn't matter if we wait for enable.
   // but this gets rid of an unused input warning
   assign out_fifo_v = en_i;  //1'b1;

   assign out_fifo_data.srcid = master_id_p;
   assign out_fifo_data.destid = client_id_p;

   // opcodes are valid only when cmd = 1, otherwise they are discarded
   assign out_fifo_data.opcode = (state_r == 2'b00)?
                                 RNRESET_DISABLE_CMD
                                 : RNENABLE_CMD;

   assign out_fifo_data.cmd = (state_r == 2'b10)? '0 : '1;
   assign out_fifo_data.data = data_gen;

   // receive data from client node

   wire [8*8-1:0] data_check;

   test_bsg_data_gen
     #(.channel_width_p(8)
       ,.num_channels_p(8)
       ,.debug_p(debug_lp)
       ) gen_in
       (.clk_i(clk_i)
        ,.reset_i(reset_i)
        ,.yumi_i(in_fifo_v)
        ,.o(data_check)
        );

   // synopsys translate_off

   // check data coming in
   always @(negedge clk_i)
     if (in_fifo_v & ~reset_i)
       assert(data_check == in_fifo_data.data)
         else $error("check mismatch %x %x ", data_check,in_fifo_data);

   // synopsys translate_on

   assign in_fifo_yumi = in_fifo_v;

   /* end your code here */

   bsg_two_fifo #( .width_p(ring_width_p)) fifo_out
     (.clk_i(clk_i)

      ,.reset_i(reset_i)

      ,.ready_o(out_fifo_ready)
      ,.v_i    (out_fifo_v    )
      ,.data_i (out_fifo_data )

      ,.v_o   (v_o   )
      ,.data_o(data_o)
      ,.yumi_i(yumi_i)
      );


endmodule

