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

LOCAL_ARM_MODE  := arm

LOCAL_STATIC_LIBRARIES := minizip lua libpng bstring

LOCAL_CFLAGS := -DANDROID_NDK \
                -DDISABLE_IMPORTGL

LOCAL_MODULE    := 	jumpz_framework

LOCAL_PATH := $(LOCAL_PATH)/../../../framework/


LOCAL_C_INCLUDES := $(LOCAL_PATH)/deps_src/minizip/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps_src/lua/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps_src/libpng/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/deps_src/bstring/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/common/
LOCAL_C_INCLUDES += $(LOCAL_PATH)/src/android/


MY_SOURCES := $(wildcard $(LOCAL_PATH)/src/common/*.c)
MY_SOURCES += $(wildcard $(LOCAL_PATH)/src/common/framework/*.c)
MY_SOURCES += $(wildcard $(LOCAL_PATH)/src/android/*.c)
MY_SOURCES += $(wildcard $(LOCAL_PATH)/src/android/framework/*.c)

LOCAL_SRC_FILES := $(MY_SOURCES:$(LOCAL_PATH)%=%)


LOCAL_LDLIBS := -lGLESv1_CM -ldl -llog -lz

include $(BUILD_SHARED_LIBRARY)


