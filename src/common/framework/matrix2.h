#ifndef MATRIX2_H_GPXSDJA1
#define MATRIX2_H_GPXSDJA1






struct Matrix2{
  double a;
  double b;
  double c;
  double d;
  double tx;
  double ty;
};
typedef struct Matrix2 Matrix2;


void Matrix2_init(Matrix2 *m, double a, double b, double c, double d, double tx, double ty);
void Matrix2_copy(Matrix2 *target, Matrix2 *source);

void Matrix2_prepend(Matrix2 *m, double a, double b, double c, double d, double tx, double ty);
void Matrix2_append(Matrix2 *m, double a, double b, double c, double d, double tx, double ty);
void Matrix2_invert(Matrix2 *m);

void Matrix2_prependTransform(Matrix2 *m, double x, double y, double scaleX, double scaleY, double rotation, double skewX, double skewY, double regX, double regY);

void Matrix2_identity(Matrix2 *m);


#endif /* end of include guard: MATRIX2_H_GPXSDJA1
#define MATRIX2_H_GPXSDJA1 */
