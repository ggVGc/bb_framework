/* San Angeles Observation OpenGL ES version example
 * Copyright 2004-2005 Jetro Lauha
 * All rights reserved.
 * Web: http://iki.fi/jetro/
 *
 * This source is free software; you can redistribute it and/or
 * modify it under the terms of EITHER:
 *   (1) The GNU Lesser General Public License as published by the Free
 *       Software Foundation; either version 2.1 of the License, or (at
 *       your option) any later version. The text of the GNU Lesser
 *       General Public License is included with this source in the
 *       file LICENSE-LGPL.txt.
 *   (2) The BSD-style license that is included with this source in
 *       the file LICENSE-BSD.txt.
 *
 * This source is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the files
 * LICENSE-LGPL.txt and LICENSE-BSD.txt for more details.
 *
 * $Id: app.h,v 1.14 2005/02/06 21:13:54 tonic Exp $
 * $Revision: 1.14 $
 */

#ifndef APP_H_INCLUDED
#define APP_H_INCLUDED


#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>

#define WINDOW_BPP              16


// The simple framework expects the application code to define these functions.
extern void appInit(int framebufferWidth, int framebufferHeight, const char* assetPath, int useAssetZip);
extern void appDeinit(void);
extern int appRender(long tick);

extern int screenWidth(void);
extern int screenHeight(void);
extern void setScreenWidth(int);
extern void setScreenHeight(int);

extern int isAppBroken(void);
extern void setAppBroken(int isBroken);

lua_State* luaVM;
int callLuaFunc(int nParams, int nRet);

#ifdef __cplusplus
}
#endif


#endif // !APP_H_INCLUDED
