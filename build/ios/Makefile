include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= ios
TARGET_CPU =

include ../common.mk

EXTRA_GN_ARGS := \
	is_debug=false \
	rtc_libvpx_build_vp9=true \
	rtc_include_tests=false \
	rtc_build_examples=false \
	rtc_build_tools=false \
	rtc_use_perfetto=false \
	use_rtti=true \
	libyuv_include_tests=false \
	proprietary_codecs=false \
	ios_deployment_target="15.0"

.PHONY: all
all: clean build package

.PHONY: package
package:
	mkdir -p $(PACKAGE_DIR) && \
	cd $(BUILD_DIR) && \
	zip -9 -r $(PACKAGE_DIR)/$(subst $(space),,$(PACKAGE_NAME)).zip WebRTC.xcframework/*

.PHONY: patch
# TODO(rogurotus): `fix_ios_capability.patch` needed to create
#                  `RtpCodecCapability` from raw values.
#                  Remove when deleting readonly attributes from
#                  `objc/api/peerconnection/RTCRtpCodecCapability.h`.
patch: common-patch
	cd $(SRC_DIR) && \
	patch -p2 < $(PATCH_DIR)/enable_ios_scalability_mode.patch && \
	patch -p2 < $(PATCH_DIR)/fix_ios_capability.patch && \
	patch -p2 < $(PATCH_DIR)/add_yuv_helper_ios_mac.patch

.PHONY: build
build: patch
	mkdir -p $(SRC_DIR)/out && \
	mkdir -p $(BUILD_DIR) && \
	cd $(SRC_DIR)/tools_webrtc/ios && \
	python3 build_ios_libs.py --output-dir out --build_config release --extra-gn-args '$(EXTRA_GN_ARGS) $(CC_WRAPPER)' && \
	mv $(SRC_DIR)/tools_webrtc/ios/out/WebRTC.xcframework $(BUILD_DIR)/
