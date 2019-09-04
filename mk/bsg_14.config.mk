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

# Select the target process. This variable is used to reference the various
# 'hardened' directories in our other repos. This variable can also be queried
# for code that is process specific. Currently, only gf_14 is supported.

export BSG_TARGET_PROCESS :=gf_14

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

export BSG_PACKAGING_FOUNDRY :=gf_14_invecas_1p8v

# Select the target padmapping. For each pinout inside of a package inside of
# bsg_packaging, there can be multiple padmappings. These padmappings often
# change configurations of various pads.

export BSG_PADMAPPING :=default

#=======================================
# PDK Setup Overrides
#=======================================

# Enable or disable pdk kits. Here we can turn on or turn off various kits that
# we have in the PDK. This includes things like multi-vt cells, low power
# cells, eco cells, level shifters, IO cells, generated IP, etc. Turning
# certain kits off can improve TTR but you will not have access to those cells.
# This will not affect the preparation flow, all kits will be prepared. This
# also means that if you enable a kit that was previously disabled, you do not
# need to redo the preparation flow.

export PDK_ENABLE_KIT_IV7P5_RVT_C14  :=true
export PDK_ENABLE_KIT_IV7P5_LVT_C14  :=true
export PDK_ENABLE_KIT_IV7P5_SLVT_C14 :=true

export PDK_ENABLE_KIT_IV7P5_HVT_C16  :=false
export PDK_ENABLE_KIT_IV7P5_RVT_C16  :=true
export PDK_ENABLE_KIT_IV7P5_LVT_C16  :=true
export PDK_ENABLE_KIT_IV7P5_SLVT_C16 :=true

export PDK_ENABLE_KIT_IV7P5_HVT_LPK  :=false
export PDK_ENABLE_KIT_IV7P5_RVT_LPK  :=false
export PDK_ENABLE_KIT_IV7P5_LVT_LPK  :=false
export PDK_ENABLE_KIT_IV7P5_SLVT_LPK :=false

export PDK_ENABLE_KIT_IV7P5_HVT_HPK  :=false
export PDK_ENABLE_KIT_IV7P5_RVT_HPK  :=true
export PDK_ENABLE_KIT_IV7P5_LVT_HPK  :=true
export PDK_ENABLE_KIT_IV7P5_SLVT_HPK :=true

export PDK_ENABLE_KIT_IV7P5_HVT_ECO  :=false
export PDK_ENABLE_KIT_IV7P5_RVT_ECO  :=false
export PDK_ENABLE_KIT_IV7P5_LVT_ECO  :=false
export PDK_ENABLE_KIT_IV7P5_SLVT_ECO :=false

export PDK_ENABLE_KIT_IV7P5_HVT_SHIFT  :=false
export PDK_ENABLE_KIT_IV7P5_RVT_SHIFT  :=false
export PDK_ENABLE_KIT_IV7P5_LVT_SHIFT  :=false
export PDK_ENABLE_KIT_IV7P5_SLVT_SHIFT :=false

export PDK_ENABLE_KIT_IV1P8V_GPIO :=true
export PDK_ENABLE_KIT_MEMGEN      :=true
export PDK_ENABLE_KIT_CDMM        := true

# Multi-VT Kits
export PDK_ENABLE_RVT_LIB  :=true
export PDK_ENABLE_HVT_LIB  :=false
export PDK_ENABLE_LVT_LIB  :=true
export PDK_ENABLE_SLVT_LIB :=true

# Standard cell kits
export PDK_ENABLE_LPK_LIB   :=false
export PDK_ENABLE_HPK_LIB   :=true
export PDK_ENABLE_ECO_LIB   :=false
export PDK_ENABLE_SHIFT_LIB :=false

# Other kits
export PDK_ENABLE_GPIO_LIB   :=true
export PDK_ENABLE_MEMGEN_LIB :=true

#export BSG_POWER_INTENT := mv_standard_pll
export BSG_POWER_INTENT := sv_standard
