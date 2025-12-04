ARCHS := arm64 arm64e
TARGET := iphone:clang:15.6:14.0

include $(THEOS)/makefiles/common.mk

# Use TOOL to create executable instead of shared library
TOOL_NAME = HeliumWidget
$(TOOL_NAME)_FILES = HeliumWidget.swift
$(TOOL_NAME)_INSTALL_PATH = /tmp/helium_widget_build
$(TOOL_NAME)_FRAMEWORKS = WidgetKit SwiftUI
$(TOOL_NAME)_SWIFTFLAGS = -swift-version 5

ifeq ($(TARGET_CODESIGN),ldid)
$(TOOL_NAME)_CODESIGN_FLAGS = -Sent.plist
else
$(TOOL_NAME)_CODESIGN_FLAGS = --entitlements ent.plist
endif

include $(THEOS_MAKE_PATH)/tool.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Applications/Helium.app/PlugIns/HeliumWidget.appex$(ECHO_END)
	$(ECHO_NOTHING)cp $(THEOS_STAGING_DIR)/tmp/helium_widget_build/HeliumWidget $(THEOS_STAGING_DIR)/Applications/Helium.app/PlugIns/HeliumWidget.appex/HeliumWidget$(ECHO_END)
	$(ECHO_NOTHING)cp Info.plist $(THEOS_STAGING_DIR)/Applications/Helium.app/PlugIns/HeliumWidget.appex/Info.plist$(ECHO_END)
