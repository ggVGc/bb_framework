#ifndef H_RECT_H
#define H_RECT_H

typedef struct {
  float x;
  float y;
  float w;
  float h;
} Rekt;

void rectInit(Rekt* r, float x, float y, float w, float h);

#endif
