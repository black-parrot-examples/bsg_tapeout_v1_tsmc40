
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set blackparrot_dir        $::env(BLACKPARROT_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)

set bsg_packaging_dir $::env(BSG_PACKAGING_DIR)
set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set TESTING_INCLUDE_PATHS [join "
  $blackparrot_dir/bp_top/src/include
  $blackparrot_dir/bp_common/src/include
  $blackparrot_dir/bp_fe/src/include
  $blackparrot_dir/bp_be/src/include
  $blackparrot_dir/bp_be/src/include/bp_be_dcache/
  $blackparrot_dir/bp_me/src/include/v
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_cache
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $basejump_stl_dir/testing/bsg_dmc/lpddr_verilog_model/
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
"]
