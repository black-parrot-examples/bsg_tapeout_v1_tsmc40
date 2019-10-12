// replays a trace

module  bsg_test_node_master
   import bsg_fsb_pkg::*;
  #(parameter ring_width_p="inv"
    , parameter enable_MITM_stimulus_p = 0
    , parameter enable_MITM_response_p = 0
    , parameter master_id_p="inv"
    , parameter client_id_p="inv"
    )

  (input clk_i
   , input reset_i

   // control
   , input en_i
   , output done_o
   , output error_o

   // input channel
   , input  v_i
   , input [ring_width_p-1:0] data_i
   , output ready_o

   // output channel
   , output v_o
   , output [ring_width_p-1:0] data_o
   , input yumi_i   // late

   );

   // guaranteed not to exceed
   localparam rom_addr_width_lp=32;

   wire done_lo, error_lo;

   localparam trace_width_lp = ring_width_p+4;

   wire [trace_width_lp-1:0  ]   rom_data_lo;
   wire [rom_addr_width_lp-1:0]  rom_addr_li;

   bsg_fsb_node_trace_replay
     #(.ring_width_p(ring_width_p)
       ,.rom_addr_width_p(rom_addr_width_lp)
       ) tr
       (.clk_i

        ,.reset_i
        ,.en_i

        ,.v_i
        ,.data_i
        ,.ready_o

        ,.v_o
        ,.data_o
        ,.yumi_i

        ,.rom_addr_o(rom_addr_li)
        ,.rom_data_i(rom_data_lo)

        ,.done_o(done_lo)
        ,.error_o(error_lo)
        );

if( enable_MITM_stimulus_p  == 1'b1 ) begin
   bsg_fsb_MITM_stimulus_rom #(.width_p      (trace_width_lp    )
                        ,.addr_width_p(rom_addr_width_lp)
                        ) rom
     (.addr_i (rom_addr_li)
      ,.data_o(rom_data_lo)
      );
end else if( enable_MITM_response_p  == 1'b1 ) begin
   bsg_fsb_MITM_response_rom #(.width_p      (trace_width_lp    )
                        ,.addr_width_p(rom_addr_width_lp)
                        ) rom
     (.addr_i (rom_addr_li)
      ,.data_o(rom_data_lo)
      );
end else begin
   bsg_fsb_master_rom #(.width_p      (trace_width_lp    )
                        ,.addr_width_p(rom_addr_width_lp)
                        ) rom
     (.addr_i (rom_addr_li)
      ,.data_o(rom_data_lo)
      );
end


   assign done_o = done_lo;
   assign error_o = error_lo;

endmodule

