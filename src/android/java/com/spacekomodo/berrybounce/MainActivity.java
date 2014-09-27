package com.spacekomodo.berrybounce;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.adflake.AdFlakeLayout;
import com.adflake.AdFlakeLayout.AdFlakeInterface;
import com.adflake.AdFlakeTargeting;
import com.adflake.util.AdFlakeUtil;
import com.chartboost.sdk.CBPreferences;
import com.chartboost.sdk.Chartboost;
import com.facebook.UiLifecycleHelper;
import com.facebook.widget.FacebookDialog;

public class MainActivity extends Activity implements AdFlakeInterface {
  public static final String TAG = "MainActivity";

  public IAP iap;
  public ChartboostDelegateImp chartboostDelegate;
  public AdFlakeLayout adFlakeLayout;

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

    iap = new IAP(this);

    requestWindowFeature(Window.FEATURE_NO_TITLE);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    RelativeLayout layout = new RelativeLayout(this);
    view = new GLView(this);
    setContentView(layout);

    cb = Chartboost.sharedChartboost();
    chartboostDelegate = new ChartboostDelegateImp(cb);
    cb.onCreate(this, AppConfig.chartboost.appId, AppConfig.chartboost.appSignature, chartboostDelegate);

    uiHelper = new UiLifecycleHelper(this, null);
    uiHelper.onCreate(savedInstanceState);


    AdFlakeTargeting.setTestMode(AppConfig.adFlake.testMode);

    DisplayMetrics displayMetrics = getResources().getDisplayMetrics();
    final float density = displayMetrics.density;
    final int width = (int) (AdFlakeUtil.BANNER_DEFAULT_WIDTH * density);
    final int height = (int) (AdFlakeUtil.BANNER_DEFAULT_HEIGHT * density);
    adFlakeLayout = new AdFlakeLayout(this, AppConfig.adFlake.sdkKey);
    adFlakeLayout.setAdFlakeInterface(this);
    adFlakeLayout.setMaxWidth(width);
    adFlakeLayout.setMaxHeight(height);
    layout.addView(view);
    RelativeLayout.LayoutParams lp = adFlakeLayout.getOptimalRelativeLayoutParams();
    lp.addRule(RelativeLayout.CENTER_HORIZONTAL);
    lp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, 1);
    layout.addView(adFlakeLayout, lp);
    adFlakeLayout.setVisibility(RelativeLayout.GONE);
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
    view.start();

    CBPreferences.getInstance().setImpressionsUseActivities(true);
    this.cb.onStart(this);
  }

  public void prepareInterstitial(){
    this.cb.cacheInterstitial();
  }

  public void showInterstitial(){
    this.cb.showInterstitial();
  }


  public native void interstitialClosed();
  public native void interstitialDisplayed();
  public native void interstitialFailedDisplay();

  public int facebookIsShareAvailable(){
    if(FacebookDialog.canPresentShareDialog(getApplicationContext(),  FacebookDialog.ShareDialogFeature.SHARE_DIALOG)){
      return 1;
    }else{
      return 0;
    }
  }

  public void facebookPost(){
    Log.i(TAG,"Activity: Facebook post");
    if (FacebookDialog.canPresentShareDialog(getApplicationContext(),  FacebookDialog.ShareDialogFeature.SHARE_DIALOG)) {
      FacebookDialog shareDialog = new FacebookDialog.ShareDialogBuilder(this)
        .setName(AppConfig.facebook.name)
        .setCaption(AppConfig.facebook.caption)
        .setDescription(AppConfig.facebook.description)
        .setPicture(AppConfig.facebook.pictureUrl)
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
    Log.i(TAG,"Activity: Pause");
    uiHelper.onPause();
    view.pause();
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
    view.stop();
    this.cb.onDestroy(this);
    uiHelper.onDestroy();
  }

  @Override
  public void onBackPressed() {
    if (this.cb.onBackPressed())
      // If a Chartboost view exists, close it and return
      return;
    else
      // If no Chartboost view exists, continue on as normal
      super.onBackPressed();
  }


  private GLView view;

  @Override
  public void adFlakeDidPushAdSubView(AdFlakeLayout arg0) {
    // TODO Auto-generated method stub
  }

  @Override
  public void adFlakeGeneric() {
    // TODO Auto-generated method stub
  }
}


