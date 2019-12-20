
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set black_parrot_dir       $::env(BLACK_PARROT_DIR)

set bp_common_dir ${black_parrot_dir}/bp_common
set bp_top_dir    ${black_parrot_dir}/bp_top
set bp_fe_dir     ${black_parrot_dir}/bp_fe
set bp_be_dir     ${black_parrot_dir}/bp_be
set bp_me_dir     ${black_parrot_dir}/bp_me

# list of files to replace
set HARD_SWAP_FILELIST [join "
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_2r1w_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_misc/bsg_mux.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_clk_gen_osc.v
"]

set NETLIST_SOURCE_FILES [join "
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_atomic_delay_tuner.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_coarse_delay_tuner.v
  $basejump_stl_dir/hard/gf_14/bsg_clk_gen/bsg_rp_clk_gen_fine_delay_tuner.v
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

