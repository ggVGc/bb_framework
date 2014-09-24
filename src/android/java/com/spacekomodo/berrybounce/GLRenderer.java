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

  public void onSurfaceCreated(GL10 gl, EGLConfig config) {
    Log.i(TAG,"GLRenderer: SURFACE CREATED");
  }

  boolean inited = false;
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

    

  private static native void nativeOnStop();
  private static native void nativeInit(String apkPath);
  private static native void nativeResize(int w, int h);
  private native void nativeRender();
}
