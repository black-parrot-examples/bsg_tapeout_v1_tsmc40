puts "Info: Start script [info script]\n"

proc bsg_tag_clock_create { clk_name clk_source tag_data tag_attach period {uncertainty 0}} {
    # this is the scan chain
    create_clock -period $period -name $clk_name $clk_source

    # apply uncertainty
    set_clock_uncertainty ${uncertainty} [get_clocks ${clk_name}]

    # we set the input delay of these pins to be half the bsg_tag clock period; we launch on the negative edge and clock and
    # data travel in parallel, so should be about right
    set_input_delay [expr $period  / 2.0] -clock $clk_name $tag_data

    # this signal is relative to the bsg_tag_clk, but is used in the bsg_tag_client in a CDC kind of way
    set_input_delay [expr $period  / 2.0] -clock $clk_name $tag_attach
}

puts "Info: Completed script [info script]\n"
