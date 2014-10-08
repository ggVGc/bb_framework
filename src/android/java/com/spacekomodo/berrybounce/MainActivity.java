package com.spacekomodo.berrybounce;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.chartboost.sdk.CBPreferences;
import com.chartboost.sdk.Chartboost;
import com.facebook.UiLifecycleHelper;
import com.facebook.widget.FacebookDialog;


public class MainActivity extends Activity{
  public static final String TAG = "MainActivity";

  private GLView view;

  public IAP iap;
  public ChartboostDelegateImp chartboostDelegate;

  static {
    System.loadLibrary("jumpz_framework");
  }
  private Chartboost cb;
  private UiLifecycleHelper uiHelper;

  public MainActivity(){
  }

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    Log.i(TAG,"Activity: Create");
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

    iap = new IAP(this);

    requestWindowFeature(Window.FEATURE_NO_TITLE);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    view = new GLView(this);
    setContentView(view);

    cb = Chartboost.sharedChartboost();
    chartboostDelegate = new ChartboostDelegateImp(cb);
    cb.onCreate(this, AppConfig.chartboost.appId, AppConfig.chartboost.appSignature, chartboostDelegate);

    uiHelper = new UiLifecycleHelper(this, null);
    uiHelper.onCreate(savedInstanceState);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (!iap.onActivityResult(requestCode, resultCode, data)) {
      super.onActivityResult(requestCode, resultCode, data);
      uiHelper.onActivityResult(requestCode, resultCode, data, new FacebookDialog.Callback() {
        @Override
        public void onError(FacebookDialog.PendingCall pendingCall, Exception error, Bundle data) {
          Log.e("Activity", String.format("Error: %s", error.toString()));
        }

        @Override
        public void onComplete(FacebookDialog.PendingCall pendingCall, Bundle data) {
          Log.i("Activity", "Success!");
        }
      });
    }

  }

  @Override
  public void onStart() {
    super.onStart();
    Log.i(TAG,"Activity: Start");
    CBPreferences.getInstance().setImpressionsUseActivities(true);
    this.cb.onStart(this);
    chartboostDelegate.onStart();
  }

  public void prepareInterstitial(){
    this.cb.cacheInterstitial();
  }

  public void showInterstitial(){
	  if(this.cb.hasCachedInterstitial()){
		  this.cb.showInterstitial();
	  }else{
		  chartboostDelegate.cacheing = true;
		  this.cb.cacheInterstitial();
		  chartboostDelegate.events.add(new Integer(ChartboostDelegateImp.Event.closed));
	  }
  }


  public native void interstitialClosed();
  public native void interstitialDisplayed();
  public native void interstitialFailedDisplay();

  public int facebookIsShareAvailable(){
   
      return 0;
     }

  public void facebookPost(){
    Log.i(TAG,"Activity: Facebook post");
   
  }

  @Override
  public void onRestart() {
    super.onRestart();
    Log.i(TAG,"Activity: Restart");
  }


  @Override
  protected void onPause() {
    super.onPause();
    Log.i(TAG,"Activity: Pause");
    uiHelper.onPause();
    view.onPause();
  }

  @Override
  protected void onResume() {
    super.onResume();
    Log.i(TAG,"Activity: Resume");
    view.onResume();
    uiHelper.onResume();
  }

  @Override
  protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    uiHelper.onSaveInstanceState(outState);
  }

  @Override
  protected void onStop() {
    super.onStop();
    Log.i(TAG,"Activity: Stop");
    this.cb.onStop(this);
  }


  @Override
  protected void onDestroy() {
    super.onDestroy();
    Log.i(TAG,"Activity: Destroy");
    this.cb.onDestroy(this);
    uiHelper.onDestroy();
  }

  @Override
  public void onBackPressed() {
    if (this.cb.onBackPressed()){
      // If a Chartboost view exists, close it and return
      return;
    }else{
      // If no Chartboost view exists, continue on as normal
      super.onBackPressed();
    }
  }
}


