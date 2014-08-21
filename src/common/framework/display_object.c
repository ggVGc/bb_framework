#include "display_object.h"
#include "quad.h"


void DisplayObject_init(DisplayObject *d){
  d->parent = 0;
  DisplayObject_setTransform(d, 0, 0, 1, 1, 0, 0, 0, 0, 0);
}

void DisplayObject_setTransform(DisplayObject *d, double x, double y, double scaleX, double scaleY, double rot, double skewX, double skewY, double regX, double regY){
  d->x = x;
  d->y = y;
  d->scaleX = scaleX;
  d->scaleY = scaleY;
  d->rotation = rot;
  d->skewX = skewX;
  d->skewY = skewY;
  d->regX = regX;
  d->regY = regY;
}


void DisplayObject_draw(DisplayObject *d){
  Matrix2 m;
  DisplayObject_getConcatenatedMatrix(d, &m);
  Matrix2_append(&m, d->tex->width, 0, 0, d->tex->height, 0, 0);
  quadDrawTex(d->tex, &m);
}


void DisplayObject_getConcatenatedMatrix(DisplayObject *d, Matrix2 *outMat){
  DisplayObject *o = d;
  Matrix2_identity(outMat);
  while (o){
    Matrix2_prependTransform(outMat, o->x, o->y, o->scaleX, o->scaleY, o->rotation, o->skewX, o->skewY, o->regX, o->regY);
    o = o->parent;
  }
}
