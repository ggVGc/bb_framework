package com.spacekomodo.berrybounce;

import android.util.Log;
import java.util.LinkedList;

import com.chartboost.sdk.CBLocation;
import com.chartboost.sdk.Chartboost;
import com.chartboost.sdk.ChartboostDelegate;
import com.chartboost.sdk.Model.CBError.CBClickError;
import com.chartboost.sdk.Model.CBError.CBImpressionError;

public  class ChartboostDelegateImp extends ChartboostDelegate{

  public static final class Event{
    public static final int none = 0;
    public static final int closed = 1;
    public static final int displayed = 2;
    public static final int failedDisplay = 3;
  }

  private static final String TAG = "Chartboost";
  public LinkedList<Integer> events = new LinkedList<Integer>();

  public boolean cacheing = false;

  void setEvent(int e){
    Log.i(TAG, "Setting event: "+e);
    events.add(new Integer(e));
  }

  public ChartboostDelegateImp(){
  }

  public void onStart(){
    cacheing = true;
    Chartboost.cacheInterstitial(CBLocation.LOCATION_DEFAULT);
  }


  @Override
  public void didClickInterstitial(String location) {
    Log.i(TAG, "DID CLICK INTERSTITIAL: "+ (location != null ? location : "null"));
    setEvent(Event.closed);
  }


  @Override
  public void didDisplayInterstitial(String location) {
    Log.i(TAG, "DID DISPLAY INTERSTITIAL: " +  (location != null ? location : "null"));
    setEvent(Event.displayed);
  }


  @Override
  public void didCloseInterstitial(String location) {
    Log.i(TAG, "DID CLOSE INTERSTITIAL: "+ (location != null ? location : "null"));
    setEvent(Event.closed);
  }


  @Override
  public void didDismissInterstitial(String location) {
    Log.i(TAG, "DID DISMISS INTERSTITIAL: "+ (location != null ? location : "null"));
    cacheing = true;
    Chartboost.cacheInterstitial(location);
  }



  @Override
  public void didFailToLoadInterstitial(String location, CBImpressionError error) {
    Log.i(TAG, "DID FAIL TO LOAD INTERSTITIAL '"+ (location != null ? location : "null")+ " Error: " + error.name());
    if(!cacheing){
      setEvent(Event.failedDisplay);
    }
    cacheing = false;
  }

  @Override
  public void didCacheInterstitial(String location) {
    Log.i(TAG, "DID CACHE INTERSTITIAL '"+ (location != null ? location : "null"));
    cacheing = false;
  }
















  @Override
  public boolean shouldRequestInterstitial(String location) {
    Log.i(TAG, "SHOULD REQUEST INTERSTITIAL '"+ (location != null ? location : "null"));		
    return true;
  }

  @Override
  public boolean shouldDisplayInterstitial(String location) {
    Log.i(TAG, "SHOULD DISPLAY INTERSTITIAL '"+ (location != null ? location : "null"));
    return true;
  }


  @Override
  public boolean shouldRequestMoreApps(String location) {
    Log.i(TAG, "SHOULD REQUEST MORE APPS: " +  (location != null ? location : "null"));
    return true;
  }

  @Override
  public boolean shouldDisplayMoreApps(String location) {
    Log.i(TAG, "SHOULD DISPLAY MORE APPS: " +  (location != null ? location : "null"));
    return true;
  }

  @Override
  public void didFailToLoadMoreApps(String location, CBImpressionError error) {
    Log.i(TAG, "DID FAIL TO LOAD MOREAPPS " +  (location != null ? location : "null")+ " Error: "+ error.name());
  }

  @Override
  public void didCacheMoreApps(String location) {
    Log.i(TAG, "DID CACHE MORE APPS: " +  (location != null ? location : "null"));
  }

  @Override
  public void didDismissMoreApps(String location) {
    Log.i(TAG, "DID DISMISS MORE APPS " +  (location != null ? location : "null"));
  }

  @Override
  public void didCloseMoreApps(String location) {
    Log.i(TAG, "DID CLOSE MORE APPS: "+  (location != null ? location : "null"));
  }

  @Override
  public void didClickMoreApps(String location) {
    Log.i(TAG, "DID CLICK MORE APPS: "+  (location != null ? location : "null"));
  }

  @Override
  public void didDisplayMoreApps(String location) {
    Log.i(TAG, "DID DISPLAY MORE APPS: " +  (location != null ? location : "null"));
  }

  @Override
  public void didFailToRecordClick(String uri, CBClickError error) {
    Log.i(TAG, "DID FAILED TO RECORD CLICK " + (uri != null ? uri : "null") + ", error: " + error.name());
  }

  @Override
  public boolean shouldDisplayRewardedVideo(String location) {
    Log.i(TAG, String.format("SHOULD DISPLAY REWARDED VIDEO: '%s'",  (location != null ? location : "null")));
    return true;
  }

  @Override
  public void didCacheRewardedVideo(String location) {
    Log.i(TAG, String.format("DID CACHE REWARDED VIDEO: '%s'",  (location != null ? location : "null")));
  }

  @Override
  public void didFailToLoadRewardedVideo(String location,
      CBImpressionError error) {
    Log.i(TAG, String.format("DID FAIL TO LOAD REWARDED VIDEO: '%s', Error:  %s",  (location != null ? location : "null"), error.name()));
  }

  @Override
  public void didDismissRewardedVideo(String location) {
    Log.i(TAG, String.format("DID DISMISS REWARDED VIDEO '%s'",  (location != null ? location : "null")));
  }

  @Override
  public void didCloseRewardedVideo(String location) {
    Log.i(TAG, String.format("DID CLOSE REWARDED VIDEO '%s'",  (location != null ? location : "null")));
  }

  @Override
  public void didClickRewardedVideo(String location) {
    Log.i(TAG, String.format("DID CLICK REWARDED VIDEO '%s'",  (location != null ? location : "null")));
  }

  @Override
  public void didCompleteRewardedVideo(String location, int reward) {
    Log.i(TAG, String.format("DID COMPLETE REWARDED VIDEO '%s' FOR REWARD %d",  (location != null ? location : "null"), reward));
  }

  @Override
  public void didDisplayRewardedVideo(String location) {
    Log.i(TAG, String.format("DID DISPLAY REWARDED VIDEO '%s' FOR REWARD", location));
  }

  @Override
  public void willDisplayVideo(String location) {
    Log.i(TAG, String.format("WILL DISPLAY VIDEO '%s", location));
  }

};
