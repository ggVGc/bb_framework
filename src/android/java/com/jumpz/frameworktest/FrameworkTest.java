package com.jumpz.frameworktest;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.WindowManager;
import android.view.Window;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ApplicationInfo;

import android.util.Log;
import android.widget.Toast;

import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.Chartboost.CBAgeGateConfirmation;
import com.chartboost.sdk.ChartboostDelegate;
import com.chartboost.sdk.Model.CBError.CBClickError;
import com.chartboost.sdk.Model.CBError.CBImpressionError;
import com.chartboost.sdk.CBPreferences;


public class FrameworkTest extends Activity {
  private static final String CHARTBOOST_TAG = "Chartboost";

  static {
    System.loadLibrary("jumpz_framework");
  }
  private Chartboost cb;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    System.out.println("ACTIVITY: Create");
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
    view = new GLView(this);
    setContentView(view);
	//setContentView(R.layout.main);

    this.cb = Chartboost.sharedChartboost();
    String appId = "53e2817b89b0bb7a9909427d";
    String appSignature = "57f6d5ff55b433c3eb75b0fd9261ef781c5e4f26";
    this.cb.onCreate(this, appId, appSignature, this.chartBoostDelegate);
  }

  @Override
  public void onStart() {
    super.onStart();
    System.out.println("ACTIVITY: Start");
    view.start();

    CBPreferences.getInstance().setImpressionsUseActivities(true);
    this.cb.onStart(this);
    //this.cb.showInterstitial();
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
    //view.onPause();
  }

  @Override
  protected void onResume() {
    super.onResume();
    System.out.println("ACTIVITY: RESUME");
    view.onResume();
  }

  @Override
  //protected void onDestroy() {
  protected void onStop() {
    super.onStop();
    System.out.println("ACTIVITY: STOP");
    view.stop();
    this.cb.onStop(this);
  }


  @Override
  protected void onDestroy() {
    super.onDestroy();
    System.out.println("ACTIVITY: DESTROY");
    this.cb.onDestroy(this);
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
      Toast.makeText(FrameworkTest.this, "Interstitial '"+location+"' Load Failed",
          Toast.LENGTH_SHORT).show();
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
      Toast.makeText(FrameworkTest.this, "Dismissed Interstitial '"+location+"'",
          Toast.LENGTH_SHORT).show();
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
      Toast.makeText(FrameworkTest.this, "Closed Interstitial '"+location+"'",
          Toast.LENGTH_SHORT).show();
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
      Toast.makeText(FrameworkTest.this, "Clicked Interstitial '"+location+"'",
          Toast.LENGTH_SHORT).show();
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
      Toast.makeText(FrameworkTest.this, "URL '"+uri+"' Click Failed",
          Toast.LENGTH_SHORT).show();
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
      Toast.makeText(FrameworkTest.this, "More Apps Load Failed",
          Toast.LENGTH_SHORT).show();

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
      Toast.makeText(FrameworkTest.this, "Dismissed More Apps",
          Toast.LENGTH_SHORT).show();
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
      Toast.makeText(FrameworkTest.this, "Closed More Apps",
          Toast.LENGTH_SHORT).show();
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
      Toast.makeText(FrameworkTest.this, "Clicked More Apps",
          Toast.LENGTH_SHORT).show();
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
}




class GLView extends GLSurfaceView 
{


  public GLView(Context context) 
  {
    super(context);
    System.out.println("GLView created");
    super.setEGLConfigChooser(8 , 8, 8, 8, 16, 0);
    renderer = new GLRenderer(context);
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

  public void start()
  {
    renderer.start();
  }

  public void stop()
  {
    renderer.stop();
  }


  public void onPause()
  {
    System.out.println("GLView: PAUSE");
    renderer.pause();
  }

  GLRenderer renderer;


  private static native void nativeOnCursorDown();
  private static native void nativeOnCursorUp();
  private static native void nativeOnCursorMove(int x, int y);
}

class GLRenderer implements GLSurfaceView.Renderer {
  private Context context;

  public GLRenderer (Context context) {
    System.out.println("GLRenderer created");
    this.context = context;
  }

  public void start() {
  }

  public void stop() {
    die = true;
  }


  boolean die = false;

  public void pause() {
    die = true;
  }

  public void onSurfaceCreated(GL10 gl, EGLConfig config) 
  {
    System.out.println("GLRenderer: SURFACE CREATED");
    // return apk file path (or null on error)
    //String apkFilePath = null;
    //ApplicationInfo appInfo = null;
    //PackageManager packMgmr = context.getPackageManager();
    //try {
    //appInfo = packMgmr.getApplicationInfo("com.jumpz.frameworktest", 0);
    //} catch (NameNotFoundException e) {
    //e.printStackTrace();
    //throw new RuntimeException("Unable to locate assets, aborting...");
    //}
    //apkFilePath = appInfo.sourceDir;

    //nativeInit(apkFilePath);
  }

  public void onSurfaceChanged(GL10 gl, int w, int h) 
  {
    System.out.println("GLRenderer: SURFACE CHANGED");

    String apkFilePath = null;
    ApplicationInfo appInfo = null;
    PackageManager packMgmr = context.getPackageManager();
    try {
      appInfo = packMgmr.getApplicationInfo("com.jumpz.frameworktest", 0);
    } catch (NameNotFoundException e) {
      e.printStackTrace();
      throw new RuntimeException("Unable to locate assets, aborting...");
    }
    apkFilePath = appInfo.sourceDir;

    nativeInit(apkFilePath);


    nativeResize(w, h);
  }

  boolean dead = false;

  public void onDrawFrame(GL10 gl) 
  {
    if(dead){
      return;
    }
    if(die)
    {
      nativeOnStop();
      dead = true;
    }
    else
    {
      nativeRender();
    }
  }


  private static native void nativeOnStop();
  private static native void nativeInit(String apkPath);
  private static native void nativeResize(int w, int h);
  private static native void nativeRender();
}
