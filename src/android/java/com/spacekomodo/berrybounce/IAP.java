package com.spacekomodo.berrybounce;

import android.app.Activity;
import android.app.AlertDialog;
import android.util.Log;

import com.example.android.trivialdrivesample.util.IabHelper;
import com.example.android.trivialdrivesample.util.IabResult;
import com.example.android.trivialdrivesample.util.Inventory;
import com.example.android.trivialdrivesample.util.Purchase;

public class IAP{
    static final String TAG = "IAP";
    static final String SKU_TEST = "android.test.purchased";
    // (arbitrary) request code for the purchase flow
    static final int RC_REQUEST = 10001;

    IabHelper mHelper;
    Activity activity;

    public IAP(Activity activity){
      this.activity = activity;
      mHelper = new IabHelper(activity, AppConfig.iap.publicKey);
      mHelper.enableDebugLogging(true);
      Log.i(TAG, "Starting setup.");
      mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
        public void onIabSetupFinished(IabResult result) {
          Log.i(TAG, "Setup finished.");

          if (!result.isSuccess()) {
            // Oh noes, there was a problem.
            complain("Problem setting up in-app billing: " + result);
            return;
          }

          // Have we been disposed of in the meantime? If so, quit.
          if (mHelper == null){
            return;
          }

          // IAB is fully set up. Now, let's get an inventory of stuff we own.
          Log.i(TAG, "Setup successful. Querying inventory.");
          mHelper.queryInventoryAsync(mGotInventoryListener);
        }
      });
    }

    public void test(){
      Log.i(TAG, "Initiating test");
      String payload = "";
      mHelper.launchPurchaseFlow(this.activity, SKU_TEST, RC_REQUEST, mPurchaseFinishedListener, payload);
    }

    // Listener that's called when we finish querying the items and subscriptions we own
    IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
      public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
        Log.i(TAG, "Query inventory finished.");

        // Have we been disposed of in the meantime? If so, quit.
        if (mHelper == null){
          return;
        }

        // Is it a failure?
        if (result.isFailure()) {
          complain("Failed to query inventory: " + result);
          return;
        }

        Log.i(TAG, "Query inventory was successful.");
        test();

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
      public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
        Log.i(TAG, "Purchase finished: " + result + ", purchase: " + purchase);

        // if we were disposed of in the meantime, quit.
        if (mHelper == null) return;

        if (result.isFailure()) {
          complain("Error purchasing: " + result);
          /*
          setWaitScreen(false);
          */
          return;
        }
        if (!verifyDeveloperPayload(purchase)) {
          complain("Error purchasing. Authenticity verification failed.");
          /*
          setWaitScreen(false);
          */
          return;
        }

        Log.i(TAG, "Purchase successful.");

        /*
        if (purchase.getSku().equals(SKU_GAS)) {
          // bought 1/4 tank of gas. So consume it.
          Log.i(TAG, "Purchase is gas. Starting gas consumption.");
          mHelper.consumeAsync(purchase, mConsumeFinishedListener);
        }
        else if (purchase.getSku().equals(SKU_PREMIUM)) {
          // bought the premium upgrade!
          Log.i(TAG, "Purchase is premium upgrade. Congratulating user.");
          alert("Thank you for upgrading to premium!");
          mIsPremium = true;
          updateUi();
          setWaitScreen(false);
        }
        else if (purchase.getSku().equals(SKU_INFINITE_GAS)) {
          // bought the infinite gas subscription
          Log.i(TAG, "Infinite gas subscription purchased.");
          alert("Thank you for subscribing to infinite gas!");
          mSubscribedToInfiniteGas = true;
          mTank = TANK_MAX;
          updateUi();
          setWaitScreen(false);
        }
        */
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
      alert("Error: " + message);
    }


    void alert(String message) {
      AlertDialog.Builder bld = new AlertDialog.Builder(activity);
      bld.setMessage(message);
      bld.setNeutralButton("OK", null);
      Log.i(TAG, "Showing alert dialog: " + message);
      bld.create().show();
    }

}
