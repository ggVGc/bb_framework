when not defined(H_RECT_H): 
  const 
    H_RECT_H* = true
  type 
    Rekt* {.importc: "Rekt", header: "rect.h".} = object 
      x* {.importc: "x".}: cfloat
      y* {.importc: "y".}: cfloat
      w* {.importc: "w".}: cfloat
      h* {.importc: "h".}: cfloat

  proc rectInit*(r: ptr Rekt; x: cfloat; y: cfloat; w: cfloat; h: cfloat) {.
      importc: "rectInit", header: "rect.h".}

