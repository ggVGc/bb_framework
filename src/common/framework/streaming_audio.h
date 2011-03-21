#ifndef _H_STREAMING_AUDIO_
#define _H_STREAMING_AUDIO_

typedef struct StreamingAudio_T StreamingAudio;

StreamingAudio* streamingAudioLoad(const char* path);
void streamingAudioPlay(StreamingAudio*);
void streamingAudioSetLooping(StreamingAudio*, int);
void streamingAudioStop(StreamingAudio*);
void streamingAudioFree(StreamingAudio*);





#endif




