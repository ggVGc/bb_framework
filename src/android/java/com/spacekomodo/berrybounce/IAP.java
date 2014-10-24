package com.spacekomodo.berrybounce;

import java.util.Arrays;

import android.app.Activity;
import android.util.Log;
import android.content.Intent;
import com.example.android.trivialdrivesample.util.IabHelper;
import com.example.android.trivialdrivesample.util.IabResult;
import com.example.android.trivialdrivesample.util.Inventory;
import com.example.android.trivialdrivesample.util.SkuDetails;
import com.example.android.trivialdrivesample.util.Purchase;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

public class IAP{
  static final String TAG = "IAP";

  IabHelper mHelper = null;
  Activity activity;
  Inventory curInventory = null;

  IabHelper.OnIabSetupFinishedListener listener;

  boolean available;
  String productToPurchaseAfterCreate = null;

  public IAP(Activity activity){
    this.activity = activity;
    int ret = GooglePlayServicesUtil.isGooglePlayServicesAvailable(activity);
    available = ret == ConnectionResult.SUCCESS;
    if(!available && (ret == ConnectionResult.SERVICE_MISSING ||
          ret == ConnectionResult.SERVICE_VERSION_UPDATE_REQUIRED ||
          ret == ConnectionResult.SERVICE_DISABLED))
    {
      Log.i(TAG, "Services not available");
      GooglePlayServicesUtil.getErrorDialog(ret, activity, 1).show();
    }
    if(available){
      listener = new IabHelper.OnIabSetupFinishedListener() {
        @Override
        public void onServiceDisconnected(){
          Log.i(TAG, "Service disconnected, recreating helper");
          mHelper = null;
        }
        @Override
        public void onIabSetupFinished(IabResult result) {
          Log.i(TAG, "Setup finished.");

          // Have we been disposed of in the meantime? If so, quit.
          if (mHelper == null){
            Log.i(TAG, "Disconnected while setting up");
            return;
          }
          if (!result.isSuccess()) {
            Log.i(TAG, "Not successful: "+result);
            // Oh noes, there was a problem.
            mHelper = null;
            return;
          }

          if(productToPurchaseAfterCreate==null){
            // IAB is fully set up. Now, let's get an inventory of stuff we own.
            Log.i(TAG, "Setup successful. Querying inventory.");
            try{
              mHelper.queryInventoryAsync(true, Arrays.asList(AppConfig.iap.skuList), mGotInventoryListener);
            }catch(Exception e){
              Log.i(TAG, "Error while querying inventory: "+e.toString());
              e.printStackTrace(System.out);
            }
          }else{
            purchaseProduct(productToPurchaseAfterCreate);
            productToPurchaseAfterCreate = null;
          }
        }
      };

      recreateHelper();
    }
  }

  void recreateHelper(){
    mHelper = new IabHelper(activity, AppConfig.iap.publicKey);
    mHelper.enableDebugLogging(AppConfig.iap.debugLogging);
    Log.i(TAG, "Starting setup.");
    mHelper.startSetup(listener);
  }

  // Listener that's called when we finish querying the items and subscriptions we own
  IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
    @Override
    public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
      Log.i(TAG, "Query inventory finished.");

      curInventory = null;

      // Have we been disposed of in the meantime? If so, quit.
      if (mHelper == null){
        return;
      }

      // Is it a failure?
      if (result.isFailure()) {
        Log.e(TAG, "Failed to query inventory: " + result);

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
    if(mHelper==null){
      return false;
    }
    int time = 0;
    /*
    while(curInventory==null){
      try{
        Log.i(TAG, "Waiting for inventory");
        Thread.sleep(10);
      }catch(Exception e){
        return false;
      }
      time += 10;
      if(time>3000){
        Log.i(TAG, "Inventory wait timed out");
        return false;
      }
    }
    */

    if(curInventory==null){
      return false;
    }
    return curInventory.hasPurchase(id);
  }



  public boolean onActivityResult(int requestCode, int resultCode, Intent data){
    if(mHelper!=null){
      try{
        return mHelper.handleActivityResult(requestCode, resultCode, data);
      }catch(Exception e){
        Log.i(TAG, e.toString());
        e.printStackTrace(System.out);
        return false;
      }
    }else{
      return false;
    }
  }

  static final int RC_REQUEST = 10001;
  public void purchaseProduct(String id){
    if(mHelper==null){
      if(available){
        productToPurchaseAfterCreate = id;
        recreateHelper();
      }
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
        e.printStackTrace(System.out);
        onPurchaseComplete(0);
      }
    }
  }

  public String getProductPrice(String id){
    if(mHelper==null){
      Log.i(TAG, "Helper is null");
      return "";
    }else{
      if(curInventory==null){
        Log.i(TAG, "Inventory is null");
        return "";
      }
      if(!curInventory.hasDetails(id)){
        Log.i(TAG, "id not in inventory");
        return "";
      }else{
        SkuDetails d = curInventory.getSkuDetails(id);
        if(d !=null){
          String price = d.getPrice();
          Log.i(TAG, "returning price: "+price);
          return price;
        }else{
          Log.i(TAG, "details was null");
          return "";
        }
      }
    }
  }


  public static native void onPurchaseComplete(int success);
}
