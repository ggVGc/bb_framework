#ifndef _H_QUAD_H_
#define _H_QUAD_H_

#include "texture.h"

void quadDrawTex(float ma, float mb, float mc, float md, float tx, float ty, Texture* tex);
void quadDrawCol(float x, float y, float width, float height, float red, float green, float blue, float alpha, float rot, float pivX, float pivY);

#endif
