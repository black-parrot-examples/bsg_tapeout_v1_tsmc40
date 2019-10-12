THIS_DIR :=$(realpath $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

GIT_CLONE_STYLE :=ssh
#GIT_CLONE_STYLE :=https

ifeq ($(GIT_CLONE_STYLE),ssh)
  GITHUB    :=git@github.com:
  BITBUCKET :=git@bitbucket.com:

else ifeq ($(GIT_CLONE_STYLE),https)
  GITHUB    :=https://github.com/
  BITBUCKET :=https://bitbucket.com/

endif

basejump_stl_dir     :=$(THIS_DIR)/basejump_stl
basejump_stl_url     :=$(GITHUB)bespoke-silicon-group/basejump_stl
basejump_stl_commit  :=tapeout_bp_rc2

bsg_40_dir           :=$(THIS_DIR)/bsg_40
bsg_40_url           :=$(GITHUB)hema0730/bsg_40
bsg_40_commit        :=master

bsg_cadenv_dir       :=$(THIS_DIR)/bsg_cadenv
bsg_cadenv_url       :=$(BITBUCKET)taylor-bsg/bsg_cadenv
bsg_cadenv_commit    :=master

board_dir            :=$(THIS_DIR)/board
board_url            :=$(BITBUCKET)taylor-bsg/board
board_commit         :=master

bsg_packaging_dir    :=$(THIS_DIR)/bsg_packaging
bsg_packaging_url    :=$(BITBUCKET)taylor-bsg/bsg_packaging
bsg_packaging_commit :=master

bp_pre_alpha_release_dir     :=$(THIS_DIR)/pre-alpha-release
bp_pre_alpha_release_url     :=$(GITHUB)black-parrot/pre-alpha-release
bp_pre_alpha_release_commit  :=tapeout_bp_rc2

all_repos = $(subst _url,.repo,$(filter %_url,$(.VARIABLES)))

all: $(all_repos)

%.repo:
	-git clone $($*_url) $($*_dir)
	-cd $($*_dir) ; git checkout $($*_commit)

clean: are_you_sure
	rm -rf $(subst .repo,,$(all_repos))

DISABLE_SAFETY_PROMPT ?= false
are_you_sure:
	@$(DISABLE_SAFETY_PROMPT) || (echo -n "Are you sure [Y/n]? " && read ans && ([ "$$ans" == "Y" ] || [ "$$ans" == "y" ]))

