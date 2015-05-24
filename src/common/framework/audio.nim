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

