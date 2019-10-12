
set basejump_stl_dir        $::env(BASEJUMP_STL_DIR)
set bsg_designs_target_dir  $::env(BSG_DESIGNS_TARGET_DIR)

set bsg_packaging_dir $::env(BSG_PACKAGING_DIR)
set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set black_parrot_dir        $::env(BLACK_PARROT_DIR)
set black_parrot_common_dir $::env(BLACK_PARROT_COMMON_DIR)
set black_parrot_top_dir    $::env(BLACK_PARROT_TOP_DIR)
set black_parrot_fe_dir     $::env(BLACK_PARROT_FE_DIR)
set black_parrot_be_dir     $::env(BLACK_PARROT_BE_DIR)
set black_parrot_me_dir     $::env(BLACK_PARROT_ME_DIR)

set SVERILOG_INCLUDE_PATHS [join "
  $bsg_packaging_dir/common/verilog
  $bsg_packaging_dir/common/foundry/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog/padmappings/$bsg_padmapping
  $basejump_stl_dir/bsg_clk_gen
  $basejump_stl_dir/bsg_dataflow
  $basejump_stl_dir/bsg_mem
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_test
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $black_parrot_common_dir/src/include
  $black_parrot_fe_dir/src/include
  $black_parrot_be_dir/src/include
  $black_parrot_be_dir/src/include/bp_be_dcache
  $black_parrot_me_dir/src/include/v
  $black_parrot_top_dir/src/include
"]
