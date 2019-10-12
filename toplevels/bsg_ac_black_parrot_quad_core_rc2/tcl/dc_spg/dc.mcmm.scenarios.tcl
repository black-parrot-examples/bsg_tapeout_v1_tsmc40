#################################################################################
# Design Compiler MCMM Scenarios Setup File Reference
# Script: dc.mcmm.scenarios.tcl
# Version: O-2018.06-SP4 
# Copyright (C) 2011-2019 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# This is an example of the MCMM scenarios setup file for Design Compiler.
# Please note that this file will not work as given and must be edited for your
# design.
#
# Create this file for each design in your MCMM flow and configure the filename
# with the value of the ${DCRM_MCMM_SCENARIOS_SETUP_FILE} in
# rm_setup/dc_setup_filenames.tcl
#
# It is recommended to use a minimum set of worst case setup scenarios
# and a worst case leakage scenario in Design Compiler.
# Further refinement to optimize across all possible scenarios is recommended
# to be done in IC Compiler.
#################################################################################

#################################################################################
# Additional Notes
#################################################################################
#
# In MCMM, good leakage and dynamic power optimization results can be obtained by
# using a worst case leakage scenario along with scenario-independent clock gating
# (compile_ultra -gate_clock).
#
# For low power placement to work, it is required to have at least one scenario with 
# dynamic power optimization enabled.
#
#    set_scenario_options -dynamic_power true ...
#
# A recommended scenario naming convention (used by Lynx) is the following:
#
# <MM_TYPE>.<OC_TYPE>.<RC_TYPE>
#
# MM_TYPE - Label that identifies the operating mode or set of timing constraints
#           Example values: mode_norm, mode_slow, mode_test
#
# OC_TYPE - Label that identifies the library operating conditions or PVT corner
#           Example values: OC_WC, OC_BC, OC_TYP, OC_LEAK, OC_TEMPINV
#
# RC_TYPE - Label that identifies an extraction corner (TLUPlus files)
#           Example values: RC_MAX_1, RC_MIN_1, RC_TYP
#################################################################################

#################################################################################
# Worst Case Setup Scenario
#################################################################################

set scenario $MODE(func)_$LIB_CORNER(wc)_$PARA_CORNER(cmax)

create_scenario ${scenario}

# If this is the top-level design in a hierarchical flow and there are scenario
# name mismatches with hierarchical blocks, use the following command to map the 
# mismatched block scenario names to this top-level scenario.

# select_block_scenario -block_references <BLOCK_DESIGNS_LIST> -block_scenario <BLOCK_SCENARIO_NAME>

# Read in scenario-specific constraints file

puts "RM-Info: Sourcing script file [which [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]]\n"
source [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]

# puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
# read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]

set_operating_conditions -max_library ${PDK_SC_RVT_WC_LIB_NAME} -max $OPERATING_CONDITION($LIB_CORNER(wc))

set_tlu_plus_files -max_tluplus ${TLUPLUS_MAX_FILE} \
                   -tech2itf_map ${MAP_FILE}

check_tlu_plus_files

# For a MV flow, apply set_voltage settings for each scenario if these settings
# are not already a part of the input SDC file.

set MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE [dcrm_mcmm_filename ${DCRM_MV_SET_VOLTAGE_INPUT_FILE} ${scenario}]

if {[file exists [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]]} {
  puts "RM-Info: Sourcing script file [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]\n"
  source -echo -verbose ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}
}

# Include scenario specific SAIF file, if possible, for power analysis.
# Otherwise, the default toggle rate of 0.1 will be used for propagating
# switching activity.

# read_saif -auto_map_names -input ${DESIGN_NAME}.${scenario}.saif -instance < DESIGN_INSTANCE > -verbose

# Set options for worst case setup scenario
set_scenario_options -setup true -hold false -leakage_power false

report_scenario_options

# Define additional setup scenarios here as needed, using the same format.

#################################################################################
# Worst Case Leakage Scenario
#################################################################################

set scenario $MODE(func)_$LIB_CORNER(bc)_$PARA_CORNER(cmin)

create_scenario ${scenario}

# If this is the top-level design in a hierarchical flow and there are scenario
# name mismatches with hierarchical blocks, use the following command to map the
# the mismatched block scenario names to this top-level scenario.

# select_block_scenario -block_references <BLOCK_DESIGNS_LIST> -block_scenario <BLOCK_SCENARIO_NAME>

# Read in scenario-specific constraints file

puts "RM-Info: Sourcing script file [which [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]]\n"
source [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]

# puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
# read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]

set_operating_conditions -max_library ${PDK_SC_RVT_BC_LIB_NAME} -max $OPERATING_CONDITION($LIB_CORNER(bc))

set_tlu_plus_files -max_tluplus ${TLUPLUS_MIN_FILE} \
                   -tech2itf_map ${MAP_FILE}

check_tlu_plus_files

# For a MV flow, apply set_voltage settings for each scenario if these settings
# are not already a part of the input SDC file.

set MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE [dcrm_mcmm_filename ${DCRM_MV_SET_VOLTAGE_INPUT_FILE} ${scenario}]

if {[file exists [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]]} {
  puts "RM-Info: Sourcing script file [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]\n"
  source -echo -verbose ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}
}

# Include scenario specific SAIF file, if possible, for power optimization and analysis.
# Otherwise, the default toggle rate of 0.1 will be used for propagating
# switching activity.

# read_saif -auto_map_names -input ${DESIGN_NAME}.${scenario}.saif -instance < DESIGN_INSTANCE > -verbose

# Set options for worst case leakage scenario
set_scenario_options -setup false -hold true -leakage_power false

report_scenario_options

##################################################################################
## Worst Case Leakage Scenario
##################################################################################
#
#set scenario mode_norm.OC_WCZ.RC_MAX
#
#create_scenario ${scenario}
#
## If this is the top-level design in a hierarchical flow and there are scenario
## name mismatches with hierarchical blocks, use the following command to map the
## the mismatched block scenario names to this top-level scenario.
#
## select_block_scenario -block_references <BLOCK_DESIGNS_LIST> -block_scenario <BLOCK_SCENARIO_NAME>
#
## Read in scenario-specific constraints file
#
#puts "RM-Info: Sourcing script file [which [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]]\n"
#source [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]
#
## puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
## read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]
#
#set_operating_conditions -max_library ${PDK_SC_RVT_WCZ_LIB_NAME} -max $OPERATING_CONDITION($::env(OPCOND_WCZ))
#
#set_tlu_plus_files -max_tluplus ${TLUPLUS_MAX_FILE} \
#                   -tech2itf_map ${MAP_FILE}
#
#check_tlu_plus_files
#
## For a MV flow, apply set_voltage settings for each scenario if these settings
## are not already a part of the input SDC file.
#
#set MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE [dcrm_mcmm_filename ${DCRM_MV_SET_VOLTAGE_INPUT_FILE} ${scenario}]
#
#if {[file exists [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]]} {
#  puts "RM-Info: Sourcing script file [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]\n"
#  source -echo -verbose ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}
#}
#
## Include scenario specific SAIF file, if possible, for power optimization and analysis.
## Otherwise, the default toggle rate of 0.1 will be used for propagating
## switching activity.
#
## read_saif -auto_map_names -input ${DESIGN_NAME}.${scenario}.saif -instance < DESIGN_INSTANCE > -verbose
#
## Set options for worst case leakage scenario
#set_scenario_options -setup true -hold false -leakage_power false
#
#report_scenario_options
#
#################################################################################
# Worst Case Leakage Scenario
#################################################################################

set scenario $MODE(func)_$LIB_CORNER(ml)_$PARA_CORNER(cmax)

create_scenario ${scenario}

# If this is the top-level design in a hierarchical flow and there are scenario
# name mismatches with hierarchical blocks, use the following command to map the
# the mismatched block scenario names to this top-level scenario.

# select_block_scenario -block_references <BLOCK_DESIGNS_LIST> -block_scenario <BLOCK_SCENARIO_NAME>

# Read in scenario-specific constraints file

puts "RM-Info: Sourcing script file [which [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]]\n"
source [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]

# puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
# read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]

set_operating_conditions -max_library ${PDK_SC_RVT_ML_LIB_NAME} -max $OPERATING_CONDITION($LIB_CORNER(ml))

set_tlu_plus_files -max_tluplus ${TLUPLUS_MAX_FILE} \
                   -tech2itf_map ${MAP_FILE}

check_tlu_plus_files

# For a MV flow, apply set_voltage settings for each scenario if these settings
# are not already a part of the input SDC file.

set MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE [dcrm_mcmm_filename ${DCRM_MV_SET_VOLTAGE_INPUT_FILE} ${scenario}]

if {[file exists [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]]} {
  puts "RM-Info: Sourcing script file [which ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}]\n"
  source -echo -verbose ${MCMM_DCRM_MV_SET_VOLTAGE_INPUT_FILE}
}

# Include scenario specific SAIF file, if possible, for power optimization and analysis.
# Otherwise, the default toggle rate of 0.1 will be used for propagating
# switching activity.

# read_saif -auto_map_names -input ${DESIGN_NAME}.${scenario}.saif -instance < DESIGN_INSTANCE > -verbose

# Set options for worst case leakage scenario
set_scenario_options -setup false -hold false -leakage_power true

report_scenario_options

current_scenario $MODE(func)_$LIB_CORNER(wc)_$PARA_CORNER(cmax)
