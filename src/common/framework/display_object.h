
#include "matrix2.h"
#include "texture.h"

struct DisplayObject;

struct DisplayObject{
  double x, y, skewX, skewY, regX, regY, rotation, scaleX, scaleY;
  struct DisplayObject *parent;
};

typedef struct DisplayObject DisplayObject;


void DisplayObject_init(DisplayObject *d);
void DisplayObject_setTransform(DisplayObject *d, double x, double y, double scaleX, double scaleY, double rot, double skewX, double skewY, double regX, double regY);

void DisplayObject_draw(DisplayObject *d, Texture *t);

void DisplayObject_getConcatenatedMatrix(DisplayObject *d, Matrix2 *outMat);

