extern "C"
{
  #include "app.h"
  #include "framework/input.h"
}


#ifdef __APPLE__
  #include <OpenGl/GL.h>
  #include <OpenGl/glu.h>
#else
  #include <GL/gl.h>
  #include <GL/glu.h>
#endif

#include <sys/time.h>
#include <SFML/System.hpp>
#include <SFML/Window.hpp>

#include <cstdio>


#define glError() { \
    GLenum err = glGetError(); \
    while (err != GL_NO_ERROR) { \
        fprintf(stderr, "glError: %s caught at %s:%u\n", (char *)gluErrorString(err), __FILE__, __LINE__); \
        err = glGetError(); \
    } \
}

const int SCREEN_WIDTH = 800; //screen dimesions
const int SCREEN_HEIGHT = 480;

  static long
_getTime(void)
{
  struct timeval  now;

  gettimeofday(&now, NULL);
  return (long)(now.tv_sec*1000 + now.tv_usec/1000);
}


int main()
{
  sf::Window wnd(sf::VideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, 32), "SFML OpenGL", sf::Style::Close);

  appInit("assets.zip", 1);

  long lastTime = 0;
  while (wnd.IsOpened())
  {
    sf::Event e;
    while (wnd.GetEvent(e))
    {
      if (e.Type == sf::Event::Closed)
        wnd.Close();

      if (e.Type == sf::Event::MouseButtonPressed)
      {
          setCursorPos(e.MouseButton.X, e.MouseButton.Y);
          setCursorDownState(1);
      }
      else if(e.Type == sf::Event::MouseButtonReleased)
      {
          setCursorPos(e.MouseButton.X, e.MouseButton.Y);
          setCursorDownState(0);
      }
      else if (e.Type == sf::Event::MouseMoved)
      {
        setCursorPos(e.MouseMove.X, e.MouseMove.Y);
      }
    }
    long curTime = _getTime();
    long delta = curTime-lastTime;
    lastTime = curTime;

    appRender(delta, SCREEN_WIDTH, SCREEN_HEIGHT);
    glError();
    wnd.Display();
  }

  appDeinit();

  return 0;
}

