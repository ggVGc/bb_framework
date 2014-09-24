package com.spacekomodo.berrybounce;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.app.Activity;
import android.content.Intent;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.WindowManager;
import android.view.Window;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ApplicationInfo;
import android.content.Context;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.util.Scanner;

import android.util.DisplayMetrics;
import android.util.Log;
import android.widget.AbsoluteLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.adflake.AdFlakeLayout;
import com.adflake.AdFlakeLayout.AdFlakeInterface;
import com.adflake.AdFlakeTargeting;
import com.adflake.util.AdFlakeUtil;
import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.Chartboost.CBAgeGateConfirmation;
import com.chartboost.sdk.ChartboostDelegate;
import com.chartboost.sdk.Model.CBError.CBClickError;
import com.chartboost.sdk.Model.CBError.CBImpressionError;
import com.chartboost.sdk.CBPreferences;
import com.facebook.UiLifecycleHelper;
import com.facebook.widget.FacebookDialog;


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
