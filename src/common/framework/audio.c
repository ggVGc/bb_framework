#include <stdlib.h>
#include <math.h>
#include <vorbis/vorbisfile.h>
#include <assert.h>
#include <string.h>
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"
#include "xmp.h"


struct ogg_file {
  char* curPtr;
  char* filePtr;
  size_t fileSize;
};

typedef struct ogg_file ogg_file;

size_t AR_readOgg(void* dst, size_t size1, size_t size2, void* fh) {
  ogg_file* of = (ogg_file*)(fh);
  size_t len = size1 * size2;
  if ( of->curPtr + len > of->filePtr + of->fileSize )
  {
      len = of->filePtr + of->fileSize - of->curPtr;
  }
  memcpy( dst, of->curPtr, len );
  of->curPtr += len;
  return len;
}

int AR_seekOgg( void *fh, ogg_int64_t to, int type ) {
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

int AR_closeOgg(void* fh) {
    return 0;
}

long AR_tellOgg( void *fh ) {
    ogg_file* of = (ogg_file*)(fh);
    return (of->curPtr - of->filePtr);
}

char pcmout[4096];

Audio* audioLoad(const char* path){
  OggVorbis_File vf;
  int eof=0;
  int current_section;
  int c = 0;
  int totalSamples;
  char *tmpBuf;
  int bufSize;
  ov_callbacks callbacks;
  vorbis_info *vi;
  ogg_file t;
  Audio *a;
  int sz;
  char* buf = (char*)loadBytes(path, &sz);
  t.curPtr = t.filePtr = buf;
  if(!buf){
    trace("Failed audio file load");
    return 0;
  }
  t.fileSize = sz;

  callbacks.read_func = AR_readOgg;
  callbacks.seek_func = AR_seekOgg;
  callbacks.close_func = AR_closeOgg;
  callbacks.tell_func = AR_tellOgg;

  if(ov_open_callbacks((void *)&t, &vf, NULL, -1, callbacks) < 0){
    /*fprintf(stderr,"Input does not appear to be an Ogg bitstream.\n");*/
    return 0;
  }

  vi=ov_info(&vf,-1);
  totalSamples = (long)ov_pcm_total(&vf,-1);
  printf("\nBitstream is %d channel, %ldHz\n",vi->channels,vi->rate);
  printf("\nDecoded length: %ld samples\n", totalSamples);
  printf("Encoded by: %s\n\n",ov_comment(&vf,-1)->vendor);


  bufSize = totalSamples*vi->channels;
  tmpBuf = (char*)malloc(sizeof(char)*bufSize);

 
  while(!eof){
    long ret=ov_read(&vf,pcmout,sizeof(pcmout),0,1,1,&current_section);
    if (ret == 0) {
      eof=1;
    } else if (ret < 0) {
      trace("Vorbis load failed");
      return 0;
    } else {
      memcpy(tmpBuf+c, pcmout, ret);
      c+=ret;
      if(c>bufSize){
        trace("Encoded stream larger than buffer. Something is wrong");
        break;
      }
      // we don't bother dealing with sample rate changes, etc, but you'll have to 
      // TODO: Yeah, I should.. But I probably won't.
    }
  }

 a = audioMake((int*)tmpBuf, bufSize, vi->rate);
 ov_clear(&vf);
 free(tmpBuf);
 return a;
}


/*
   Audio* audioLoad(const char* path){
   const int bufSize = 1000*1000*50;
   const int sampleRate = 44100;
   int sz, success;
   int* tmpBuf;
   unsigned char *data = loadBytes(path, &sz);
   xmp_context c;
   struct xmp_frame_info mi;
   if(!data){
   trace("Invalid music file path");
   return 0;
   }
   c = xmp_create_context();
   success = xmp_load_module_from_memory(c, data, sz);
   if(success != 0){
   trace("XM load fail");
   return 0;
   }

   xmp_start_player(c, sampleRate, XMP_FORMAT_MONO);
   tmpBuf = (int*)malloc(sizeof(int)*bufSize);
   success = xmp_play_buffer(c, tmpBuf, bufSize, 0);

   if(success!=0){
   trace("Failed XM playback");
   return 0;
   }

   xmp_end_player(c);
   xmp_release_module(c);        [> unload module <]
   xmp_free_context(c);          [> destroy the player context <]

   Audio *a = audioMake(tmpBuf, bufSize, sampleRate);
   free(tmpBuf);
   audioSetLooping(a, 0);
   return a;
   }
   */
