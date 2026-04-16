# ======================================================================
# Makefile for cross-compiling UniBone/QBone software on Linux
# ======================================================================


# ======================================================================
# Build Options
#
# QUNIBONE_PLATFORM=UNIBUS|QBUS
# MAKE_CONFIGURATION=RELEASE|DBG
# 
# ======================================================================

QUNIBONE_PLATFORM    ?= UNIBUS
MAKE_CONFIGURATION   ?= RELEASE


# ======================================================================
# URLs for External Packages
# ======================================================================

ARM_TOOLCHAIN_URL    ?= https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-linux-gnueabihf.tar.xz
PRU_TOOLCHAIN_URL ?= https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-FaNNGkDH7s/2.3.3/ti_cgt_pru_2.3.3_linux_installer_x86.bin
PRU_PACKAGE_REPO_URL ?= https://github.com/beagleboard/am335x_pru_package.git
LIBTIRPC_PACKAGE_URL ?= https://downloads.sourceforge.net/libtirpc/libtirpc-1.3.7.tar.bz2
QUNIBONE_REPO_URL    ?= https://github.com/j-hoppe/QUniBone.git


# ======================================================================
# Logging
# ======================================================================

HIGHLIGHT            ?= \\e[1;33m
NORMAL               ?= \\e[0m
define LOG =
@echo "$(HIGHLIGHT)$(strip $(1))$(NORMAL)"
endef


# ======================================================================
# Directory Creation Rules
# ======================================================================

BUILD_DIR            ?= $(dir $(firstword $(MAKEFILE_LIST)))
DOWNLOAD_DIR         ?= $(ABS_BUILD_DIR)/dl
ABS_BUILD_DIR        := $(abspath $(BUILD_DIR))
ABS_DOWNLOAD_DIR     := $(abspath $(DOWNLOAD_DIR))

$(ABS_BUILD_DIR) :
	@mkdir -p $(ABS_BUILD_DIR)

$(ABS_DOWNLOAD_DIR) :
	@mkdir -p $(ABS_DOWNLOAD_DIR)


# ======================================================================
# ARM Toolchain Rules
# ======================================================================

ARM_TOOLCHAIN_PACKAGE_FILE = $(shell basename $(ARM_TOOLCHAIN_URL))

.PHONY : download-arm-toolchain install-arm-toolchain remove-arm-toolchain

download-arm-toolchain : $(ABS_DOWNLOAD_DIR)/$(ARM_TOOLCHAIN_PACKAGE_FILE)

$(ABS_DOWNLOAD_DIR)/$(ARM_TOOLCHAIN_PACKAGE_FILE) : | $(ABS_DOWNLOAD_DIR)
	$(call LOG, "===== Fetching ARM toolchain")
	wget -O $(ABS_DOWNLOAD_DIR)/$(ARM_TOOLCHAIN_PACKAGE_FILE) $(ARM_TOOLCHAIN_URL)

install-arm-toolchain : $(ABS_BUILD_DIR)/arm-toolchain

$(ABS_BUILD_DIR)/arm-toolchain : $(ABS_DOWNLOAD_DIR)/$(ARM_TOOLCHAIN_PACKAGE_FILE) | $(ABS_BUILD_DIR)
	$(call LOG, "===== Installing ARM toolchain")
	@rm -rf $(ABS_BUILD_DIR)/arm-toolchain $(ABS_BUILD_DIR)/arm-toolchain-tmp
	@mkdir -p $(ABS_BUILD_DIR)/arm-toolchain-tmp
	tar -C $(ABS_BUILD_DIR)/arm-toolchain-tmp --strip-components=1 -xf $(ABS_DOWNLOAD_DIR)/$(ARM_TOOLCHAIN_PACKAGE_FILE)
	mv $(ABS_BUILD_DIR)/arm-toolchain-tmp $(ABS_BUILD_DIR)/arm-toolchain

remove-arm-toolchain :
	$(call LOG, "===== Removing ARM toolchain")
	@rm -rf $(ABS_BUILD_DIR)/arm-toolchain


# ======================================================================
# PRU Toolchain Rules
# ======================================================================

PRU_TOOLCHAIN_PACKAGE_FILE = $(shell basename $(PRU_TOOLCHAIN_URL))

.PHONY : download-pru-toolchain install-pru-toolchain remove-pru-toolchain

download-pru-toolchain : $(ABS_DOWNLOAD_DIR)/$(PRU_TOOLCHAIN_PACKAGE_FILE)

$(ABS_DOWNLOAD_DIR)/$(PRU_TOOLCHAIN_PACKAGE_FILE) : | $(ABS_DOWNLOAD_DIR)
	$(call LOG, "===== Fetching TI PRU toolchain")
	wget -O $(ABS_DOWNLOAD_DIR)/$(PRU_TOOLCHAIN_PACKAGE_FILE) $(PRU_TOOLCHAIN_URL)
	chmod +x $(ABS_DOWNLOAD_DIR)/$(PRU_TOOLCHAIN_PACKAGE_FILE)

install-pru-toolchain : $(ABS_BUILD_DIR)/pru-toolchain

$(ABS_BUILD_DIR)/pru-toolchain : $(ABS_DOWNLOAD_DIR)/$(PRU_TOOLCHAIN_PACKAGE_FILE) | $(ABS_BUILD_DIR)
	$(call LOG, "===== Installing TI PRU toolchain")
	@rm -rf $(ABS_BUILD_DIR)/pru-toolchain $(ABS_BUILD_DIR)/pru-toolchain-tmp
	@mkdir -p $(ABS_BUILD_DIR)/pru-toolchain-tmp
	$(ABS_DOWNLOAD_DIR)/$(PRU_TOOLCHAIN_PACKAGE_FILE) --mode unattended --prefix $(ABS_BUILD_DIR)/pru-toolchain-tmp
	mv $(ABS_BUILD_DIR)/pru-toolchain-tmp/ti-cgt-pru_* $(ABS_BUILD_DIR)/pru-toolchain
	rmdir $(ABS_BUILD_DIR)/pru-toolchain-tmp

remove-pru-toolchain :
	$(call LOG, "===== Removing PRU toolchain")
	@rm -rf $(ABS_BUILD_DIR)/pru-toolchain


# ======================================================================
# AM335x PRU Package Rules
# ======================================================================

PRU_PACKET_CFLAGS   =-I$(ABS_BUILD_DIR)/am335x_pru_package/pru_sw/app_loader/include

.PHONY : download-pru-package remove-pru-package

download-pru-package : $(ABS_BUILD_DIR)/am335x_pru_package

$(ABS_BUILD_DIR)/am335x_pru_package : 
	$(call LOG, "===== Fetching AM335x PRU package")
	git clone $(PRU_PACKAGE_REPO_URL) $(ABS_BUILD_DIR)/am335x_pru_package

remove-pru-package :
	$(call LOG, "===== Removing AM335x PRU package")
	@rm -rf $(ABS_BUILD_DIR)/am335x_pru_package


# ======================================================================
# libtirpc (Transport-Independent RPC Library) Package Rules
# ======================================================================

LIBTIRPC_PACKAGE_FILE   = $(shell basename $(LIBTIRPC_PACKAGE_URL))
LIBTIRPC_OUTPUT_DIR     = $(ABS_BUILD_DIR)/libtirpc/output
LIBTIRPC_CFLAGS         = -I$(LIBTIRPC_OUTPUT_DIR)/include -I$(LIBTIRPC_OUTPUT_DIR)/include/tirpc
LIBTIRPC_LDFLAGS        = -L$(LIBTIRPC_OUTPUT_DIR)/lib -ltirpc -Wl,-rpath-link,$(LIBTIRPC_OUTPUT_DIR)/lib

.PHONY : download-libtirpc unpack-libtirpc configure-libtirpc build-libtirpc clean-libtirpc

download-libtirpc : $(ABS_DOWNLOAD_DIR)/$(LIBTIRPC_PACKAGE_FILE)

$(ABS_DOWNLOAD_DIR)/$(LIBTIRPC_PACKAGE_FILE) : | $(ABS_DOWNLOAD_DIR)
	$(call LOG, "===== Fetching libtirpc")
	wget -O $(ABS_DOWNLOAD_DIR)/$(LIBTIRPC_PACKAGE_FILE) $(LIBTIRPC_PACKAGE_URL)

unpack-libtirpc : $(ABS_BUILD_DIR)/libtirpc

$(ABS_BUILD_DIR)/libtirpc : $(ABS_DOWNLOAD_DIR)/$(LIBTIRPC_PACKAGE_FILE) | $(ABS_BUILD_DIR)
	$(call LOG, "===== Unpacking libtirpc")
	@rm -rf $(ABS_BUILD_DIR)/libtirpc $(ABS_BUILD_DIR)/libtirpc-tmp
	@mkdir $(ABS_BUILD_DIR)/libtirpc-tmp
	tar -C $(ABS_BUILD_DIR)/libtirpc-tmp --strip-components=1 -xf $(ABS_DOWNLOAD_DIR)/$(LIBTIRPC_PACKAGE_FILE)
	mv $(ABS_BUILD_DIR)/libtirpc-tmp $(ABS_BUILD_DIR)/libtirpc

configure-libtirpc : $(ABS_BUILD_DIR)/libtirpc/config.status

$(ABS_BUILD_DIR)/libtirpc/config.status : | $(ABS_BUILD_DIR)/libtirpc 
	$(call LOG, "===== Configuring libtirpc")
	(cd $(ABS_BUILD_DIR)/libtirpc; \
	 PATH=$(ABS_BUILD_DIR)/arm-toolchain/bin:$$PATH \
	 ./configure --host=arm-none-linux-gnueabihf --prefix=$(abspath $(LIBTIRPC_OUTPUT_DIR)) --disable-gssapi \
	)
	touch $(ABS_BUILD_DIR)/libtirpc/config.status

build-libtirpc : $(LIBTIRPC_OUTPUT_DIR)/lib/libtirpc.a

$(LIBTIRPC_OUTPUT_DIR)/lib/libtirpc.a : $(ABS_BUILD_DIR)/libtirpc/config.status
	$(call LOG, "===== Building libtirpc")
	PATH=$(ABS_BUILD_DIR)/arm-toolchain/bin:$$PATH \
	make -C $(ABS_BUILD_DIR)/libtirpc install

clean-libtirpc :
	$(call LOG, "===== Cleaning libtirpc")
	@[ \! -d $(ABS_BUILD_DIR)/libtirpc ] || { \
		cp $(ABS_BUILD_DIR)/libtirpc/src/libtirpc.map $(ABS_BUILD_DIR)/libtirpc/src/libtirpc.map.save; \
		make -C $(ABS_BUILD_DIR)/libtirpc clean; \
		mv $(ABS_BUILD_DIR)/libtirpc/src/libtirpc.map.save $(ABS_BUILD_DIR)/libtirpc/src/libtirpc.map; \
	}
	@rm -rf $(LIBTIRPC_OUTPUT_DIR)

remove-librirpc : 
	$(call LOG, "===== Removing libtirpc")
	@rm -rf $(ABS_BUILD_DIR)/libtirpc


# ======================================================================
# QUniBone Source Tree Rules
# ======================================================================

clone-qunibone : $(ABS_BUILD_DIR)/QUniBone

$(ABS_BUILD_DIR)/QUniBone :
	$(call LOG, "===== Fetching QUniBone Source Tree")
	git clone $(QUNIBONE_REPO_URL) $(ABS_BUILD_DIR)/QUniBone

patch-qunibone : $(ABS_BUILD_DIR)/QUniBone/.patched

$(ABS_BUILD_DIR)/QUniBone/.patched : $(wildcard patches/*.patch) | $(ABS_BUILD_DIR)/QUniBone
	$(call LOG, "===== Patching QUniBone Source Tree")
	for p in patches/*.patch; do \
		patch -d $(ABS_BUILD_DIR)/QUniBone -r - -N -p1 <$$p; \
	done
	touch $(ABS_BUILD_DIR)/QUniBone/.patched

build-qunibone : $(ABS_BUILD_DIR)/QUniBone/.patched | install-arm-toolchain install-pru-toolchain download-pru-package build-libtirpc
	$(call LOG, "===== Building QUniBone Source Tree")
	PATH=$(ABS_BUILD_DIR)/arm-toolchain/bin:$$PATH \
	QUNIBONE_DIR="$(ABS_BUILD_DIR)/QUniBone" \
	QUNIBONE_PLATFORM=$(QUNIBONE_PLATFORM) \
	MAKE_CONFIGURATION=RELEASE \
	MAKE_TARGET_ARCH=BBB \
	PRU_CGT="$(ABS_BUILD_DIR)/pru-toolchain" \
	BBB_CC="arm-none-linux-gnueabihf-gcc -mthumb-interwork -mfloat-abi=hard -mfpu=neon -march=armv7-a $(PRU_PACKET_CFLAGS) $(LIBTIRPC_CFLAGS)" \
	LDFLAGS="$(LIBTIRPC_LDFLAGS)" \
	make -C $(ABS_BUILD_DIR)/QUniBone/10.03_app_demo/2_src \

clean-qunibone :
	$(call LOG, "===== Cleaning QUniBone Source Tree")
	@[ \! -d $(ABS_BUILD_DIR)/QUniBone ] || { \
		PATH=$(ABS_BUILD_DIR)/arm-toolchain/bin:$$PATH \
		QUNIBONE_DIR="$(ABS_BUILD_DIR)/QUniBone" \
		QUNIBONE_PLATFORM=UNIBUS \
		QUNIBONE_PLATFORM_SUFFIX=_u \
		MAKE_CONFIGURATION=RELEASE \
		MAKE_TARGET_ARCH=BBB \
		PRU_CGT="$(ABS_BUILD_DIR)/pru-toolchain" \
		BBB_CC="arm-none-linux-gnueabihf-gcc -mthumb-interwork -mfloat-abi=hard -mfpu=neon -march=armv7-a $(PRU_PACKET_CFLAGS) $(LIBTIRPC_CFLAGS)" \
		LDFLAGS="$(LIBTIRPC_LDFLAGS)" \
		make -C $(ABS_BUILD_DIR)/QUniBone/10.03_app_demo/2_src clean \
	}

remove-qunibone :
	$(call LOG, ===== Removing QUniBone Source Tree)
	@rm -rf $(ABS_BUILD_DIR)/QUniBone


# ======================================================================
# Global Rules
# ======================================================================

.DEFAULT_GOAL := all

.PHONY : all clean reset

all : build-qunibone

clean : clean-qunibone

reset : remove-qunibone remove-librirpc remove-pru-package remove-pru-toolchain remove-arm-toolchain
