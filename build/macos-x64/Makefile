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
	is_component_build=false \
	treat_warnings_as_errors=false \
	rtc_build_examples=false \
	rtc_build_tools=false \
	rtc_enable_objc_symbol_export=true \
	rtc_enable_symbol_export=true \
	rtc_include_tests=false \
	rtc_libvpx_build_vp9=true \
	rtc_use_perfetto=false \
	use_custom_libcxx=false \
	use_custom_libcxx_for_host=false \
	use_rtti=true \
	libyuv_include_tests=false \
	proprietary_codecs=false \
	mac_deployment_target="10.15"

.PHONY: all
all: clean build package

.PHONY: package
package: copy
	cd $(PACKAGE_DIR) && \
	tar -czvf $(subst $(space),,$(PACKAGE_NAME)).tar.gz include debug release NOTICE VERSION Frameworks

.PHONY: copy
copy: common-copy
	rm -f $(PACKAGE_DIR)/lib/libboringssl.a
	rm -rf $(PACKAGE_DIR)/Frameworks/WebRTC.xcframework
	xcodebuild \
		-create-xcframework \
		-framework $(BUILD_DIR_RELEASE)/WebRTC.framework \
		-debug-symbols $(BUILD_DIR_RELEASE)/WebRTC.dSYM \
		-output $(PACKAGE_DIR)/Frameworks/WebRTC.xcframework

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) && \
	patch -p2 < $(PATCH_DIR)/add_yuv_helper_ios_mac.patch

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR_DEBUG) --args='$(EXTRA_GN_ARGS) $(CC_WRAPPER)' && \
	gn gen $(BUILD_DIR_RELEASE) --args='$(EXTRA_GN_ARGS) is_debug=false $(CC_WRAPPER)' && \
	ninja -v -C $(BUILD_DIR_DEBUG) && \
	ninja -v -C $(BUILD_DIR_DEBUG) \
		api/audio_codecs:builtin_audio_decoder_factory \
		api/task_queue:default_task_queue_factory \
		sdk:native_api \
		sdk:default_codec_factory_objc \
		pc:peer_connection \
		sdk:videocapture_objc \
		sdk:mac_framework_objc && \
	ninja -v -C $(BUILD_DIR_RELEASE) && \
	ninja -v -C $(BUILD_DIR_RELEASE) \
		api/audio_codecs:builtin_audio_decoder_factory \
		api/task_queue:default_task_queue_factory \
		sdk:native_api \
		sdk:default_codec_factory_objc \
		pc:peer_connection \
		sdk:videocapture_objc \
		sdk:mac_framework_objc
	cd $(BUILD_DIR_DEBUG)/obj && \
	/usr/bin/ar -rc $(BUILD_DIR_DEBUG)/obj/libwebrtc.a `find . -name '*.o'`
	cd $(BUILD_DIR_RELEASE)/obj && \
	/usr/bin/ar -rc $(BUILD_DIR_RELEASE)/obj/libwebrtc.a `find . -name '*.o'`
