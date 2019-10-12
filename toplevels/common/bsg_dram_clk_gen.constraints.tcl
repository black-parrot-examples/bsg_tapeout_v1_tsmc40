puts "Info: Start script [info script]\n"

proc bsg_dram_clk_gen_clock_create { osc_path clk_name clk_gen_period_int } {
  # very little is actually timed with this domain; just the receive
  # side of the bsg_tag_client and the downsampler.
  #
  # Although the fastest target period of the oscillator itself is below
  # this, we don't want this support logic to not be able to keep up
  # in the event that oscillator runs faster than the tools say
  #

  # this is for the output of the downsampler, goes to the clock selection mux
  set clk_gen_period_ds [expr $clk_gen_period_int * 2.0]

  # this is for the output of the oscillator, which goes to the downsampler
  create_clock -period $clk_gen_period_int -name ${clk_name}_osc [get_pins -leaf -of_objects [get_nets ${osc_path}osc_clk_o] -filter "pin_direction==out"]

  echo "Detecting Version 1/2 of bsg_clk_gen"
  set buf_btc_o_search [sizeof_collection [get_pins ${osc_path}clk_gen_osc_inst/fdt/buf_btc_o]]
  echo $buf_btc_o_search
  # for version 1 bsg_clk_gen
  if { $buf_btc_o_search } {
    echo "Detected Version 1 of bsg_clk_gen"
    # this is for the output of the oscillator, which goes to the osc's bt client
    create_clock -period $clk_gen_period_int -name ${clk_name}_btc [get_pins ${osc_path}clk_gen_osc_inst/fdt/buf_btc_o]
    # clock domains being crossed into via bsg_tag
    bsg_tag_add_client_cdc_timing_constraints $bsg_tag_clk_name ${clk_name}_btc
  } else {
    echo "Detected Version 2 of bsg_clk_gen"
    # if we do this, it adds lots of buffers which is a big problem.
    #create_clock -period $clk_gen_period_int -name ${clk_name}_btc [get_pins ${osc_path}/clk_gen_osc_inst/fdt/o]
    # clock domains being crossed into via bsg_tag
    #bsg_tag_add_client_cdc_timing_constraints $bsg_tag_clk_name ${clk_name}_btc
  }

  create_generated_clock -name ${clk_name}_osc_ds \
                         -divide_by 2 \
                         -source [get_attribute [get_clocks ${clk_name}_osc] sources] \
                         [get_pins -leaf -of_objects [get_nets ${osc_path}div_clk_o] -filter "pin_direction==out"]
}

puts "Info: Completed script [info script]\n"
