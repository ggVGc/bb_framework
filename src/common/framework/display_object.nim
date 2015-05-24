import 
  matrix2, texture

type 
  DisplayObject* {.importc: "DisplayObject", header: "display_object.h".} = object 
  
  DisplayObject* {.importc: "DisplayObject", header: "display_object.h".} = object 
    x* {.importc: "x".}: cdouble
    y* {.importc: "y".}: cdouble
    skewX* {.importc: "skewX".}: cdouble
    skewY* {.importc: "skewY".}: cdouble
    regX* {.importc: "regX".}: cdouble
    regY* {.importc: "regY".}: cdouble
    rotation* {.importc: "rotation".}: cdouble
    scaleX* {.importc: "scaleX".}: cdouble
    scaleY* {.importc: "scaleY".}: cdouble
    alpha* {.importc: "alpha".}: cdouble
    parent* {.importc: "parent".}: ptr DisplayObject
    tex* {.importc: "tex".}: ptr Texture


proc DisplayObject_init*(d: ptr DisplayObject) {.importc: "DisplayObject_init", 
    header: "display_object.h".}
proc DisplayObject_setTransform*(d: ptr DisplayObject; x: cdouble; y: cdouble; 
                                 scaleX: cdouble; scaleY: cdouble; rot: cdouble; 
                                 skewX: cdouble; skewY: cdouble; regX: cdouble; 
                                 regY: cdouble) {.
    importc: "DisplayObject_setTransform", header: "display_object.h".}
proc DisplayObject_draw*(d: ptr DisplayObject) {.importc: "DisplayObject_draw", 
    header: "display_object.h".}
proc DisplayObject_getConcatenatedMatrix*(d: ptr DisplayObject; 
    outMat: ptr Matrix2) {.importc: "DisplayObject_getConcatenatedMatrix", 
                           header: "display_object.h".}
proc DisplayObject_getConcatAlpha*(d: ptr DisplayObject): cdouble {.
    importc: "DisplayObject_getConcatAlpha", header: "display_object.h".}

