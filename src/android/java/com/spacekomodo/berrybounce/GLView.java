package com.spacekomodo.berrybounce;

import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.opengl.GLSurfaceView;


public class GLView extends GLSurfaceView {
  public GLRenderer renderer;

  private int nextEventIndex = 0;

  private static native void nativeOnStop();
  private static native void appSetPaused(int paused);
  private static native void appSuspend();

  private static final String TAG = MainActivity.TAG;
  public GLView(MainActivity activity) {
    super(activity);
    Log.i(TAG,"GLView created");
    super.setEGLConfigChooser(8 , 8, 8, 8, 16, 0);
    renderer = new GLRenderer(activity, this);
    setRenderer(renderer);
  }


  @Override
  public boolean onTouchEvent(final MotionEvent event) {
    int a = event.getActionMasked();
    if(renderer.eventPool[nextEventIndex].alive){
      return true;
    }
    GLRenderer.TouchEvent e = renderer.eventPool[nextEventIndex];
    e.alive = true;

    int ai = event.getActionIndex();
    e.x = (int)event.getX(ai);
    e.y = (int)event.getY(ai);
    e.onlyMove = false;
    e.index = event.getPointerId(ai);
    if (a == MotionEvent.ACTION_DOWN || a==MotionEvent.ACTION_POINTER_DOWN) {
      e.down = true;
    }else if (a == MotionEvent.ACTION_UP || a==MotionEvent.ACTION_POINTER_UP){
      e.down = false;
    }else if(a == MotionEvent.ACTION_MOVE){
      e.onlyMove = true;
    }
    nextEventIndex++;
    if(nextEventIndex>=GLRenderer.MAX_EVENTS){
      nextEventIndex = 0;
    }
    return true;
  }

  public void stop(){
    renderer.inited = false;
    nativeOnStop();
  }

  @Override
  public void onResume() {
    Log.i(TAG,"GLView: Resume");
    super.onResume();
    setPreserveEGLContextOnPause(false);
    appSetPaused(0);
  }

  @Override
  public void onPause() {
    Log.i(TAG,"GLView: Pause");
    super.onPause();
    appSetPaused(1);
    appSuspend();
  }
}
