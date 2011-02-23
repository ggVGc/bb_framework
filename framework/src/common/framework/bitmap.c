/*#include <stdlib.h>*/
/*#include <stdio.h>*/
/*#include <string.h>*/
/*#include "bitmap.h"*/
/*#include "GLES/gl.h"*/
/*#include "bitmapdata.h"*/
/*#include "app.h"*/



/*struct Bitmap_T*/
/*{*/
    /*unsigned int width;*/
    /*unsigned int height;*/

    /*GLfloat quadVertices[12];*/
    /*GLfloat quadTexCoords[12];*/
    /*GLuint texHandle;*/
/*};*/

/*//unsigned int BITMAP_SIZE = sizeof(Bitmap);*/


/*Bitmap* bitmapAlloc(void)*/
/*{*/
    /*return (Bitmap*)malloc(sizeof(Bitmap));*/
/*}*/


/*void bitmapDestroy(Bitmap* b)*/
/*{*/
  /*glDeleteTextures(1, &(b->texHandle));*/
/*}*/


/*void bitmapInit(Bitmap* b, int width, int height, BitmapData* textureData)*/
/*{*/
  /*int w = width;*/
  /*int h = height;*/

    /*GLfloat texCoords[12] = {*/
        /*0, 1,*/
        /*1, 1,*/
        /*0,  0,*/
        /*1, 1,*/
        /*1,  0,*/
        /*0,  0*/
    /*};*/



    /*b->quadVertices[0] = 0; b->quadVertices[1] = h;*/
    /*b->quadVertices[2] = w; b->quadVertices[3] = h;*/
    /*b->quadVertices[4] = 0; b->quadVertices[5] = 0;*/
    /*b->quadVertices[6] = w; b->quadVertices[7] = h;*/
    /*b->quadVertices[8] = w; b->quadVertices[9] = 0;*/
    /*b->quadVertices[10] = 0; b->quadVertices[11] = 0;*/


    /*memcpy(b->quadTexCoords, texCoords, sizeof(GLfloat)*12);*/

    /*b->width = width;*/
    /*b->height = height;*/

    /*glGenTextures(1, &(b->texHandle));*/
    /*glBindTexture(GL_TEXTURE_2D, b->texHandle);*/
    /*glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); */
    /*glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);*/
    /*glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureData->width, textureData->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData->data);*/
/*}*/



/*Bitmap* bitmapCreate(int width, int height, BitmapData* textureData)*/
/*{*/
    /*Bitmap* b = bitmapAlloc();*/
    /*bitmapInit(b, width, height, textureData);*/
    /*return b;*/
/*}*/



/*void bitmapDraw(Bitmap* b, float x, float y, float rot, float pivX, float pivY, float scaleX, float scaleY)*/
/*{*/
  /*float w = b->width*scaleX;*/
  /*float h = b->height*scaleY;*/

    /*glEnableClientState(GL_VERTEX_ARRAY);*/
    /*glEnableClientState(GL_TEXTURE_COORD_ARRAY);*/
    /*glBindTexture(GL_TEXTURE_2D, b->texHandle);*/
    /*glTexCoordPointer(2, GL_FLOAT, 0, b->quadTexCoords);*/
    /*glVertexPointer(2, GL_FLOAT, 0, b->quadVertices);*/

    /*glPushMatrix();*/
    /*glLoadIdentity();*/

    /*glTranslatef(x-w*pivX, y-h*pivY, 0);*/
    /*glTranslatef(w*pivX, h*pivY, 0);*/
    /*glRotatef(rot, 0, 0, 1);*/
    /*glTranslatef(-w*pivX, -h*pivY, 0);*/

    /*glScalef(scaleX, scaleY, 1);*/
    /*glDrawArrays(GL_TRIANGLES, 0, 6);*/
    /*glPopMatrix();*/

    /*glDisableClientState(GL_TEXTURE_COORD_ARRAY);*/
    /*glDisableClientState(GL_VERTEX_ARRAY);*/
/*}*/
