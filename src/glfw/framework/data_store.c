#include <stdlib.h>
#include <string.h>
#include "framework/data_store.h"


static char *data = 0;

void dataStoreGlobalInit(){
  /*data = 0;*/
}

void dataStoreCommit(const char* dataString){
  if(data){
    free(data);
  }
  data = strdup(dataString);
}

const char* dataStoreReload(){
  return data;
}



