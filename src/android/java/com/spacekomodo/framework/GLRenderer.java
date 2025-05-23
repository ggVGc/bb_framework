package com.spacekomodo.framework;

import com.purplebrain.giftiz.sdk.GiftizSDK;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Scanner;

import java.lang.Thread;

import android.widget.RelativeLayout;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.Log;
import java.util.concurrent.ConcurrentLinkedQueue;
import android.os.Handler;
import android.os.Looper;

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
  public ConcurrentLinkedQueue<GLRenderer.TouchEvent> eventQueue;
  private boolean shouldPause = false;


  public boolean inited = false;
  boolean needsReload = false;

  private static native void nativeOnCursorDown(int ind);
  private static native void nativeOnCursorUp(int ind);
  private static native void nativeOnCursorMove(int ind, int x, int y);
  private static native void nativeInit();
  private static native void nativeResize(int w, int h, int wasSuspended);
  private static native void appGraphicsReload(int w, int h);
  private native void nativeRender();


  GLView parentView;

  public GLRenderer (MainActivity activity, GLView  parent) {
    Log.i(TAG,"GLRenderer created");
    parentView = parent;
    this.activity = activity;
    for(int i=0;i<MAX_EVENTS;++i){
      eventPool[i] = new GLRenderer.TouchEvent();
    }
    eventQueue = new ConcurrentLinkedQueue<GLRenderer.TouchEvent>();
  }

  @Override
  public void onSurfaceCreated(GL10 gl, EGLConfig config) {
    Log.i(TAG,"GLRenderer: Surface created");
    needsReload = true;
  }

  @Override
  public void onSurfaceChanged(GL10 gl, int w, int h) {
    Log.i(TAG,"GLRenderer: Surface changed");


    if(!inited){
      nativeInit();
      nativeResize(w, h, 1);
      inited = true;
      needsReload = false;
    }else if(needsReload){
      needsReload = false;
      appGraphicsReload(w, h);
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
    if(shouldPause){
      shouldPause = false;
      GLView.appSetPaused(1, 0);
    }

    /*
    if(activity.chartboostDelegate.events.size()!=0){
      int e = activity.chartboostDelegate.events.remove().intValue();
    */
    if(activity.adBuddizDel.events.size()!=0){
      int e = activity.adBuddizDel.events.remove().intValue();
      Log.i(TAG, "Handling chartboost event: "+e);
      switch (e){
        case AdMediator.Event.closed:
          activity.interstitialClosed();
          break;
        case AdMediator.Event.clicked:
          activity.interstitialClosed();
          break;
        case AdMediator.Event.failedDisplay:
          activity.interstitialFailedDisplay();
          break;
        case AdMediator.Event.displayed:
          activity.interstitialDisplayed();
          break;
      }
    }


    // TODO: If we handle all events here, we need to make sure the framework input
    // handles it, and detects a 'click', even if a down and up happens during
    // the same rendered frame. This is not currently the case, hence use an if
    // and handle only one event per frame
    GLRenderer.TouchEvent e = eventQueue.poll();
    while(e != null){
      //Log.i(TAG, "Processing input event");
      processTouchEvent(e);
      e.alive = false;
      e = eventQueue.poll();
    }
    nativeRender();
  }
  
  public void onInterstitialShow(){
    shouldPause = true;
  }

  private void facebookPost(final int score){
    activity.runOnUiThread(new Runnable() {
      public void run() {
        activity.facebookPost(score);
      }
    });
  }

  private void showInterstitial(){
    this.activity.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        Log.i(TAG, "Showing interstitial on main thread");
        parentView.setPreserveContext(true);
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

  private static void dataStoreCommit(final String dataString){
    Handler mainHandler = new Handler(Looper.getMainLooper());
    mainHandler.post(new Runnable() {
      public void run() {
      try{
        FileOutputStream f = MainActivity.appContext.openFileOutput("datastore", Context.MODE_PRIVATE);
        f.write(dataString.getBytes());
        f.close();
      } catch (Exception e) {
        Log.e(TAG, "Failed writing to data store");
      }
    }});
  }

  private String dataStoreReload(){
    try{
      FileInputStream f = this.activity.openFileInput("datastore");
      Scanner scan = new Scanner(f);  
      scan.useDelimiter("\\Z");  
      StringBuilder sb = new StringBuilder();
      while(scan.hasNext()){
        String ret = scan.next();
        if(ret != null){
          sb.append(ret);
        }
      }
      return sb.toString();
    } catch (Exception e) {
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
    if(activity==null || activity.iap==null || !activity.iap.isAvailable()){
      IAP.onPurchaseComplete(0);
    }else{
      GLView.appSetPaused(1, 1);
      activity.runOnUiThread(new Runnable() {
        public void run() {
          parentView.setPreserveContext(true);
          activity.iap.purchaseProduct(id);
        }
      });
    }
  }

  public String getProductPrice(String id){
    if(activity == null || activity.iap == null){
      return "";
    }
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
