#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <string.h>
#include "decoder_ogg.h"
#include "util.h"


static size_t AR_readOgg(void* dst, size_t size1, size_t size2, void* fh) {
  ogg_file* of = (ogg_file*)(fh);
  size_t len = size1 * size2;
  if ( of->curPtr + len > of->filePtr + of->fileSize ) {
    len = of->filePtr + of->fileSize - of->curPtr;
  }
  memcpy( dst, of->curPtr, len );
  of->curPtr += len;
  return len;
}

static int AR_seekOgg( void *fh, ogg_int64_t to, int type ) {
  ogg_file* of = (ogg_file*)(fh);
  switch( type ) {
    case SEEK_CUR:
      of->curPtr += to;
      break;
    case SEEK_END:
      of->curPtr = of->filePtr + of->fileSize - to;
      break;
    case SEEK_SET:
      of->curPtr = of->filePtr + to;
      break;
    default:
      return -1;
  }
  if ( of->curPtr < of->filePtr ) {
    of->curPtr = of->filePtr;
    return -1;
  }
  if ( of->curPtr > of->filePtr + of->fileSize ) {
    of->curPtr = of->filePtr + of->fileSize;
    return -1;
  }
  return 0;
}

static int AR_closeOgg(void* fh) {
  return 0;
}

static long AR_tellOgg( void *fh ) {
  ogg_file* of = (ogg_file*)(fh);
  return (of->curPtr - of->filePtr);
}

int decoderOgg_init(DecoderOgg_State *s, char *bytes, int sz){
  ov_callbacks callbacks;
  callbacks.read_func = AR_readOgg;
  callbacks.seek_func = AR_seekOgg;
  callbacks.close_func = AR_closeOgg;
  callbacks.tell_func = AR_tellOgg;
  s->oggFile.curPtr = s->oggFile.filePtr = bytes;
  s->oggFile.fileSize = sz;
  if(ov_open_callbacks((void *)&s->oggFile, &s->vf, NULL, -1, callbacks) < 0){
    trace("Input does not appear to be an Ogg bitstream.\n");
    return 0;
  }
  s->info=ov_info(&s->vf,-1);
  s->totalSamples = (long)ov_pcm_total(&s->vf,-1)*s->info->channels;
  s->introSilenceSampleCount = 0;
  decoderOgg_reset(s);
  /*
     s->count = 0;
     */
  /*
     printf("\nBitstream is %d channel, %ldHz\n",vi->channels,vi->rate);
     printf("\nDecoded length: %ld samples\n", totalSamples);
     printf("Encoded by: %s\n\n",ov_comment(&vf,-1)->vendor);
     */
  return 1;
}


int genEmptySamples(int emptyCount, short *out, int maxSamples){
  int i;
  int count = emptyCount>maxSamples?maxSamples:emptyCount;
  memset(out, 0, sizeof(short)*count);
  return count;
}

int decoderOgg_decode(DecoderOgg_State *s, short *out, int maxSamples, int loop){
  int current_section = 0;
  int c = 0;
  int bufSize = maxSamples*sizeof(short);
  if(s->remainingSilenceSamples>0){
    int count = genEmptySamples(s->remainingSilenceSamples, out, maxSamples);
    s->remainingSilenceSamples -= count;
    return count;
  }
  while(!s->eof && c<maxSamples){
    long ret=ov_read(&s->vf,(char*)(out+c),(maxSamples-c)*sizeof(short),0,2,1,&current_section);
    /*printf("Decoded %i\n", ret);*/
    if (ret == 0) {
      if(loop){
        decoderOgg_reset(s);
        s->remainingSilenceSamples = 0;
      }else{
        s->eof=1;
      }
    } else if (ret < 0) {
      trace("Vorbis load failed");
      return 0;
    } else {
      c+=ret/sizeof(short);
      if(c>bufSize){
        trace("BUFFER OVERFLOW - Ogg Decoder");
        return 0;
      }
      // we don't bother dealing with sample rate changes, etc, but you'll have to 
      // TODO: Yeah, I should.. But I probably won't.
    }
  }
  return c;
}


short* decoderOgg_decodeAll(DecoderOgg_State *s, int *sampleCount){
  short *ret = (short*)malloc(DecoderOgg_calcStreamSize(s));
  decoderOgg_reset(s);
  *sampleCount = decoderOgg_decode(s, ret, s->totalSamples, 0);
  return ret;
}

void decoderOgg_reset(DecoderOgg_State *s){
  s->remainingSilenceSamples = s->introSilenceSampleCount;
  s->eof = 0;
  ov_raw_seek(&s->vf, 0);
}
size_t DecoderOgg_calcStreamSize(DecoderOgg_State *s){
  return s->totalSamples*sizeof(short);
}

void decoderOgg_free(DecoderOgg_State *s){
  ov_clear(&s->vf);
  free(s->oggFile.filePtr);
}

int decoderOgg_msToSamples(DecoderOgg_State *s, long milliseconds){
  return (milliseconds*s->info->channels*s->info->rate)/1000;
}


int decoderOgg_setIntroSilence(DecoderOgg_State *s, long milliseconds){
  s->introSilenceSampleCount = s->remainingSilenceSamples = decoderOgg_msToSamples(s, milliseconds);
  return s->introSilenceSampleCount;
}
