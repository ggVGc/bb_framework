#include <stdlib.h>
#include "framework/streaming_audio.h"
#include "framework/resource_loading.h"
//#include "xmp.h"
#include "framework/util.h"

struct StreamingAudio_T
{
  //sf::Music m;
  /*sf::Sound s;*/
  /*sf::SoundBuffer buf;*/
  int dummy;
};

StreamingAudio* streamingAudioLoad(const char* path){
	const int bufSize = 1000*1000*50;
  int sz, success;
  int* tmpBuf;
  StreamingAudio* ret = (StreamingAudio*)malloc(sizeof(StreamingAudio));
/*
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
    return ret;
  }

  xmp_start_player(c, 44100, 0);
  tmpBuf = (int*)malloc(sizeof(int)*bufSize);
  success = xmp_play_buffer(c, tmpBuf, bufSize, 0);

  if(success!=0){
    trace("Failed XM playback");
    return ret;
  }

  xmp_end_player(c);
  xmp_release_module(c);        [> unload module <]
  xmp_free_context(c);          [> destroy the player context <]
*/

  /*const int sampleCount = bufSize;*/
  /*sf::Int16* samples = (sf::Int16*)malloc(sizeof(sf::Int16)*bufSize);*/

  /*for(int i=0;i<sampleCount; ++i){*/
    /*samples[i] = tmpBuf[i];*/
  /*}*/

  /*if (!ret->buf.LoadFromSamples(samples, sampleCount, 1, 44100)) {*/
      /*trace("Failed buffer creation");*/
  /*}*/
  /*ret->s.SetBuffer(ret->buf);*/
  //ret->m.OpenFromMemory((const char*)ret->data, bufSize);
  return ret;
}
void streamingAudioPlay(StreamingAudio* m) {
  /*m->s.SetLoop(true);*/
  /*m->s.Play();*/
}
void streamingAudioSetLooping(StreamingAudio* m, int loop) {
  //m->m.SetLoop(loop != 0);
}
void streamingAudioStop(StreamingAudio* m) {
  //m->m.Stop();
}
void streamingAudioFree(StreamingAudio* m) {
  //delete m->data;
  //delete m;
}




