package com.partner.example;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;

import com.purplebrain.giftiz.sdk.GiftizSDK;

public class TestActivity extends Activity {
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }
    
    @Override
    protected void onResume() {
    	super.onResume();
        GiftizSDK.onResumeMainActivity(this);
    }
    
    @Override
    protected void onPause() {
    	super.onPause();
    	GiftizSDK.onPauseMainActivity(this);
    }
    
    public void missionCompleted(View v) {
    	GiftizSDK.missionComplete(this);
    }

	public void inAppLevel1(View v) {
		GiftizSDK.inAppPurchase(this, 1.99f); // amount in euros
    }
	
    public void inAppLevel2(View v) {
    	GiftizSDK.inAppPurchase(this, 4.99f); // amount in euros
    }
    
    public void inAppLevel3(View v) {
    	GiftizSDK.inAppPurchase(this, 9.99f); // amount in euros
    }
    
    public void inAppLevel4(View v) {
    	GiftizSDK.inAppPurchase(this, 10.00f); // amount in euros
    }
}