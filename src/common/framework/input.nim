when not defined(H_INPUT_H): 
  const 
    H_INPUT_H* = true
    MAX_KEYS* = 512
  proc setCursorPos*(index: cint; x: cint; y: cint) {.importc: "setCursorPos", 
      header: "input.h".}
  proc setCursorDownState*(index: cint; isDown: cint) {.
      importc: "setCursorDownState", header: "input.h".}
  proc setKeyPressed*(keyCode: cint) {.importc: "setKeyPressed", 
                                       header: "input.h".}
  proc setKeyReleased*(keyCode: cint) {.importc: "setKeyReleased", 
                                        header: "input.h".}

