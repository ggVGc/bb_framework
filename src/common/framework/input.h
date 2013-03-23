#ifndef _H_INPUT_H_
#define _H_INPUT_H_

#define MAX_KEYS 512

int cursorX(void);
int cursorY(void);
int cursorDown(void);
int keyDown(int keyCode);
//int cursorPressed(void);
//int cursorReleased(void);

void inputInit();
void setCursorPos(int x, int y);
void setCursorDownState(int isDown);

void setKeyPressed(int keyCode);
void setKeyReleased(int keyCode);


#endif
