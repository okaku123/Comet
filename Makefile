ROOTLESS ?= 0

# Build config
ARCHS = arm64 arm64e
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = Preferences
PACKAGE_VERSION = 1.0.2

# Rootless / Rootful settings
ifeq ($(ROOTLESS),1)
	THEOS_PACKAGE_SCHEME = rootless
	COMET_INSTALL_PATH = /var/jb/Library/Frameworks
	# Control
	PKG_ARCHITECTURE = iphoneos-arm64
	PKG_NAME_SUFFIX = (Rootless)
else
	COMET_INSTALL_PATH = /Library/Frameworks
	# Control
	PKG_ARCHITECTURE = iphoneos-arm
endif

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Comet
Comet_XCODEFLAGS = LD_DYLIB_INSTALL_NAME=$(COMET_INSTALL_PATH)/Comet.framework/Comet
Comet_XCODEFLAGS += DYLIB_INSTALL_NAME_BASE=$(COMET_INSTALL_PATH)/Comet.framework/Comet
Comet_XCODEFLAGS += DWARF_DSYM_FOLDER_PATH=$(THEOS_OBJ_DIR)/dSYMs
Comet_XCODEFLAGS += CONFIGURATION_BUILD_DIR=$(THEOS_OBJ_DIR)/

include $(THEOS)/makefiles/xcodeproj.mk

override THEOS_PACKAGE_NAME := com.ginsu.comet-$(PKG_ARCHITECTURE)

before-package::
	# Append values to control file
	$(ECHO_NOTHING)sed -i '' \
		-e 's/\$${PKG_ARCHITECTURE}/$(PKG_ARCHITECTURE)/g' \
		-e 's/\$${VERSION}/$(PACKAGE_VERSION)/g' \
		-e 's/\$${PKG_NAME_SUFFIX}/$(PKG_NAME_SUFFIX)/g' \
		$(THEOS_STAGING_DIR)/DEBIAN/control$(ECHO_END)
	
	# Move to staging dir
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)$(ECHO_END)
	$(ECHO_NOTHING)mv $(THEOS_OBJ_DIR)/Comet.framework/ $(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)$(ECHO_END)
	
	# Sign
	$(ECHO_NOTHING)ldid -Sentitlements.xml $(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)/Comet.framework/Comet$(ECHO_END)
internal-stage::
	$(ECHO_NOTHING)rm -rf $(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)$(ECHO_END)
