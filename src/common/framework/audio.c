#include <stdlib.h>
#include <math.h>
#include <vorbis/vorbisfile.h>
#include <assert.h>
#include <string.h>
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"
//#include "xmp.h"


struct ogg_file {
  char* curPtr;
  char* filePtr;
  size_t fileSize;
};

typedef struct ogg_file ogg_file;

int audioGlobalInit(){
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    soundInstances[i] = NULL;
  }
  return audioGlobalPlatformInit();
}

size_t AR_readOgg(void* dst, size_t size1, size_t size2, void* fh) {
  ogg_file* of = (ogg_file*)(fh);
  size_t len = size1 * size2;
  if ( of->curPtr + len > of->filePtr + of->fileSize ) {
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

int audioLoadInto(Audio *a, const char* path){
  OggVorbis_File vf;
  int eof=0;
  int current_section;
  int c = 0;
  long totalSamples;
  char *tmpBuf;
  int bufSize;
  ov_callbacks callbacks;
  vorbis_info *vi;
  ogg_file t;
  int sz;
  char* buf;
  int i;
  int soundIndex = -1;

  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] == NULL){
      soundIndex = i;
      break;
    }
  }

  if(soundIndex < 0){
    trace("WARNING: Max sound instances reached");
    return 0;
  }
  
  buf = (char*)loadBytes(path, &sz);
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
    trace("Input does not appear to be an Ogg bitstream.\n");
    free(buf);
    return 0;
  }

  vi=ov_info(&vf,-1);
  totalSamples = (long)ov_pcm_total(&vf,-1);
  /*
  printf("\nBitstream is %d channel, %ldHz\n",vi->channels,vi->rate);
  printf("\nDecoded length: %ld samples\n", totalSamples);
  printf("Encoded by: %s\n\n",ov_comment(&vf,-1)->vendor);
  */


  bufSize = totalSamples*vi->channels*2;
  tmpBuf = (char*)malloc(sizeof(char)*bufSize);

 
  while(!eof){
    long ret=ov_read(&vf,pcmout,sizeof(pcmout),0,2,1,&current_section);
    if (ret == 0) {
      eof=1;
    } else if (ret < 0) {
      trace("Vorbis load failed");
      free(buf);
      free(tmpBuf);
      return 0;
    } else {
      memcpy(tmpBuf+c, pcmout, ret);
      c+=ret;
      if(c>bufSize){
        trace("Encoded stream larger than buffer. Something is wrong");
        free(buf);
        free(tmpBuf);
        return 0;
      }
      // we don't bother dealing with sample rate changes, etc, but you'll have to 
      // TODO: Yeah, I should.. But I probably won't.
    }
  }


 if(audioInit(a, (int*)tmpBuf, bufSize, vi->rate, vi->channels)){
   soundInstances[soundIndex] = a;
 }

 ov_clear(&vf);
 free(buf);
 free(tmpBuf);
 return 1;
}

Audio* audioLoad(const char *path){
  Audio *a = audioAlloc();
  // Always return this, because we don't want application go crash just because audio failed loading
  // Need to add other way to let user know audio load failed
  audioLoadInto(a, path);
  return a;
}

void audioFree(Audio *a){
  int i;
  audioStop(a);
  audioPlatformFree(a);
  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] == a){
      free(soundInstances[i]);
      soundInstances[i] = NULL;
      break;
    }
  }
}

void audioCleanup(){
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] != NULL){
      traceNoNL("Killing audio instance: ");
      traceInt(i);
      audioFree(soundInstances[i]);
    }
  }
  audioPlatformCleanup();
}

void audioSetAllPaused(int paused){
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] != NULL){
      audioSetPaused(soundInstances[i], paused);
    }
  }
}

Audio* audioModLoad(const char *path){
  /*
   const int bugSizeInc = 1024*500;
  const int bufSize = 50*1024*1024;
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

  xmp_start_player(c, sampleRate, 0);
  tmpBuf = (int*)malloc(sizeof(int)*bufSize);
  success = xmp_play_buffer(c, tmpBuf, bufSize, 0);

  if(success!=0){
    trace("Failed mod pl/ayback");
    return 0;
  }

  xmp_end_player(c);
  xmp_release_module(c);
  xmp_free_context(c);

  Audio *a = audioAlloc();
  audioInit(a, tmpBuf, bufSize, sampleRate, 2);
  free(tmpBuf);
  audioSetLooping(a, 0);
   
  return a;
   */
    return 0;
}
