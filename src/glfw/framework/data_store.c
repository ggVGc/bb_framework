#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "framework/data_store.h"



void dataStoreGlobalInit(){
}

void dataStoreCommit(const char* dataString){
  FILE *f = fopen("data", "w");
  if(f){
    fwrite(dataString, sizeof(char), strlen(dataString), f);
    fclose(f);
  }
}

const char* dataStoreReload(){
  char * buffer = 0;
  long length;
  FILE * f = fopen ("data", "r");

  if (f) {
    fseek (f, 0, SEEK_END);
    length = ftell (f);
    fseek (f, 0, SEEK_SET);
    buffer = malloc (length+1);
    if (buffer) {
      fread (buffer, 1, length, f);
    }
    buffer[length] = '\0';
    fclose (f);
  }

  if (buffer) {
    return buffer;
  }

  return 0;
}



