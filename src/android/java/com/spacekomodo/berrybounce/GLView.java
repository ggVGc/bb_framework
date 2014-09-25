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
    int a = event.getAction();
    if (a == MotionEvent.ACTION_DOWN) 
    {
      nativeOnCursorMove((int)event.getX(), (int)event.getY());
      nativeOnCursorDown();
    }
    else if (a == MotionEvent.ACTION_UP)
      nativeOnCursorUp();
    else if(a == MotionEvent.ACTION_MOVE)
      nativeOnCursorMove((int)event.getX(), (int)event.getY());

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

  GLRenderer renderer;

  private static native void nativeOnCursorDown();
  private static native void nativeOnCursorUp();
  private static native void nativeOnCursorMove(int x, int y);
}
