#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include "GLFW/glfw3.h"
#include "app.h"
#include "framework/input.h"

#ifdef __APPLE__
  #include <mach-o/dyld.h>
  #include <OpenGl/GL.h>
  #include <OpenGl/glu.h>
  #include <unistd.h>
  #include <libgen.h>
#else
  #ifdef WIN32
    #include <Windows.h>
  #endif
  #include <GL/gl.h>
  #include <GL/glu.h>
#endif

#include <time.h>

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


const int SCREEN_WIDTH = 960;
const int SCREEN_HEIGHT = 640;


static void error_callback(int error, const char* description) {
    fputs(description, stderr);
}

static void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
  int k = key-GLFW_KEY_A+'a';
  if(key>=GLFW_KEY_A && key<=GLFW_KEY_Z){
    if(action==GLFW_PRESS){
      setKeyPressed(k);
    }else if(action==GLFW_RELEASE){
      setKeyReleased(k);
    }
  }
}

static void char_callback(GLFWwindow* window, unsigned int ch) {
  setKeyPressed(ch);
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

int main(int argc, char **argv) {
  GLFWwindow* window;
  long curTime, delta, lastTime;

  glfwSetErrorCallback(error_callback);


  if (!glfwInit()){
    exit(EXIT_FAILURE);
  }

  glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
  /*glfwWindowHint(GLFW_SAMPLES, 8);*/

  window = glfwCreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Framework", NULL, NULL);
  if (!window) {
    glfwTerminate();
    exit(EXIT_FAILURE);
  }

  glfwMakeContextCurrent(window);
  glfwSetKeyCallback(window, key_callback);
  /*glfwSetCharCallback(window, char_callback);*/
  glfwSetMouseButtonCallback(window, mouse_callback);
  glfwSetCursorPosCallback(window, cursor_pos_callback);

  glfwSwapInterval(1);

  {
	  int width, height;
#if defined(__APPLE__) || defined(WIN32)
  #ifndef PATH_MAX
    #define PATH_MAX MAX_PATH
  #endif

  #define PATH_SIZE 2048

  const char *assets = "assets.zip";
  char execPath[PATH_SIZE+1];
  char fullPath[PATH_SIZE+1];
  char assetPath[PATH_SIZE+1];
#ifdef __APPLE__
    uint32_t pathSize = PATH_SIZE;
    int ret;
    pid_t pid; 

  if(_NSGetExecutablePath(execPath, &pathSize) == 0){
    printf("Exec path: %s\n", execPath);
  }else{
    printf("Exec path size needs to be: %u\n", pathSize);
    pid = getpid();
    ret = proc_pidpath (pid, execPath, sizeof(execPath));
    if ( ret <= 0 ) {
        fprintf(stderr, "PID %d: proc_pidpath ();\n", pid);
    } else {
        printf("proc %d: %s\n", pid, execPath);
    }
  }
  realpath(execPath, fullPath);
  printf("Real path: %s\n", fullPath);
  sprintf(assetPath, "%s/%s", dirname(fullPath), assets);
  #else
    char *filePartPtr;
    GetModuleFileName(0, execPath, 512);
	GetFullPathName(execPath, 512, fullPath, &filePartPtr);
	*filePartPtr = '\0';
	sprintf(assetPath, "%s%s", fullPath, assets);
	/*printf("%s", assetPath);*/
  #endif
#else
  const char *assetPath = "assets.zip";
#endif


  int screenW, screenH;
  glfwGetWindowSize(window, &screenW, &screenH);
  setScreenWidth(screenW);
  setScreenHeight(screenH);
  
  glfwGetFramebufferSize(window, &width, &height);
  appInit(width, height, assetPath, 1);
  }


  lastTime = _getTime();
  while (!glfwWindowShouldClose(window)) {
    curTime = _getTime();
    delta =(curTime-lastTime);
    lastTime = curTime;

    if(appRender(delta)){
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

