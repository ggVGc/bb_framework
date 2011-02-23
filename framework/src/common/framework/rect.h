#ifndef _H_RECT_H_
#define _H_RECT_H_

typedef struct {
  float x;
  float y;
  float w;
  float h;
} Rect;

void rectInit(Rect* r, float x, float y, float w, float h);

#endif
