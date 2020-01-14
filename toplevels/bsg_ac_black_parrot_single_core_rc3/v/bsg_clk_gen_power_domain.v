`include "bsg_tag.vh"

module bsg_clk_gen_power_domain

import bsg_tag_pkg::bsg_tag_s;

#(parameter num_clk_endpoint_p = "inv"
, parameter ds_width_p         = 8
, parameter num_adgs_p         = 1
)

( // bsg_tag signals
  input bsg_tag_s                          async_reset_tag_lines_i
, input bsg_tag_s [num_clk_endpoint_p-1:0] osc_tag_lines_i
, input bsg_tag_s [num_clk_endpoint_p-1:0] osc_trigger_tag_lines_i
, input bsg_tag_s [num_clk_endpoint_p-1:0] ds_tag_lines_i
, input bsg_tag_s [num_clk_endpoint_p-1:0] sel_tag_lines_i

// external clock input
, input [num_clk_endpoint_p-1:0] ext_clk_i

// output clocks
, output logic [num_clk_endpoint_p-1:0] clk_o
);

  logic async_reset_lo;

  bsg_tag_client_unsync #( .width_p(1) )
    btc_async_reset
      (.bsg_tag_i(async_reset_tag_lines_i)
      ,.data_async_r_o(async_reset_lo)
      );

  logic [num_clk_endpoint_p-1:0][1:0] clk_select;

  for (genvar i = 0; i < num_clk_endpoint_p; i++)
    begin: clk_gen

      bsg_tag_client_unsync #( .width_p(2) )
        btc_clk_select
          (.bsg_tag_i(sel_tag_lines_i[i])
          ,.data_async_r_o(clk_select[i])
          );

      bsg_clk_gen #(.downsample_width_p(ds_width_p)
                   ,.num_adgs_p(num_adgs_p)
                   ,.version_p(2)
                   )
        clk_gen_inst
          (.async_osc_reset_i     (async_reset_lo)
          ,.bsg_osc_tag_i         (osc_tag_lines_i[i])
          ,.bsg_osc_trigger_tag_i (osc_trigger_tag_lines_i[i])
          ,.bsg_ds_tag_i          (ds_tag_lines_i[i])
          ,.ext_clk_i             (ext_clk_i[i])
          ,.select_i              (clk_select[i])
          ,.clk_o                 (clk_o[i])
          );

    end

endmodule
