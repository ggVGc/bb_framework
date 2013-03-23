#ifndef _H_QUAD_H_
#define _H_QUAD_H_

#include "texture.h"

void quadDrawTex(float x, float y, float width, float height, Texture* tex, float rot, float pivX, float pivY);
void quadDrawCol(float x, float y, float width, float height, float red, float green, float blue, float alpha, float rot, float pivX, float pivY);

#endif
