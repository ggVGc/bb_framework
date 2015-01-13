package com.spacekomodo.framework;

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.Context;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;

import com.purplebrain.giftiz.sdk.GiftizSDK.Inner.ButtonNeedsUpdateDelegate;

/*
import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.CBLocation;
import com.chartboost.sdk.Libraries.CBLogging.Level;
import com.facebook.UiLifecycleHelper;
import com.facebook.widget.FacebookDialog;
*/

import com.purplebrain.adbuddiz.sdk.AdBuddiz;
import com.purplebrain.adbuddiz.sdk.AdBuddizDelegate;
import com.purplebrain.adbuddiz.sdk.AdBuddizError;
import com.purplebrain.adbuddiz.sdk.AdBuddizLogLevel;

import com.purplebrain.giftiz.sdk.GiftizSDK;
import com.spacekomodo.framework.R;

public class MainActivity extends Activity implements ButtonNeedsUpdateDelegate{
  public static final String TAG = "MainActivity";

  public static Context appContext;
  public static MainActivity curActivityInstance;

  private GLView view;
  //private boolean facebookAvailable = false;

  public IAP iap;
  /*
  public ChartboostDelegateImp chartboostDelegate;
  */
  public AdBuddizDelegateImp adBuddizDel;
  /*
  private UiLifecycleHelper uiHelper;
  */
  
  public ImageView giftizButton;

  static {
    System.loadLibrary("jumpz_framework");
  }

  public String getApkPath(){
    ApplicationInfo appInfo = null;
    PackageManager packMgmr = this.getPackageManager();
    try {
      appInfo = packMgmr.getApplicationInfo(AppConfig.packageName, 0);
    } catch (NameNotFoundException e) {
      e.printStackTrace();
      throw new RuntimeException("Unable to locate assets, aborting...");
    }
    return appInfo.sourceDir;
  }

  public MainActivity(){}

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    curActivityInstance = this;
    appContext = getApplicationContext();
    Log.i(TAG,"Activity: Create");
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    setScreenRefreshRate((int)((WindowManager) getSystemService(WINDOW_SERVICE)).getDefaultDisplay().getRefreshRate());

    iap = new IAP(this);

    RelativeLayout rootLayout = new RelativeLayout(this);
    view = new GLView(this);
    setContentView(rootLayout);

/*
    chartboostDelegate = new ChartboostDelegateImp();
    Chartboost.startWithAppId(this, AppConfig.chartboost.appId, AppConfig.chartboost.appSignature);
    Chartboost.setLoggingLevel(Level.ALL);
    Chartboost.setDelegate(chartboostDelegate);
    Chartboost.onCreate(this);
*/
    AdBuddiz.setLogLevel(AdBuddizLogLevel.Info);
    AdBuddiz.setPublisherKey(AppConfig.AdBuddiz.publisherKey);
    if(AppConfig.AdBuddiz.testing){
      AdBuddiz.setTestModeActive();
    }
	AdBuddiz.cacheAds(this);
    adBuddizDel= new AdBuddizDelegateImp();
	AdBuddiz.setDelegate(adBuddizDel);

    /*
    uiHelper = new UiLifecycleHelper(this, null);
    uiHelper.onCreate(savedInstanceState);
    */

    giftizButton = new ImageView(this);
    giftizButton.setOnClickListener(new OnClickListener() {
      @Override public void onClick(View v) {
          GiftizSDK.Inner.buttonClicked(MainActivity.this);
      }
    });
    rootLayout.addView(view);
    rootLayout.addView(giftizButton);
    RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT); //The WRAP_CONTENT parameters can be replaced by an absolute width and height or the FILL_PARENT option)
    lp.topMargin = 4;
    lp.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
    giftizButton.setLayoutParams(lp);
    updateButtonImage();
    giftizButton.setVisibility(View.GONE);
    preInit(getApkPath());
  }
	@Override // Callback to update button
	public void buttonNeedsUpdate() {
		updateButtonImage();
	}

	public void updateButtonImage() { // pick the right button image according to the button status
        switch (GiftizSDK.Inner.getButtonStatus(this)) {
        case ButtonInvisible : giftizButton.setVisibility(View.GONE);break;
        case ButtonNaked : giftizButton.setImageResource(R.drawable.giftiz_logo);break;
        case ButtonBadge : giftizButton.setImageResource(R.drawable.giftiz_logo_badge);break;
        case ButtonWarning : giftizButton.setImageResource(R.drawable.giftiz_logo_warning);break;
        }
	}
    
    public void missionCompleted(View v) {
    	GiftizSDK.missionComplete(this);
    }


  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    Log.i(TAG, "onActivityResult");
    if (!iap.onActivityResult(requestCode, resultCode, data)) {
      super.onActivityResult(requestCode, resultCode, data);
/*
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
*/
    }
  }

  @Override
  public void onStart() {
    super.onStart();
    Log.i(TAG,"Activity: Start");
    /*
    Chartboost.setImpressionsUseActivities(true);
    Chartboost.onStart(this);
    chartboostDelegate.onStart();
    */
    //facebookAvailable = FacebookDialog.canPresentShareDialog(getApplicationContext(),  FacebookDialog.ShareDialogFeature.SHARE_DIALOG);
    }

  public void prepareInterstitial(){
    //Chartboost.cacheInterstitial(CBLocation.LOCATION_DEFAULT);
  }

  public void showInterstitial(){
    /*
    if(Chartboost.hasInterstitial(CBLocation.LOCATION_DEFAULT)){
      Log.i(TAG, "Showing cached interstitial");
      chartboostDelegate.cacheing = false;
      view.renderer.onInterstitialShow();
      Chartboost.showInterstitial(CBLocation.LOCATION_DEFAULT);
    }else{
      Log.i(TAG, "Tried showing interstitial, but none cached. Cacheing new");
      chartboostDelegate.cacheing = true;
      Chartboost.cacheInterstitial(CBLocation.LOCATION_DEFAULT);
      chartboostDelegate.events.add(new Integer(AdMediator.Event.failedDisplay));
    }
    */

	AdBuddiz.showAd(this);
  }


  native void preInit(String apkPath);

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
    /*
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
    */
  }
  @Override
  public void onRestart() {
    super.onRestart();
    Log.i(TAG,"Activity: Restart");
  }


  @Override
  protected void onPause() {
    super.onPause();
    /*
    uiHelper.onPause();
    */
    Log.i(TAG,"Activity: Pause");
    /*
    Chartboost.onPause(this);
    */
    view.onPause();
    GiftizSDK.onPauseMainActivity(this);
  }

  @Override
  protected void onResume() {
    super.onResume();
    Log.i(TAG,"Activity: Resume");
    /*
    uiHelper.onResume();
    */
    /*
    Chartboost.onResume(this);
    */
    view.onResume();
    GiftizSDK.onResumeMainActivity(this);
  }


  @Override
  protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    /*
    uiHelper.onSaveInstanceState(outState);
    */
  }

  @Override
  protected void onStop() {
    view.stop();
    super.onStop();
    Log.i(TAG,"Activity: Stop");
    /*
    Chartboost.onStop(this);
    */
  }

  static void giftizCompleteMission(){
    GiftizSDK.missionComplete(MainActivity.curActivityInstance);
  }

  static void giftizSetButtonVisible(final int v){
    final MainActivity a = MainActivity.curActivityInstance;
    a.runOnUiThread(new Runnable() {
      public void run() {
        a.giftizButton.setVisibility(v==1?View.VISIBLE:View.GONE);
        a.updateButtonImage();
      }
    });
  }


  @Override
  protected void onDestroy() {
    super.onDestroy();
    Log.i(TAG,"Activity: Destroy");
    AdBuddiz.onDestroy();
    /*
    uiHelper.onDestroy();
    */
    /*
    Chartboost.onDestroy(this);
    */
  }

  /*
  @Override
  public void onBackPressed() {
    if (Chartboost.onBackPressed()){
      return;
    }else{
      super.onBackPressed();
    }
  }
  */
}


