#include "framework/input.h"
#include "util.h"

static int x=0;
static int y=0;
static int down=0;
static int keyStates[MAX_KEYS];


void inputInit(){
  int i;
  for(i=0; i<MAX_KEYS; i++){
    keyStates[i] = 0;
  }
}



int cursorX(void)
{
  return x;
}
int cursorY(void)
{
  return y;
}
int cursorDown(void)
{
  return down;
}

int keyDown(int keyCode){
  if(keyCode<MAX_KEYS && keyCode>=0){
    return keyStates[keyCode];
  }
  else{ return 0; }
}


void setCursorPos(int newX, int newY)
{
  x = newX;
  y = newY;

}
void setCursorDownState(int isDown)
{
  down = isDown;
}



void setKeyPressed(int keyCode){
  if(keyCode<MAX_KEYS && keyCode>=0){
    keyStates[keyCode] = 1;
  }
}
void setKeyReleased(int keyCode){
  if(keyCode<MAX_KEYS && keyCode>=0){
    keyStates[keyCode] = 0;
  }
}
