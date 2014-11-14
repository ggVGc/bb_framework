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

#define MAX_BUFFERS 1
#define BUF_SIZE 1024

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
  short  *sampleData;
  unsigned int curBufPos;
  unsigned int sampleCount;
  int loop;
  SLPlayItf player;
  SLObjectItf player_obj;
  /*SLVolumeItf player_vol;*/
  SLAndroidSimpleBufferQueueItf bufferQueue;
  int is_playing;
  int is_done_buffer;
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
    trace("Audio: Buffer finished");
    a->is_done_buffer = 1;
    /*
    if(a->loop){
      trace("Audio: Looping");
    }
    */
  }
}
 

void buffer_callback(SLAndroidSimpleBufferQueueItf bq, void *context){
  PlatformAudio *a = (PlatformAudio*)context;
  if(a->curBufPos<a->sampleCount){
    unsigned int step = BUF_SIZE;
    if(a->curBufPos+step > a->sampleCount){
      step = a->sampleCount-a->curBufPos;
    }
    SLresult res = (*bq)->Enqueue(bq, a->sampleData+a->curBufPos, step*sizeof(short));
    assert(SL_RESULT_SUCCESS == res);
    a->curBufPos+=step;
  }
}


PlatformAudio* audioPlatformAlloc(){
  return (PlatformAudio*)malloc(sizeof(PlatformAudio));
}

int audioPlatformInit(PlatformAudio *a, short *buf, int samplesPerChannel, int sampleRate, int channels){
  int bufSize = samplesPerChannel*channels*sizeof(short);
  if(!initialised){
    return 0;
  }
  a->curBufPos = 0;
  a->loop = 0;
  a->is_playing = 0;
  a->is_done_buffer = 0;
  a->sampleData = (short*)malloc(bufSize);
  memcpy(a->sampleData, buf, bufSize);
  a->sampleCount = samplesPerChannel*channels;

  SLresult result;
  // Configure Buffer Queue.
  SLDataLocator_AndroidSimpleBufferQueue bufferQueue;
  bufferQueue.locatorType = SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE;
  bufferQueue.numBuffers = MAX_BUFFERS;
  // Configure data format.
  SLDataFormat_PCM pcm;
  pcm.formatType = SL_DATAFORMAT_PCM;
  pcm.numChannels = channels==1?1:2;
  if(!(sampleRate==48000 || sampleRate==44100)){
    traceNoNL("Warning! Unhandled sample rate: ");
    traceInt(sampleRate);
    traceNoNL("Setting to 44.1kHz");
    sampleRate = 44100;
  }
  pcm.samplesPerSec = sampleRate*1000;
  pcm.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
  pcm.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
  if(channels ==1){
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

  result = (*engine)->CreateAudioPlayer(engine, &a->player_obj, &source, &sink, 1, ids, req);

  (*a->player_obj)->Realize( a->player_obj, SL_BOOLEAN_FALSE );
  (*a->player_obj)->GetInterface( a->player_obj,SL_IID_PLAY, &a->player );
  (*a->player_obj)->GetInterface( a->player_obj,SL_IID_BUFFERQUEUE, &a->bufferQueue );
  /*
     if((*a->player_obj)->GetInterface( a->player_obj, SL_IID_VOLUME, &a->player_vol ) != SL_RESULT_SUCCESS){
     trace("Warning: Audio instance volume interface not available");
     a->player_vol = 0;
     }
     */

  SLresult res = (*a->bufferQueue)->RegisterCallback( a->bufferQueue,buffer_callback, a );
  CheckErr(res);
  (*a->player)->RegisterCallback( a->player, play_callback, a );
  res = (*a->player)->SetCallbackEventsMask( a->player, SL_PLAYEVENT_HEADATEND );
  CheckErr(res);
  return 1;
}

void audioPlatformPlay(PlatformAudio* a) {
  if(!initialised){
    return;
  }
     trace("Audio: Playing");
  a->curBufPos = 0;
  (*a->player)->SetPlayState( a->player, SL_PLAYSTATE_PLAYING );
  SLresult res = (*a->bufferQueue)->Enqueue(a->bufferQueue, a->sampleData, BUF_SIZE*sizeof(short));
  assert(SL_RESULT_SUCCESS == res);
  a->is_playing = 1;
  a->is_done_buffer = 0;
}

void audioSetLooping(Audio* a, int loop) {
  if(!initialised){
    return;
  }
  a->pa->loop = loop;
}

void audioStop(Audio* a) {
  if(!initialised){
    return;
  }
  (*a->pa->player)->SetPlayState( a->pa->player, SL_PLAYSTATE_STOPPED );
  (*a->pa->bufferQueue)->Clear(a->pa->bufferQueue );
  a->pa->is_playing = 0;
}

void audioPlatformFree(PlatformAudio *a) {
  if(!initialised){
    return;
  }
  (*a->player_obj)->Destroy(a->player_obj);
  free(a->sampleData);
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
  if(a->pa->is_playing && a->pa->is_done_buffer){
    if(a->pa->loop){
      audioPlay(a);
    }else{
      trace("Audio finished");
      a->pa->is_playing = 0;
    }
  }
}
