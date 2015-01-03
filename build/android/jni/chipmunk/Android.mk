LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := chipmunk

LOCAL_PATH := $(LOCAL_PATH)/../../../../deps/common/chipmunk-6.2.1/src
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include/chipmunk 

LOCAL_CFLAGS += -std=c99

LOCAL_SRC_FILES := \
  chipmunk.c \
  cpArbiter.c \
  cpArray.c \
  cpBB.c \
  cpBBTree.c \
  cpBody.c \
  cpCollision.c \
  cpHashSet.c \
  cpPolyShape.c \
  cpShape.c \
  cpSpace.c \
  cpSpaceComponent.c \
  cpSpaceHash.c \
  cpSpaceQuery.c \
  cpSpaceStep.c \
  cpSpatialIndex.c \
  cpSweep1D.c \
  cpVect.c \
  constraints/cpConstraint.c \
  constraints/cpDampedRotarySpring.c \
  constraints/cpDampedSpring.c \
  constraints/cpGearJoint.c \
  constraints/cpGrooveJoint.c \
  constraints/cpPinJoint.c \
  constraints/cpPivotJoint.c \
  constraints/cpRatchetJoint.c \
  constraints/cpRotaryLimitJoint.c \
  constraints/cpSimpleMotor.c \
  constraints/cpSlideJoint.c

include $(BUILD_STATIC_LIBRARY)
