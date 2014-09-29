package com.spacekomodo.berrybounce;

import java.util.Arrays;

import android.app.Activity;
import android.util.Log;
import android.content.Intent;
import com.example.android.trivialdrivesample.util.IabHelper;
import com.example.android.trivialdrivesample.util.IabResult;
import com.example.android.trivialdrivesample.util.Inventory;
import com.example.android.trivialdrivesample.util.Purchase;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

public class IAP{
  static final String TAG = "IAP";

  IabHelper mHelper;
  Activity activity;
  Inventory curInventory = null;

  boolean available = false;

  public IAP(Activity activity){
    this.activity = activity;
    int ret = GooglePlayServicesUtil.isGooglePlayServicesAvailable(activity);
    available = ret == ConnectionResult.SUCCESS;
    if(!available && (ret == ConnectionResult.SERVICE_MISSING ||
          ret == ConnectionResult.SERVICE_VERSION_UPDATE_REQUIRED ||
          ret == ConnectionResult.SERVICE_DISABLED))
    {
      GooglePlayServicesUtil.getErrorDialog(ret, activity, 1).show();
    }
    if(available){
      mHelper = new IabHelper(activity, AppConfig.iap.publicKey);
      mHelper.enableDebugLogging(AppConfig.iap.debugLogging);
      Log.i(TAG, "Starting setup.");
      mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
        @Override
        public void onIabSetupFinished(IabResult result) {
          Log.i(TAG, "Setup finished.");

          // Have we been disposed of in the meantime? If so, quit.
          if (mHelper == null){
            available = false;
            return;
          }
          if (!result.isSuccess()) {
            // Oh noes, there was a problem.
            available = false;
            return;
          }

          // IAB is fully set up. Now, let's get an inventory of stuff we own.
          Log.i(TAG, "Setup successful. Querying inventory.");
          try{
            mHelper.queryInventoryAsync(true, Arrays.asList(AppConfig.iap.skuList), mGotInventoryListener);
          }catch(Exception e){
            available = false;
            Log.i(TAG, "Error while querying inventory: "+e.toString());
          }
        }
      });
    }
  }

  // Listener that's called when we finish querying the items and subscriptions we own
  IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
    @Override
    public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
      Log.i(TAG, "Query inventory finished.");

      curInventory = null;

      // Have we been disposed of in the meantime? If so, quit.
      if (mHelper == null){
        available = false;
        return;
      }

      // Is it a failure?
      if (result.isFailure()) {
        Log.e(TAG, "Failed to query inventory: " + result);
        available = false;

        return;
      }


      Log.i(TAG, "Query inventory was successful.");
      curInventory = inventory;
    }
  };


  IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
    @Override
    public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
      Log.i(TAG, "Purchase finished: " + result + ", purchase: " + purchase);

      int success = 1;

      // if we were disposed of in the meantime, quit.
      if (mHelper == null){
        success = 0;
      }else if (result==null || result.isFailure()) {
        Log.e(TAG, "Error purchasing: " + result);
        success = 0;
      }

      onPurchaseComplete(success);
    }
  };


  /** Verifies the developer payload of a purchase. */
  boolean verifyDeveloperPayload(Purchase p) {
    String payload = p.getDeveloperPayload();
    return true;
  }


  public boolean userOwnsProduct(String id){
    if(!available){
      return false;
    }
    int time = 0;
    while(curInventory==null){
      try{
        Log.i(TAG, "Waiting for inventory");
        Thread.sleep(10);
      }catch(Exception e){
        return false;
      }
      time += 10;
      if(time>5000){
        Log.i(TAG, "Inventory wait timed out");
        return false;
      }
    }
    return curInventory.hasPurchase(id);
  }



  public boolean onActivityResult(int requestCode, int resultCode, Intent data){
    try{
      return mHelper.handleActivityResult(requestCode, resultCode, data);
    }catch(Exception e){
      Log.i(TAG, e.toString());
      return false;
    }
  }

  static final int RC_REQUEST = 10001;
  public void purchaseProduct(String id){
    if(!available){
      onPurchaseComplete(0);
      return;
    }else{
      Log.i(TAG, "Launching purchase flow: "+id);
      String payload = "";
      try{
        mHelper.launchPurchaseFlow(activity, id, RC_REQUEST, mPurchaseFinishedListener, payload);
      }catch(Exception e){
        Log.i(TAG, "Something went wrong while launching purchase flow");
        Log.i(TAG, e.toString());
      }
    }
  }

  public String getProductPrice(String id){
    if(!available){
      return "";
    }else{
      int time = 0;
      while(curInventory==null){
        try{
          Log.i(TAG, "Waiting for inventory");
          Thread.sleep(10);
        }catch(Exception e){
          return "";
        }
        time += 10;
        if(time>5000){
          Log.i(TAG, "Inventory wait timed out");
          return "";
        }
      }
      return curInventory.hasDetails(id)?curInventory.getSkuDetails(id).getPrice():null;
    }
  }


  native void onPurchaseComplete(int success);
}
