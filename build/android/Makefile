include ../../VERSION

BASE_DIR := $(realpath ../..)

include ../env.mk

TARGET_OS ?= android
TARGET_CPU =

include ../common.mk

EXTRA_GN_ARGS_RELEASE := \
	is_debug=false \
	is_java_debug=false \
	$(RTC_USE_H264) \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_include_tests=false \
	is_clang=true \
	is_component_build=false \
	rtc_enable_protobuf=false \
	rtc_build_json=true \
	use_rtti=true

EXTRA_GN_ARGS_DEBUG := \
	is_debug=true \
	is_java_debug=false \
	$(RTC_USE_H264) \
	rtc_build_tools=false \
	rtc_build_examples=false \
	rtc_include_tests=false \
	is_clang=true \
	is_component_build=false \
	rtc_enable_protobuf=false \
	rtc_build_json=true \
	use_rtti=true

.PHONY: all
all: clean build package

.PHONY: package
package: copy
	cd $(PACKAGE_DIR) && \
	tar -Jcf $(subst $(space),,$(PACKAGE_NAME)).tar.xz aar jar include lib NOTICE VERSION

.PHONY: copy
copy:
	rm -rf $(PACKAGE_DIR)/aar
	rm -rf $(PACKAGE_DIR)/jar
	rm -rf $(PACKAGE_DIR)/include
	rm -rf $(PACKAGE_DIR)/lib
	rm -f $(PACKAGE_DIR)/NOTICE
	rm -f $(PACKAGE_DIR)/VERSION
	mkdir -p $(PACKAGE_DIR)/aar
	mkdir -p $(PACKAGE_DIR)/aar/debug
	mkdir -p $(PACKAGE_DIR)/aar/release
	mkdir -p $(PACKAGE_DIR)/jar
	mkdir -p $(PACKAGE_DIR)/jar/debug
	mkdir -p $(PACKAGE_DIR)/jar/release
	mkdir -p $(PACKAGE_DIR)/lib
	mkdir -p $(PACKAGE_DIR)/lib/debug
	mkdir -p $(PACKAGE_DIR)/lib/debug/armeabi-v7a
	mkdir -p $(PACKAGE_DIR)/lib/debug/arm64-v8a
	mkdir -p $(PACKAGE_DIR)/lib/debug/x86_64
	mkdir -p $(PACKAGE_DIR)/lib/release
	mkdir -p $(PACKAGE_DIR)/lib/release/armeabi-v7a
	mkdir -p $(PACKAGE_DIR)/lib/release/arm64-v8a
	mkdir -p $(PACKAGE_DIR)/lib/release/x86_64

	mkdir -p $(PACKAGE_DIR)/include
	cp -f $(BUILD_DIR_DEBUG)/static/armeabi-v7a/libwebrtc.a $(PACKAGE_DIR)/lib/debug/armeabi-v7a/
	cp -f $(BUILD_DIR_DEBUG)/static/arm64-v8a/libwebrtc.a $(PACKAGE_DIR)/lib/debug/arm64-v8a/
	cp -f $(BUILD_DIR_DEBUG)/static/x86_64/libwebrtc.a $(PACKAGE_DIR)/lib/debug/x86_64/
	cp -f $(BUILD_DIR_DEBUG)/libwebrtc.jar $(PACKAGE_DIR)/jar/debug
	cp -f $(BUILD_DIR_DEBUG)/libwebrtc.aar $(PACKAGE_DIR)/aar/debug
	cp -f $(BUILD_DIR_RELEASE)/static/armeabi-v7a/libwebrtc.a $(PACKAGE_DIR)/lib/release/armeabi-v7a/
	cp -f $(BUILD_DIR_RELEASE)/static/arm64-v8a/libwebrtc.a $(PACKAGE_DIR)/lib/release/arm64-v8a/
	cp -f $(BUILD_DIR_RELEASE)/static/x86_64/libwebrtc.a $(PACKAGE_DIR)/lib/release/x86_64/
	cp -f $(BUILD_DIR_RELEASE)/libwebrtc.jar $(PACKAGE_DIR)/jar/release
	cp -f $(BUILD_DIR_RELEASE)/libwebrtc.aar $(PACKAGE_DIR)/aar/release
	rsync -amv '--include=*/' '--include=*.h' '--include=*.hpp' '--exclude=*' $(SRC_DIR)/. $(PACKAGE_DIR)/include/.
	rm -rf $(PACKAGE_DIR)/include/rtc_tools
	cp -f $(BUILD_DIR_RELEASE)/LICENSE.md $(PACKAGE_DIR)/NOTICE
	echo '$(WEBRTC_VERSION)' > $(PACKAGE_DIR)/VERSION

.PHONY: patch
patch: common-patch
	cd $(SRC_DIR) \
	&& patch -p2 < $(PATCH_DIR)/android_version.patch \
	&& $(SCRIPTS_DIR)/generate_android_version.sh $(SRC_DIR) $(WEBRTC_COMMIT) $(WEBRTC_SEMANTIC_VERSION)


define build-android
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR_RELEASE)/static/$1 --args='$(EXTRA_GN_ARGS_RELEASE) $(CC_WRAPPER) target_os="android" target_cpu="$2" $3' && \
	ninja -C $(BUILD_DIR_RELEASE)/static/$1 && \
	ninja -C $(BUILD_DIR_RELEASE)/static/$1 native_api

	cd $(BUILD_DIR_RELEASE)/static/$1/obj && \
	rm -f sdk/android/libjingle_peerconnection_so/jni_onload.o && \
	$(SRC_DIR)/third_party/llvm-build/Release+Asserts/bin/llvm-ar -rc $(BUILD_DIR_RELEASE)/static/$1/libwebrtc.a `find . -name '*.o'`
endef

define build-debug-android
	cd $(SRC_DIR) && \
	gn gen $(BUILD_DIR_DEBUG)/static/$1 --args='$(EXTRA_GN_ARGS_DEBUG) $(CC_WRAPPER) target_os="android" target_cpu="$2" $3' && \
	ninja -C $(BUILD_DIR_DEBUG)/static/$1 && \
	ninja -C $(BUILD_DIR_DEBUG)/static/$1 native_api

	cd $(BUILD_DIR_DEBUG)/static/$1/obj && \
	rm -f sdk/android/libjingle_peerconnection_so/jni_onload.o && \
	$(SRC_DIR)/third_party/llvm-build/Release+Asserts/bin/llvm-ar -rc $(BUILD_DIR_DEBUG)/static/$1/libwebrtc.a `find . -name '*.o'`
endef

.PHONY: build
build: patch
	cd $(SRC_DIR) && \
	python3 $(SRC_DIR)/tools_webrtc/android/build_aar.py \
	  --build-dir $(BUILD_DIR_DEBUG)/aar \
	  --output $(BUILD_DIR_DEBUG)/libwebrtc.aar \
	  --arch armeabi-v7a arm64-v8a x86_64 \
	  --extra-gn-args '$(EXTRA_GN_ARGS_DEBUG) $(CC_WRAPPER)'

	cd $(SRC_DIR) && \
	python3 $(SRC_DIR)/tools_webrtc/android/build_aar.py \
	  --build-dir $(BUILD_DIR_RELEASE)/aar \
	  --output $(BUILD_DIR_RELEASE)/libwebrtc.aar \
	  --arch armeabi-v7a arm64-v8a x86_64 \
	  --extra-gn-args '$(EXTRA_GN_ARGS_RELEASE) $(CC_WRAPPER)'

	$(call build-debug-android,armeabi-v7a,arm,arm_version=7)
	$(call build-android,armeabi-v7a,arm,arm_version=7)

	$(call build-debug-android,arm64-v8a,arm64)
	$(call build-android,arm64-v8a,arm64)

	$(call build-debug-android,x86_64,x64)
	$(call build-android,x86_64,x64)


	cd $(BUILD_DIR_DEBUG) && \
	unzip -q libwebrtc.aar && \
	rm -rf jni && \
	rm -f AndroidManifest.xml && \
	mv classes.jar libwebrtc.jar

	cd $(BUILD_DIR_RELEASE) && \
	unzip -q libwebrtc.aar && \
	rm -rf jni && \
	rm -f AndroidManifest.xml && \
	mv classes.jar libwebrtc.jar

