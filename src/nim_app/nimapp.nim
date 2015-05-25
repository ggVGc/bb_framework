import app_main
proc nimInit(appWasSuspended:cint): void {.exportc.} =
  return


proc nimDoFrame(tick:cint): cint {.exportc.} =
  app_main.update(tick)
  app_main.draw()
  return 0

