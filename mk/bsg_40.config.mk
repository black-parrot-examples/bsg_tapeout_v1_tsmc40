# Select the design type for the toplevel. If set to 'block' then the toplevel
# will not have IO drivers but rather pins (good for creating hard-macros or
# for doing apr runs before the toplevel is ready). If set to 'chip_*' the
# toplevel will have IO drivers, and the die size is determined by the *. Only
# certain die sizes have been implemented. Right now only 3x3mm is supported.

#export BSG_TOPLEVEL_DESIGN_TYPE :=block
export BSG_TOPLEVEL_DESIGN_TYPE :=chip_3x3

# Select the backend flow style (either hier or flat). This determines if ICC2
# is going to perform a hierarchical or flat physical implementation of the
# chip. When set to flat, you may still synthesize hierarchically. To
# synthesize flat, setup your design's hier.mk such that there is only a single
# block. If there is only a single block in your design's hier.mk, this
# variable has no affect and is effectively  forced to flat.

export BSG_FLOW_STYLE :=hier
#export BSG_FLOW_STYLE :=flat

# Select if the backend flor is going to perform Design Planning (DP). Design
# planning is about 10 additional steps that occurs before any placement and
# routing actually occurs. These steps are used to partition the physical
# hierarchy and implement a full-chip floorplan early on in the building flow.
# It is possible to skip this step and go directly to place and route however
# this may result is poor QoR, particularly for hierarchical flows.

export BSG_FLOW_USE_DP :=true
#export BSG_FLOW_USE_DP :=false

# Select the target package. Inside of bsg_packaging there multiple packages to
# choose from that determine the intended package for the ASIC.

export BSG_PACKAGE :=uw_bga

# Select the target pinout. For each package inside of bsg_packaging, there can
# be multiple specific pinouts defined. This selects the intended pinout for
# the ASIC.

export BSG_PINOUT :=bsg_asic_cloud

# Select the target packaging foundry. This is going to select IO cells for
# your specific process but for a given target process there may be multiple IP
# vendors that supply IO cells that we have support for therefore we don't just
# use the BSG_TARGET_PROCESS variables.

export BSG_PACKAGING_FOUNDRY :=tsmc_40

# Select the target padmapping. For each pinout inside of a package inside of
# bsg_packaging, there can be multiple padmappings. These padmappings often
# change configurations of various pads.

export BSG_PADMAPPING :=default

#=======================================
# PDK Setup Overrides
#=======================================

# Use CCS or NLDM models. If set to true, the flow will use the composite
# current source (ccs) timing models rather than the nonlinear delay models
# (nldm). QoR will be significantly worse when using nldm but TTR will be
# improved. Never sign-off a chip using nldm models!!!

export PDK_USE_CCS :=false

# Enable or disable pdk kits. Here we can turn on or turn off various kits that
# we have in the PDK. This includes things like multi-vt cells, low power
# cells, eco cells, level shifters, IO cells, generated IP, etc. Turning
# certain kits off can improve TTR but you will not have access to those cells.
# This will not affect the preparation flow, all kits will be prepared. This
# also means that if you enable a kit that was previously disabled, you do not
# need to redo the preparation flow.

# Multi-VT Kits
export PDK_USE_HVT :=false
export PDK_USE_LVT :=true

# Other kits
export PDK_USE_GPIO   :=true
export PDK_USE_BOND   :=true
export PDK_USE_MEMGEN :=true

#
export PDK_USE_WC  ?=true
export PDK_USE_WCZ ?=false
export PDK_USE_WCL ?=false
export PDK_USE_BC  ?=true
export PDK_USE_LT  ?=false
export PDK_USE_ML  ?=true
export PDK_USE_MLG ?=false
export PDK_USE_TC  ?=false
