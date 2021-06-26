ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = com.galacticdev.isponsorblock

$(BUNDLE_NAME)_INSTALL_PATH = /var/mobile/Library/Application Support

TWEAK_NAME = iSponsorBlock

$(TWEAK_NAME)_FILES = iSponsorBlock.xm $(wildcard *.m)
$(TWEAK_NAME)_LIBRARIES = colorpicker
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
