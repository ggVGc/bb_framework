when not defined(H_GRAPHICS): 
  const 
    H_GRAPHICS* = true
  proc graphicsInit*(framebufferWidth: cint; framebufferHeight: cint) {.
      importc: "graphicsInit", header: "graphics.h".}
  proc beginRenderFrame*() {.importc: "beginRenderFrame", header: "graphics.h".}
  proc setScissor*(x: cint; y: cint; w: cint; h: cint) {.importc: "setScissor", 
      header: "graphics.h".}

