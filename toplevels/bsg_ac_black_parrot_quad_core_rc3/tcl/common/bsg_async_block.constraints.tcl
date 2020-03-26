puts "Info: Start script [info script]\n"

# clks = collection of clocks.
proc bsg_async_block {clks} {

  # Put clocks in async clock groups.
  #foreach_in_collection clk in $clks {
  #  set_clock_groups -async -group [get_clock $clk]
  #}

  # Create cdc clocks.
  foreach_in_collection clk $clks {
    set clk_period [get_attribute [get_clock $clk] period]
    set clk_name [get_attribute [get_clock $clk] name]
    set cdc_clk_name ${clk_name}_cdc
    set clk_sources [get_attribute [get_clock $clk] sources]
    create_clock -name $cdc_clk_name -period $clk_period $clk_sources -add
  }

  # Make sure cdc clocks are not propagated.
  remove_propagated_clock [get_clocks *_cdc]
 
  # No internal paths on cdc clocks.
  foreach_in_collection cdcclk [get_clocks *_cdc] {
    set_false_path -from [get_clock $cdcclk] -to [get_clock $cdcclk] 
  } 

  # Make cdc clocks physically exclusive from all other clocks.
  set_clock_groups -physically_exclusive \
    -group [get_clocks $clks] \
    -group [get_clocks *_cdc] 

  foreach_in_collection cdcclk [get_clocks *_cdc] {
    set other_cdcclks [remove_from_collection [get_clocks *_cdc] $cdcclk]
    # set group_path
    group_path -name async_paths -from $cdcclk -to $other_cdcclks
    # apply set max delay
    set_max_delay [get_attribute $cdcclk period] -from $cdcclk -to $other_cdcclks
    # apply set min delay
    set_min_delay 0 -from $cdcclk -to $other_cdcclks
  }

  # set false path to IO
  # we only care about paths to flops.
  set_false_path -from [get_clocks *_cdc] -to [all_outputs]
  
}

puts "Info: Completed script [info script]\n"
