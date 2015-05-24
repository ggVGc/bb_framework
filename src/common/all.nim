when not defined(ADS_H_OSH6QJIZ): 
  const 
    ADS_H_OSH6QJIZ* = true
  proc adPrepareInterstitial*() {.importc: "adPrepareInterstitial", 
                                  header: "ads.h".}
  proc adShowInterstitial*() {.importc: "adShowInterstitial", header: "ads.h".}
  proc adInterstitialDisplayed*(success: cint) {.
      importc: "adInterstitialDisplayed", header: "ads.h".}
  proc adInterstitialClosed*() {.importc: "adInterstitialClosed", 
                                 header: "ads.h".}
  proc adSetBannersEnabled*(enable: cint) {.importc: "adSetBannersEnabled", 
      header: "ads.h".}

when not defined(H_AUDIO): 
  const 
    H_AUDIO* = true
  import 
    decoder_ogg

  const 
    SHORT_SAMPLE_LIMIT* = (1024 * 512)
  type 
    PlatformAudio* = PlatformAudio_T
    Audio* {.importc: "Audio", header: "audio.h".} = object 
      pa* {.importc: "pa".}: ptr PlatformAudio
      decoder* {.importc: "decoder".}: DecoderOgg_State
      muted* {.importc: "muted".}: cint

  proc audioGlobalInit*(): cint {.importc: "audioGlobalInit", header: "audio.h".}
  proc audioGlobalPlatformInit*(): cint {.importc: "audioGlobalPlatformInit", 
      header: "audio.h".}
  proc audioAlloc*(): ptr Audio {.importc: "audioAlloc", header: "audio.h".}
  proc audioInit*(a: ptr Audio; buf: cstring; sz: cint; loop: cint; 
                  introSilenceMs: clong): cint {.importc: "audioInit", 
      header: "audio.h".}
  proc audioLoad*(path: cstring; loop: cint; introSilenceMs: clong): ptr Audio {.
      importc: "audioLoad", header: "audio.h".}
  proc audioModLoad*(path: cstring): ptr Audio {.importc: "audioModLoad", 
      header: "audio.h".}
  proc audioLoadInto*(a: ptr Audio; path: cstring; loop: cint; 
                      introSilenceMs: clong): cint {.importc: "audioLoadInto", 
      header: "audio.h".}
  proc audioPlay*(a2: ptr Audio) {.importc: "audioPlay", header: "audio.h".}
  #void audioSetLooping(Audio*, int);
  proc audioStop*(a2: ptr Audio) {.importc: "audioStop", header: "audio.h".}
  proc audioSetPaused*(a: ptr Audio; paused: cint) {.importc: "audioSetPaused", 
      header: "audio.h".}
  proc audioFree*(a2: ptr Audio) {.importc: "audioFree", header: "audio.h".}
  proc audioOnFrame*() {.importc: "audioOnFrame", header: "audio.h".}
  proc audioCleanup*() {.importc: "audioCleanup", header: "audio.h".}
  proc audioPlatformCleanup*() {.importc: "audioPlatformCleanup", 
                                 header: "audio.h".}
  proc audioSetAllPaused*(paused: cint) {.importc: "audioSetAllPaused", 
      header: "audio.h".}
  proc audioSetAllMuted*(muted: cint) {.importc: "audioSetAllMuted", 
                                        header: "audio.h".}
  proc audioIsPlaying*(a: ptr Audio): cint {.importc: "audioIsPlaying", 
      header: "audio.h".}
  proc audioInstanceOnFrame*(a: ptr Audio) {.importc: "audioInstanceOnFrame", 
      header: "audio.h".}
  proc audioPlatformAlloc*(): ptr PlatformAudio {.importc: "audioPlatformAlloc", 
      header: "audio.h".}
  proc audioPlatformInit*(a: ptr Audio; loop: cint): cint {.
      importc: "audioPlatformInit", header: "audio.h".}
  proc audioPlatformFree*(a2: ptr PlatformAudio) {.importc: "audioPlatformFree", 
      header: "audio.h".}
  proc audioPlatformPlay*(a2: ptr Audio) {.importc: "audioPlatformPlay", 
      header: "audio.h".}
  proc audioPlatformSetPaused*(a: ptr PlatformAudio; paused: cint) {.
      importc: "audioPlatformSetPaused", header: "audio.h".}
  # Because I am lazy..
  # TODO: Dynamically resize, to support infinite sounds.
  const 
    MAX_SOUNDS* = 512
  var soundInstances* {.importc: "soundInstances", header: "audio.h".}: array[
      MAX_SOUNDS, ptr Audio]
  proc audioIsShort*(a: ptr Audio): cint {.importc: "audioIsShort", 
      header: "audio.h".}

when not defined(H_BITMAPDATA): 
  const 
    H_BITMAPDATA* = true
  import 
    rawbitmapdata

  type 
    BitmapData* {.importc: "BitmapData", header: "bitmapdata.h".} = object 
      width* {.importc: "width".}: cint
      height* {.importc: "height".}: cint
      glTexHandle* {.importc: "glTexHandle".}: GLuint

  proc bitmapDataInit*(data: ptr BitmapData; rawData: ptr RawBitmapData) {.
      importc: "bitmapDataInit", header: "bitmapdata.h".}
  proc bitmapDataCleanup*(data: ptr BitmapData) {.importc: "bitmapDataCleanup", 
      header: "bitmapdata.h".}

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

when not defined(DATA_STORE_H_VI96GFE5): 
  const 
    DATA_STORE_H_VI96GFE5* = true
  proc dataStoreGlobalInit*() {.importc: "dataStoreGlobalInit", 
                                header: "data_store.h".}
  proc dataStoreCommit*(dataString: cstring) {.importc: "dataStoreCommit", 
      header: "data_store.h".}
  proc dataStoreReload*(): cstring {.importc: "dataStoreReload", 
                                     header: "data_store.h".}

when not defined(DECODER_OGG_H_7YA29KAK): 
  const 
    DECODER_OGG_H_7YA29KAK* = true
  type 
    ogg_file* {.importc: "ogg_file", header: "decoder_ogg.h".} = object 
      curPtr* {.importc: "curPtr".}: cstring
      filePtr* {.importc: "filePtr".}: cstring
      fileSize* {.importc: "fileSize".}: csize

  type 
    DecoderOgg_State* {.importc: "DecoderOgg_State", header: "decoder_ogg.h".} = object 
      totalSamples* {.importc: "totalSamples".}: clong
      vf* {.importc: "vf".}: OggVorbis_File
      info* {.importc: "info".}: ptr vorbis_info
      oggFile* {.importc: "oggFile".}: ogg_file
      eof* {.importc: "eof".}: cint
      introSilenceSampleCount* {.importc: "introSilenceSampleCount".}: clong
      remainingSilenceSamples* {.importc: "remainingSilenceSamples".}: clong #
                                                                             #  int count;
                                                                             #  
    
  proc decoderOgg_init*(s: ptr DecoderOgg_State; bytes: cstring; sz: cint): cint {.
      importc: "decoderOgg_init", header: "decoder_ogg.h".}
  proc decoderOgg_decode*(s: ptr DecoderOgg_State; `out`: ptr cshort; 
                          maxSamples: cint; loop: cint): cint {.
      importc: "decoderOgg_decode", header: "decoder_ogg.h".}
  proc decoderOgg_decodeAll*(s: ptr DecoderOgg_State; sampleCount: ptr cint): ptr cshort {.
      importc: "decoderOgg_decodeAll", header: "decoder_ogg.h".}
  proc decoderOgg_free*(s: ptr DecoderOgg_State) {.importc: "decoderOgg_free", 
      header: "decoder_ogg.h".}
  proc decoderOgg_reset*(s: ptr DecoderOgg_State) {.importc: "decoderOgg_reset", 
      header: "decoder_ogg.h".}
  proc DecoderOgg_calcStreamSize*(s: ptr DecoderOgg_State): csize {.
      importc: "DecoderOgg_calcStreamSize", header: "decoder_ogg.h".}
  proc decoderOgg_msToSamples*(s: ptr DecoderOgg_State; milliseconds: clong): cint {.
      importc: "decoderOgg_msToSamples", header: "decoder_ogg.h".}
  proc decoderOgg_setIntroSilence*(s: ptr DecoderOgg_State; milliseconds: clong): cint {.
      importc: "decoderOgg_setIntroSilence", header: "decoder_ogg.h".}

when not defined(DECODE_RUNNER_H_5XOKDV): 
  const 
    DECODE_RUNNER_H_5XOKDV* = true
  type 
    DecodeRunnerState* {.importc: "DecodeRunnerState", header: "decode_runner.h".} = object 
    

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

when not defined(FACEBOOK_H_L1OIHWE8): 
  const 
    FACEBOOK_H_L1OIHWE8* = true
  proc facebookPost*(score: cint) {.importc: "facebookPost", 
                                    header: "facebook.h".}
  proc facebookIsShareAvailable*(): cint {.importc: "facebookIsShareAvailable", 
      header: "facebook.h".}

when not defined(H_GRAPHICS): 
  const 
    H_GRAPHICS* = true
  proc graphicsInit*(framebufferWidth: cint; framebufferHeight: cint) {.
      importc: "graphicsInit", header: "graphics.h".}
  proc beginRenderFrame*() {.importc: "beginRenderFrame", header: "graphics.h".}
  proc setScissor*(x: cint; y: cint; w: cint; h: cint) {.importc: "setScissor", 
      header: "graphics.h".}

when not defined(IAP_H_E25DMUWI): 
  const 
    IAP_H_E25DMUWI* = true
  proc userOwnsProduct*(id: cstring): cint {.importc: "userOwnsProduct", 
      header: "iap.h".}
  proc purchaseProduct*(id: cstring) {.importc: "purchaseProduct", 
                                       header: "iap.h".}
  proc getProductPrice*(id: cstring): cstring {.importc: "getProductPrice", 
      header: "iap.h".}
  proc onPurchaseComplete*(success: cint) {.importc: "onPurchaseComplete", 
      header: "iap.h".}
  proc iapCanRestorePurchases*(): cint {.importc: "iapCanRestorePurchases", 
      header: "iap.h".}
  proc iapRestorePurchases*() {.importc: "iapRestorePurchases", header: "iap.h".}
  proc iapAvailable*(): cint {.importc: "iapAvailable", header: "iap.h".}

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

template macro_round*(x: expr): expr = 
  (if (x) >= 0: (long)((x) + 0.5) else: (long)((x) - 0.5))


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

when not defined(PROFILE_H_7FNWFLPZ): 
  const 
    PROFILE_H_7FNWFLPZ* = true
  proc startProfiler*() {.importc: "startProfiler", header: "profiler.h".}
  proc stopProfiler*() {.importc: "stopProfiler", header: "profiler.h".}

when not defined(H_QUAD_H): 
  const 
    H_QUAD_H* = true
  import 
    texture, matrix2

  proc quadGlobalInit*() {.importc: "quadGlobalInit", header: "quad.h".}
  proc quadBeginFrame*() {.importc: "quadBeginFrame", header: "quad.h".}
  proc setTint*(r: cfloat; g: cfloat; b: cfloat) {.importc: "setTint", 
      header: "quad.h".}
  proc quadDrawTex*(tex: ptr Texture; m: ptr Matrix2) {.importc: "quadDrawTex", 
      header: "quad.h".}
  proc quadDrawTexAlpha*(tex: ptr Texture; m: ptr Matrix2; alpha: cfloat) {.
      importc: "quadDrawTexAlpha", header: "quad.h".}
  proc quadDrawCol*(x: cfloat; y: cfloat; width: cfloat; height: cfloat; 
                    red: cfloat; green: cfloat; blue: cfloat; alpha: cfloat; 
                    rot: cfloat; pivX: cfloat; pivY: cfloat) {.
      importc: "quadDrawCol", header: "quad.h".}
  proc quadFlush*() {.importc: "quadFlush", header: "quad.h".}
  proc quadEndFrame*() {.importc: "quadEndFrame", header: "quad.h".}
  proc getDrawCallCount*(): cint {.importc: "getDrawCallCount", header: "quad.h".}

when not defined(H_RANDOM): 
  const 
    H_RANDOM* = true
  proc randomSeed*(a2: cint) {.importc: "randomSeed", header: "random.h".}
  proc randomRandom*(): cint {.importc: "randomRandom", header: "random.h".}

when not defined(H_RAWBITMAPDATA_H): 
  const 
    H_RAWBITMAPDATA_H* = true
  type 
    RawBitmapData* {.importc: "RawBitmapData", header: "rawbitmapdata.h".} = object 
      data* {.importc: "data".}: ptr cuchar # RGBA
      width* {.importc: "width".}: cuint
      height* {.importc: "height".}: cuint

  proc rawBitmapDataCleanup*(rawData: ptr RawBitmapData) {.
      importc: "rawBitmapDataCleanup", header: "rawbitmapdata.h".}

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

when not defined(H_RESOURCE_LOADING): 
  const 
    H_RESOURCE_LOADING* = true
  import 
    rawbitmapdata

  proc setResourcePath*(path: cstring) {.importc: "setResourcePath", 
      header: "resource_loading.h".}
  proc loadBytesIntoBuffer*(inPath: cstring; data: ptr cuchar; bufferSize: cint): cint {.
      importc: "loadBytesIntoBuffer", header: "resource_loading.h".}
  proc loadBytes*(path: cstring; sz: ptr cint): ptr cuchar {.
      importc: "loadBytes", header: "resource_loading.h".}
  proc loadText*(path: cstring): cstring {.importc: "loadText", 
      header: "resource_loading.h".}
  proc loadImage*(filePath: cstring): ptr RawBitmapData {.importc: "loadImage", 
      header: "resource_loading.h".}

when not defined(H_STREAMING_AUDIO): 
  const 
    H_STREAMING_AUDIO* = true
  type 
    StreamingAudio* = StreamingAudio_T
  proc streamingAudioLoad*(path: cstring): ptr StreamingAudio {.
      importc: "streamingAudioLoad", header: "streaming_audio.h".}
  proc streamingAudioPlay*(a2: ptr StreamingAudio) {.
      importc: "streamingAudioPlay", header: "streaming_audio.h".}
  proc streamingAudioSetLooping*(a2: ptr StreamingAudio; a3: cint) {.
      importc: "streamingAudioSetLooping", header: "streaming_audio.h".}
  proc streamingAudioStop*(a2: ptr StreamingAudio) {.
      importc: "streamingAudioStop", header: "streaming_audio.h".}
  proc streamingAudioFree*(a2: ptr StreamingAudio) {.
      importc: "streamingAudioFree", header: "streaming_audio.h".}

when not defined(H_TEXTURE_H): 
  const 
    H_TEXTURE_H* = true
  import 
    rect

  type 
    BitmapData* {.importc: "BitmapData", header: "texture.h".} = object 
    
  type 
    Texture* {.importc: "Texture", header: "texture.h".} = object 
      width* {.importc: "width".}: cint
      height* {.importc: "height".}: cint
      uvCoords* {.importc: "uvCoords".}: array[12, GLfloat]
      data* {.importc: "data".}: ptr BitmapData

  proc textureInit*(tex: ptr Texture; data: ptr BitmapData; sourceRect: Rekt) {.
      importc: "textureInit", header: "texture.h".}

when not defined(H_UTIL): 
  const 
    H_UTIL* = true
  proc trace*(msg: cstring) {.importc: "trace", header: "util.h".}
  proc traceNoNL*(msg: cstring) {.importc: "traceNoNL", header: "util.h".}
  proc traceInt*(a2: cint) {.importc: "traceInt", header: "util.h".}
  proc traceFmt*(fmt: cstring) {.varargs, importc: "traceFmt", header: "util.h".}

