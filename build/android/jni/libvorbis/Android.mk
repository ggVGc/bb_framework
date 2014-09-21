LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libvorbis

#LOCAL_CFLAGS += -fsigned-char
#LOCAL_CFLAGS += -march=armv6 -marm -mfloat-abi=softfp -mfpu=vfp
LOCAL_PATH := $(LOCAL_PATH)/../../../../deps/common/libvorbis/lib
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../libogg/include


LOCAL_SRC_FILES := \
	mdct.c		\
	smallft.c	\
	block.c		\
	envelope.c	\
	window.c	\
	lsp.c		\
	lpc.c		\
	analysis.c	\
	synthesis.c	\
	psy.c		\
	info.c		\
	floor1.c	\
	floor0.c	\
	res0.c		\
	mapping0.c	\
	registry.c	\
	codebook.c	\
	sharedbook.c	\
	lookup.c	\
	bitrate.c	\
	vorbisfile.c	\
	vorbisenc.c

include $(BUILD_STATIC_LIBRARY)
