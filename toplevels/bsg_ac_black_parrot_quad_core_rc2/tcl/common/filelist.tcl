#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set bsg_chip_dir           $::env(BSG_CHIP_DIR)
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set black_parrot_dir       $::env(BLACK_PARROT_DIR)
set bsg_designs_dir        $::env(BSG_DESIGNS_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir      $::env(BSG_PACKAGING_DIR)

set bsg_package           $::env(BSG_PACKAGE)
set bsg_pinout            $::env(BSG_PINOUT)
set bsg_padmapping        $::env(BSG_PADMAPPING)
set bsg_packaging_foundry $::env(BSG_PACKAGING_FOUNDRY)

set bp_common_dir ${black_parrot_dir}/bp_common
set bp_top_dir    ${black_parrot_dir}/bp_top
set bp_fe_dir     ${black_parrot_dir}/bp_fe
set bp_be_dir     ${black_parrot_dir}/bp_be
set bp_me_dir     ${black_parrot_dir}/bp_me

set SVERILOG_INCLUDE_PATHS [join "
  $bsg_packaging_dir/common/verilog
  $bsg_packaging_dir/common/foundry/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_packaging_foundry/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/$bsg_packaging_foundry/verilog/padmappings/$bsg_padmapping
  $basejump_stl_dir/bsg_clk_gen
  $basejump_stl_dir/bsg_dataflow
  $basejump_stl_dir/bsg_mem
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_test
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $bp_common_dir/src/include
  $bp_fe_dir/src/include
  $bp_be_dir/src/include
  $bp_be_dir/src/include/bp_be_dcache
  $bp_me_dir/src/include/v
  $bp_top_dir/src/include
"]

set SVERILOG_PACKAGE_FILES [join "
  $basejump_stl_dir/bsg_tag/bsg_tag_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_noc_pkg.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_pkg.v
  $bp_common_dir/src/include/bp_common_pkg.vh
  $bp_common_dir/src/include/bp_common_aviary_pkg.vh
  $bp_common_dir/src/include/bp_common_cfg_link_pkg.vh
  $bp_common_dir/src/include/bp_common_rv64_pkg.vh
  $bp_fe_dir/src/include/bp_fe_icache_pkg.vh
  $bp_fe_dir/src/include/bp_fe_pkg.vh
  $bp_be_dir/src/include/bp_be_pkg.vh
  $bp_be_dir/src/include/bp_be_dcache/bp_be_dcache_pkg.vh
  $bp_me_dir/src/include/v/bp_cce_pkg.v
  $bp_me_dir/src/include/v/bp_me_pkg.vh
  $bsg_designs_target_dir/v/bsg_chip_pkg.v
"]

# Best Practice: Keep bsg_defines first, then all pacakges (denoted by ending
# in _pkg). The rest of the files should allowed in any order.
set SVERILOG_SOURCE_FILES [join "
  $SVERILOG_PACKAGE_FILES
  $basejump_stl_dir/bsg_async/bsg_async_credit_counter.v
  $basejump_stl_dir/bsg_async/bsg_async_fifo.v
  $basejump_stl_dir/bsg_async/bsg_async_ptr_gray.v
  $basejump_stl_dir/bsg_async/bsg_launch_sync_sync.v
  $basejump_stl_dir/bsg_async/bsg_sync_sync.v
  $basejump_stl_dir/bsg_clk_gen/bsg_clk_gen.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged.v
  $basejump_stl_dir/bsg_dataflow/bsg_1_to_n_tagged_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_in.v
  $basejump_stl_dir/bsg_dataflow/bsg_channel_tunnel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_pseudo_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1r1w_small.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_1rw_large.v
  $basejump_stl_dir/bsg_dataflow/bsg_fifo_tracker.v
  $basejump_stl_dir/bsg_dataflow/bsg_flow_counter.v
  $basejump_stl_dir/bsg_dataflow/bsg_one_fifo.v
  $basejump_stl_dir/bsg_dataflow/bsg_parallel_in_serial_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_parallel_in_serial_out_dynamic.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_1_to_n.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_2_to_2.v
  $basejump_stl_dir/bsg_dataflow/bsg_round_robin_n_to_1.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out_dynamic.v
  $basejump_stl_dir/bsg_dataflow/bsg_serial_in_parallel_out_full.v
  $basejump_stl_dir/bsg_dataflow/bsg_shift_reg.v
  $basejump_stl_dir/bsg_dataflow/bsg_two_fifo.v
  $basejump_stl_dir/bsg_link/bsg_link_ddr_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_ddr_upstream.v
  $basejump_stl_dir/bsg_link/bsg_link_iddr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_oddr_phy.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_downstream.v
  $basejump_stl_dir/bsg_link/bsg_link_source_sync_upstream.v
  $basejump_stl_dir/bsg_mem/bsg_cam_1r1w.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1r1w_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_bit_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_mask_write_byte_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_1rw_sync_synth.v
  $basejump_stl_dir/bsg_mem/bsg_mem_2r1w_sync.v
  $basejump_stl_dir/bsg_mem/bsg_mem_2r1w_sync_synth.v
  $basejump_stl_dir/bsg_misc/bsg_adder_ripple_carry.v
  $basejump_stl_dir/bsg_misc/bsg_arb_fixed.v
  $basejump_stl_dir/bsg_misc/bsg_array_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_buf.v
  $basejump_stl_dir/bsg_misc/bsg_circular_ptr.v
  $basejump_stl_dir/bsg_misc/bsg_concentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clear_up.v
  $basejump_stl_dir/bsg_misc/bsg_counter_clock_downsample.v
  $basejump_stl_dir/bsg_misc/bsg_counter_set_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down.v
  $basejump_stl_dir/bsg_misc/bsg_counter_up_down_variable.v
  $basejump_stl_dir/bsg_misc/bsg_crossbar_o_by_i.v
  $basejump_stl_dir/bsg_misc/bsg_cycle_counter.v
  $basejump_stl_dir/bsg_misc/bsg_decode.v
  $basejump_stl_dir/bsg_misc/bsg_decode_with_v.v
  $basejump_stl_dir/bsg_misc/bsg_dff.v
  $basejump_stl_dir/bsg_misc/bsg_dff_chain.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en.v
  $basejump_stl_dir/bsg_misc/bsg_dff_en_bypass.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset.v
  $basejump_stl_dir/bsg_misc/bsg_dff_reset_en.v
  $basejump_stl_dir/bsg_misc/bsg_encode_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_gray_to_binary.v
  $basejump_stl_dir/bsg_misc/bsg_lfsr.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_decode.v
  $basejump_stl_dir/bsg_misc/bsg_lru_pseudo_tree_encode.v
  $basejump_stl_dir/bsg_misc/bsg_mux.v
  $basejump_stl_dir/bsg_misc/bsg_mux2_gatestack.v
  $basejump_stl_dir/bsg_misc/bsg_mux_butterfly.v
  $basejump_stl_dir/bsg_misc/bsg_mux_one_hot.v
  $basejump_stl_dir/bsg_misc/bsg_mux_segmented.v
  $basejump_stl_dir/bsg_misc/bsg_muxi2_gatestack.v
  $basejump_stl_dir/bsg_misc/bsg_nand.v
  $basejump_stl_dir/bsg_misc/bsg_nor3.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode.v
  $basejump_stl_dir/bsg_misc/bsg_priority_encode_one_hot_out.v
  $basejump_stl_dir/bsg_misc/bsg_reduce.v
  $basejump_stl_dir/bsg_misc/bsg_round_robin_arb.v
  $basejump_stl_dir/bsg_misc/bsg_scan.v
  $basejump_stl_dir/bsg_misc/bsg_strobe.v
  $basejump_stl_dir/bsg_misc/bsg_swap.v
  $basejump_stl_dir/bsg_misc/bsg_tielo.v
  $basejump_stl_dir/bsg_misc/bsg_thermometer_count.v
  $basejump_stl_dir/bsg_misc/bsg_transpose.v
  $basejump_stl_dir/bsg_misc/bsg_unconcentrate_static.v
  $basejump_stl_dir/bsg_misc/bsg_xnor.v
  $basejump_stl_dir/bsg_noc/bsg_mesh_stitch.v
  $basejump_stl_dir/bsg_noc/bsg_noc_repeater_node.v
  $basejump_stl_dir/bsg_noc/bsg_ready_and_link_async_to_wormhole.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_in.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_concentrator_out.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_adapter.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_adapter_in.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_adapter_out.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_decoder_dor.v
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_input_control.v  
  $basejump_stl_dir/bsg_noc/bsg_wormhole_router_output_control.v 
  $basejump_stl_dir/bsg_tag/bsg_tag_client.v
  $basejump_stl_dir/bsg_tag/bsg_tag_client_unsync.v
  $basejump_stl_dir/bsg_tag/bsg_tag_master.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_bypass.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_calculator_top.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_instr_decoder.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_int_alu.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_pipe_fp.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_pipe_int.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_pipe_mem.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_pipe_mul.v
  $bp_be_dir/src/v/bp_be_calculator/bp_be_regfile.v
  $bp_be_dir/src/v/bp_be_checker/bp_be_checker_top.v
  $bp_be_dir/src/v/bp_be_checker/bp_be_detector.v
  $bp_be_dir/src/v/bp_be_checker/bp_be_director.v
  $bp_be_dir/src/v/bp_be_checker/bp_be_scheduler.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_csr.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_dcache/bp_be_dcache.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_dcache/bp_be_dcache_lce.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_dcache/bp_be_dcache_lce_cmd.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_dcache/bp_be_dcache_lce_req.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_dcache/bp_be_dcache_wbuf.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_dcache/bp_be_dcache_wbuf_queue.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_mem_top.v
  $bp_be_dir/src/v/bp_be_mem/bp_be_ptw.v
  $bp_be_dir/src/v/bp_be_top.v
  $bp_common_dir/src/v/bp_addr_map.v
  $bp_common_dir/src/v/bsg_fifo_1r1w_fence.v
  $bp_common_dir/src/v/bsg_fifo_1r1w_rolly.v
  $bp_common_dir/src/v/bp_tlb.v
  $bp_common_dir/src/v/bp_tlb_replacement.v
  $bp_fe_dir/src/v/bp_fe_bht.v
  $bp_fe_dir/src/v/bp_fe_btb.v
  $bp_fe_dir/src/v/bp_fe_icache.v
  $bp_fe_dir/src/v/bp_fe_instr_scan.v
  $bp_fe_dir/src/v/bp_fe_lce.v
  $bp_fe_dir/src/v/bp_fe_lce_cmd.v
  $bp_fe_dir/src/v/bp_fe_lce_req.v
  $bp_fe_dir/src/v/bp_fe_pc_gen.v
  $bp_fe_dir/src/v/bp_fe_top.v
  $bp_me_dir/src/v/cce/bp_cce.v
  $bp_me_dir/src/v/cce/bp_cce_alu.v
  $bp_me_dir/src/v/cce/bp_cce_dir.v
  $bp_me_dir/src/v/cce/bp_cce_dir_lru_extract.v
  $bp_me_dir/src/v/cce/bp_cce_dir_tag_checker.v
  $bp_me_dir/src/v/cce/bp_cce_gad.v
  $bp_me_dir/src/v/cce/bp_cce_inst_decode.v
  $bp_me_dir/src/v/cce/bp_cce_msg.v
  $bp_me_dir/src/v/cce/bp_cce_pc.v
  $bp_me_dir/src/v/cce/bp_cce_pending.v
  $bp_me_dir/src/v/cce/bp_cce_reg.v
  $bp_me_dir/src/v/cce/bp_cce_msg_uncached.v
  $bp_me_dir/src/v/wormhole/bp_me_cce_id_to_cord.v
  $bp_me_dir/src/v/wormhole/bp_me_cce_to_wormhole_link_client.v
  $bp_me_dir/src/v/wormhole/bp_me_cce_to_wormhole_link_master.v
  $bp_me_dir/src/v/wormhole/bp_me_lce_id_to_cord.v
  $bp_me_dir/src/v/wormhole/bp_me_wormhole_packet_encode_lce_cmd.v
  $bp_me_dir/src/v/wormhole/bp_me_wormhole_packet_encode_lce_req.v
  $bp_me_dir/src/v/wormhole/bp_me_wormhole_packet_encode_lce_resp.v
  $bp_me_dir/src/v/wormhole/bp_me_wormhole_packet_encode_mem_cmd.v
  $bp_me_dir/src/v/wormhole/bp_me_wormhole_packet_encode_mem_resp.v
  $bp_top_dir/src/v/bp_processor.v
  $bp_top_dir/src/v/bp_core.v
  $bp_top_dir/src/v/bp_core_complex.v
  $bp_top_dir/src/v/bp_mem_complex.v
  $bp_top_dir/src/v/bp_clint.v
  $bp_top_dir/src/v/bp_clint_node.v
  $bp_top_dir/src/v/bp_tile.v
  $bp_top_dir/src/v/bp_tile_node.v
  $bsg_designs_dir/modules/bsg_chip_io_complex/bsg_chip_io_complex.v
  $bsg_designs_target_dir/v/bsg_chip.v
  $bsg_designs_target_dir/v/bsg_clk_gen_osc.v
  $bsg_designs_target_dir/v/bsg_clk_gen_power_domain.v
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog/bsg_chip_swizzle_adapter.v
"]

