package com.jumpz.frameworktest;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.WindowManager;
import android.view.Window;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ApplicationInfo;

public class FrameworkTest extends Activity
{
  static
  {
    System.loadLibrary("jumpz_framework");
  }

  @Override
    public void onCreate(Bundle savedInstanceState)
    {
      super.onCreate(savedInstanceState);
      System.out.println("ACTIVITY: Create");
      requestWindowFeature(Window.FEATURE_NO_TITLE);
      setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
      getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
      view = new GLView(this);
      setContentView(view);
    }

  @Override
    public void onStart()
    {
      super.onStart();
      System.out.println("ACTIVITY: Start");
      view.start();
    }

  @Override
    public void onRestart()
    {
      super.onRestart();
      System.out.println("ACTIVITY: Restart");
    }


  @Override
    protected void onPause() {
      super.onPause();
      System.out.println("ACTIVITY: PAUSE");
      view.onPause();
    }

  @Override
    protected void onResume() {
      super.onResume();
      System.out.println("ACTIVITY: RESUME");
      //view.onResume();
    }

  @Override
    //protected void onDestroy() {
    protected void onStop() {
      super.onStop();
      System.out.println("ACTIVITY: STOP");
      view.stop();
    }


  @Override
    protected void onDestroy() {
      super.onDestroy();
      System.out.println("ACTIVITY: DESTROY");
    }
  private GLView view;


}




class GLView extends GLSurfaceView 
{


  public GLView(Context context) 
  {
    super(context);
    System.out.println("GLView created");
    renderer = new GLRenderer(context);
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

  public void start()
  {
    renderer.start();
  }

  public void stop()
  {
    renderer.stop();
  }


  public void onPause()
  {
    System.out.println("GLView: PAUSE");
    renderer.pause();
  }

  GLRenderer renderer;


  private static native void nativeOnCursorDown();
  private static native void nativeOnCursorUp();
  private static native void nativeOnCursorMove(int x, int y);
}

class GLRenderer implements GLSurfaceView.Renderer 
{
  private Context context;
  

	public GLRenderer (Context context) {
    System.out.println("GLRenderer created");
		this.context = context;
	}

  public void start()
  {
  }

  public void stop()
  {
    die = true;
  }


    boolean die = false;

    public void pause()
    {
      die = true;
    }

  public void onSurfaceCreated(GL10 gl, EGLConfig config) 
  {
    System.out.println("GLRenderer: SURFACE CREATED");
    // return apk file path (or null on error)
    //String apkFilePath = null;
    //ApplicationInfo appInfo = null;
    //PackageManager packMgmr = context.getPackageManager();
    //try {
      //appInfo = packMgmr.getApplicationInfo("com.jumpz.frameworktest", 0);
    //} catch (NameNotFoundException e) {
      //e.printStackTrace();
      //throw new RuntimeException("Unable to locate assets, aborting...");
    //}
    //apkFilePath = appInfo.sourceDir;

    //nativeInit(apkFilePath);
  }

  public void onSurfaceChanged(GL10 gl, int w, int h) 
  {
    System.out.println("GLRenderer: SURFACE CHANGED");

    String apkFilePath = null;
    ApplicationInfo appInfo = null;
    PackageManager packMgmr = context.getPackageManager();
    try {
      appInfo = packMgmr.getApplicationInfo("com.jumpz.frameworktest", 0);
    } catch (NameNotFoundException e) {
      e.printStackTrace();
      throw new RuntimeException("Unable to locate assets, aborting...");
    }
    apkFilePath = appInfo.sourceDir;

    nativeInit(apkFilePath);


    nativeResize(w, h);
  }

  boolean dead = false;

  public void onDrawFrame(GL10 gl) 
  {
    if(dead)
      return;
    if(die)
    {
      nativeOnStop();
      dead = true;
    }
    else
    {
      nativeRender();
    }
  }



  private static native void nativeOnStop();
  private static native void nativeInit(String apkPath);
  private static native void nativeResize(int w, int h);
  private static native void nativeRender();
}
