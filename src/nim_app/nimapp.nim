proc nimInit(appWasSuspended:cint): void {.exportc.} =
  return

let cam = new Camera
cameraInit(cast[ptr Camera](cam), 0,0,400,400)

proc nimDoFrame(tick:cint): cint {.exportc.} =
  cameraSetActive(cast[ptr Camera](cam))
  return 0

