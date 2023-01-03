include ../../VERSION

BASE_DIR := $(CURDIR)/../..

include ../env.mk

TARGET_OS ?= macos
TARGET_CPU ?= x64

include ../common.mk

EXTRA_GN_ARGS := \
	target_os="mac" \
	target_cpu="$(TARGET_CPU)" \
	enable_stripping=true \
	enable_dsyms=true \
	treat_warnings_as_errors=false \
	rtc_use_h264=true \
	rtc_include_tests=false \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_libvpx_build_vp9=true \
	rtc_enable_symbol_export=true \
	rtc_enable_objc_symbol_export=true \
	is_component_build=false \
	use_rtti=true \
	use_custom_libcxx=false \
	use_custom_libcxx_for_host=false

.PHONY: all
all: clean build package

.PHONY: package
package: copy
	cd $(PACKAGE_DIR) && \
	tar -czvf $(subst $(space),,$(PACKAGE_NAME)).tar.gz include debug release NOTICE VERSION

.PHONY: copy
copy: common-copy

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) && \
	patch -p2 < $(PATCH_DIR)/macos_h264_encoder.patch

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR_DEBUG) --args='$(EXTRA_GN_ARGS) $(CC_WRAPPER)' && \
	gn gen $(BUILD_DIR_RELEASE) --args='$(EXTRA_GN_ARGS) is_debug=false $(CC_WRAPPER)' && \
	ninja -C $(BUILD_DIR_DEBUG) && \
	ninja -C $(BUILD_DIR_DEBUG) \
		api/audio_codecs:builtin_audio_decoder_factory \
		api/task_queue:default_task_queue_factory \
		sdk:native_api \
		sdk:default_codec_factory_objc \
		pc:peerconnection \
		sdk:videocapture_objc \
		sdk:mac_framework_objc && \
	ninja -C $(BUILD_DIR_RELEASE) && \
	ninja -C $(BUILD_DIR_RELEASE) \
		api/audio_codecs:builtin_audio_decoder_factory \
		api/task_queue:default_task_queue_factory \
		sdk:native_api \
		sdk:default_codec_factory_objc \
		pc:peerconnection \
		sdk:videocapture_objc \
		sdk:mac_framework_objc
	cd $(BUILD_DIR_DEBUG)/obj && \
	/usr/bin/ar -rc $(BUILD_DIR_DEBUG)/obj/libwebrtc.a `find . -name '*.o'`
	cd $(BUILD_DIR_RELEASE)/obj && \
	/usr/bin/ar -rc $(BUILD_DIR_RELEASE)/obj/libwebrtc.a `find . -name '*.o'`
