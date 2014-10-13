package com.spacekomodo.berrybounce;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Scanner;

import android.widget.RelativeLayout;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.opengl.GLSurfaceView;
import android.util.Log;

import java.util.LinkedList;


public class GLRenderer implements GLSurfaceView.Renderer {
  public static class TouchEvent{
    public boolean alive = false;
    public boolean down = false;
    public int x;
    public int y;
    public int index;
    public boolean onlyMove = false;
  }
  private static final String TAG = MainActivity.TAG;
  MainActivity activity;

  public static final  int MAX_EVENTS = 100;
  public GLRenderer.TouchEvent[] eventPool = new GLRenderer.TouchEvent[100];

  int lastEventIndex = 0;
  boolean startedOnce = false;

  /*
  public boolean shouldPause = false;
  public boolean shouldResume = false;
  */



  private static native void appSetPaused(int paused);
  private static native void nativeOnCursorDown(int ind);
  private static native void nativeOnCursorUp(int ind);
  private static native void nativeOnCursorMove(int ind, int x, int y);
  private static native void nativeInit(String apkPath);
  private static native void nativeResize(int w, int h, int wasSuspended);
  private native void nativeRender();

  public GLRenderer (MainActivity activity) {
    Log.i(TAG,"GLRenderer created");
    this.activity = activity;
    for(int i=0;i<MAX_EVENTS;++i){
      eventPool[i] = new GLRenderer.TouchEvent();
    }
  }

  @Override
  public void onSurfaceCreated(GL10 gl, EGLConfig config) {
    Log.i(TAG,"GLRenderer: Surface created");
  }

  public boolean inited = false;
  @Override
  public void onSurfaceChanged(GL10 gl, int w, int h) {
    Log.i(TAG,"GLRenderer: Surface changed");

    String apkFilePath = null;
    ApplicationInfo appInfo = null;
    PackageManager packMgmr = activity.getPackageManager();
    try {
      appInfo = packMgmr.getApplicationInfo(AppConfig.packageName, 0);
    } catch (NameNotFoundException e) {
      e.printStackTrace();
      throw new RuntimeException("Unable to locate assets, aborting...");
    }
    apkFilePath = appInfo.sourceDir;
    if(!inited){
      nativeInit(apkFilePath);
      nativeResize(w, h, startedOnce?1:0);
      startedOnce = true;
      inited = true;
    }
  }

  void processTouchEvent(TouchEvent e){
    nativeOnCursorMove(e.index, e.x, e.y);
    if(!e.onlyMove){
      if(e.down){
        nativeOnCursorDown(e.index);
      }else{
        nativeOnCursorUp(e.index);
      }
    }
  }


  @Override
  public void onDrawFrame(GL10 gl) {
    if(activity.chartboostDelegate.events.size()!=0){
      int e = activity.chartboostDelegate.events.remove().intValue();
      Log.i(TAG, "Handling chartboost event: "+e);
      switch (e){
        case ChartboostDelegateImp.Event.closed:
          activity.interstitialClosed();
          break;
        case ChartboostDelegateImp.Event.failedDisplay:
          activity.interstitialFailedDisplay();
          break;
        case ChartboostDelegateImp.Event.displayed:
          activity.interstitialDisplayed();
          break;
      }
    }

    GLRenderer.TouchEvent e = eventPool[lastEventIndex];
    while(e.alive){
      processTouchEvent(e);
      lastEventIndex++;
      if(lastEventIndex>=MAX_EVENTS){
        lastEventIndex = 0;
      }
      e.alive = false;
      e = eventPool[lastEventIndex];
    }
    /*
    if(shouldPause){
      shouldPause = false;
      appSetPaused(1);
    }else if(shouldResume){
      shouldResume = false;
      appSetPaused(0);
    }
    */
    nativeRender();
  }

  private void facebookPost(){
    this.activity.facebookPost();
  }
  private void showInterstitial(){
    this.activity.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        activity.showInterstitial();
      }
    });
  }
  private void prepareInterstitial(){
    this.activity.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        activity.prepareInterstitial();
      }
    });
  }

  private void dataStoreCommit(String dataString){
    try{
      FileOutputStream f = this.activity.openFileOutput("datastore", Context.MODE_PRIVATE);
      Log.i(TAG, "Commiting: "+dataString);
      f.write(dataString.getBytes());
      f.close();
    } catch (Exception e) {
      Log.e(TAG, "Failed writing to data store");
    }
  }
  private String dataStoreReload(){
    try{
      FileInputStream f = this.activity.openFileInput("datastore");
      Scanner scan = new Scanner(f);  
      scan.useDelimiter("\\Z");  
      String ret =  scan.next();  
      if(ret!=null){
        Log.i(TAG, "Loaded: "+ret);
        return ret;
      }else{
        Log.e(TAG, "Failed reading data store");
        return "";
      }
    } catch (Exception e) {
      Log.e(TAG, "Failed reading data store");
      return "";
    }
  }

  public int facebookIsShareAvailable(){
    return activity.facebookIsShareAvailable();
  }

  public int userOwnsProduct(String id){
    if(activity.iap.userOwnsProduct(id)){
      return 1;
    }else{
      return 0;
    }
  }
  public void purchaseProduct(final String id){
    activity.runOnUiThread(new Runnable() {
      public void run() {
        activity.iap.purchaseProduct(id);
      }
    });
  }

  public String getProductPrice(String id){
    return activity.iap.getProductPrice(id);
  }


  void setBannersEnabled(final int enable){
    Log.i(TAG, "Setting banner visibility: "+enable);
    /*
       activity.runOnUiThread(new Runnable() {
       public void run() {
       activity.adFlakeLayout.setVisibility(enable==1?RelativeLayout.VISIBLE:RelativeLayout.GONE);
       }
       });
       */
  }

}
