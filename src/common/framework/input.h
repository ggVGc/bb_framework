#ifndef H_INPUT_H
#define H_INPUT_H

#define MAX_KEYS 512

void setCursorPos(int index, int x, int y);
void setCursorDownState(int index, int isDown);

void setKeyPressed(int keyCode);
void setKeyReleased(int keyCode);


#endif
