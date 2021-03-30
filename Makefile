#Only use if using Xcode 12+
PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

export ARCHS = arm64 arm64e
TARGET := iphone:clang:13.4
INSTALL_TARGET_PROCESSES = YouTube

ifeq ($(JAILED),1)
EXTRA_CFLAGS = -DJAILED
else
EXTRA_CFLAGS =
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iSponsorBlock

iSponsorBlock_FILES = iSponsorBlock.xm $(wildcard *.m)
iSponsorBlock_LIBRARIES = colorpicker
iSponsorBlock_CFLAGS = -fobjc-arc -Wno-deprecated-declarations $(EXTRA_CFLAGS)
ifeq ($(JAILED),1)
iSponsorBlock_FRAMEWORKS = UIKit CoreGraphics AVFoundation CoreMedia QuartzCore
endif

include $(THEOS_MAKE_PATH)/tweak.mk

# Add bundle for jailed support
ifeq ($(JAILED),1)
BUNDLE_NAME = com.galacticdev.isponsorblock
include $(THEOS)/makefiles/bundle.mk
else
internal-stage::
	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)/var/mobile/Library/Application Support/iSponsorBlock/"$(ECHO_END)
	$(ECHO_NOTHING)cp -r Resources/* "$(THEOS_STAGING_DIR)/var/mobile/Library/Application Support/iSponsorBlock/"$(ECHO_END)
endif
