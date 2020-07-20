puts "BSG-info: Running script [info script]\n"

set OSC_PERIOD 1.0

# core clock (everything that isn't a part of another clock is on this domain)
set ROUTER_CLK_NAME   "router_clk"
set ROUTER_CLK_PERIOD 2.5

# 2x clock for DDR IO paths (1x clock generated from this clock)
set IOM_CLK_NAME   "io_master_clk"
set IOM_CLK_PERIOD 2.5

# main clock running the manycore complex
set CORE_CLK_NAME   "bp_clk"
set CORE_CLK_PERIOD 2.5

# main clock running the dram controller and phy
set DFI_CLK_2X_NAME   "dfi_clk_2x"
set DFI_CLK_2X_PERIOD 2.5
set DFI_CLK_1X_NAME   "dfi_clk_1x"

# tag clock
set TAG_CLK_NAME   "tag_clk"
set TAG_CLK_PERIOD 10.0

puts "BSG-info: Completed script [info script]\n"
