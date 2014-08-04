extern "C"
{
  #include "framework/streaming_audio.h"
  #include "framework/resource_loading.h"

}
#include <SFML/Audio.hpp>


struct StreamingAudio_T
{
  sf::Music m;
  const unsigned char* data;
};

extern "C" StreamingAudio* streamingAudioLoad(const char* path)
{
  int sz;
  StreamingAudio* ret = new StreamingAudio();
  const unsigned char *data = (const unsigned char*)loadBytes(path, &sz);
  if(!data){
    return 0;
  }
  ret->data = data;
  ret->m.OpenFromMemory((const char*)ret->data, sz);
  return ret;
}
extern "C" void streamingAudioPlay(StreamingAudio* m)
{
  m->m.Play();
}
extern "C" void streamingAudioSetLooping(StreamingAudio* m, int loop)
{
  m->m.SetLoop(loop != 0);
}
extern "C" void streamingAudioStop(StreamingAudio* m)
{
  m->m.Stop();
}
extern "C" void streamingAudioFree(StreamingAudio* m)
{
  delete m->data;
  delete m;
}




