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

/*#define w  100.0*/
/*#define h  100.0*/


/*static GLfloat vertices[12] = {*/
  /*0, h,*/
  /*w, h,*/
  /*0, 0, */
  /*w, h, */
  /*w, 0, */
  /*0, 0*/
/*};*/
    /*b->quadVertices[0] = 0; b->quadVertices[1] = h;*/
    /*b->quadVertices[2] = w; b->quadVertices[3] = h;*/
    /*b->quadVertices[4] = 0; b->quadVertices[5] = 0;*/
    /*b->quadVertices[6] = w; b->quadVertices[7] = h;*/
    /*b->quadVertices[8] = w; b->quadVertices[9] = 0;*/
    /*b->quadVertices[10] = 0; b->quadVertices[11] = 0;*/

void quadDraw(float x, float y, float width, float height, Texture* tex, float rot, float pivX, float pivY)
{
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glBindTexture(GL_TEXTURE_2D, tex->data->glTexHandle);
  glTexCoordPointer(2, GL_FLOAT, 0, tex->uvCoords);
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

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
}

