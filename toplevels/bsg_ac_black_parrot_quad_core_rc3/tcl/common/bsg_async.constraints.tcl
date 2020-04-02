puts "Info: Start script [info script]\n"

############################################
#
# cdc timing assertions
#
# this is a general procedure for constraining all the cdc paths in a design
# metastability issues should be fixed by synchronizers (two-stage dff) in the design
# a timing path between a clock and its generated clock is a synchronous path
# read http://www.zimmerdesignservices.com/mydownloads/no_mans_land_20130328.pdf for 
# motivation and more details
proc bsg_async_icl {} {
  # find all clocks in the design
  set clocks [all_clocks]
  foreach_in_collection launch_clk $clocks {
    # the source clock and its generated clocks should be put into the same launch clock group
    if { [get_attribute $launch_clk is_generated] } {
      set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk master_clock_name]"]
      append_to_collection launch_group [get_attribute $launch_clk master_clock]
    } else {
      set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk name]"]
      append_to_collection launch_group $launch_clk
    }
    # the latch clock should be a clock which is not in the launch clock group
    foreach_in_collection latch_clk [remove_from_collection $clocks $launch_group] {
      set launch_period [get_attribute $launch_clk period]
      #set latch_period [get_attribute $latch_clk period]
      #set max_delay_ps [expr min($launch_period,$latch_period)/2]
      # we use -ignore_clock_latency to avoid taking clock network delay into account
      #set_max_delay $max_delay_ps -from $launch_clk -to $latch_clk -ignore_clock_latency
      set_max_delay $launch_period -from $launch_clk -to $latch_clk -ignore_clock_latency
      set_min_delay 0              -from $launch_clk -to $latch_clk -ignore_clock_latency
    }
  }
}


# async constraint script based on creating shadow "_cdc" clock.
# clks = collection of clocks.
#
proc bsg_async_cdc { clks } {

  # Report clocks
  report_clock $clks

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
    -group [remove_from_collection [all_clocks] [get_clocks *_cdc]] \
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
