// MBT 8/3/2016
//

// **************************************************************
// *
// * pull in macros that define I/Os
// * see bsg_packaging
// *

`include "bsg_iopad_macros.v"

module bsg_frame #(parameter gateway_p="inv"   // 0 or 1
                   ,parameter nodes_p="inv")   // 1 to N

// **************************************************************
// *
// * pull in top-level module signature, corresponding to pinout
// * also defines the I/O pads
// *

`include "bsg_pinout.v"

// ***********************************
// *
// * pack bsg_comm_link into structs; swizzle
// *
// *

`include "bsg_comm_link.vh"

`declare_bsg_comm_link_channel_in_s (8);
`declare_bsg_comm_link_channel_out_s(8);

`define SWIZZLE_3120(a) { a[3], a[1], a[2], a[0] }

   bsg_comm_link_channel_in_s  [3:0] ch_li;
   bsg_comm_link_channel_out_s [3:0] ch_lo;

   bsg_comm_link_group #(.num_channels_p(4), ,.channel_width_p(8)) bclg
     (.co_i(ch_lo)
      ,.ci_o(ch_li)

      // we reverse input channels 1 and 2 for physical design
      ,.sdi_sclk_i (`SWIZZLE_3120(sdi_sclk_i_int ))
      ,.sdi_ncmd_i (`SWIZZLE_3120(sdi_ncmd_i_int ))
      ,.sdi_data_i({sdi_D_data_i_int, sdi_B_data_i_int, sdi_C_data_i_int, sdi_A_data_i_int})

      ,.sdi_token_o(`SWIZZLE_3120(sdi_token_o_int))

      // no reversal of output channels
      ,.sdo_sclk_o (sdo_sclk_o_int )
      ,.sdo_ncmd_o (sdo_ncmd_o_int )
      ,.sdo_data_o({sdi_D_data_i_int, sdi_C_data_i_int, sdi_B_data_i_int, sdi_A_data_i_int})
      ,.sdo_token_i(sdo_token_o_int)
      );

   // ***********************************
   // *
   // * instantiate body of chip
   // *
   // *

   logic im_slave_reset_tline_r_lo;
   logic core_calib_reset_r_lo;

   bsg_frame_core      #(.uniqueness_p(1)
                         ,.gateway_p(gateway_p)
                         ,.nodes_p  (nodes_p  )
                        ) bcc
     (.core_clk_i            (misc_L_i_int[3])
      ,.async_reset_i        (reset_i_int    )
      ,.io_master_clk_i      (PLL_CLK_i_int  )

      ,.bsg_comm_link_i      (ch_li)
      ,.bsg_comm_link_o      (ch_lo)

      // unused by ASIC, but used by Gateway (goes to reset of ASIC)
      ,.im_slave_reset_tline_r_o()
      ,.core_calib_reset_r_o    (core_calib_reset_r_lo    ) // post calibration reset; unused; could be useful to have as output pin
      );

   // we borrow this pin:

   // on an ASIC, this pin means that calibration has finished

   assign sdo_tkn_ex_o_int = core_calib_reset_r_lo;

endmodule
