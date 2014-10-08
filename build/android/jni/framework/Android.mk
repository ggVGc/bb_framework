# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

include $(CLEAR_VARS)
LOCAL_MODULE    := libluajit 
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libluajit.a

include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_ARM_MODE  := arm

LOCAL_STATIC_LIBRARIES := minizip libluajit libpng bstring coremod libvorbis libogg

LOCAL_CFLAGS := -DANDROID_NDK \
                -DDISABLE_IMPORTGL

LOCAL_MODULE    := 	jumpz_framework

LOCAL_PATH := $(LOCAL_PATH)/../../../..

LOCAL_C_INCLUDES := $(LOCAL_PATH)/deps/common/luajit/src/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps/common/minizip/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps/common/libpng/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps/common/bstring/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps/common/coremod/include/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps/common/libogg/include/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps/common/libvorbis/include/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/common/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/android/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/gen/

MY_SOURCES := src/common/app.c \
  src/common/framework_wrap.c \
  src/common/framework/bitmapdata.c \
  src/common/framework/camera.c \
  src/common/framework/graphics.c \
  src/common/framework/input.c \
  src/common/framework/quad.c \
  src/common/framework/random.c \
  src/common/framework/rawbitmapdata.c \
  src/common/framework/rect.c \
  src/common/framework/resource_loading.c \
  src/common/framework/texture.c \
  src/common/framework/matrix2.c \
  src/common/framework/display_object.c \
  src/common/framework/audio.c \
  src/android/app_android.c \
  src/android/framework/util.c \
  src/android/framework/audio.c


#MY_SOURCES += $(wildcard src/android/framework/*.c)

#LOCAL_SRC_FILES := $(MY_SOURCES:$(LOCAL_PATH)%=%)
LOCAL_SRC_FILES := $(MY_SOURCES)


LOCAL_LDLIBS := -lGLESv1_CM -lOpenSLES -ldl -llog -lz

include $(BUILD_SHARED_LIBRARY)


