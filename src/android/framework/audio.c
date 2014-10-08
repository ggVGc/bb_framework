#include <stdlib.h>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"

#define MAX_BUFFERS 1

static SLObjectItf engine_obj;
static SLEngineItf engine;
SLObjectItf output_mix_obj;
SLVolumeItf output_mix_vol;

static int initialised = 0;


struct Audio_T {
  void *sampleData;
  unsigned int sampleCount;
  int loop;
  SLPlayItf player;
  SLObjectItf player_obj;
  SLVolumeItf player_vol;
  SLAndroidSimpleBufferQueueItf player_buf_q;
  int is_playing;
  int is_done_buffer;
};


int audioGlobalPlatformInit(){
  initialised = 0;
  slCreateEngine( &engine_obj, 0, 0, 0, 0, 0);
  (*engine_obj)->Realize( engine_obj, SL_BOOLEAN_FALSE );
  (*engine_obj)->GetInterface( engine_obj, SL_IID_ENGINE, &engine );

  const SLInterfaceID ids[] = { SL_IID_VOLUME };
  const SLboolean req[] = { SL_BOOLEAN_FALSE };

   
  (*engine)->CreateOutputMix( engine, &output_mix_obj, 1, ids, req );
   
  (*output_mix_obj)->Realize( output_mix_obj, SL_BOOLEAN_FALSE );
   
  if((*output_mix_obj)->GetInterface( output_mix_obj, SL_IID_VOLUME, &output_mix_vol ) != SL_RESULT_SUCCESS ){
    output_mix_vol = 0;
  }

  

  initialised = 1;
  return 0;
}

void SLAPIENTRY play_callback( SLPlayItf player, void *context, SLuint32 event ){
  Audio *a = (Audio*)context;
  if( event & SL_PLAYEVENT_HEADATEND ){
    /*
    trace("Audio: Buffer finished");
    */
    a->is_done_buffer = 1;
    /*
    if(a->loop){
      trace("Audio: Looping");
    }
    */
  }
}
 

Audio* audioMake(int *buf, int bufSize, int sampleRate, int channels){
  if(!initialised){
    return 0;
  }
  Audio* a = (Audio*)malloc(sizeof(Audio));
  a->loop = 0;
  a->is_playing = 0;
  a->is_done_buffer = 0;
  a->sampleData = malloc(sizeof(int)*bufSize);
  memcpy(a->sampleData, buf, bufSize);
  a->sampleCount = bufSize;

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
  const SLInterfaceID ids[1] = {SL_IID_ANDROIDSIMPLEBUFFERQUEUE};
  const SLboolean req[1] = {SL_BOOLEAN_TRUE};

  result = (*engine)->CreateAudioPlayer(engine, &a->player_obj, &source, &sink, 1, ids, req);

  (*a->player_obj)->Realize( a->player_obj, SL_BOOLEAN_FALSE );
  (*a->player_obj)->GetInterface( a->player_obj,SL_IID_PLAY, &a->player );
  (*a->player_obj)->GetInterface( a->player_obj, SL_IID_VOLUME, &a->player_vol );
  (*a->player_obj)->GetInterface( a->player_obj,SL_IID_ANDROIDSIMPLEBUFFERQUEUE, &a->player_buf_q );

  (*a->player)->RegisterCallback( a->player, play_callback, a );
  (*a->player)->SetCallbackEventsMask( a->player, SL_PLAYEVENT_HEADATEND );
  return a;
}

void audioPlay(Audio* a) {
  /*
  trace("Audio: Playing");
  */
  audioStop(a);
  (*a->player_buf_q)->Enqueue(a->player_buf_q, a->sampleData, a->sampleCount );
  (*a->player)->SetPlayState( a->player, SL_PLAYSTATE_PLAYING );
  a->is_playing = 1;
  a->is_done_buffer = 0;
}

void audioSetLooping(Audio* a, int loop) {
  a->loop = loop;
}

void audioStop(Audio* a) {
  (*a->player)->SetPlayState( a->player, SL_PLAYSTATE_STOPPED );
  (*a->player_buf_q)->Clear(a->player_buf_q );
  a->is_playing = 0;
}

void audioPlatformFree(Audio* a) {
  (*a->player_obj)->Destroy(a->player_obj);
  free(a->sampleData);
}

/*
int audioIsFinished(Audio *a){
  if(a->is_playing && a->is_done_buffer ){
    audioStop(a);
  }
  return !a->is_playing;
}
*/

void audioPlatformCleanup(){
  if(initialised){
    (*output_mix_obj)->Destroy(output_mix_obj);
    (*engine_obj)->Destroy(engine_obj);
  }
}

void audioOnFrame(){
  Audio *a;
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    a = soundInstances[i];
    if(a){
      if(a->is_playing){
        if(a->is_done_buffer){
          if(a->loop){
            audioPlay(a);
          }else{
            a->is_playing = 0;
          }
        }
      }
    }
  }
}

