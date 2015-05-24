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

