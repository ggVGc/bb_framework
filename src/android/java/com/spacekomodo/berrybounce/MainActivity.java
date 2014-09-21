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


  public int cbEvent = ChartboostEvent.none;

  static {
    System.loadLibrary("jumpz_framework");
  }
  private Chartboost cb;
  private UiLifecycleHelper uiHelper;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    System.out.println("ACTIVITY: Create");
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
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
    System.out.println("ACTIVITY: Start");
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
    System.out.println("ACTIVITY: FACBOOK POST");
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
    System.out.println("ACTIVITY: Restart");
  }


  @Override
  protected void onPause() {
    super.onPause();
    System.out.println("ACTIVITY: PAUSE");
    uiHelper.onPause();
    view.pause();
  }

  @Override
  protected void onResume() {
    super.onResume();
    System.out.println("ACTIVITY: RESUME");
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
    System.out.println("ACTIVITY: STOP");
    this.cb.onStop(this);
  }


  @Override
  protected void onDestroy() {
    super.onDestroy();
    System.out.println("ACTIVITY: DESTROY");
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

class GLView extends GLSurfaceView {
  public GLView(MainActivity activity) 
  {
    super(activity);
    System.out.println("GLView created");
    super.setEGLConfigChooser(8 , 8, 8, 8, 16, 0);
    renderer = new GLRenderer(activity);
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


  @Override
  public void onResume() {
    super.onResume();
    renderer.start();
  }

  public void start() {
    renderer.start();
  }

  public void stop() {
    renderer.stop();
  }


  public void pause() {
    System.out.println("GLView: PAUSE");
    renderer.pause();
  }

  GLRenderer renderer;

  private static native void nativeOnCursorDown();
  private static native void nativeOnCursorUp();
  private static native void nativeOnCursorMove(int x, int y);
}

class GLRenderer implements GLSurfaceView.Renderer {
  private MainActivity activity;

  public GLRenderer (MainActivity activity) {
    System.out.println("GLRenderer created");
    this.activity = activity;
  }

  public void start() {
    paused = false;
  }

  public void stop() {
    die = true;
  }


  boolean die = false;
  boolean paused = false;

  public void pause() {
    paused = true;
  }

  public void onSurfaceCreated(GL10 gl, EGLConfig config) {
    System.out.println("GLRenderer: SURFACE CREATED");
  }

  boolean inited = false;
  public void onSurfaceChanged(GL10 gl, int w, int h) {
    System.out.println("GLRenderer: SURFACE CHANGED");

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
      switch (activity.cbEvent){
        case ChartboostEvent.closed:
          activity.interstitialClosed();
        break;
        case ChartboostEvent.failedDisplay:
          activity.interstitialFailedDisplay();
        break;
        case ChartboostEvent.displayed:
          activity.interstitialDisplayed();
        break;
      }
      activity.cbEvent = ChartboostEvent.none;
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
