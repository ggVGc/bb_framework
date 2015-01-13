package com.spacekomodo.framework;

import com.purplebrain.adbuddiz.sdk.AdBuddizDelegate;
import com.purplebrain.adbuddiz.sdk.AdBuddizError;
import android.util.Log;
import java.util.LinkedList;

public class AdBuddizDelegateImp implements AdBuddizDelegate{
  private static final String TAG = "AdBuddiz";
  public LinkedList<Integer> events = new LinkedList<Integer>();

  void setEvent(int e){
    Log.i(TAG, "Setting event: "+e);
    events.add(new Integer(e));
  }

  @Override
  public void didCacheAd() {
    Log.i(TAG, "didCacheAd");
  }
  @Override
  public void didShowAd() {
    Log.i(TAG, "didShowAd");
    setEvent(AdMediator.Event.displayed);
  }
  @Override
  public void didFailToShowAd(AdBuddizError error) {
    Log.i(TAG, error.name());
    setEvent(AdMediator.Event.failedDisplay);
  }
  @Override
  public void didClick() {
    Log.i(TAG, "didClick");
    setEvent(AdMediator.Event.clicked);
  }
  @Override
  public void didHideAd() {
    Log.i(TAG, "didHideAd");
    setEvent(AdMediator.Event.closed);
  }
}
