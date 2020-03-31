puts "BSG-info: Running script [info script]\n"

source -echo -verbose bsg_tag.constraints.tcl
source -echo -verbose bsg_clk_gen.constraints.tcl
source -echo -verbose bsg_link.constraints.tcl
source -echo -verbose bsg_dmc.constraints.tcl
source -echo -verbose bsg_async.constraints.tcl

source -echo -verbose clock_variables.tcl

foreach_in_collection adt [get_cells -hier adt] {
  set path [get_attribute $adt full_name]
  set_disable_timing [get_cells $path/M1]
  set_disable_timing [get_cells $path/sel_r_reg_0]
}

foreach_in_collection cdt [get_cells -hier cdt] {
  set path [get_attribute $cdt full_name]
  set_disable_timing [get_cells $path/M1]
}

foreach_in_collection fdt [get_cells -hier fdt] {
  set path [get_attribute $fdt full_name]
  set_disable_timing [get_cells $path/M2]
}

#bsg_tag_clock_create $TAG_CLK_NAME p_bsg_tag_clk_i p_bsg_tag_data_i p_bsg_tag_en_i $TAG_CLK_PERIOD 0.1
bsg_tag_clock_create $TAG_CLK_NAME \
                     [get_pins -of_objects [get_cells -of_objects [get_ports p_bsg_tag_clk_i]] -filter "name==C"] \
                     [get_pins -of_objects [get_cells -of_objects [get_ports p_bsg_tag_data_i]] -filter "name==C"] \
                     [get_pins -of_objects [get_cells -of_objects [get_ports p_bsg_tag_en_i]] -filter "name==C"] \
                     $TAG_CLK_PERIOD 0.1

bsg_clk_gen_clock_create $CORE_CLK_NAME   $OSC_PERIOD $CORE_CLK_PERIOD   0.1 0.1 0.1
bsg_clk_gen_clock_create $IOM_CLK_NAME    $OSC_PERIOD $IOM_CLK_PERIOD    0.1 0.1 0.1
bsg_clk_gen_clock_create $ROUTER_CLK_NAME $OSC_PERIOD $ROUTER_CLK_PERIOD 0.1 0.1 0.1
#bsg_clk_gen_clock_create $DFI_CLK_2X_NAME $DFI_CLK_2X_PERIOD $DFI_CLK_2X_PERIOD 0.1 0.1 0.1
#create_generated_clock -name $DFI_CLK_1X_NAME -divide_by 2 -source [get_attribute [get_clocks $DFI_CLK_2X_NAME] sources] -master_clock [get_clocks $DFI_CLK_2X_NAME] [get_pins -leaf -of_objects [get_nets -hierarchical ${DFI_CLK_1X_NAME}_lo] -filter "direction==out"]

create_clock -period $OSC_PERIOD -name ${CORE_CLK_NAME}_ext   [get_pins -of_objects [get_cells -of_objects [get_ports p_clk_A_i]] -filter "name==C"]
create_clock -period $OSC_PERIOD -name ${IOM_CLK_NAME}_ext    [get_pins -of_objects [get_cells -of_objects [get_ports p_clk_B_i]] -filter "name==C"]
create_clock -period $OSC_PERIOD -name ${ROUTER_CLK_NAME}_ext [get_pins -of_objects [get_cells -of_objects [get_ports p_clk_C_i]] -filter "name==C"]

global io_link
set gid 0
set io_link($gid,clk_i)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_clk_i]] -filter "name==C"]
set io_link($gid,dat_i) [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_*_i]] -filter "name==C"] $io_link($gid,clk_i)]
set io_link($gid,tkn_o)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_tkn_o]] -filter "name==I"]
set io_link($gid,clk_o)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_clk_o]] -filter "name==I"]
set io_link($gid,dat_o) [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_*_o]] -filter "name==I"] $io_link($gid,clk_o)]
set io_link($gid,tkn_i)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_tkn_i]] -filter "name==C"]
incr gid
set io_link($gid,clk_i)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co_clk_i]] -filter "name==C"]
set io_link($gid,dat_i) [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co_*_i]] -filter "name==C"] $io_link($gid,clk_i)]
set io_link($gid,tkn_o)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co_tkn_o]] -filter "name==I"]
set io_link($gid,clk_o)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_clk_o]] -filter "name==I"]
set io_link($gid,dat_o) [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_*_o]] -filter "name==I"] $io_link($gid,clk_o)]
set io_link($gid,tkn_i)                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_tkn_i]] -filter "name==C"]

foreach id [list 0 1] {
  bsg_link_timing_constraints false $IOM_CLK_NAME $id 0.1
}

global ddr_intf
set ddr_intf(ck_p)         [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_ck_p_o]] -filter "name==I"]
set ddr_intf(ck_n)         [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_ck_n_o]] -filter "name==I"]
set ddr_intf(ca)           [get_pins -of_objects [get_cells -of_objects [get_ports -filter "name=~p_ddr_*_o&&name!~p_ddr_ck_*&&name!~p_ddr_dm_*"]] -filter "name==I"]
set gid 0
set ddr_intf($gid,dqs_p_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_0_io]] -filter "name==C"]
set ddr_intf($gid,dqs_p_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_0_io]] -filter "name==I"]
set ddr_intf($gid,dqs_n_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_0_io]] -filter "name==C"]
set ddr_intf($gid,dqs_n_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_0_io]] -filter "name==I"]
set ddr_intf($gid,dm_o)    [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dm_0_o]] -filter "name==I"]
set ddr_intf($gid,dq_i)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_([0-7])_io}]] -filter "name==C"]
set ddr_intf($gid,dq_o)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_([0-7])_io}]] -filter "name==I||name==OEN"]
incr gid
set ddr_intf($gid,dqs_p_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_1_io]] -filter "name==C"]
set ddr_intf($gid,dqs_p_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_1_io]] -filter "name==I"]
set ddr_intf($gid,dqs_n_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_1_io]] -filter "name==C"]
set ddr_intf($gid,dqs_n_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_1_io]] -filter "name==I"]
set ddr_intf($gid,dm_o)    [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dm_1_o]] -filter "name==I"]
set ddr_intf($gid,dq_i)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_([8-9]|1[0-5])_io}]] -filter "name==C"]
set ddr_intf($gid,dq_o)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_([8-9]|1[0-5])_io}]] -filter "name==I||name==OEN"]
incr gid
set ddr_intf($gid,dqs_p_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_2_io]] -filter "name==C"]
set ddr_intf($gid,dqs_p_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_2_io]] -filter "name==I"]
set ddr_intf($gid,dqs_n_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_2_io]] -filter "name==C"]
set ddr_intf($gid,dqs_n_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_2_io]] -filter "name==I"]
set ddr_intf($gid,dm_o)    [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dm_2_o]] -filter "name==I"]
set ddr_intf($gid,dq_i)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_(1[6-9]|2[0-3])_io}]] -filter "name==C"]
set ddr_intf($gid,dq_o)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_(1[6-9]|2[0-3])_io}]] -filter "name==I||name==OEN"]
incr gid
set ddr_intf($gid,dqs_p_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_3_io]] -filter "name==C"]
set ddr_intf($gid,dqs_p_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_p_3_io]] -filter "name==I"]
set ddr_intf($gid,dqs_n_i) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_3_io]] -filter "name==C"]
set ddr_intf($gid,dqs_n_o) [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dqs_n_3_io]] -filter "name==I"]
set ddr_intf($gid,dm_o)    [get_pins -of_objects [get_cells -of_objects [get_ports p_ddr_dm_3_o]] -filter "name==I"]
set ddr_intf($gid,dq_i)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_(2[4-9]|3[0-1])_io}]] -filter "name==C"]
set ddr_intf($gid,dq_o)    [get_pins -of_objects [get_cells -of_objects [get_ports -regexp {p_ddr_dq_(2[4-9]|3[0-1])_io}]] -filter "name==I||name==OEN"]

#bsg_dmc_ctrl_timing_constraints $DFI_CLK_1X_NAME $DFI_CLK_2X_NAME
#foreach id [list 0 1 2 3] {
#  bsg_dmc_data_timing_constraints false $id $DFI_CLK_1X_NAME $DFI_CLK_2X_NAME
#}

#
set clk_grp(tag) [get_clocks tag_clk]
#set_clock_groups -asynchronous -name tag_clk_grp -group $clk_grp(tag)

set clk_grp(sdi_0) [get_clocks sdi_0_clk]
#set_clock_groups -asynchronous -name sdi_0_clk_grp -group $clk_grp(sdi_0)

set clk_grp(sdo_0_tkn) [get_clocks sdo_0_tkn_clk]
#set_clock_groups -asynchronous -name sdo_0_tkn_clk_grp -group $clk_grp(sdo_0_tkn)

set clk_grp(sdi_1) [get_clocks sdi_1_clk]
#set_clock_groups -asynchronous -name sdi_1_clk_grp -group $clk_grp(sdi_1)

set clk_grp(sdo_1_tkn) [get_clocks sdo_1_tkn_clk]
#set_clock_groups -asynchronous -name sdo_1_tkn_clk_grp -group $clk_grp(sdo_1_tkn)

set clk_grp(bp) [get_clocks bp_clk*]
#set_clock_groups -asynchronous -name bp_clk_grp -group $clk_grp(bp)

set clk_grp(io_master) [get_clocks io_master_clk*]
append_to_collection clk_grp(io_master) [get_clocks -filter "name=~sdo_*_clk&&name!~sdo_*_tkn_clk"]
#set_clock_groups -asynchronous -name io_master_clk_grp -group $clk_grp(io_master)

set clk_grp(router) [get_clocks router_clk*]
#set_clock_groups -asynchronous -name router_clk_grp -group $clk_grp(router)

set_clock_groups -asynchronous              \
                 -group $clk_grp(tag)       \
                 -group $clk_grp(sdi_0)     \
                 -group $clk_grp(sdo_0_tkn) \
                 -group $clk_grp(sdi_1)     \
                 -group $clk_grp(sdo_1_tkn) \
                 -group $clk_grp(io_master) \
                 -group $clk_grp(router)    \
                 -group $clk_grp(bp)
                 #-allow_paths               \

#set clk_grp(dmc) [get_clocks dfi_clk*]
#append_to_collection clk_grp(dmc) [get_clocks dqs*]
#append_to_collection clk_grp(dmc) [get_clocks ddr*]
#set_clock_groups -asynchronous -name dmc_clk_grp -group $clk_grp(dmc)

# timing exceptions
update_timing

bsg_async_cdc [list [get_clock bp_clk] \
                      [get_clock router_clk] \
                      [get_clock io_master_clk] \
                      [get_clock tag_clk] \
                      [get_clock bp_clk_osc] \
                      [get_clock router_clk_osc] \
                      [get_clock io_master_clk_osc] \
                      [get_clock sdi_0_clk] \
                      [get_clock sdi_1_clk] \
                      [get_clock sdo_0_tkn_clk] \
                      [get_clock sdo_1_tkn_clk]]

#foreach launch_grp [array name clk_grp] {
#  set index [lsearch [array name clk_grp] $launch_grp]
#  foreach latch_grp [lreplace [array name clk_grp] $index $index] {
#    foreach_in_collection launch_clk $clk_grp($launch_grp) {
#      foreach_in_collection latch_clk $clk_grp($latch_grp) {
#        group_path -name async_paths -from $launch_clk -to $latch_clk
#        set launch_period [get_attribute $launch_clk period]
#        set_max_delay $launch_period -from $launch_clk -to $latch_clk -ignore_clock_latency
#        set_min_delay 0              -from $launch_clk -to $latch_clk -ignore_clock_latency
#      }
#    }
#  }
#}

#set_false_path -to [get_pins -of_objects [get_fp_cells -filter "is_hard_macro"] -filter "name==CLKR||name==CLKW"]
#update_timing
#bsg_async

set_max_transition 0.4 [current_design]
set_max_capacitance 0.15 [current_design]
set_max_fanout 16 [current_design]

puts "BSG-info: Completed script [info script]\n"

