# list of files to replace
set HARD_SWAP_FILELIST [join "
  $basejump_stl_dir/hard/tsmc_40/bsg_clk_gen/bsg_clk_gen_osc.v
  $basejump_stl_dir/hard/tsmc_40/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/hard/tsmc_40/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v
  $basejump_stl_dir/hard/tsmc_40/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $basejump_stl_dir/hard/tsmc_40/bsg_mem/bsg_mem_2r1w_sync.v
  $basejump_stl_dir/hard/tsmc_40/bsg_misc/bsg_mux.v
"]

set NETLIST_SOURCE_FILES [join "
  $basejump_stl_dir/hard/tsmc_40/bsg_clk_gen/bsg_rp_clk_gen_atomic_delay_tuner.v
  $basejump_stl_dir/hard/tsmc_40/bsg_clk_gen/bsg_rp_clk_gen_coarse_delay_tuner.v
  $basejump_stl_dir/hard/tsmc_40/bsg_clk_gen/bsg_rp_clk_gen_fine_delay_tuner.v
  $bsg_chip_dir/pdk_prep/soft_ip/bsg/bsg_misc/bsg_rp_tsmc_40_CLKINVX16.v
  $bsg_chip_dir/pdk_prep/soft_ip/bsg/bsg_misc/bsg_rp_tsmc_40_MXI4X4.v
  $bsg_chip_dir/pdk_prep/soft_ip/bsg/bsg_misc/bsg_rp_tsmc_40_mux_w2_b16.v
  $bsg_chip_dir/pdk_prep/soft_ip/bsg/bsg_misc/bsg_rp_tsmc_40_mux_w2_b32.v
  $bsg_chip_dir/pdk_prep/soft_ip/bsg/bsg_misc/bsg_rp_tsmc_40_mux_w2_b33.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

