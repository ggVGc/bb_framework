#ifndef _H_RECT_H_
#define _H_RECT_H_

typedef struct {
  float x;
  float y;
  float w;
  float h;
} Rekt;

void rectInit(Rekt* r, float x, float y, float w, float h);

#endif
