package com.spacekomodo.framework;

import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.opengl.GLSurfaceView;


public class GLView extends GLSurfaceView {
  public GLRenderer renderer;


  private static native void nativeOnStop();
  public  static native void appSetPaused(int paused, int pauseAudio);
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
    GLRenderer.TouchEvent e = null;
    for(int i=0;i<renderer.eventPool.length;++i){
      if(!renderer.eventPool[i].alive){
        e = renderer.eventPool[i];
      }
    }
    if(e == null){
      Log.i(TAG, "WARNING: Skipped input event, no free events");
      return true;
    }
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
    renderer.eventQueue.add(e);
    return true;
  }

  public void stop(){
    renderer.inited = false;
    nativeOnStop();
  }

  public void setPreserveContext(boolean preserve){
    if (android.os.Build.VERSION.SDK_INT >= 11) {
      setPreserveEGLContextOnPause(preserve);
    }
  }

  @Override
  public void onResume() {
    Log.i(TAG,"GLView: Resume");
    super.onResume();
    setPreserveContext(false);
    appSetPaused(0, 0);
    // Clear events
    /*
    GLRenderer.TouchEvent e;
    while((e = renderer.eventQueue.poll())!=null){
      e.alive = false;
    }
    */
  }

  @Override
  public void onPause() {
    Log.i(TAG,"GLView: Pause");
    super.onPause();
    appSetPaused(1, 1);
    appSuspend();
  }
}
