puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Version: M-2016.12-SP4 (July 17, 2017)
# Copyright (C) 2010-2017 Synopsys, Inc. All rights reserved.
##########################################################################################

set SCENARIO_1                "$MODE(func)_$LIB_CORNER(wc)_$PARA_CORNER(cmax)"  		;# name of scenario
set ICC_IN_SDC_1_FILE         "${DESIGN_NAME}.mapped.${SCENARIO_1}.sdc"         ;# implementation SDC file for the scenario; create_voltage_area commands should be removed from SDC,
  						;# otherwise, the message "Error: Core Area not defined" will appear  
set PT_SDC_1_FILE             ""  	       	;# optional, signoff SDC to be used with with PT, if different from implementation SDC
set OPCOND_1                  "$OPERATING_CONDITION($LIB_CORNER(wc))"  	       	;# name of operating condition
set OPCOND_1_LIB              "${PDK_SC_RVT_WC_LIB_NAME}"  	       	;# name of library containing definition of the operating condition
set TLUPLUS_EMULATION_1_FILE  ""            ;# Max EMULATION TLUplus file; note : emulated metal fill may not correlate well with real metal fill, especially for advanced technology nodes; please use it for reference only
#  Please use it for reference only.
set TLUPLUS_1_FILE            "${TLUPLUS_MAX_FILE}"                ;# Max TLUplus file
set STARRC_NXTGRD_1_FILE      ""         	;# Max NXTGRD file			
set SCENARIO_1_IS_LEAKAGE_SCENARIO  "FALSE"		;# TRUE|FALSE, specify TRUE to enable this scenario for leakage optimization.
  						;# For leakage optimization to work (performed by -power option of the core commands except clock_opt -only_cts), 
  						;# you should enable at least one scenario as leakage scenario.
  						;# However, for focal_opt, you should only enable a single scenario as leakage scenario.
set ICC_LATE_DERATING_FACTOR_1 $ICC_LATE_DERATING_FACTOR   ;# Late derating factor for SCENARIO_1, used for both data and clock; default to $ICC_LATE_DERATING_FACTOR
set ICC_EARLY_DERATING_FACTOR_1 $ICC_EARLY_DERATING_FACTOR ;# Early derating factor for SCENARIO_1, used for both data and clock; default to $ICC_EARLY_DERATING_FACTOR 

set SCENARIO_2                "$MODE(func)_$LIB_CORNER(bc)_$PARA_CORNER(cmin)"  		;# name of scenario
set ICC_IN_SDC_2_FILE         "${DESIGN_NAME}.mapped.${SCENARIO_2}.sdc"  ;# implementation SDC file for the scenario; create_voltage_area commands should be removed from SDC,
  						;# otherwise, the message "Error: Core Area not defined" will appear
set PT_SDC_2_FILE             ""  	       	;# optional, signoff SDC to be used with with PT, if different from implementation SDC
set OPCOND_2                  "$OPERATING_CONDITION($LIB_CORNER(bc))"  		;# name of operating condition
set OPCOND_2_LIB              "${PDK_SC_RVT_BC_LIB_NAME}"  		;# name of library containing definition of the operating condition
set TLUPLUS_EMULATION_2_FILE  ""            ;# Min EMULATION TLUplus file; note : emulated metal fill may not correlate well with real metal fill, especially for advanced technology nodes; please use it for reference only
set TLUPLUS_2_FILE            "${TLUPLUS_MIN_FILE}"                ;# Min TLUplus file
set STARRC_NXTGRD_2_FILE      ""         	;# Min NXTGRD file
set SCENARIO_2_IS_LEAKAGE_SCENARIO  "FALSE"		;# TRUE|FALSE, specify TRUE to enable this scenario for leakage optimization.
  						;# For leakage optimization to work (performed by -power option of the core commands except clock_opt -only_cts), 
  						;# you should enable at least one scenario as leakage scenario.
  						;# However, for focal_opt, you should only enable a single scenario as leakage scenario.
set ICC_LATE_DERATING_FACTOR_2 $ICC_LATE_DERATING_FACTOR   ;# Late derating factor for SCENARIO_2, used for both data and clock; default to $ICC_LATE_DERATING_FACTOR
set ICC_EARLY_DERATING_FACTOR_2 $ICC_EARLY_DERATING_FACTOR ;# Early derating factor for SCENARIO_2, used for both data and clock; default to $ICC_EARLY_DERATING_FACTOR

#set SCENARIO_3                "mode_norm.OC_WCZ.RC_MAX"  		;# name of scenario
set SCENARIO_3                ""  		;# name of scenario
set ICC_IN_SDC_3_FILE         "${DESIGN_NAME}.mapped.${SCENARIO_3}.sdc"  ;# implementation SDC file for the scenario; create_voltage_area commands should be removed from SDC,
  						;# otherwise, the message "Error: Core Area not defined" will appear
set PT_SDC_3_FILE             ""  	       	;# optional, signoff SDC to be used with with PT, if different from implementation SDC
set OPCOND_3                  "$OPERATING_CONDITION($LIB_CORNER(wcz))"  		;# name of operating condition
set OPCOND_3_LIB              "${PDK_SC_RVT_WCZ_LIB_NAME}"  		;# name of library containing definition of the operating condition
set TLUPLUS_EMULATION_3_FILE  ""            ;# Max EMULATION TLUplus file; note : emulated metal fill may not correlate well with real metal fill, especially for advanced technology nodes; please use it for reference only
set TLUPLUS_3_FILE            "${TLUPLUS_MAX_FILE}"                ;# Max TLUplus file
set STARRC_NXTGRD_3_FILE      ""         	;# Max NXTGRD file			
set SCENARIO_3_IS_LEAKAGE_SCENARIO  "FALSE"		;# TRUE|FALSE, specify TRUE to enable this scenario for leakage optimization.
  						;# For leakage optimization to work (performed by -power option of the core commands except clock_opt -only_cts), 
  						;# you should enable at least one scenario as leakage scenario.
  						;# However, for focal_opt, you should only enable a single scenario as leakage scenario.
set ICC_LATE_DERATING_FACTOR_3 $ICC_LATE_DERATING_FACTOR   ;# Late derating factor for SCENARIO_3, used for both data and clock; default to $ICC_LATE_DERATING_FACTOR
set ICC_EARLY_DERATING_FACTOR_3 $ICC_EARLY_DERATING_FACTOR ;# Early derating factor for SCENARIO_3, used for both data and clock; default to $ICC_EARLY_DERATING_FACTOR

set SCENARIO_4                "$MODE(func)_$LIB_CORNER(ml)_$PARA_CORNER(cmax)"  		;# name of scenario
set ICC_IN_SDC_4_FILE         "${DESIGN_NAME}.mapped.${SCENARIO_4}.sdc"  ;# implementation SDC file for the scenario; create_voltage_area commands should be removed from SDC,
  						;# otherwise, the message "Error: Core Area not defined" will appear
set PT_SDC_4_FILE             ""  	       	;# optional, signoff SDC to be used with with PT, if different from implementation SDC
set OPCOND_4                  "$OPERATING_CONDITION($LIB_CORNER(ml))"  		;# name of operating condition
set OPCOND_4_LIB              "${PDK_SC_RVT_ML_LIB_NAME}"  		;# name of library containing definition of the operating condition
set TLUPLUS_EMULATION_4_FILE  ""            ;# Min EMULATION TLUplus file; note : emulated metal fill may not correlate well with real metal fill, especially for advanced technology nodes; please use it for reference only
set TLUPLUS_4_FILE            "${TLUPLUS_MAX_FILE}"                ;# Min TLUplus file
set STARRC_NXTGRD_4_FILE      ""         	;# Min NXTGRD file
set SCENARIO_4_IS_LEAKAGE_SCENARIO  "TRUE"		;# TRUE|FALSE, specify TRUE to enable this scenario for leakage optimization.
  						;# For leakage optimization to work (performed by -power option of the core commands except clock_opt -only_cts), 
  						;# you should enable at least one scenario as leakage scenario.
  						;# However, for focal_opt, you should only enable a single scenario as leakage scenario.
set ICC_LATE_DERATING_FACTOR_4 $ICC_LATE_DERATING_FACTOR   ;# Late derating factor for SCENARIO_4, used for both data and clock; default to $ICC_LATE_DERATING_FACTOR
set ICC_EARLY_DERATING_FACTOR_4 $ICC_EARLY_DERATING_FACTOR ;# Early derating factor for SCENARIO_4, used for both data and clock; default to $ICC_EARLY_DERATING_FACTOR

##########################################################################################
################     USAGE OF ABOVE VARIABLES FOR 4 SCENARIOS     ########################
################  IF YOU HAVE MORE SCENARIOS, ADD THEM HERE BELOW  #######################
##########################################################################################

if {$SCENARIO_1 != "" && $ICC_IN_SDC_1_FILE != ""} {
    echo "RM-Info : Setting up scenario $SCENARIO_1"
    create_scenario $SCENARIO_1

    set auto_link_disable true
    read_sdc $ICC_IN_SDC_1_FILE
    set auto_link_disable false

    ## On chip variation is used as analysis type for the example.
    #  As -min_library and -min are not specified, the tool uses the max operating condition for -min.
    #  That means tool is modeling on chip variation using the max operating condition and the early and late derating factors for
    #  min and max path delay analysis, respectively. 
    set_operating_conditions \
          -analysis_type on_chip_variation -max_library $OPCOND_1_LIB -max $OPCOND_1

    if {$TLUPLUS_EMULATION_1_FILE == ""} {
       set_tlu_plus_files -max_tluplus $TLUPLUS_1_FILE -tech2itf_map $MAP_FILE
    } else {
       set_tlu_plus_files -max_tluplus $TLUPLUS_1_FILE -tech2itf_map $MAP_FILE \
             -max_emulation_tluplus $TLUPLUS_EMULATION_1_FILE
    }

    if {[file exists [which $PT_SDC_1_FILE]]} {
    set_primetime_options -sdc_file $PT_SDC_1_FILE
    }
    if {[file exists [which $STARRC_NXTGRD_1_FILE]]} {
    set_starrcxt_options -max_nxtgrd_file $STARRC_NXTGRD_1_FILE
    }

    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_1 -cell_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_1  -cell_delay 
    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_1 -net_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_1  -net_delay

    set_scenario_options -leakage_power $SCENARIO_1_IS_LEAKAGE_SCENARIO

    ## You could set the following based on technology: set_starrcxt_options -mode <value>
    #  For 65nm and below, the recommendation is 400.

    ## Hold only
    #  set_scenario_options -setup false -hold true -leakage_power false

    ## Leakage power optimization only
    #  set_scenario_options -setup false -hold false -leakage_power true 

    ## Dynamic power optimization only
    ## The -setup option must be true if the -dynamic_power option is true
    #  set_scenario_options -setup true -hold false -leakage_power false -dynamic_power true

    ## Setup only 
    set_scenario_options -setup true -hold false -leakage_power false

    ## MMCTS
    #  set_scenario_options -cts_mode true
    ## To be optimized by CTS ONLY, please set the following:
    #  set_scenario_options -cts_mode true -setup false -hold false
    
    ## For Clock Concurrent and Data Optimization
    ## At least one scenario from each mode should have -cts mode true
    ## The timing critical scenarios need to have -cts_mode true 

    ## MCCTO 
    #  If you want this scenario to be optimized by MCCTO,
    #  please specify the corners to be optimized.
    #  set_scenario_options -cts_corner min/max/min_max/none

    report_scenario_options
}

if {$SCENARIO_2 != "" && $ICC_IN_SDC_2_FILE != ""} {
    echo "RM-Info : Setting up scenario $SCENARIO_2"
    create_scenario $SCENARIO_2

    set auto_link_disable true
    read_sdc $ICC_IN_SDC_2_FILE
    set auto_link_disable false

    ## On chip variation is used as analysis type for the example.
    #  As -min_library and -min are not specified, the tool uses the max operating condition for -min.
    #  That means tool is modeling on chip variation using the max operating condition and the early and late derating factors for
    #  min and max path delay analysis, respectively.
    set_operating_conditions \
          -analysis_type on_chip_variation -max_library $OPCOND_2_LIB -max $OPCOND_2

    if {$TLUPLUS_EMULATION_2_FILE == ""} {
       set_tlu_plus_files -max_tluplus $TLUPLUS_2_FILE -tech2itf_map $MAP_FILE
    } else {
       set_tlu_plus_files -max_tluplus $TLUPLUS_2_FILE -tech2itf_map $MAP_FILE \
             -max_emulation_tluplus $TLUPLUS_EMULATION_2_FILE
    }

    if {[file exists [which $PT_SDC_2_FILE]]} {
    set_primetime_options -sdc_file $PT_SDC_2_FILE
    }
    if {[file exists [which $STARRC_NXTGRD_2_FILE]]} {
    set_starrcxt_options -max_nxtgrd_file $STARRC_NXTGRD_2_FILE
    }

    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_2 -cell_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_2  -cell_delay 
    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_2 -net_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_2  -net_delay

    set_scenario_options -leakage_power $SCENARIO_2_IS_LEAKAGE_SCENARIO

    ## You could set the following based on technology: set_starrcxt_options -mode <value>
    #  For 65nm and below, the recommendation is 400.

    ## Hold only
    set_scenario_options -setup false -hold true -leakage_power false

    ## Leakage power optimization only
    #  set_scenario_options -setup false -hold false -leakage_power true 

    ## Dynamic power optimization only
    ## The -setup option must be true if the -dynamic_power option is true
    #  set_scenario_options -setup true -hold false -leakage_power false -dynamic_power true

    ## Setup only 
    #  set_scenario_options -setup true -hold false -leakage_power false

    ## MMCTS
    #  set_scenario_options -cts_mode true
    ## To be optimized by CTS ONLY, please set the following:
    #  set_scenario_options -cts_mode true -setup false -hold false

    ## For Clock Concurrent and Data Optimization
    ## At least one scenario from each mode should have -cts mode true
    ## The timing critical scenarios need to have -cts_mode true 

    ## MCCTO 
    #  If you want this scenario to be optimized by MCCTO,
    #  please specify the corners to be optimized.
    #  set_scenario_options -cts_corner min/max/min_max/none

    report_scenario_options
}

if {$SCENARIO_3 != "" && $ICC_IN_SDC_3_FILE != ""} {
    echo "RM-Info : Setting up scenario $SCENARIO_3"
    create_scenario $SCENARIO_3

    set auto_link_disable true
    read_sdc $ICC_IN_SDC_3_FILE
    set auto_link_disable false

    ## On chip variation is used as analysis type for the example.
    #  As -min_library and -min are not specified, the tool uses the max operating condition for -min.
    #  That means tool is modeling on chip variation using the max operating condition and the early and late derating factors for
    #  min and max path delay analysis, respectively.
    set_operating_conditions \
          -analysis_type on_chip_variation -max_library $OPCOND_3_LIB -max $OPCOND_3

    if {$TLUPLUS_EMULATION_3_FILE == ""} {
       set_tlu_plus_files -max_tluplus $TLUPLUS_3_FILE -tech2itf_map $MAP_FILE
    } else {
       set_tlu_plus_files -max_tluplus $TLUPLUS_3_FILE -tech2itf_map $MAP_FILE \
             -max_emulation_tluplus $TLUPLUS_EMULATION_3_FILE
    }

    if {[file exists [which $PT_SDC_3_FILE]]} {
    set_primetime_options -sdc_file $PT_SDC_3_FILE
    }
    if {[file exists [which $STARRC_NXTGRD_3_FILE]]} {
    set_starrcxt_options -max_nxtgrd_file $STARRC_NXTGRD_3_FILE
    }

    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_3 -cell_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_3  -cell_delay 
    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_3 -net_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_3  -net_delay

    set_scenario_options -leakage_power $SCENARIO_3_IS_LEAKAGE_SCENARIO

    ## You could set the following based on technology: set_starrcxt_options -mode <value>
    #  For 65nm and below, the recommendation is 400.

    ## Hold only
    #  set_scenario_options -setup false -hold true -leakage_power false

    ## Leakage power optimization only
    #  set_scenario_options -setup false -hold false -leakage_power true 

    ## Dynamic power optimization only
    ## The -setup option must be true if the -dynamic_power option is true
    #  set_scenario_options -setup true -hold false -leakage_power false -dynamic_power true

    ## Setup only 
    set_scenario_options -setup true -hold false -leakage_power false

    ## MMCTS
    #  set_scenario_options -cts_mode true
    ## To be optimized by CTS ONLY, please set the following:
    #  set_scenario_options -cts_mode true -setup false -hold false

    ## For Clock Concurrent and Data Optimization
    ## At least one scenario from each mode should have -cts mode true
    ## The timing critical scenarios need to have -cts_mode true 

    ## MCCTO 
    #  If you want this scenario to be optimized by MCCTO,
    #  please specify the corners to be optimized.
    #  set_scenario_options -cts_corner min/max/min_max/none

    report_scenario_options
}

if {$SCENARIO_4 != "" && $ICC_IN_SDC_4_FILE != ""} {
    echo "RM-Info : Setting up scenario $SCENARIO_4"
    create_scenario $SCENARIO_4

    set auto_link_disable true
    read_sdc $ICC_IN_SDC_4_FILE
    set auto_link_disable false

    ## On chip variation is used as analysis type for the example.
    #  As -min_library and -min are not specified, the tool uses the max operating condition for -min.
    #  That means tool is modeling on chip variation using the max operating condition and the early and late derating factors for
    #  min and max path delay analysis, respectively.
    set_operating_conditions \
          -analysis_type on_chip_variation -max_library $OPCOND_4_LIB -max $OPCOND_4

    if {$TLUPLUS_EMULATION_4_FILE == ""} {
       set_tlu_plus_files -max_tluplus $TLUPLUS_4_FILE -tech2itf_map $MAP_FILE
    } else {
       set_tlu_plus_files -max_tluplus $TLUPLUS_4_FILE -tech2itf_map $MAP_FILE \
             -max_emulation_tluplus $TLUPLUS_EMULATION_4_FILE
    }

    if {[file exists [which $PT_SDC_4_FILE]]} {
    set_primetime_options -sdc_file $PT_SDC_4_FILE
    }
    if {[file exists [which $STARRC_NXTGRD_4_FILE]]} {
    set_starrcxt_options -max_nxtgrd_file $STARRC_NXTGRD_4_FILE
    }

    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_4 -cell_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_4  -cell_delay 
    set_timing_derate -early $ICC_EARLY_DERATING_FACTOR_4 -net_delay 
    set_timing_derate -late  $ICC_LATE_DERATING_FACTOR_4  -net_delay

    set_scenario_options -leakage_power $SCENARIO_4_IS_LEAKAGE_SCENARIO

    ## You could set the following based on technology: set_starrcxt_options -mode <value>
    #  For 65nm and below, the recommendation is 400.

    ## Hold only
    #  set_scenario_options -setup false -hold true -leakage_power false

    ## Leakage power optimization only
    set_scenario_options -setup false -hold false -leakage_power true 

    ## Dynamic power optimization only
    ## The -setup option must be true if the -dynamic_power option is true
    #  set_scenario_options -setup true -hold false -leakage_power false -dynamic_power true

    ## Setup only 
    #  set_scenario_options -setup true -hold false -leakage_power false

    ## MMCTS
    #  set_scenario_options -cts_mode true
    ## To be optimized by CTS ONLY, please set the following:
    #  set_scenario_options -cts_mode true -setup false -hold false

    ## For Clock Concurrent and Data Optimization
    ## At least one scenario from each mode should have -cts mode true
    ## The timing critical scenarios need to have -cts_mode true 

    ## MCCTO 
    #  If you want this scenario to be optimized by MCCTO,
    #  please specify the corners to be optimized.
    #  set_scenario_options -cts_corner min/max/min_max/none

    report_scenario_options
}

current_scenario $SCENARIO_1

puts "RM-Info: Completed script [info script]\n"
