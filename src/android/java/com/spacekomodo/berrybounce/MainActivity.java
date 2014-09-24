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

final class ChartboostEvent{
  public static final int none = 0;
  public static final int closed = 1;
  public static final int displayed = 2;
  public static final int failedDisplay = 3;
}

public class MainActivity extends Activity implements AdFlakeInterface {
  private static final String CHARTBOOST_TAG = "Chartboost";
  public static final String TAG = "MainActivity";


  public int cbEvent = ChartboostEvent.none;
  IAP iap;

  static {
    System.loadLibrary("jumpz_framework");
  }
  private Chartboost cb;
  private UiLifecycleHelper uiHelper;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    Log.i(TAG,"Activity: Create");
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    RelativeLayout layout = new RelativeLayout(this);
    view = new GLView(this);
    setContentView(layout);
    

    this.cb = Chartboost.sharedChartboost();
    String appId = "53e2817b89b0bb7a9909427d";
    String appSignature = "57f6d5ff55b433c3eb75b0fd9261ef781c5e4f26";
    this.cb.onCreate(this, appId, appSignature, this.chartBoostDelegate);

    uiHelper = new UiLifecycleHelper(this, null);
    uiHelper.onCreate(savedInstanceState);

    iap = new IAP(this);


	AdFlakeTargeting.setTestMode(true);
    
    DisplayMetrics displayMetrics = getResources().getDisplayMetrics();
    final float density = displayMetrics.density;
    final int width = (int) (AdFlakeUtil.BANNER_DEFAULT_WIDTH * density);
    final int height = (int) (AdFlakeUtil.BANNER_DEFAULT_HEIGHT * density);
    final String myAdFlakeSdkKey = "541ee0b3a391bc8b063e453a";
    AdFlakeLayout adFlakeLayout2 = new AdFlakeLayout(this, myAdFlakeSdkKey);
    adFlakeLayout2.setAdFlakeInterface(this);
    adFlakeLayout2.setMaxWidth(width);
    adFlakeLayout2.setMaxHeight(height);
    layout.addView(view);
    RelativeLayout.LayoutParams lp = adFlakeLayout2.getOptimalRelativeLayoutParams();
	lp.addRule(RelativeLayout.CENTER_HORIZONTAL);
	lp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, 1);
    layout.addView(adFlakeLayout2, lp);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
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
    Log.i(TAG,"Activity: FACBOOK POST");
    if (FacebookDialog.canPresentShareDialog(getApplicationContext(),  FacebookDialog.ShareDialogFeature.SHARE_DIALOG)) {
      FacebookDialog shareDialog = new FacebookDialog.ShareDialogBuilder(this)
            .setName("BerryBounceTest")
            .setCaption("BBCaption")
            .setDescription("Playing Berry Bounce like a pro")
            .setPicture("http://www.berrybounce.com/share_image.png")
            .setLink("http://www.berrybounce.com")
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

  private ChartboostDelegate chartBoostDelegate = new ChartboostDelegate() {

    /*
     * Chartboost delegate methods
     * 
     * Implement the delegate methods below to finely control Chartboost's behavior in your app
     * 
     * Minimum recommended: shouldDisplayInterstitial()
     */


    /* 
     * shouldDisplayInterstitial(String location)
     *
     * This is used to control when an interstitial should or should not be displayed
     * If you should not display an interstitial, return false
     *
     * For example: during gameplay, return false.
     *
     * Is fired on:
     * - showInterstitial()
     * - Interstitial is loaded & ready to display
     */
    @Override
    public boolean shouldDisplayInterstitial(String location) {
      Log.i(CHARTBOOST_TAG, "SHOULD DISPLAY INTERSTITIAL '"+location+ "'?");
      return true;
    }

    /*
     * shouldRequestInterstitial(String location)
     * 
     * This is used to control when an interstitial should or should not be requested
     * If you should not request an interstitial from the server, return false
     *
     * For example: user should not see interstitials for some reason, return false.
     *
     * Is fired on:
     * - cacheInterstitial()
     * - showInterstitial() if no interstitial is cached
     * 
     * Notes: 
     * - We do not recommend excluding purchasers with this delegate method
     * - Instead, use an exclusion list on your campaign so you can control it on the fly
     */
    @Override
    public boolean shouldRequestInterstitial(String location) {
      Log.i(CHARTBOOST_TAG, "SHOULD REQUEST INSTERSTITIAL '"+location+ "'?");
      return true;
    }

    /*
     * didCacheInterstitial(String location)
     * 
     * Passes in the location name that has successfully been cached
     * 
     * Is fired on:
     * - cacheInterstitial() success
     * - All assets are loaded
     * 
     * Notes:
     * - Similar to this is: cb.hasCachedInterstitial(String location) 
     * Which will return true if a cached interstitial exists for that location
     */
    @Override
    public void didCacheInterstitial(String location) {
      Log.i(CHARTBOOST_TAG, "INTERSTITIAL '"+location+"' CACHED");
    }

    /*
     * didFailToLoadInterstitial(String location, CBImpressionError error)
     * 
     * This is called when an interstitial has failed to load for any reason
     * 
     * Is fired on:
     * - cacheInterstitial() failure
     * - showInterstitial() failure if no interstitial was cached
     * 
     * Notes:
     * - Please refer to to CBError.CBImpressionError.html in the sdk doc folder
     */
    @Override
    public void didFailToLoadInterstitial(String location, CBImpressionError error) {
      // Show a house ad or do something else when a chartboost interstitial fails to load

      Log.i(CHARTBOOST_TAG, "INTERSTITIAL '"+location+"' REQUEST FAILED - " + error.name());
      //Toast.makeText(MainActivity.this, "Interstitial '"+location+"' Load Failed",Toast.LENGTH_SHORT).show();
      cbEvent = ChartboostEvent.failedDisplay;
    }

    /*
     * didDismissInterstitial(String location)
     *
     * This is called when an interstitial is dismissed
     *
     * Is fired on:
     * - Interstitial click
     * - Interstitial close
     *
     * #Pro Tip: Use the delegate method below to immediately re-cache interstitials
     */
    @Override
    public void didDismissInterstitial(String location) {
      // Immediately re-caches an interstitial
      cb.cacheInterstitial(location);

      Log.i(CHARTBOOST_TAG, "INTERSTITIAL '"+location+"' DISMISSED");
      //Toast.makeText(MainActivity.this, "Dismissed Interstitial '"+location+"'",Toast.LENGTH_SHORT).show();
    }

    /*
     * didCloseInterstitial(String location)
     *
     * This is called when an interstitial is closed
     *
     * Is fired on:
     * - Interstitial close
     */
    @Override
    public void didCloseInterstitial(String location) {
      Log.i(CHARTBOOST_TAG, "INSTERSTITIAL '"+location+"' CLOSED");
      //Toast.makeText(MainActivity.this, "Closed Interstitial '"+location+"'",Toast.LENGTH_SHORT).show();
      cbEvent = ChartboostEvent.closed;
    }

    /*
     * didClickInterstitial(String location)
     *
     * This is called when an interstitial is clicked
     *
     * Is fired on:
     * - Interstitial click
     */
    @Override
    public void didClickInterstitial(String location) {
      Log.i(CHARTBOOST_TAG, "DID CLICK INTERSTITIAL '"+location+"'");
      //Toast.makeText(MainActivity.this, "Clicked Interstitial '"+location+"'",Toast.LENGTH_SHORT).show();
      cbEvent = ChartboostEvent.closed;
    }

    /*
     * didShowInterstitial(String location)
     *
     * This is called when an interstitial has been successfully shown
     *
     * Is fired on:
     * - showInterstitial() success
     */
    @Override
    public void didShowInterstitial(String location) {
      Log.i(CHARTBOOST_TAG, "INTERSTITIAL '" + location + "' SHOWN");
      cbEvent = ChartboostEvent.displayed;
    }

    /*
     * didFailToRecordClick(String url)
     *
     * This is called when our click API fails to respond
     *
     * Is fired on:
     * - Interstitial click
     * - More-Apps click
     * 
     * Notes:
     * - Please refer to to CBError.CBClickError.html in the sdk doc folder
     */
    @Override
    public void didFailToRecordClick(String uri, CBClickError error) {

      Log.i(CHARTBOOST_TAG, "FAILED TO RECORD CLICK " + (uri != null ? uri : "null") + ", error: " + error.name());
      //Toast.makeText(MainActivity.this, "URL '"+uri+"' Click Failed",Toast.LENGTH_SHORT).show();
    }

    /*
     * More Apps delegate methods
     */

    /*
     * shouldDisplayLoadingViewForMoreApps()
     *
     * Return false to prevent the pretty More-Apps loading screen
     *
     * Is fired on:
     * - showMoreApps()
     */
    @Override
    public boolean shouldDisplayLoadingViewForMoreApps() {
      return true;
    }

    /*
     * shouldRequestMoreApps()
     * 
     * Return false to prevent a More-Apps page request
     *
     * Is fired on:
     * - cacheMoreApps()
     * - showMoreApps() if no More-Apps page is cached
     */
    @Override
    public boolean shouldRequestMoreApps() {

      return true;
    }

    /*
     * shouldDisplayMoreApps()
     * 
     * Return false to prevent the More-Apps page from displaying
     *
     * Is fired on:
     * - showMoreApps() 
     * - More-Apps page is loaded & ready to display
     */
    @Override
    public boolean shouldDisplayMoreApps() {
      Log.i(CHARTBOOST_TAG, "SHOULD DISPLAY MORE APPS?");
      return true;
    }

    /*
     * didFailToLoadMoreApps()
     * 
     * This is called when the More-Apps page has failed to load for any reason
     * 
     * Is fired on:
     * - cacheMoreApps() failure
     * - showMoreApps() failure if no More-Apps page was cached
     * 
     * Notes:
     * - Please refer to to CBError.CBImpressionError.html in the sdk doc folder
     */
    @Override
    public void didFailToLoadMoreApps(CBImpressionError error) {
      Log.i(CHARTBOOST_TAG, "MORE APPS REQUEST FAILED - " + error.name());
      //Toast.makeText(MainActivity.this, "More Apps Load Failed",Toast.LENGTH_SHORT).show();

    }

    /*
     * didCacheMoreApps()
     * 
     * Is fired on:
     * - cacheMoreApps() success
     * - All assets are loaded
     */
    @Override
    public void didCacheMoreApps() {
      Log.i(CHARTBOOST_TAG, "MORE APPS CACHED");
    }

    /*
     * didDismissMoreApps()
     *
     * This is called when the More-Apps page is dismissed
     *
     * Is fired on:
     * - More-Apps click
     * - More-Apps close
     */
    @Override
    public void didDismissMoreApps() {
      Log.i(CHARTBOOST_TAG, "MORE APPS DISMISSED");
      //Toast.makeText(MainActivity.this, "Dismissed More Apps",Toast.LENGTH_SHORT).show();
    }

    /*
     * didCloseMoreApps()
     *
     * This is called when the More-Apps page is closed
     *
     * Is fired on:
     * - More-Apps close
     */
    @Override
    public void didCloseMoreApps() {
      Log.i(CHARTBOOST_TAG, "MORE APPS CLOSED");
      //Toast.makeText(MainActivity.this, "Closed More Apps", Toast.LENGTH_SHORT).show();
    }

    /*
     * didClickMoreApps()
     *
     * This is called when the More-Apps page is clicked
     *
     * Is fired on:
     * - More-Apps click
     */
    @Override
    public void didClickMoreApps() {
      Log.i(CHARTBOOST_TAG, "MORE APPS CLICKED");
      //Toast.makeText(MainActivity.this, "Clicked More Apps",Toast.LENGTH_SHORT).show();
    }

    /*
     * didShowMoreApps()
     *
     * This is called when the More-Apps page has been successfully shown
     *
     * Is fired on:
     * - showMoreApps() success
     */
    @Override
    public void didShowMoreApps() {
      Log.i(CHARTBOOST_TAG, "MORE APPS SHOWED");
    }

    /*
     * shouldRequestInterstitialsInFirstSession()
     *
     * Return false if the user should not request interstitials until the 2nd startSession()
     * 
     */
    @Override
    public boolean shouldRequestInterstitialsInFirstSession() {
      return true;
    }

    @Override
    public boolean shouldPauseClickForConfirmation(
        CBAgeGateConfirmation callback) {
      // TODO Auto-generated method stub
      return false;
        }
  };


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


