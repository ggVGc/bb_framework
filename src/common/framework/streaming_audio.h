#ifndef H_STREAMING_AUDIO
#define H_STREAMING_AUDIO

typedef struct StreamingAudio_T StreamingAudio;

StreamingAudio* streamingAudioLoad(const char* path);
void streamingAudioPlay(StreamingAudio*);
void streamingAudioSetLooping(StreamingAudio*, int);
void streamingAudioStop(StreamingAudio*);
void streamingAudioFree(StreamingAudio*);





#endif




