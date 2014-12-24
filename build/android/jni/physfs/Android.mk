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

LOCAL_MODULE    := physfs



LOCAL_PATH := $(LOCAL_PATH)/../../../../deps/common/physfs/src

LOCAL_SRC_FILES :=\
  archiver_dir.c \
  archiver_grp.c \
  archiver_hog.c \
  archiver_iso9660.c \
  archiver_lzma.c \
  archiver_mvl.c \
  archiver_qpak.c \
  archiver_slb.c \
  archiver_unpacked.c \
  archiver_wad.c \
  archiver_zip.c \
  physfs.c \
  physfs_byteorder.c \
  physfs_unicode.c \
  platform_beos.cpp \
  platform_macosx.c \
  platform_posix.c \
  platform_unix.c \
  platform_windows.c


include $(BUILD_STATIC_LIBRARY)
