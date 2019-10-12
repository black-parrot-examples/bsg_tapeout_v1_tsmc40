
############################################
#
# bsg_clk_gen timing assertions
#
# note: you need to create the BSG_TAG clock first
#
#

proc bsg_dram_clk_gen_clock_create { osc_path clk_name bsg_tag_clk_name clk_gen_period_int clk_gen_period_ext clock_uncertainty_percent } {

    # very little is actually timed with this domain; just the receive
    # side of the bsg_tag_client and the downsampler.
    #
    # Although the fastest target period of the oscillator itself is below
    # this, we don't want this support logic to not be able to keep up
    # in the event that oscillator runs faster than the tools say
    #

    # this is for the output of the downsampler, goes to the clock selection mux
    set clk_gen_period_ds [expr $clk_gen_period_int * 2]

    # this is for the output of the oscillator, which goes to the downsampler
    create_clock -period $clk_gen_period_int -name ${clk_name}_osc [get_pins -leaf -of_objects [get_nets ${osc_path}osc_clk_o] -filter "pin_direction==out"]
    set_clock_uncertainty  [expr ($clock_uncertainty_percent * $clk_gen_period_int) / 100.0] ${clk_name}_osc
    #set_disable_timing [get_cells ${osc_path}clk_gen_osc_inst/adt/*]
    #set_disable_timing [get_cells ${osc_path}clk_gen_osc_inst/cdt/*]
    #set_disable_timing [get_cells ${osc_path}clk_gen_osc_inst/fdt/*]

    echo "Detecting Version 1/2 of bsg_clk_gen"
    set buf_btc_o_search [sizeof_collection [get_pins ${osc_path}clk_gen_osc_inst/fdt/buf_btc_o]]
    echo $buf_btc_o_search

    # for version 1 bsg_clk_gen
    if {$buf_btc_o_search} {
        echo "Detected Version 1 of bsg_clk_gen"
        # this is for the output of the oscillator, which goes to the osc's bt client
        create_clock -period $clk_gen_period_int -name ${clk_name}_btc [get_pins ${osc_path}clk_gen_osc_inst/fdt/buf_btc_o]
        set_clock_uncertainty  [expr ($clock_uncertainty_percent * $clk_gen_period_int) / 100.0] ${clk_name}_btc
        # clock domains being crossed into via bsg_tag
        bsg_tag_add_client_cdc_timing_constraints $bsg_tag_clk_name ${clk_name}_btc

    } else {
        echo "Detected Version 2 of bsg_clk_gen"
	# if we do this, it adds lots of buffers which is a big problem.
        #create_clock -period $clk_gen_period_int -name ${clk_name}_btc [get_pins ${osc_path}/clk_gen_osc_inst/fdt/o]
        #set_clock_uncertainty  [expr ($clock_uncertainty_percent * $clk_gen_period_int) / 100.0] ${clk_name}_btc
        # clock domains being crossed into via bsg_tag
        #bsg_tag_add_client_cdc_timing_constraints $bsg_tag_clk_name ${clk_name}_btc
    }

    # these are generated clocks; we call them clocks to get preferred shielding and routing
    # nothing is actually timed with these

    create_clock -period $clk_gen_period_ds  -name ${clk_name}_osc_ds [get_pins -leaf -of_objects [get_nets ${osc_path}div_clk_o] -filter "pin_direction==out"]
    set_clock_uncertainty  [expr ($clock_uncertainty_percent * $clk_gen_period_int) / 100.0] ${clk_name}_osc_ds

    # the output of the mux is the externally visible bonafide clock
    #create_clock -period $clk_gen_period_ext -name ${clk_name}        [get_pins -leaf -of_objects [get_nets ${osc_path}clk_o] -filter "pin_direction==out"]
    #set_clock_uncertainty  [expr ($clock_uncertainty_percent * $clk_gen_period_ext) / 100.0] ${clk_name}

    # clock domains being crossed into via bsg_tag
    bsg_tag_add_client_cdc_timing_constraints $bsg_tag_clk_name ${clk_name}_osc
}
