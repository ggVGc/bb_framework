#include "framework/input.h"
#include "util.h"

static int x=0;
static int y=0;
static int down=0;

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


void setCursorPos(int newX, int newY)
{
  x = newX;
  y = newY;

}
void setCursorDownState(int isDown)
{
  down = isDown;
}
