package com.spacekomodo.berrybounce;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.CBLocation;
import com.chartboost.sdk.Libraries.CBLogging.Level;
import com.facebook.UiLifecycleHelper;
import com.facebook.widget.FacebookDialog;


public class MainActivity extends Activity{
  public static final String TAG = "MainActivity";

  private GLView view;
  //private boolean facebookAvailable = false;

  public IAP iap;
  public ChartboostDelegateImp chartboostDelegate;
  private UiLifecycleHelper uiHelper;

  static {
    System.loadLibrary("jumpz_framework");
  }

  public MainActivity(){}

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Log.i(TAG,"Activity: Create");
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    setScreenRefreshRate((int)((WindowManager) getSystemService(WINDOW_SERVICE)).getDefaultDisplay().getRefreshRate());

    iap = new IAP(this);

    view = new GLView(this);
    setContentView(view);
    
    chartboostDelegate = new ChartboostDelegateImp();
    Chartboost.startWithAppId(this, AppConfig.chartboost.appId, AppConfig.chartboost.appSignature);
    Chartboost.setLoggingLevel(Level.ALL);
    Chartboost.setDelegate(chartboostDelegate);
    Chartboost.onCreate(this);

    uiHelper = new UiLifecycleHelper(this, null);
    uiHelper.onCreate(savedInstanceState);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    Log.i(TAG, "onActivityResult");
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
    Chartboost.setImpressionsUseActivities(true);
    Chartboost.onStart(this);
    chartboostDelegate.onStart();
    //facebookAvailable = FacebookDialog.canPresentShareDialog(getApplicationContext(),  FacebookDialog.ShareDialogFeature.SHARE_DIALOG);
  }

  public void prepareInterstitial(){
    //Chartboost.cacheInterstitial(CBLocation.LOCATION_DEFAULT);
  }

  public void showInterstitial(){
      if(Chartboost.hasInterstitial(CBLocation.LOCATION_DEFAULT)){
        Log.i(TAG, "Showing caches interstitial");
          Chartboost.showInterstitial(CBLocation.LOCATION_DEFAULT);
      }else{
          Log.i(TAG, "Cacheing interstitial");
          chartboostDelegate.cacheing = true;
          Chartboost.cacheInterstitial(CBLocation.LOCATION_DEFAULT);
          Log.i(TAG, "Adding gailed display event");
          chartboostDelegate.events.add(new Integer(ChartboostDelegateImp.Event.failedDisplay));
      }
  }


  public native void setScreenRefreshRate(int rate);
  public native void interstitialClosed();
  public native void interstitialDisplayed();
  public native void interstitialFailedDisplay();

 public int facebookIsShareAvailable(){
    //return facebookAvailable?1:0;
    //return FacebookDialog.canPresentShareDialog(getApplicationContext(),  FacebookDialog.ShareDialogFeature.SHARE_DIALOG)?1:0;
    return 0;
  }

  public void facebookPost(int score){
    final MainActivity self = this;
    Log.i(TAG,"Activity: Facebook post");
    Log.i(TAG,"Activity: RUNNING Facebook post");
    if (facebookIsShareAvailable()!=0){
      FacebookDialog shareDialog = new FacebookDialog.ShareDialogBuilder(self)
            //.setName(AppConfig.facebook.name)
            .setName(score+" Berries!")
            .setCaption(AppConfig.facebook.caption)
            .setDescription(AppConfig.facebook.description)
            .setPicture(AppConfig.facebook.pictureUrl)
            .setApplicationName("Berry Bounce")
            .setLink(AppConfig.facebook.link)
            .build();
        uiHelper.trackPendingDialogCall(shareDialog.present());
    }
  }
  @Override
  public void onRestart() {
    super.onRestart();
    Log.i(TAG,"Activity: Restart");
  }


  @Override
  protected void onPause() {
    super.onPause();
    uiHelper.onPause();
    Log.i(TAG,"Activity: Pause");
    Chartboost.onPause(this);
    view.onPause();
  }

  @Override
  protected void onResume() {
    super.onResume();
    Log.i(TAG,"Activity: Resume");
    uiHelper.onResume();
    Chartboost.onResume(this);
    view.onResume();
  }


  @Override
  protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    uiHelper.onSaveInstanceState(outState);
  }

  @Override
  protected void onStop() {
    view.stop();
    super.onStop();
    Log.i(TAG,"Activity: Stop");
    Chartboost.onStop(this);
  }


  @Override
  protected void onDestroy() {
    super.onDestroy();
    Log.i(TAG,"Activity: Destroy");
    uiHelper.onDestroy();
    Chartboost.onDestroy(this);
  }

  @Override
  public void onBackPressed() {
    if (Chartboost.onBackPressed()){
      return;
    }else{
      super.onBackPressed();
    }
  }
}


