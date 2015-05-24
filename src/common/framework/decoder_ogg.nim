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

