when not defined(CAMERA_H_D4FVIPNE): 
  const 
    CAMERA_H_D4FVIPNE* = true
  type 
    Camera* {.importc: "Camera", header: "camera.h".} = object 
      posX* {.importc: "posX".}: cfloat
      posY* {.importc: "posY".}: cfloat
      width* {.importc: "width".}: cint
      height* {.importc: "height".}: cint

  proc cameraInit*(cam: ptr Camera; x: cfloat; y: cfloat; width: cint; 
                   height: cint) {.importc: "cameraInit", header: "camera.h".}
  proc cameraSetActive*(cam: ptr Camera) {.importc: "cameraSetActive", 
      header: "camera.h".}

