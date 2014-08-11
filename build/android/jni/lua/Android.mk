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
#LOCAL_PATH := $(call my-dir)

#include $(CLEAR_VARS)

#LOCAL_MODULE    := lua

#LOCAL_PATH := $(LOCAL_PATH)/../../../../deps/common/lua
#MY_SOURCES := lapi.c lauxlib.c lbaselib.c lbitlib.c lcode.c lcorolib.c lctype.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c lpcap.c lpcode.c lpprint.c lptree.c lpvm.c lstate.c lstring.c ltable.c ltablib.c ltm.c lua.c lundump.c lvm.c lzio.c lstrlib.c

#LOCAL_PATH := $(LOCAL_PATH)/../../../../deps/common/luajit/src/
#MY_SOURCES := lj_vmmath.c lj_vmevent.c lj_udata.c lj_trace.c lj_tab.c lj_strscan.c lj_str.c lj_state.c lj_snap.c lj_record.c lj_parse.c lj_opt_split.c lj_opt_sink.c lj_opt_narrow.c lj_opt_mem.c lj_opt_loop.c lj_opt_fold.c lj_opt_dce.c lj_obj.c lj_meta.c lj_mcode.c lj_load.c lj_lib.c lj_lex.c lj_ir.c lj_gdbjit.c lj_gc.c lj_func.c lj_ffrecord.c lj_err.c lj_dispatch.c lj_debug.c lj_ctype.c lj_crecord.c lj_cparse.c lj_clib.c lj_char.c lj_cdata.c lj_cconv.c lj_ccall.c lj_ccallback.c lj_carith.c lj_bcwrite.c lj_bcread.c lj_bc.c lj_asm.c lj_api.c ljamalg.c lj_alloc.c lib_table.c lib_string.c lib_package.c lib_os.c lib_math.c lib_jit.c lib_io.c lib_init.c lib_ffi.c lib_debug.c lib_bit.c lib_base.c lib_aux.c 

#LOCAL_SRC_FILES := $(MY_SOURCES:$(LOCAL_PATH)%=%)

#include $(BUILD_STATIC_LIBRARY)
