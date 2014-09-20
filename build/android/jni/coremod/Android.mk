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

LOCAL_MODULE := coremod

LOCAL_PATH := $(LOCAL_PATH)/../../../../deps/common/coremod
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

include $(LOCAL_PATH)/src/Makefile
include $(LOCAL_PATH)/src/loaders/Makefile

SRC_SOURCES	:= $(addprefix src/,$(SRC_OBJS))
LOADERS_SOURCES := $(addprefix src/loaders/,$(LOADERS_OBJS))

LOCAL_MODULE    := coremod
LOCAL_CFLAGS	:= -O3 -I$(LOCAL_PATH)/include/coremod -I$(LOCAL_PATH)/src \
		   -DLIBXMP_CORE_PLAYER

LOCAL_SRC_FILES := $(SRC_SOURCES:.o=.c.arm) \
		   $(LOADERS_SOURCES:.o=.c)

include $(BUILD_STATIC_LIBRARY)
