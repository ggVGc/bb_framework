extern "C"
{
  #include "framework/streaming_audio.h"
  #include "framework/resource_loading.h"

}
#include <SFML/Audio.hpp>


struct StreamingAudio_T
{
  sf::Music m;
  const char* data;
};

extern "C" StreamingAudio* streamingAudioLoad(const char* path)
{
  /*
  int sz;
  StreamingAudio* ret = new StreamingAudio();
  ret->data = loadBytes(path, &sz);
  ret->m.OpenFromMemory(ret->data, sz);
  return ret;
  */
	return 0;
}
extern "C" void streamingAudioPlay(StreamingAudio* m)
{
  //m->m.Play();
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
  /*
  delete m->data;
  delete m;
  */
}




