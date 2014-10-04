package com.spacekomodo.berrybounce;

import android.opengl.GLSurfaceView;
import android.util.Log;
import android.view.MotionEvent;


public class GLView extends GLSurfaceView 
{
  private static final String TAG = MainActivity.TAG;
  public GLView(MainActivity activity) 
  {
    super(activity);
    Log.i(TAG,"GLView created");
    super.setEGLConfigChooser(8 , 8, 8, 8, 16, 0);
    renderer = new GLRenderer(activity);
    setRenderer(renderer);
  }

  @Override
  public boolean onTouchEvent(final MotionEvent event) 
  {
    int a = event.getActionMasked();
    GLRenderer.TouchEvent e = new GLRenderer.TouchEvent();
    int ai = event.getActionIndex();
    e.x = (int)event.getX(ai);
    e.y = (int)event.getY(ai);
    e.index = event.getPointerId(ai);
    if (a == MotionEvent.ACTION_DOWN || a==MotionEvent.ACTION_POINTER_DOWN) {
      e.down = true;
    }else if (a == MotionEvent.ACTION_UP || a==MotionEvent.ACTION_POINTER_UP){
      e.down = false;
    }else if(a == MotionEvent.ACTION_MOVE){
      e.onlyMove = true;
    }
    renderer.events.add(e);

  return true;
}


@Override
public void onResume() {
  super.onResume();
  Log.i(TAG,"GLView: Resume");
  renderer.start();
}

public void start() {
  Log.i(TAG,"GLView: Start");
  renderer.start();
}

public void stop() {
  renderer.stop();
}


public void pause() {
  Log.i(TAG,"GLView: Pause");
  renderer.pause();
}

public GLRenderer renderer;

private static native void nativeOnCursorDown(int ind);
private static native void nativeOnCursorUp(int ind);
private static native void nativeOnCursorMove(int ind, int x, int y);
}
