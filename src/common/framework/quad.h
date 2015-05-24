#ifndef H_QUAD_H
#define H_QUAD_H

#ifndef C2NIM
#include "texture.h"
#include "matrix2.h"
#endif

void quadGlobalInit();
void quadBeginFrame();

void setTint(float r, float g, float b);
#ifndef C2NIM
void quadDrawTex(Texture* tex, Matrix2 *m);
void quadDrawTexAlpha(Texture* tex, Matrix2 *m, float alpha);
#endif
void quadDrawCol(float x, float y, float width, float height, float red, float green, float blue, float alpha, float rot, float pivX, float pivY);
void quadFlush();
void quadEndFrame();

int getDrawCallCount();

#endif
