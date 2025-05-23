#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <math.h>
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"

 /*
 #define MIN(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })
 */

#define MIN(a,b) ((a) < (b) ? (a) : (b))

#define MAX_BUFFERS (3)
#define PLAYBACK_BUFFERS (1)
#define MAX_SAMPLES (1024*256)
#define DECODE_STEP_SIZE (1024*16)

#define CheckErr(x) ErrorFunc(x,__LINE__)

static char errMsgBuf[4096*4];

void ErrorFunc( SLresult result , int line) {
  if (SL_RESULT_SUCCESS != result) {
    sprintf(errMsgBuf, "%lu error code encountered at line %d\n", result, line);
    trace(errMsgBuf);
    /*exit(EXIT_FAILURE);*/
  }
}

static SLObjectItf engine_obj;
static SLEngineItf engine;
SLObjectItf output_mix_obj;
/*SLVolumeItf output_mix_vol;*/
static int initialised = 0;

struct PlatformAudio_T {
  int looping;
  SLPlayItf player;
  SLObjectItf player_obj;
  /*SLVolumeItf player_vol;*/
  SLAndroidSimpleBufferQueueItf bufferQueue;
  int is_playing;
  int is_done_buffer;
  short* buffers[MAX_BUFFERS];
  long bufferSizes[MAX_BUFFERS];
  int bufWriteIndex;
  int bufReadIndex;
  short *shortBuffer;
  int shortBufSize;
  int readCounter;
  long dataWriteCounter;
};

float gain_to_attenuation( float gain ) {
  return gain < 0.01F ? -96.0F : 20 * log10( gain );
}

int audioGlobalPlatformInit(){
  initialised = 0;
  slCreateEngine( &engine_obj, 0, 0, 0, 0, 0);
  (*engine_obj)->Realize( engine_obj, SL_BOOLEAN_FALSE );
  (*engine_obj)->GetInterface( engine_obj, SL_IID_ENGINE, &engine );

  const SLInterfaceID ids[] = { SL_IID_VOLUME };
  const SLboolean req[] = { SL_BOOLEAN_FALSE };

  (*engine)->CreateOutputMix( engine, &output_mix_obj, 1, ids, req );
  (*output_mix_obj)->Realize( output_mix_obj, SL_BOOLEAN_FALSE );

  /*
     if((*output_mix_obj)->GetInterface( output_mix_obj, SL_IID_VOLUME, &output_mix_vol ) != SL_RESULT_SUCCESS ){
     trace("Warning: Global audio volume interface not available");
     output_mix_vol = 0;
     }
     */

  initialised = 1;
  return 0;
}


void SLAPIENTRY play_callback( SLPlayItf player, void *context, SLuint32 event ){
  PlatformAudio *a = (PlatformAudio*)context;
  if( event & SL_PLAYEVENT_HEADATEND ){
    /*trace("Audio: Buffer finished");*/
    a->is_done_buffer = 1;
    /*
       if(a->looping){
       trace("Audio: Looping");
       }
       */
  }
}


void buffer_callback(SLAndroidSimpleBufferQueueItf bq, void *context){
  Audio *a = (Audio*)context;
  PlatformAudio *pa = a->pa;
  /*
  trace("Audio: Buffer Callback");
  */
  if(pa->shortBuffer){
    return;
  }
  short *buf = pa->buffers[pa->bufReadIndex];
  int sz = pa->bufferSizes[pa->bufReadIndex];
  if(sz>0){
    /*
    trace("Audio: Loading new buffer");
    traceInt(pa->bufReadIndex);
    traceInt(sz);
    */
    SLresult res = (*pa->bufferQueue)->Enqueue(pa->bufferQueue, buf, sz);
    CheckErr(res);
    ++pa->readCounter;
    ++a->pa->bufReadIndex;
    if(pa->bufReadIndex>=MAX_BUFFERS){
      pa->bufReadIndex = 0;
    }
  }else{
    trace("Audio: Buf size zero!");
  }
}

PlatformAudio* audioPlatformAlloc(){
  return (PlatformAudio*)malloc(sizeof(PlatformAudio));
}


void loadBuffers(Audio *a, int checkShort){
  SLresult res;
  PlatformAudio *pa = a->pa;
  if(pa->shortBuffer){
    return;
  }else{
    int i;
    long decoded;
    decoderOgg_reset(&a->decoder);
    if(checkShort && audioIsShort(a) && !a->pa->looping){
      /*
      trace("SHORT SAMPLE");
      */
      pa->shortBuffer = (short*)malloc(SHORT_SAMPLE_LIMIT);
      for(i=0;i<MAX_BUFFERS;++i){
        if(pa->buffers[i]){
          free(pa->buffers[i]);
          pa->buffers[i] = 0;
        }
      }
      decoded = decoderOgg_decode(&a->decoder, pa->shortBuffer, SHORT_SAMPLE_LIMIT, 0);
      /*
      traceInt(decoded);
      */
      if(decoded){
        pa->shortBufSize = decoded*sizeof(short);
      }
    }else{
      pa->readCounter = 0;
      pa->bufReadIndex = 0;
      pa->bufWriteIndex = 0;
      pa->dataWriteCounter = 0;
      for(pa->bufWriteIndex=0;pa->bufWriteIndex<MAX_BUFFERS;++pa->bufWriteIndex){
        decoded = decoderOgg_decode(&a->decoder, pa->buffers[pa->bufWriteIndex], MAX_SAMPLES, a->pa->looping);
        if(decoded){
          int sz = decoded*sizeof(short);
          pa->bufferSizes[pa->bufWriteIndex] = sz;
        }else{
          pa->bufferSizes[pa->bufWriteIndex] = 0;
          break;
        }
      }
      if(pa->bufWriteIndex>=MAX_BUFFERS){
        pa->bufWriteIndex = 0;
      }
    }
  }
}

int audioPlatformInit(Audio *a, int loop){
  int i;
  if(!initialised){
    return 0;
  }
  a->pa->looping = loop;
  a->pa->is_playing = 0;
  a->pa->is_done_buffer = 0;
  a->pa->readCounter = 0;
  a->pa->dataWriteCounter = 0;
  a->pa->shortBuffer = 0;
  a->pa->shortBufSize = 0;
  a->pa->bufReadIndex = 0;
  a->pa->bufWriteIndex = 0;
  for(i=0;i<MAX_BUFFERS;++i){
    a->pa->buffers[i] = malloc(MAX_SAMPLES*sizeof(short));
    a->pa->bufferSizes[i] = 0;
  }

  SLresult result;
  // Configure Buffer Queue.
  SLDataLocator_AndroidSimpleBufferQueue bufferQueue;
  bufferQueue.locatorType = SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE;
  bufferQueue.numBuffers = 1;
  // Configure data format.
  SLDataFormat_PCM pcm;
  pcm.formatType = SL_DATAFORMAT_PCM;
  pcm.numChannels = a->decoder.info->channels==1?1:2;
  int sampleRate = a->decoder.info->rate;
  if(!(sampleRate==48000 || sampleRate==44100)){
    traceNoNL("Warning! Unhandled sample rate: ");
    traceInt(sampleRate);
    traceNoNL("Setting to 44.1kHz");
    sampleRate = 44100;
  }
  pcm.samplesPerSec = sampleRate*1000;
  pcm.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
  pcm.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
  if(pcm.numChannels ==1){
    pcm.channelMask = SL_SPEAKER_FRONT_CENTER;
  }else{
    pcm.channelMask = SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT;
  }
  pcm.endianness = SL_BYTEORDER_LITTLEENDIAN;

  // Configure Audio Source.
  SLDataSource source;
  source.pFormat = &pcm;
  source.pLocator = &bufferQueue;
  // Configure output mix.
  SLDataLocator_OutputMix outputMix;
  outputMix.locatorType = SL_DATALOCATOR_OUTPUTMIX;
  outputMix.outputMix = output_mix_obj;
  // Configure Audio sink.
  SLDataSink sink;
  sink.pFormat = NULL;
  sink.pLocator = &outputMix;
  // Create Audio player.
  const SLInterfaceID ids[2] = {SL_IID_ANDROIDSIMPLEBUFFERQUEUE, SL_IID_VOLUME};
  const SLboolean req[2] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_FALSE};

  result = (*engine)->CreateAudioPlayer(engine, &a->pa->player_obj, &source, &sink, 1, ids, req);

  (*a->pa->player_obj)->Realize( a->pa->player_obj, SL_BOOLEAN_FALSE );
  (*a->pa->player_obj)->GetInterface( a->pa->player_obj,SL_IID_PLAY, &a->pa->player );
  (*a->pa->player_obj)->GetInterface( a->pa->player_obj,SL_IID_BUFFERQUEUE, &a->pa->bufferQueue );
  /*
     if((*a->pa->player_obj)->GetInterface( a->pa->player_obj, SL_IID_VOLUME, &a->pa->player_vol ) != SL_RESULT_SUCCESS){
     trace("Warning: Audio instance volume interface not available");
     a->pa->player_vol = 0;
     }
     */

  SLresult res = (*a->pa->bufferQueue)->RegisterCallback( a->pa->bufferQueue,buffer_callback, a);
  CheckErr(res);
  (*a->pa->player)->RegisterCallback( a->pa->player, play_callback, a->pa );
  res = (*a->pa->player)->SetCallbackEventsMask( a->pa->player, SL_PLAYEVENT_HEADATEND );
  CheckErr(res);

  if(audioIsShort(a) && !a->pa->looping){
    loadBuffers(a, 1);
  }

  return 1;
}

void audioPlatformPlay(Audio* a) {
  PlatformAudio *pa = a->pa;
  if(!initialised){
    return;
  }
  /*
  trace("Audio: Playing");
  */


  if(pa->shortBuffer){
    SLresult res = (*a->pa->player)->SetPlayState( a->pa->player, SL_PLAYSTATE_PLAYING );
    assert(SL_RESULT_SUCCESS == res);
    res = (*a->pa->bufferQueue)->Enqueue(a->pa->bufferQueue, pa->shortBuffer, pa->shortBufSize);
    assert(SL_RESULT_SUCCESS == res);
  }else{
    loadBuffers(a, 0);
    SLresult res = (*a->pa->player)->SetPlayState( a->pa->player, SL_PLAYSTATE_PLAYING );
    assert(SL_RESULT_SUCCESS == res);
    res = (*a->pa->bufferQueue)->Enqueue(a->pa->bufferQueue, pa->buffers[0], pa->bufferSizes[0]);
    assert(SL_RESULT_SUCCESS == res);
    pa->bufReadIndex = 1;
  }
  a->pa->is_playing = 1;
  a->pa->is_done_buffer = 0;
}

/*
void audioSetLooping(Audio* a, int loop) {
  if(!initialised){
    return;
  }
  a->pa->looping = loop;
}
*/

void audioStop(Audio* a) {
  if(!initialised){
    return;
  }
  (*a->pa->player)->SetPlayState( a->pa->player, SL_PLAYSTATE_STOPPED );
  (*a->pa->bufferQueue)->Clear(a->pa->bufferQueue );
  a->pa->is_playing = 0;
}


int audioIsPlaying(Audio *a){
  if(!initialised){
    return 0;
  }
  if(a->pa->is_playing && a->pa->is_done_buffer ){
    audioStop(a);
  }
  return a->pa->is_playing;
}

void audioPlatformSetPaused(PlatformAudio *a, int paused){
  if(!initialised){
    return;
  }
  if(paused){
    (*a->player)->SetPlayState( a->player, SL_PLAYSTATE_PAUSED );
  }else{
    (*a->player)->SetPlayState( a->player, SL_PLAYSTATE_PLAYING );
  }
}


void audioPlatformCleanup(){
  if(initialised){
    (*output_mix_obj)->Destroy(output_mix_obj);
    (*engine_obj)->Destroy(engine_obj);
  }
}

void audioInstanceOnFrame(Audio *a){
  PlatformAudio *pa = a->pa;
  if(pa->readCounter>PLAYBACK_BUFFERS){
    short *buf = pa->buffers[pa->bufWriteIndex];
    long step = MIN(MAX_SAMPLES-pa->dataWriteCounter, DECODE_STEP_SIZE);
    long decoded = decoderOgg_decode(&a->decoder, buf+pa->dataWriteCounter, step, pa->looping);
    if(decoded){
      /*
      trace("Decoded");
      traceInt(decoded);
      */
      pa->dataWriteCounter+=decoded;
    }else{
      /*
      trace("Audio: Filled buffer");
      traceInt(pa->bufWriteIndex);
      */
      pa->bufferSizes[pa->bufWriteIndex]=pa->dataWriteCounter*sizeof(short);
      --pa->readCounter;
      ++pa->bufWriteIndex;
      if(pa->bufWriteIndex>=MAX_BUFFERS){
        pa->bufWriteIndex = 0;
      }
      pa->dataWriteCounter = 0;
      pa->bufferSizes[pa->bufWriteIndex] = 0;
    }
  }
  /*
  if(a->pa->is_playing && a->pa->is_done_buffer){
    if(a->pa->looping){
      audioPlay(a);
    }else{
      trace("Audio finished");
      a->pa->is_playing = 0;
    }
  }
  */
}

void audioPlatformFree(PlatformAudio *a) {
  int i;
  if(!initialised){
    return;
  }
  (*a->player_obj)->Destroy(a->player_obj);
  if(a->shortBuffer){
    free(a->shortBuffer);
  }
  for(i=0;i<MAX_BUFFERS;++i){
    if(a->buffers[i]){
      free(a->buffers[i]);
    }
  }
}
