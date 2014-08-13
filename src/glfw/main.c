#include <stdlib.h>
#include <stdio.h>
#include "GLFW/glfw3.h"
#include "app.h"
#include "framework/input.h"

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
  #include <time.h>
#endif

#ifdef __MACH__
  #include <mach/clock.h>
  #include <mach/mach.h>
#endif


#define glError() { \
    GLenum err = glGetError(); \
    while (err != GL_NO_ERROR) { \
        fprintf(stderr, "glError: %s caught at %s:%u\n", (char *)gluErrorString(err), __FILE__, __LINE__); \
        err = glGetError(); \
    } \
}

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
  #endif
    return (long)(ts.tv_sec*1000 + ts.tv_nsec/1000000);
#endif
}


const int SCREEN_WIDTH = 960; //screen dimesions
const int SCREEN_HEIGHT = 640;


static void error_callback(int error, const char* description) {
    fputs(description, stderr);
}

static void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
  if(key>=GLFW_KEY_A && key<=GLFW_KEY_Z){
    if (key == GLFW_KEY_Q && action == GLFW_PRESS)
      if(action==GLFW_KEY_DOWN){
          setKeyPressed(key);
      }else if(action==GLFW_KEY_UP){
          setKeyPressed(key);
      }
      glfwSetWindowShouldClose(window, GL_TRUE);
  }
}

static void mouse_callback(GLFWwindow* window, int button, int action, int mods) {
  double x, y;
  glfwGetCursorPos(window, &x, &y);
  setCursorPos(x, y);
  switch(action){
    case GLFW_PRESS:
      setCursorDownState(1);
    break;
    case GLFW_RELEASE:
      setCursorDownState(0);
    break;
  }
}

static void cursor_pos_callback(GLFWwindow* window, double x, double y) {
  setCursorPos(x, y);
}

int main(void) {
  GLFWwindow* window;

  glfwSetErrorCallback(error_callback);


  if (!glfwInit())
    exit(EXIT_FAILURE);

  window = glfwCreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Framework", NULL, NULL);
  if (!window) {
    glfwTerminate();
    exit(EXIT_FAILURE);
  }

  glfwMakeContextCurrent(window);
  glfwSetKeyCallback(window, key_callback);
  glfwSetMouseButtonCallback(window, mouse_callback);
  glfwSetCursorPosCallback(window, cursor_pos_callback);

  glfwSwapInterval(1);

  appInit("assets.zip", 1);

  long lastTime = 0;
  while (!glfwWindowShouldClose(window)) {
    float ratio;
    int width, height;

    glfwGetFramebufferSize(window, &width, &height);

    long curTime = _getTime();
    long delta =(curTime-lastTime);
    lastTime = curTime;

    if(appRender(delta, SCREEN_WIDTH, SCREEN_HEIGHT)){
      glfwSetWindowShouldClose(window, GL_TRUE);
      break;
    }else{
      fflush(stdout);
      glError();
      glfwSwapBuffers(window);
      glfwPollEvents();
    }
  }
  appDeinit();
  fflush(stdout);

  glfwDestroyWindow(window);
  glfwTerminate();
  exit(EXIT_SUCCESS);
}

