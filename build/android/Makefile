include ../../VERSION

BASE_DIR := $(realpath ../..)

include ../env.mk

TARGET_OS ?= android
TARGET_CPU =

include ../common.mk

EXTRA_GN_ARGS := \
	is_debug=false \
	is_java_debug=false \
	is_clang=true \
	is_component_build=false \
	rtc_build_examples=false \
	rtc_build_json=true \
	rtc_build_tools=false \
	rtc_enable_protobuf=false \
	rtc_include_tests=false \
	rtc_use_perfetto=false \
	use_rtti=true \
	libyuv_include_tests=false \
	proprietary_codecs=false

.PHONY: all
all: clean build package

.PHONY: package
package:
ifeq ($(static),yes)
	mkdir -p $(PACKAGE_DIR)/lib/$(arch)/
	cp -f $(BUILD_DIR)/static/$(arch)/libwebrtc.a $(PACKAGE_DIR)/lib/$(arch)/
	cd $(PACKAGE_DIR) && \
	tar -czvf libwebrtc-android-$(target_cpu).tar.gz lib
else
	make copy
	cd $(PACKAGE_DIR) && \
	tar -czvf $(subst $(space),,$(PACKAGE_NAME)).tar.gz aar jar include lib NOTICE VERSION
endif

.PHONY: copy
copy:
	rm -rf $(PACKAGE_DIR)/aar
	rm -rf $(PACKAGE_DIR)/jar
	rm -rf $(PACKAGE_DIR)/include
	rm -rf $(PACKAGE_DIR)/lib
	rm -f $(PACKAGE_DIR)/NOTICE
	rm -f $(PACKAGE_DIR)/VERSION
	mkdir -p $(PACKAGE_DIR)/aar
	mkdir -p $(PACKAGE_DIR)/jar
	mkdir -p $(PACKAGE_DIR)/lib/armeabi-v7a
	mkdir -p $(PACKAGE_DIR)/lib/arm64-v8a
	mkdir -p $(PACKAGE_DIR)/lib/x86_64
	mkdir -p $(PACKAGE_DIR)/include
	cp -f $(BUILD_DIR)/libwebrtc.jar $(PACKAGE_DIR)/jar/
	cp -f $(BUILD_DIR)/libwebrtc.aar $(PACKAGE_DIR)/aar/
	rsync -amv '--include=*/' '--include=*.h' '--include=*.hpp' '--include=*.inc' '--exclude=*' $(SRC_DIR)/. $(PACKAGE_DIR)/include/.
	rm -rf $(PACKAGE_DIR)/include/rtc_tools
	cp -f $(BUILD_DIR)/LICENSE.md $(PACKAGE_DIR)/NOTICE
	echo '$(WEBRTC_VERSION)' > $(PACKAGE_DIR)/VERSION

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) && \
	patch -p1 < $(PATCH_DIR)/disable_use_hermetic_xcode_on_linux.patch && \
	patch -p1 < $(PATCH_DIR)/android_version.patch && \
	patch -p1 < $(PATCH_DIR)/android_use_libunwind.patch && \
	patch -p1 < $(PATCH_DIR)/linux_fix_enable_safe_libstdcxx.patch && \
	patch -p2 < $(PATCH_DIR)/enable_android_scalability_mode.patch && \
	patch -p1 < $(PATCH_DIR)/android_include_environment.patch && \
	$(SCRIPTS_DIR)/generate_android_version.sh $(SRC_DIR) $(WEBRTC_COMMIT) $(WEBRTC_VERSION)


define build-android
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR)/static/$1 --args='$(EXTRA_GN_ARGS) use_custom_libcxx=false android_static_analysis="off" $(CC_WRAPPER) target_os="android" target_cpu="$2" $3' && \
	autoninja -C $(BUILD_DIR)/static/$1 && \
	autoninja -C $(BUILD_DIR)/static/$1 native_api

	cd $(BUILD_DIR)/static/$1/obj && \
	rm -f sdk/android/libjingle_peerconnection_so/jni_onload.o && \
	$(SRC_DIR)/third_party/llvm-build/Release+Asserts/bin/llvm-ar -rc $(BUILD_DIR)/static/$1/libwebrtc.a `find . -name '*.o'`
endef

.PHONY: build
build: patch
ifeq ($(static),yes)
	$(call build-android,$(arch),$(target_cpu),$(version))
else
	cd $(SRC_DIR) && \
	mkdir -p $(SRC_DIR)/out/ && \
	mkdir -p $(BUILD_DIR) && \
	vpython3 $(SRC_DIR)/tools_webrtc/android/build_aar.py \
		--build-dir $(SRC_DIR)/out \
		--output $(BUILD_DIR)/libwebrtc.aar \
		--arch armeabi-v7a arm64-v8a x86_64 \
		--extra-gn-args '$(EXTRA_GN_ARGS) $(CC_WRAPPER)'

	cd $(BUILD_DIR) && \
	unzip -q libwebrtc.aar && \
	rm -rf jni && \
	rm -f AndroidManifest.xml && \
	mv classes.jar libwebrtc.jar
endif
