#Only use if using Xcode 12+
PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

export ARCHS = arm64 arm64e
TARGET := iphone:clang:13.4
INSTALL_TARGET_PROCESSES = YouTube


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iSponsorBlock

iSponsorBlock_FILES = iSponsorBlock.xm $(wildcard *.m)
iSponsorBlock_LIBRARIES = colorpicker
iSponsorBlock_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
