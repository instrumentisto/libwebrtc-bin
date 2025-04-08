include ../../VERSION

BASE_DIR := $(realpath ../..)

include ../env.mk

TARGET_OS ?= linux
TARGET_CPU ?= arm64

include ../common.mk

EXTRA_GN_ARGS := \
	target_os="$(TARGET_OS)" \
	target_cpu="$(TARGET_CPU)" \
	proprietary_codecs=false \
	rtc_use_x11=true \
	rtc_include_tests=false \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_use_pipewire=false \
	rtc_build_json=true \
	use_rtti=true \
	use_custom_libcxx=false \
	use_custom_libcxx_for_host=false \
	libyuv_include_tests=false

.PHONY: all
all: clean build package

.PHONY: package
package: common-package

.PHONY: copy
copy: common-copy

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) && \
	patch -p1 < $(PATCH_DIR)/4k_linux.patch && \
	patch -p1 < $(PATCH_DIR)/disable_use_hermetic_xcode_on_linux.patch && \
	patch -p1 < $(PATCH_DIR)/linux_clang_optional.patch && \
	patch -p1 < $(PATCH_DIR)/linux_fix_enable_safe_libstdcxx.patch

.PHONY: build
build: download patch
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR_DEBUG) --args='$(EXTRA_GN_ARGS) $(CC_WRAPPER)' && \
	gn gen $(BUILD_DIR_RELEASE) --args='$(EXTRA_GN_ARGS) is_debug=false $(CC_WRAPPER)' && \
	ninja -C $(BUILD_DIR_DEBUG) && \
	ninja -C $(BUILD_DIR_RELEASE)

	cd $(BUILD_DIR_DEBUG)/obj && \
	/usr/bin/ar -rc $(BUILD_DIR_DEBUG)/obj/libwebrtc.a `find . -name '*.o'`

	cd $(BUILD_DIR_RELEASE)/obj && \
	/usr/bin/ar -rc $(BUILD_DIR_RELEASE)/obj/libwebrtc.a `find . -name '*.o'`
