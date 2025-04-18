#ifndef DECODER_OGG_H_7YA29KAK
#define DECODER_OGG_H_7YA29KAK

#include <vorbis/vorbisfile.h>

struct ogg_file {
  char* curPtr;
  char* filePtr;
  size_t fileSize;
};
typedef struct ogg_file ogg_file;

typedef struct DecoderOgg_State{
  long totalSamples;
  OggVorbis_File vf;
  vorbis_info *info;
  ogg_file oggFile;
  int eof;
  long introSilenceSampleCount;
  long remainingSilenceSamples;
  /*
  int count;
  */
} DecoderOgg_State;

int decoderOgg_init(DecoderOgg_State *s, char* bytes, int sz);
int decoderOgg_decode(DecoderOgg_State *s, short *out, int maxSamples, int loop);
short* decoderOgg_decodeAll(DecoderOgg_State *s, int *sampleCount);
void decoderOgg_free(DecoderOgg_State *s);
void decoderOgg_reset(DecoderOgg_State *s);
size_t DecoderOgg_calcStreamSize(DecoderOgg_State *s);
int decoderOgg_msToSamples(DecoderOgg_State *s, long milliseconds);
int decoderOgg_setIntroSilence(DecoderOgg_State *s, long milliseconds);

#endif /* end of include guard: DECODER_OGG_H_7YA29KAK */

