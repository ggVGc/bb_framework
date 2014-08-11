
#define _USE_MATH_DEFINES
#include <math.h>
#include "matrix2.h"

static const double DEG_TO_RAD = M_PI/180.0f;

void Matrix2_init(Matrix2 *m, double a, double b, double c, double d, double tx, double ty){
  m->a = a;
  m->b = b;
  m->c = c;
  m->d = d;
  m->tx = tx;
  m->ty = ty;
}

void Matrix2_copy(Matrix2 *target, Matrix2 *source){
  target->a = source->a;
  target->b = source->b;
  target->c = source->c;
  target->d = source->d;
  target->tx = source->tx;
  target->ty = source->ty;
}

void Matrix2_identity(Matrix2 *m){
  m->a = 1;
  m->b = 0;
  m->c = 0;
  m->d = 1;
  m->tx = 0;
  m->ty = 0;
}

void Matrix2_prepend(Matrix2 *m, double a, double b, double c, double d, double tx, double ty){
  double tx1 = m->tx;
  if (a != 1 || b != 0 || c != 0 || d != 1){
    double a1 = m->a;
    double c1 = m->c;
    m->a  = a1*a+m->b*c;
    m->b  = a1*b+m->b*d;
    m->c  = c1*a+m->d*c;
    m->d  = c1*b+m->d*d;
  }
  m->tx = tx1*a+m->ty*c+tx;
  m->ty = tx1*b+m->ty*d+ty;
}


void Matrix2_append(Matrix2 *m, double a, double b, double c, double d, double tx, double ty){
  double a1 = m->a;
  double b1 = m->b;
  double c1 = m->c;
  double d1 = m->d;
  m->a  = a*a1+b*c1;
  m->b  = a*b1+b*d1;
  m->c  = c*a1+d*c1;
  m->d  = c*b1+d*d1;
  m->tx = tx*a1+ty*c1+m->tx;
  m->ty = tx*b1+ty*d1+m->ty;
}



void Matrix2_prependTransform(Matrix2 *m, double x, double y, double scaleX, double scaleY, double rotation, double skewX, double skewY, double regX, double regY){
  double c = 1;
  double s = 0;

  if((int)rotation%360 != 0){
    double r = rotation*DEG_TO_RAD;
    c = cos(r);
    s = sin(r);
  }

  if (regX!=0 || regY!=0){
    m->tx -= regX;
    m->ty -= regY;
  }

  if (skewX!=0 || skewY!=0){
    skewX *= DEG_TO_RAD;
    skewY *= DEG_TO_RAD;
    Matrix2_prepend(m, c*scaleX, s*scaleX, -s*scaleY, c*scaleY, 0, 0);
    Matrix2_prepend(m,cos(skewY), sin(skewY), -sin(skewX), cos(skewX), x, y);
  }else{
    Matrix2_prepend(m,c*scaleX, s*scaleX, -s*scaleY, c*scaleY, x, y);
  }
}
