LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libogg

#LOCAL_CFLAGS += -fsigned-char
#LOCAL_CFLAGS += -march=armv6 -marm -mfloat-abi=softfp -mfpu=vfp
LOCAL_PATH := $(LOCAL_PATH)/../../../../deps/common/libogg/src
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include


LOCAL_SRC_FILES := \
	bitwise.c \
	framing.c

include $(BUILD_STATIC_LIBRARY)
