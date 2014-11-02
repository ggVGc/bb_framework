#include "framework/data_store.h"

void dataStoreGlobalInit(void){
}

void dataStoreCommit(const char *dataString){
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *state = [NSString stringWithUTF8String:dataString];
    [defaults setObject:state forKey:@"state"];
    [defaults synchronize];
}

const char* dataStoreReload(){
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
  NSString *s = [defaults stringForKey:@"state"];
    if(s){
        return strdup([s UTF8String]);
    }else{
        return 0;
    }
}



