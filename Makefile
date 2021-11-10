#Only use if using Xcode 12+
PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

export ARCHS = arm64 arm64e
TARGET = iphone:clang:14.4
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iSponsorBlock

iSponsorBlock_FILES = iSponsorBlock.xm $(wildcard *.m)
iSponsorBlock_LIBRARIES = colorpicker
iSponsorBlock_FRAMEWORKS = UIKit CoreGraphics AVFoundation CoreMedia QuartzCore
iSponsorBlock_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

BUNDLE_NAME = com.galacticdev.isponsorblock
com.galacticdev.isponsorblock_INSTALL_PATH = /Library/Application Support/

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk