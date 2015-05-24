when not defined(FACEBOOK_H_L1OIHWE8): 
  const 
    FACEBOOK_H_L1OIHWE8* = true
  proc facebookPost*(score: cint) {.importc: "facebookPost", 
                                    header: "facebook.h".}
  proc facebookIsShareAvailable*(): cint {.importc: "facebookIsShareAvailable", 
      header: "facebook.h".}

