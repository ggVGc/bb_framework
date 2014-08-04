#include <GLES/gl.h>
#include "quad.h"

static GLfloat vertices[12] = {
  0, 1,
  1, 1,
  0, 0,
  1, 1,
  1, 0,
  0, 0
};

void quadDrawCommon(float x, float y, float width, float height, float rot, float pivX, float pivY){
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(2, GL_FLOAT, 0, vertices);

  glPushMatrix();
  glLoadIdentity();

  glTranslatef(x-width*pivX, y-height*pivY, 0);
  glTranslatef(width*pivX, height*pivY, 0);
  glRotatef(rot, 0, 0, 1);
  glTranslatef(-width*pivX, -height*pivY, 0);

  glScalef(width, height, 1);
  glDrawArrays(GL_TRIANGLES, 0, 6);
  glPopMatrix();

  glDisableClientState(GL_VERTEX_ARRAY);
}


void quadDrawTex(float x, float y, float width, float height, Texture* tex, float rot, float pivX, float pivY){
  glColor4f(1,1,1,1);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glBindTexture(GL_TEXTURE_2D, tex->data->glTexHandle);
  glTexCoordPointer(2, GL_FLOAT, 0, tex->uvCoords);
  quadDrawCommon(x, y, width, height, rot, pivX, pivY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  /*glBindTexture(GL_TEXTURE_2D,0);*/
}


void quadDrawCol(float x, float y, float width, float height, float red, float green, float blue, float alpha, float rot, float pivX, float pivY){
  glBindTexture(GL_TEXTURE_2D,0);
  glColor4f(red, green, blue, alpha);
  quadDrawCommon(x, y, width, height, rot, pivX, pivY);
}

