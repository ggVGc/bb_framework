
#include <math.h>
#include "matrix2.h"

static const double DEG_TO_RAD = 1.5707963267949;

void Matrix2_init(Matrix2 *m, double a, double b, double c, double d, double tx, double ty){
  m->a = a;
  m->b = b;
  m->c = c;
  m->d = d;
  m->tx = tx;
  m->ty = ty;
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



void Matrix2_prependTransform(Matrix2 *m, double x, double y, double scaleX, double scaleY, int rotation, double skewX, double skewY, double regX, double regY){
  double cosVal;
  double sinVal;
  int xxx = rotation%360;
  if (xxx != 0){
    double r = (double)rotation*DEG_TO_RAD;
    cosVal = cos(r);
    sinVal = sin(r);
  }else{
    cosVal = 1;
    sinVal = 0;
  }

  if (regX || regY){
    m->tx -= regX;
    m->ty -= regY;
  }

  /*if (skewX!=0 || skewY!=0){*/
    /*skewX = skewX * DEG_TO_RAD;*/
    /*skewY = skewY * DEG_TO_RAD;*/
    /*Matrix2_prepend(m, cosVal*scaleX, sinVal*scaleX, -sinVal*scaleY, cosVal*scaleY, 0, 0);*/
    /*Matrix2_prepend(m,cos(skewY), sin(skewY), -sin(skewX), cos(skewX), x, y);*/
  /*}else{*/
    Matrix2_prepend(m,cosVal*scaleX, sinVal*scaleX, -sinVal*scaleY, cosVal*scaleY, x, y);
  /*}*/
}


double Matrix2_a(Matrix2 *m){
  return m->a;
}
double Matrix2_b(Matrix2 *m){
  return m->b;
}
double Matrix2_c(Matrix2 *m){
  return m->c;
}
double Matrix2_d(Matrix2 *m){
  return m->d;
}
double Matrix2_tx(Matrix2 *m){
  return m->tx;
}
double Matrix2_ty(Matrix2 *m){
  return m->ty;
}

