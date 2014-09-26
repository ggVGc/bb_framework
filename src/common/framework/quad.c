#include <string.h>
#include <GLES/gl.h>
#include "quad.h"

#define MAX_QUADS 250
#define BUF_SIZE MAX_QUADS*12

static int drawCallCount;
static GLuint texHandle;
static int noLastHandle;
static int quadCount;



static GLfloat vertices[12] = {
  0, 0,
  1, 0,
  0, 1,
  1, 0,
  1, 1,
  0, 1
};

static GLfloat tmpVerts[12];

static GLfloat vertexBuf[BUF_SIZE];
static GLfloat texCoordBuf[BUF_SIZE];


void quadGlobalInit(){
  int i;
  glEnableClientState(GL_VERTEX_ARRAY);
  noLastHandle = 1;
  quadCount = 0;
  drawCallCount = 0;
  texHandle = (GLuint)-1;
  for(i=0;i<BUF_SIZE;++i){
    vertexBuf[i] = texCoordBuf[i] = 0;
  }
}

void quadBeginFrame(){
  drawCallCount = 0;
  quadCount = 0;
}

void quadEndFrame(){
  quadFlush();
}

int getDrawCallCount(){
  return drawCallCount;
}

void quadFlush(){
  if(quadCount>0){
    glBindTexture(GL_TEXTURE_2D, texHandle);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoordBuf);
    glVertexPointer(2, GL_FLOAT, 0, vertexBuf);
    glLoadIdentity();
    glDrawArrays(GL_TRIANGLES, 0, quadCount*6);
    ++drawCallCount;
    quadCount = 0;
  }
}


void transformVertices(Matrix2 *m, GLfloat *inPoints, GLfloat *outPoints){
  int i;
  for(i=0;i<6;++i){
    GLfloat x = inPoints[i*2];
    GLfloat y = inPoints[i*2+1];
    outPoints[i*2] =x*m->a+y*m->c+m->tx;
    outPoints[i*2+1]=x*m->b+y*m->d+m->ty;
  }
}


void quadDrawTexCol(Texture* tex, Matrix2 *m, double r, double g, double b, double alpha){
  int notFullCol = (r!=1||g!=1||b!=1||alpha != 1);
  if(notFullCol||noLastHandle || tex->data->glTexHandle != texHandle || quadCount>=MAX_QUADS){
    quadFlush();
    glColor4f(r*alpha, g*alpha, b*alpha, alpha);
    texHandle = tex->data->glTexHandle;
  }

  transformVertices(m, vertices, tmpVerts);
  memcpy(&vertexBuf[12*quadCount], tmpVerts, sizeof(GLfloat)*12);
  memcpy(&texCoordBuf[12*quadCount], tex->uvCoords, sizeof(GLfloat)*12);
  ++quadCount;

  noLastHandle = notFullCol;
}

void quadDrawTexAlpha(Texture* tex, Matrix2 *m, double alpha){
  quadDrawTexCol(tex, m, 1, 1, 1, alpha);
}

void quadDrawTex(Texture* tex, Matrix2 *m){
  quadDrawTexAlpha(tex, m, 1);
}

void quadDrawCol(float x, float y, float width, float height, float red, float green, float blue, float alpha, float rot, float pivX, float pivY){
  quadFlush();
  glBindTexture(GL_TEXTURE_2D,0);
  glColor4f(red, green, blue, alpha);

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

