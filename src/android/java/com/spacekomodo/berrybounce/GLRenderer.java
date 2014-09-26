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



public class GLRenderer implements GLSurfaceView.Renderer {
  private static final String TAG = MainActivity.TAG;
  MainActivity activity;

  public GLRenderer (MainActivity activity) {
    Log.i(TAG,"GLRenderer created");
    this.activity = activity;
  }

  public void start() {
    Log.i(TAG,"GLRenderer start");
    paused = false;
  }

  public void stop() {
    Log.i(TAG,"GLRenderer stop");
    die = true;
  }


  boolean die = false;
  boolean paused = false;

  public void pause() {
    paused = true;
  }

  @Override
public void onSurfaceCreated(GL10 gl, EGLConfig config) {
    Log.i(TAG,"GLRenderer: SURFACE CREATED");
  }

  boolean inited = false;
  @Override
public void onSurfaceChanged(GL10 gl, int w, int h) {
    Log.i(TAG,"GLRenderer: SURFACE CHANGED");

    String apkFilePath = null;
    ApplicationInfo appInfo = null;
    PackageManager packMgmr = activity.getPackageManager();
    try {
      appInfo = packMgmr.getApplicationInfo("com.spacekomodo.berrybounce", 0);
    } catch (NameNotFoundException e) {
      e.printStackTrace();
      throw new RuntimeException("Unable to locate assets, aborting...");
    }
    apkFilePath = appInfo.sourceDir;
    if(!inited){
      nativeInit(apkFilePath);
      nativeResize(w, h);
      inited = true;
    }
  }

  boolean dead = false;

  @Override
public void onDrawFrame(GL10 gl) {
    if(dead || paused){
      return;
    }
    if(die) {
      nativeOnStop();
      dead = true;
    }
    else {
      switch (activity.chartboostDelegate.event){
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
      activity.chartboostDelegate.event = ChartboostDelegateImp.Event.none;
      nativeRender();
    }
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
      f.write(dataString.getBytes());
      f.close();
    } catch (Exception e) {
    }
  }
  private String dataStoreReload(){
    try{
      FileInputStream f = this.activity.openFileInput("datastore");
      Scanner scan = new Scanner(f);  
      scan.useDelimiter("\\Z");  
      return scan.next();  
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
    activity.runOnUiThread(new Runnable() {
      public void run() {
        activity.adFlakeLayout.setVisibility(enable==1?RelativeLayout.VISIBLE:RelativeLayout.GONE);
      }
    });
  }



  private static native void nativeOnStop();
  private static native void nativeInit(String apkPath);
  private static native void nativeResize(int w, int h);
  private native void nativeRender();
}
