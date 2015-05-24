#ifndef C2NIM

#ifndef TIME_H_AHU9LJXW
#define TIME_H_AHU9LJXW

  #ifdef WIN32
    #include <Windows.h>
  #endif

#include <time.h>

#ifdef __MACH__
  #include <mach/clock.h>
  #include <mach/mach.h>
#endif


static time_t  _getTime(void) {
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
    return ts.tv_sec*1000 + ts.tv_nsec/1000000;
#endif
}


#endif /* end of include guard: TIME_H_AHU9LJXW */

#endif
