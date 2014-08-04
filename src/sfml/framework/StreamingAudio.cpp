extern "C"
{
  #include "framework/streaming_audio.h"
  #include "framework/resource_loading.h"
  #include "xmp.h"
  #include "util.h"
}
#include <SFML/Audio.hpp>
#include <cmath>

struct StreamingAudio_T
{
  //sf::Music m;
  sf::Sound s;
  sf::SoundBuffer buf;
};

extern "C" StreamingAudio* streamingAudioLoad(const char* path)
{
  int sz;
  StreamingAudio* ret = new StreamingAudio();
  unsigned char *data = loadBytes(path, &sz);
  xmp_context c;
  struct xmp_frame_info mi;
  if(!data){
    trace("Invalid music file path");
    return 0;
  }
  c = xmp_create_context();
  int success = xmp_load_module_from_memory(c, data, sz);
  if(success != 0){
    trace("XM load fail");
    return ret;
  }

  xmp_start_player(c, 44100, 0);
  const int bufSize = 1000*1000*10;
  int* tmpBuf = (int*)malloc(sizeof(int)*bufSize);
  success = xmp_play_buffer(c, tmpBuf, bufSize, 0);

  if(success!=0){
    trace("Failed XM playback");
    return ret;
  }

  xmp_end_player(c);
  xmp_release_module(c);        /* unload module */
  xmp_free_context(c);          /* destroy the player context */

  const int sampleCount = bufSize;
  sf::Int16* samples = (sf::Int16*)malloc(sizeof(sf::Int16)*bufSize);

  for(int i=0;i<sampleCount; ++i){
    samples[i] = tmpBuf[i];
  }

  if (!ret->buf.LoadFromSamples(samples, sampleCount, 1, 44100)) {
      trace("Failed buffer creation");
  }
  ret->s.SetBuffer(ret->buf);
  ret->s.SetLoop(true);
  //ret->s.SetPitch(1.5f);
  ret->s.Play();



  //ret->m.OpenFromMemory((const char*)ret->data, bufSize);
  return ret;
}
extern "C" void streamingAudioPlay(StreamingAudio* m)
{
  //trace("PLAY");
  //m->s.Play();
}
extern "C" void streamingAudioSetLooping(StreamingAudio* m, int loop)
{
  //m->m.SetLoop(loop != 0);
}
extern "C" void streamingAudioStop(StreamingAudio* m)
{
  //m->m.Stop();
}
extern "C" void streamingAudioFree(StreamingAudio* m)
{
  //delete m->data;
  //delete m;
}




