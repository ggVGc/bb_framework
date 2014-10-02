package com.spacekomodo.berrybounce;

import android.util.Log;
import java.util.LinkedList;

import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.Chartboost.CBAgeGateConfirmation;
import com.chartboost.sdk.ChartboostDelegate;
import com.chartboost.sdk.Model.CBError.CBClickError;
import com.chartboost.sdk.Model.CBError.CBImpressionError;

public  class ChartboostDelegateImp implements ChartboostDelegate{

  public static final class Event{
    public static final int none = 0;
    public static final int closed = 1;
    public static final int displayed = 2;
    public static final int failedDisplay = 3;
  }

  private static final String TAG = "Chartboost";
  public LinkedList<Integer> events = new LinkedList<Integer>();
  private Chartboost cb;

  boolean cacheing = false;

  void setEvent(int e){
    Log.i(TAG, "Setting event: "+e);
    events.add(new Integer(e));
  }

  public ChartboostDelegateImp(Chartboost cb){
    this.cb = cb;
  }

  public void onStart(){
    cacheing = true;
    this.cb.cacheInterstitial();
  }

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
      Log.i(TAG, "SHOULD DISPLAY INTERSTITIAL '"+location+ "'?");
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
      Log.i(TAG, "SHOULD REQUEST INSTERSTITIAL '"+location+ "'?");
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
      Log.i(TAG, "INTERSTITIAL '"+location+"' CACHED");
      cacheing = false;
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

      Log.i(TAG, "INTERSTITIAL '"+location+"' REQUEST FAILED - " + error.name());
      //Toast.makeText(MainActivity.this, "Interstitial '"+location+"' Load Failed",Toast.LENGTH_SHORT).show();

      if(!cacheing){
        setEvent(Event.failedDisplay);
      }
      cacheing = false;
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
      Log.i(TAG, "INTERSTITIAL '"+location+"' DISMISSED");
      cacheing = true;
      cb.cacheInterstitial(location);
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
      Log.i(TAG, "INSTERSTITIAL '"+location+"' CLOSED");
      //Toast.makeText(MainActivity.this, "Closed Interstitial '"+location+"'",Toast.LENGTH_SHORT).show();
      setEvent(Event.closed);
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
      Log.i(TAG, "DID CLICK INTERSTITIAL '"+location+"'");
      //Toast.makeText(MainActivity.this, "Clicked Interstitial '"+location+"'",Toast.LENGTH_SHORT).show();
      setEvent(Event.closed);
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
      Log.i(TAG, "INTERSTITIAL '" + location + "' SHOWN");
      setEvent(Event.displayed);
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

      Log.i(TAG, "FAILED TO RECORD CLICK " + (uri != null ? uri : "null") + ", error: " + error.name());
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
      return false;
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

      return false;
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
      Log.i(TAG, "SHOULD DISPLAY MORE APPS?");
      return false;
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
      Log.i(TAG, "MORE APPS REQUEST FAILED - " + error.name());
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
      Log.i(TAG, "MORE APPS CACHED");
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
      Log.i(TAG, "MORE APPS DISMISSED");
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
      Log.i(TAG, "MORE APPS CLOSED");
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
      Log.i(TAG, "MORE APPS CLICKED");
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
      Log.i(TAG, "MORE APPS SHOWED");
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
