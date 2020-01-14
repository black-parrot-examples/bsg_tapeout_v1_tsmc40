.DEFAULT_GOAL=run

# Note: most variables that are file/dir paths are ?= because they can be
# overriden by the chip repo if this makefile is called from the chip
# infrastructure.

export BSG_DESIGNS_DIR        ?= $(abspath ../../../../)
export BSG_DESIGNS_TARGET_DIR ?= $(abspath ../../)

BSG_WORK_DIR := $(abspath ./)
BSG_OUT_DIR  := $(BSG_WORK_DIR)/out
BSG_OUT_SIM  := $(BSG_OUT_DIR)/simv

include $(BSG_DESIGNS_TARGET_DIR)/bsg_cadenv/cadenv.mk

# Repository setup
export BASEJUMP_STL_DIR       ?= $(BSG_DESIGNS_TARGET_DIR)/basejump_stl
export BSG_PACKAGING_DIR      ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_packaging
export BLACKPARROT_DIR        ?= $(BSG_DESIGNS_TARGET_DIR)/pre-alpha-release
export BOARD_DIR              ?= $(BSG_DESIGNS_TARGET_DIR)/board

export TESTING_BSG_DESIGNS_DIR        ?= $(BSG_OUT_DIR)/root
export TESTING_BASEJUMP_STL_DIR       ?= $(BSG_OUT_DIR)/root/basejump_stl
export TESTING_BSG_PACKAGING_DIR      ?= $(BSG_OUT_DIR)/root/bsg_packaging
export TESTING_BLACKPARROT_DIR        ?= $(BSG_OUT_DIR)/root/pre-alpha-release
export TESTING_BOARD_DIR              ?= $(BSG_OUT_DIR)/root/board
export TESTING_BSG_DESIGNS_TARGET_DIR ?= $(BSG_DESIGNS_TARGET_DIR)

export BSG_PACKAGE           ?=uw_bga
export BSG_PINOUT            ?=bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY ?=gf_14_invecas_1p8v
export BSG_PADMAPPING        ?=default

export BLACKPARROT_COMMON_DIR ?= $(BLACKPARROT_DIR)/bp_common
export BLACKPARROT_TOP_DIR    ?= $(BLACKPARROT_DIR)/bp_top
export BLACKPARROT_FE_DIR     ?= $(BLACKPARROT_DIR)/bp_fe
export BLACKPARROT_BE_DIR     ?= $(BLACKPARROT_DIR)/bp_be
export BLACKPARROT_ME_DIR     ?= $(BLACKPARROT_DIR)/bp_me

# Additional setup for RTL-Hard
export BSG_CHIP_DIR             ?= $(BSG_DESIGNS_TARGET_DIR)/bsg_14
export MEMGEN_RUN_DIR           ?= $(BSG_CHIP_DIR)/sources/memgen
export BSG_TOPLEVEL_DESIGN_TYPE ?=chip_3x3
export BSG_TARGET_PROCESS       ?=gf_14

########################################
## VCS OPTIONS
########################################

# Common VCS Options (will be used most of the time by all corners)
VCS_OPTIONS := -full64
VCS_OPTIONS += -notice
VCS_OPTIONS += -debug_pp
VCS_OPTIONS += -V
VCS_OPTIONS += +v2k
VCS_OPTIONS += -sverilog -assert svaext
VCS_OPTIONS += +noportcoerce
VCS_OPTIONS += +vc
VCS_OPTIONS += +vcs+loopreport
VCS_OPTIONS += -timescale=1ps/1ps
VCS_OPTIONS += -diag timescale 
VCS_OPTIONS += -o $(BSG_OUT_SIM)
VCS_OPTIONS += -Mdir=$(BSG_OUT_DIR)
VCS_OPTIONS += -top bsg_config bsg_config.v
VCS_OPTIONS += +warn_all,noOPD,noTMR,noTFIPC

# DRAMSim2
VCS_OPTIONS += -CFLAGS "-I$(BLACKPARROT_DIR)/external/include -std=c++11"
VCS_OPTIONS += -LDFLAGS "-L$(BLACKPARROT_DIR)/external/lib -ldramsim -Wl,-rpath=$(BLACKPARROT_DIR)/external/lib"

# Add extra packages that get dropped by the build system
VCS_OPTIONS += +incdir+$(BASEJUMP_STL_DIR)/bsg_misc/
VCS_OPTIONS += +incdir+$(BASEJUMP_STL_DIR)/bsg_noc/
VCS_OPTIONS += +incdir+$(BLACKPARROT_COMMON_DIR)/src/include
VCS_OPTIONS += +incdir+$(BLACKPARROT_TOP_DIR)/src/include
VCS_OPTIONS += +incdir+$(BLACKPARROT_FE_DIR)/bp_fe/src/include
VCS_OPTIONS += +incdir+$(BLACKPARROT_BE_DIR)/src/include
VCS_OPTIONS += +incdir+$(BLACKPARROT_BE_DIR)/src/include/bp_be_dcache/
VCS_OPTIONS += +incdir+$(BLACKPARROT_ME_DIR)/src/include/v
VCS_OPTIONS += $(BLACKPARROT_COMMON_DIR)/src/include/bp_common_pkg.vh 
VCS_OPTIONS += $(BLACKPARROT_COMMON_DIR)/src/include/bp_common_aviary_pkg.vh
VCS_OPTIONS += $(BLACKPARROT_COMMON_DIR)/src/include/bp_common_rv64_pkg.vh
VCS_OPTIONS += $(BLACKPARROT_BE_DIR)/src/include/bp_be_pkg.vh
VCS_OPTIONS += $(BLACKPARROT_ME_DIR)/src/include/v/bp_cce_pkg.v
VCS_OPTIONS += $(BLACKPARROT_ME_DIR)/src/include/v/bp_me_pkg.vh
VCS_OPTIONS += $(BLACKPARROT_BE_DIR)/src/include/bp_be_dcache/bp_be_dcache_pkg.vh
VCS_OPTIONS += $(BASEJUMP_STL_DIR)/bsg_noc/bsg_wormhole_router_pkg.v
VCS_OPTIONS += $(BLACKPARROT_COMMON_DIR)/src/include/bp_common_cfg_link_pkg.vh
VCS_OPTIONS += $(BSG_DESIGNS_TARGET_DIR)/v/bsg_chip_pkg.v

# Additional options for RTL-Hard
VCS_OPTIONS += +notimingcheck
VCS_OPTIONS += +nospecify

########################################
## Chip and Testing Filelists and Liblists
########################################

BSG_TOP_SIM_MODULE = bsg_asic_cloud_pcb
BSG_CHIP_INSTANCE_PATH = bsg_asic_cloud_pcb.IC0.ASIC

VCS_OPTIONS += +define+BSG_TOP_SIM_MODULE=$(BSG_TOP_SIM_MODULE)
VCS_OPTIONS += +define+BSG_CHIP_INSTANCE_PATH=$(BSG_CHIP_INSTANCE_PATH)

export BSG_CHIP_LIBRARY_NAME = bsg_chip
export BSG_CHIP_FILELIST = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).filelist
export BSG_CHIP_LIBRARY = $(BSG_OUT_DIR)/$(BSG_CHIP_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_CHIP_LIBRARY_NAME=$(BSG_CHIP_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_CHIP_FILELIST)
VCS_OPTIONS += -libmap $(BSG_CHIP_LIBRARY)

export BSG_DESIGNS_TESTING_LIBRARY_NAME = bsg_design_testing
export BSG_DESIGNS_TESTING_FILELIST = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).filelist
export BSG_DESIGNS_TESTING_LIBRARY = $(BSG_OUT_DIR)/$(BSG_DESIGNS_TESTING_LIBRARY_NAME).library

VCS_OPTIONS += +define+BSG_DESIGNS_TESTING_LIBRARY_NAME=$(BSG_DESIGNS_TESTING_LIBRARY_NAME)
VCS_OPTIONS += -f $(BSG_DESIGNS_TESTING_FILELIST)
VCS_OPTIONS += -libmap $(BSG_DESIGNS_TESTING_LIBRARY)
VCS_OPTIONS += +define+den2048Mb+sg5+x16+FULL_MEM

$(BSG_CHIP_FILELIST): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_CHIP_LIBRARY): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_DESIGNS_TESTING_FILELIST): $(BSG_DESIGNS_TESTING_LIBRARY)
$(BSG_DESIGNS_TESTING_LIBRARY): $(BSG_OUT_DIR)/root
	/usr/bin/tclsh bsg_config.tcl

########################################
## Trace Replay Roms
########################################

BSG_TRACE_FILES := $(notdir $(wildcard $(BSG_WORK_DIR)/../traces/*.tr))
BSG_TRACE_ROMS  := $(addprefix $(BSG_OUT_DIR)/,${BSG_TRACE_FILES:.tr=_rom.v})

$(BSG_OUT_DIR)/%_rom.v: $(BSG_WORK_DIR)/../traces/%.tr | $(BSG_OUT_DIR)
	$(BASEJUMP_STL_DIR)/bsg_mem/bsg_ascii_to_rom.py $< $*_rom > $@

VCS_OPTIONS += $(addprefix -v ,$(BSG_TRACE_ROMS))

########################################
## BlackParrot test junk
########################################

PROG     :=hello_world
DRAM_CH  :=DDR2_micron_16M_8b_x8_sg3E.ini
DRAM_SYS :=system.ini

prog.nbf:
	@cp $(BLACKPARROT_DIR)/bp_common/test/mem/$(PROG).nbf $(BSG_OUT_DIR)/$@

prog.mem:
	@cp $(BLACKPARROT_DIR)/bp_common/test/mem/$(PROG).mem $(BSG_OUT_DIR)/$@

dram_ch.ini:
	@cp $(BLACKPARROT_DIR)/bp_common/test/cfg/$(DRAM_CH) $(BSG_OUT_DIR)/$@

dram_sys.ini:
	@cp $(BLACKPARROT_DIR)/bp_common/test/cfg/$(DRAM_SYS) $(BSG_OUT_DIR)/$@

cce_ucode.mem:
	@cp $(BLACKPARROT_DIR)/bp_me/src/asm/roms/mesi/bp_cce_inst_rom_mesi.mem $(BSG_OUT_DIR)/$@

########################################
## Run Targets
########################################

run: clean $(BSG_OUT_SIM)
	cd $(BSG_OUT_DIR); ./simv | tee -i $(BSG_OUT_DIR)/run.log

run-no-tee: clean $(BSG_OUT_SIM)
	cd $(BSG_OUT_DIR); ./simv

rerun: $(BSG_OUT_SIM)
	cd $(BSG_OUT_DIR); ./simv | tee -i $(BSG_OUT_DIR)/run.log

rerun-no-tee: $(BSG_OUT_SIM)
	cd $(BSG_OUT_DIR); ./simv

view:
	cd $(BSG_OUT_DIR); $(VCS_BIN)/dve -full64 -vpd vcdplus.vpd

build: $(BSG_OUT_SIM)
$(BSG_OUT_SIM): $(BSG_CHIP_FILELIST) $(BSG_CHIP_LIBRARY) $(BSG_DESIGNS_TESTING_FILELIST) $(BSG_DESIGNS_TESTING_LIBRARY) $(BSG_TRACE_ROMS) prog.nbf prog.mem dram_ch.ini dram_sys.ini cce_ucode.mem
	$(VCS) $(VCS_OPTIONS) | tee -i $(BSG_OUT_DIR)/build.log

$(BSG_OUT_DIR)/root: | $(BSG_OUT_DIR)
	ln -nsf $(BSG_DESIGNS_TARGET_DIR) $@

$(BSG_OUT_DIR):
	mkdir -p $@

clean:
	rm -rf $(BSG_OUT_DIR)
	rm -rf DVEfiles
	rm -rf stack.info.*
	rm -f  vc_hdrs.h
	rm -f  vcdplus.vpd
	rm -f  inter.vpd
	rm -f  ucli.key
	rm -f  main.riscv main_dmem.mem main_dram.mem

