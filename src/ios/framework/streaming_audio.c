#include "framework/streaming_audio.h"
#include "framework/resource_loading.h"

#include <stdlib.h>
//#include <SFML/Audio.hpp>


struct StreamingAudio_T
{
  int nothing;
 //sf::Music m;
 //const char* data;
};

StreamingAudio* streamingAudioLoad(const char* path)
{
  //int sz;
  StreamingAudio* ret = (StreamingAudio*)malloc(sizeof(StreamingAudio));
  //ret->data = loadAscii(path, &sz);
  //ret->m.OpenFromMemory(ret->data, sz);
  return ret;
}

void streamingAudioPlay(StreamingAudio* m)
{
  //m->m.Play();
}

void streamingAudioSetLooping(StreamingAudio* m, int loop)
{
  //m->m.SetLoop(loop != 0);
}

void streamingAudioStop(StreamingAudio* m)
{
  //m->m.Stop();
}

void streamingAudioFree(StreamingAudio* m)
{
  //delete m->data;
  free(m);
}




