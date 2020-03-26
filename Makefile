ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iSponsorBlock

iSponsorBlock_FILES = Tweak.xm sponsorTimes.m
iSponsorBlock_CFLAGS = -fobjc-arc
iSponsorBlock_FRAMEWORKS = CoreML
include $(THEOS_MAKE_PATH)/tweak.mk
