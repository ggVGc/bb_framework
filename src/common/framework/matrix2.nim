when not defined(MATRIX2_H_GPXSDJA1): 
  const 
    MATRIX2_H_GPXSDJA1* = true
  type 
    Matrix2* {.importc: "Matrix2", header: "matrix2.h".} = object 
      a* {.importc: "a".}: cdouble
      b* {.importc: "b".}: cdouble
      c* {.importc: "c".}: cdouble
      d* {.importc: "d".}: cdouble
      tx* {.importc: "tx".}: cdouble
      ty* {.importc: "ty".}: cdouble

  proc Matrix2_init*(m: ptr Matrix2; a: cdouble; b: cdouble; c: cdouble; 
                     d: cdouble; tx: cdouble; ty: cdouble) {.
      importc: "Matrix2_init", header: "matrix2.h".}
  proc Matrix2_copy*(target: ptr Matrix2; source: ptr Matrix2) {.
      importc: "Matrix2_copy", header: "matrix2.h".}
  proc Matrix2_prepend*(m: ptr Matrix2; a: cdouble; b: cdouble; c: cdouble; 
                        d: cdouble; tx: cdouble; ty: cdouble) {.
      importc: "Matrix2_prepend", header: "matrix2.h".}
  proc Matrix2_append*(m: ptr Matrix2; a: cdouble; b: cdouble; c: cdouble; 
                       d: cdouble; tx: cdouble; ty: cdouble) {.
      importc: "Matrix2_append", header: "matrix2.h".}
  proc Matrix2_invert*(m: ptr Matrix2) {.importc: "Matrix2_invert", 
      header: "matrix2.h".}
  proc Matrix2_prependTransform*(m: ptr Matrix2; x: cdouble; y: cdouble; 
                                 scaleX: cdouble; scaleY: cdouble; 
                                 rotation: cdouble; skewX: cdouble; 
                                 skewY: cdouble; regX: cdouble; regY: cdouble) {.
      importc: "Matrix2_prependTransform", header: "matrix2.h".}
  proc Matrix2_identity*(m: ptr Matrix2) {.importc: "Matrix2_identity", 
      header: "matrix2.h".}

