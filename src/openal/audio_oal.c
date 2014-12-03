#include <stdlib.h>
#if defined(__APPLE__)||defined(ANDROID_NDK)
#include <OpenAL/al.h>
#include <OpenAL/alc.h>
#else
#include <AL/al.h>
#include <AL/alc.h>
#endif
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"


#define MAX_SAMPLES (1024*2)
#define STREAM_BUFFER_COUNT 10


static short decodeBuffer[MAX_SAMPLES];

struct PlatformAudio_T {
  ALuint source;
  ALuint buffers[STREAM_BUFFER_COUNT];
  DecoderOgg_State *decoder;
  int streaming;
  int looping;
};

int hasError = 0;
int alCheckError(const char* msg){
  int err;
  if(hasError){
    return 1;
  }
  err = alGetError();
  if(err !=AL_NO_ERROR){
    trace(msg);
    traceNoNL("Error code: ");
    traceInt(err);
    hasError = 1;
    return 1;
  }
  return 0;
}

static int initialised = 0;
static ALCcontext *context;                                                      
static ALCdevice *device;                                                       

int queueBuffer(ALuint id, short *buf, int bufSize, int channels, int sampleRate){
  alBufferData(id, channels==2?AL_FORMAT_STEREO16:AL_FORMAT_MONO16, buf, bufSize, sampleRate); 
  if(alCheckError("Failed OpenAL setting buffer data")){return 0;}
  return 1;
}

PlatformAudio* audioPlatformAlloc(){
  return (PlatformAudio*)malloc(sizeof(PlatformAudio));
}


int audioGlobalPlatformInit(){
  ALfloat ListenerPos[] = { 0.0, 0.0, 0.0 };
  ALfloat ListenerVel[] = { 0.0, 0.0, 0.0 };
  ALfloat ListenerOri[] = { 0.0, 0.0, -1.0,  0.0, 1.0, 0.0 };
  hasError = 0;
  initialised = 0;
  device = alcOpenDevice(NULL);                                              
  if(!device){
    trace("Failed creating OpenAL device");
    return 1;
  }
  context = alcCreateContext(device, NULL);                                   
  if(!context){
    trace("Failed creating OpenAL context");
    return 1;
  }
  alcMakeContextCurrent(context);
  if(alCheckError("Could not make OpenAL context current")){return 1;}

  alListenerfv(AL_POSITION,    ListenerPos);
  alListenerfv(AL_VELOCITY,    ListenerVel);
  alListenerfv(AL_ORIENTATION, ListenerOri);

  initialised = 1;
  trace("loaded OpenAL");
  return 0;
}

static ALfloat SourcePos[] = { 0.0, 0.0, 0.0 };
static ALfloat SourceVel[] = { 0.0, 0.0, 0.0 };

int audioPlatformInit(Audio *a, int loop){
  if(!initialised){
    return 0;
  }

  a->pa->looping = loop;
  a->pa->streaming = !audioIsShort(a);

  if(a->pa->streaming){
    alGenBuffers(STREAM_BUFFER_COUNT, a->pa->buffers);
  }else{
    alGenBuffers(1, a->pa->buffers);
  }
  if(alCheckError("Failed OpenAL buffer creation")){return 0;}

  alGenSources(1, &a->pa->source);
  if(alCheckError("Failed OpenAL source creation")){return 0;}

  alSourcef (a->pa->source, AL_PITCH,    1.0f     );
  alSourcef (a->pa->source, AL_GAIN,     1.0f     );
  alSourcefv(a->pa->source, AL_POSITION, SourcePos);
  alSourcefv(a->pa->source, AL_VELOCITY, SourceVel);
  if(!a->pa->streaming){
    int decoded;
    short *buf = decoderOgg_decodeAll(&a->decoder, &decoded);
    queueBuffer(a->pa->buffers[0], buf, decoded*sizeof(short), a->decoder.info->channels, a->decoder.info->rate);
    alSourcei (a->pa->source, AL_BUFFER,   a->pa->buffers[0]);
    free(buf);
  }

  if(!a->pa->streaming && a->pa->looping){
    alSourcei (a->pa->source, AL_LOOPING,  AL_TRUE);
  }
  return 1;
}

void audioPlatformPlay(Audio* a) {
  int i, decoded;
  int bufCount = 0;
  if(!initialised){
    return;
  }
  if(a->pa->streaming){
    decoderOgg_reset(&a->decoder);
    for(i=0;i<STREAM_BUFFER_COUNT;++i){
      decoded = decoderOgg_decode(&a->decoder, decodeBuffer, MAX_SAMPLES, a->pa->looping);
      if(decoded>0){
        queueBuffer(a->pa->buffers[i], decodeBuffer, decoded*sizeof(short), a->decoder.info->channels, a->decoder.info->rate);
        ++bufCount;
      }else{
        break;
      }
    }
    if(bufCount>0){
      alSourceQueueBuffers( a->pa->source, bufCount, a->pa->buffers);
      alCheckError("Failed OpenAL queue buffers");
    }
  }

  alSourcePlay(a->pa->source);
  alCheckError("Failed playing source");
}
/*
void audioSetLooping(Audio* a, int loop) {
  a->pa->looping = loop;
  if(!a->pa->streaming){
    alSourcei (a->pa->source, AL_LOOPING,  loop==0?AL_FALSE:AL_TRUE);
  }
}
*/

void processBuffers(Audio *a, int queueNewData){
  ALint processed;
  alGetSourcei(a->pa->source , AL_BUFFERS_PROCESSED, &processed );
  while ( processed-- ) {
    ALuint id;
    alSourceUnqueueBuffers( a->pa->source, 1, &id );
    if(queueNewData){
      int decoded = decoderOgg_decode(&a->decoder, decodeBuffer, MAX_SAMPLES, a->pa->looping);
      if(decoded>0){
        queueBuffer(id, decodeBuffer, decoded*sizeof(short), a->decoder.info->channels, a->decoder.info->rate);
        alSourceQueueBuffers( a->pa->source, 1, &id );
      }
    }
  }
}

void audioStop(Audio* a) {
  alSourceStop(a->pa->source);
  if(a->pa->streaming){
    processBuffers(a, 0);
  }
}

void audioPlatformFree(PlatformAudio* a) {
  alSourceStop(a->source);
  alSourcei (a->source, AL_BUFFER, 0);
  alDeleteSources(1, &a->source);
  alDeleteBuffers(a->streaming?STREAM_BUFFER_COUNT:1, a->buffers);
}

void audioPlatformCleanup(){
  alcDestroyContext(context);
  alcCloseDevice(device);
}


void audioInstanceOnFrame(Audio *a){
  if(a->pa->streaming){
    processBuffers(a, 1);
  }
}

void audioPlatformSetPaused(PlatformAudio *a, int paused){
  int state;
  if(!initialised){
    return;
  }
  alGetSourcei(a->source, AL_SOURCE_STATE, &state);
  if(paused && state == AL_PLAYING){
    alSourcePause(a->source);
  }else if(!paused && state == AL_PAUSED){
    alSourcePlay(a->source);
  }
}


int audioIsPlaying(Audio *a){
  int state;
  alGetSourcei(a->pa->source, AL_SOURCE_STATE, &state);
  return state==AL_PLAYING?1:0;
}

