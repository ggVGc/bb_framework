package com.spacekomodo.berrybounce;

import android.app.Activity;
import android.util.Log;

import com.example.android.trivialdrivesample.util.IabHelper;
import com.example.android.trivialdrivesample.util.IabResult;
import com.example.android.trivialdrivesample.util.Inventory;
import com.example.android.trivialdrivesample.util.Purchase;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

public class IAP{
  static final String TAG = "IAP";
  // (arbitrary) request code for the purchase flow

  IabHelper mHelper;
  Activity activity;
  Inventory curInventory;

  boolean available;

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

          if (!result.isSuccess()) {
            // Oh noes, there was a problem.
            available = false;
            return;
          }

          // Have we been disposed of in the meantime? If so, quit.
          if (mHelper == null){
            available = false;
            return;
          }

          // IAB is fully set up. Now, let's get an inventory of stuff we own.
          Log.i(TAG, "Setup successful. Querying inventory.");
          mHelper.queryInventoryAsync(mGotInventoryListener);
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
        complain("Failed to query inventory: " + result);
        available = false;

        return;
      }

      Log.i(TAG, "Query inventory was successful.");
      curInventory = inventory;
      /*
       * Check for items we own. Notice that for each purchase, we check
       * the developer payload to see if it's correct! See
       * verifyDeveloperPayload().
       */

      /*

      // Do we have the premium upgrade?
      Purchase premiumPurchase = inventory.getPurchase(SKU_PREMIUM);
      mIsPremium = (premiumPurchase != null && verifyDeveloperPayload(premiumPurchase));
      Log.i(TAG, "User is " + (mIsPremium ? "PREMIUM" : "NOT PREMIUM"));

      // Do we have the infinite gas plan?
      Purchase infiniteGasPurchase = inventory.getPurchase(SKU_INFINITE_GAS);
      mSubscribedToInfiniteGas = (infiniteGasPurchase != null &&
      verifyDeveloperPayload(infiniteGasPurchase));
      Log.i(TAG, "User " + (mSubscribedToInfiniteGas ? "HAS" : "DOES NOT HAVE")
      + " infinite gas subscription.");
      if (mSubscribedToInfiniteGas) mTank = TANK_MAX;

      // Check for gas delivery -- if we own gas, we should fill up the tank immediately
      Purchase gasPurchase = inventory.getPurchase(SKU_GAS);
      if (gasPurchase != null && verifyDeveloperPayload(gasPurchase)) {
      Log.i(TAG, "We have gas. Consuming it.");
      mHelper.consumeAsync(inventory.getPurchase(SKU_GAS), mConsumeFinishedListener);
      return;
      }

      updateUi();
      setWaitScreen(false);
      */
      Log.i(TAG, "Initial inventory query finished; enabling main UI.");
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
      }else if (result.isFailure()) {
        complain("Error purchasing: " + result);
        success = 0;
      }

      onPurchaseComplete(purchase.getSku(), success);
    }
  };


  /** Verifies the developer payload of a purchase. */
  boolean verifyDeveloperPayload(Purchase p) {
    String payload = p.getDeveloperPayload();

    /*
     * TODO: verify that the developer payload of the purchase is correct. It will be
     * the same one that you sent when initiating the purchase.
     *
     * WARNING: Locally generating a random string when starting a purchase and
     * verifying it here might seem like a good approach, but this will fail in the
     * case where the user purchases an item on one device and then uses your app on
     * a different device, because on the other device you will not have access to the
     * random string you originally generated.
     *
     * So a good developer payload has these characteristics:
     *
     * 1. If two different users purchase an item, the payload is different between them,
     *    so that one user's purchase can't be replayed to another user.
     *
     * 2. The payload must be such that you can verify it even when the app wasn't the
     *    one who initiated the purchase flow (so that items purchased by the user on
     *    one device work on other devices owned by the user).
     *
     * Using your own server to store and verify developer payloads across app
     * installations is recommended.
     */

    return true;
  }


  void complain(String message) {
    Log.e(TAG, "**** TrivialDrive Error: " + message);
  }

  public boolean userOwnsProduct(String id){
    return curInventory!=null && curInventory.hasPurchase(id);
  }


  static final int RC_REQUEST = 10001;
  public void purchaseProduct(String id){
    if(!available){
      onPurchaseComplete(id, 0);
      return;
    }else{
      String payload = "";
      mHelper.launchPurchaseFlow(activity, id, RC_REQUEST, mPurchaseFinishedListener, payload);
    }
  }


  native void onPurchaseComplete(String id, int success);
}
