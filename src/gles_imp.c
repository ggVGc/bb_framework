#ifdef WIN32
#include <Windows.h>
#endif
#include <GLES/gl.h>

#ifdef __APPLE__
  #include <OpenGl/GL.h>
#else
  #undef __gl_h_
  #include <GL/gl.h>
#endif


void GL_APIENTRY glClearColorx(GLclampx red, GLclampx green, GLclampx blue, GLclampx alpha) {
    glClearColor((float)red/65636.0, (float)green/65636.0, (float)blue/65636.0, (float)alpha/65636.0);
}

void GL_APIENTRY glOrthof (GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar) {
  glOrtho(left, right, bottom, top, zNear, zFar);
}
