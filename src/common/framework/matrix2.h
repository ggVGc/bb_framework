
typedef struct Matrix2{
  double a;
  double b;
  double c;
  double d;
  double tx;
  double ty;
} Matrix2;


void Matrix2_init(Matrix2 *m, double a, double b, double c, double d, double tx, double ty);
void Matrix2_prepend(Matrix2 *m, double a, double b, double c, double d, double tx, double ty);
void Matrix2_prependTransform(Matrix2 *m, double x, double y, double scaleX, double scaleY, int rotation, double skewX, double skewY, double regX, double regY);


double Matrix2_a(Matrix2 *m);
double Matrix2_b(Matrix2 *m);
double Matrix2_c(Matrix2 *m);
double Matrix2_d(Matrix2 *m);
double Matrix2_tx(Matrix2 *m);
double Matrix2_ty(Matrix2 *m);

