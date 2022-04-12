include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= macos
TARGET_CPU ?= x64

include ../common.mk

EXTRA_GN_ARGS_DEBUG := \
	target_os="mac" \
	target_cpu="$(TARGET_CPU)" \
	enable_stripping=true \
	enable_dsyms=true \
	is_debug=true \
	treat_warnings_as_errors=false \
	$(RTC_USE_H264) \
	rtc_include_tests=false \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_libvpx_build_vp9=true \
	is_component_build=false \
	use_rtti=true

EXTRA_GN_ARGS_RELEASE := \
	target_os="mac" \
	target_cpu="$(TARGET_CPU)" \
	enable_stripping=true \
	enable_dsyms=true \
	is_debug=false \
	treat_warnings_as_errors=false \
	$(RTC_USE_H264) \
	rtc_include_tests=false \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_libvpx_build_vp9=true \
	is_component_build=false \
	use_rtti=true

.PHONY: all
all: clean build package

.PHONY: package
package: common-package

.PHONY: copy
copy: common-copy

.PHONY: patch
patch: common-patch

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR_DEBUG)   --args='$(EXTRA_GN_ARGS_DEBUG)   $(CC_WRAPPER)' && \
	gn gen $(BUILD_DIR_RELEASE) --args='$(EXTRA_GN_ARGS_RELEASE) $(CC_WRAPPER)' && \
	ninja -C $(BUILD_DIR_DEBUG) && \
	ninja -C $(BUILD_DIR_DEBUG) \
	  builtin_audio_decoder_factory \
	  default_task_queue_factory \
	  native_api \
	  default_codec_factory_objc \
	  peerconnection \
	  videocapture_objc && \
	ninja -C $(BUILD_DIR_RELEASE) && \
	ninja -C $(BUILD_DIR_RELEASE) \
	  builtin_audio_decoder_factory \
	  default_task_queue_factory \
	  native_api \
	  default_codec_factory_objc \
	  peerconnection \
	  videocapture_objc
