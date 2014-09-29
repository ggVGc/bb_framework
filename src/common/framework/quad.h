#ifndef _H_QUAD_H_
#define _H_QUAD_H_

#include "texture.h"
#include "matrix2.h"



void quadGlobalInit();
void quadBeginFrame();

void setTint(float r, float g, float b);
void quadDrawTex(Texture* tex, Matrix2 *m);
void quadDrawTexAlpha(Texture* tex, Matrix2 *m, float alpha);
void quadDrawCol(float x, float y, float width, float height, float red, float green, float blue, float alpha, float rot, float pivX, float pivY);
void quadFlush();
void quadEndFrame();

int getDrawCallCount();

#endif
