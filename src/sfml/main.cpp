extern "C"
{
  #include "app.h"
  #include "framework/input.h"
}

#ifdef __APPLE__
  #include <OpenGl/GL.h>
  #include <OpenGl/glu.h>
#else
  #ifdef WIN32
    #include <Windows.h>
  #endif
  #include <GL/gl.h>
  #include <GL/glu.h>
#endif

#ifndef WIN32
  #include <sys/time.h>
#endif

#ifdef __MACH__
#include <mach/clock.h>
#include <mach/mach.h>
#endif

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

typedef  sf::Event E;

const int SCREEN_WIDTH = 960; //screen dimesions
const int SCREEN_HEIGHT = 640;


static long _getTime(void) {
#ifdef WIN32
	return timeGetTime();
#else
    struct timespec ts;
  #ifdef __MACH__ // OS X does not have clock_gettime, use clock_get_time
    clock_serv_t cclock;
    mach_timespec_t mts;
    host_get_clock_service(mach_host_self(), CALENDAR_CLOCK, &cclock);
    clock_get_time(cclock, &mts);
    mach_port_deallocate(mach_task_self(), cclock);
    ts.tv_sec = mts.tv_sec;
    ts.tv_nsec = mts.tv_nsec;
  #else
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long)(ts.tv_sec*1000 + ts.tv_nsec/1000000);
  #endif
#endif
}


int main() {
  sf::Window wnd(sf::VideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, 32), "SFML OpenGL", sf::Style::Close);
  wnd.UseVerticalSync (true);

  appInit("assets.zip", 1);

  long lastTime = 0;
  while (wnd.IsOpened()) {
    E e;
    while (wnd.GetEvent(e)) {
      switch(e.Type){
        case E::Closed:
          wnd.Close();
          appDeinit();
          return 0;
        break;
        case E::MouseButtonPressed:
          setCursorPos(e.MouseButton.X, e.MouseButton.Y);
          setCursorDownState(1);
        break;
        case E::MouseButtonReleased:
          setCursorPos(e.MouseButton.X, e.MouseButton.Y);
          setCursorDownState(0);
        break;
        case E::MouseMoved:
          setCursorPos(e.MouseMove.X, e.MouseMove.Y);
        break;
        case E::KeyPressed:
          setKeyPressed(e.Key.Code);
        break;
        case E::KeyReleased:
          setKeyReleased(e.Key.Code);
        break;
      }
    }
    long curTime = _getTime();
    long delta =(curTime-lastTime);

    lastTime = curTime;

    if(appRender(delta, SCREEN_WIDTH, SCREEN_HEIGHT)){
      wnd.Close();
      break;
    }else{
      fflush(stdout);
      glError();
      wnd.Display();
    }
  }

  appDeinit();
  fflush(stdout);

  return 0;
}

