// this is an example of a test node client that is paired with bsg_guts

module  bsg_test_node_client
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

   localparam debug_lp=1;

   // synopsys translate_off
   if (debug_lp)
     begin
        always @(negedge clk_i)
          if (v_i & ready_o)
            $display("## bsg_test_node_client received %x",data_i);

        always @(negedge clk_i)
          if (v_o & yumi_i)
            $display("## bsg_test_node_client sent %x",data_o);
     end
   // synopsys translate_on

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

   // client: a loopback device
   always_comb
     begin
        // out_fifo_data        = in_fifo_data;
        // we explicitly list the fields here since it is an example
        out_fifo_data.cmd    = in_fifo_data.cmd;
        out_fifo_data.opcode = in_fifo_data.opcode;
        out_fifo_data.data   = in_fifo_data.data;

        // swap source and dest
        out_fifo_data.srcid  = in_fifo_data.destid;
        out_fifo_data.destid = in_fifo_data.srcid;
     end

   /* begin your code here */

   // en_i is not really necessary
   // but we do it to prevent unused input
   assign out_fifo_v    = in_fifo_v & en_i;
   assign in_fifo_yumi  = out_fifo_v & out_fifo_ready;


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

