package com.partner.example;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;

import com.partner.example.self.managed.button.R;
import com.purplebrain.giftiz.sdk.GiftizSDK;
import com.purplebrain.giftiz.sdk.GiftizSDK.Inner.ButtonNeedsUpdateDelegate;

// implements interfaces to be notified when button needs to be updated
public class TestActivity extends Activity implements ButtonNeedsUpdateDelegate {
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        // Register to know when to update Giftiz Button
        GiftizSDK.Inner.setButtonNeedsUpdateDelegate(this);
        
        // Connect Click action
  		ImageView selfManagedButton = (ImageView) findViewById(R.id.self_managed_button);
          selfManagedButton.setOnClickListener(new OnClickListener() {
  			@Override public void onClick(View v) {
  				GiftizSDK.Inner.buttonClicked(TestActivity.this);
  			}
  		});
    }
    
    @Override
    protected void onResume() {
    	super.onResume();
        GiftizSDK.onResumeMainActivity(this);
        
		updateButtonImage(); // configure button
    }
    
    @Override
    protected void onPause() {
    	super.onPause();
    	GiftizSDK.onPauseMainActivity(this);
    }

	@Override // Callback to update button
	public void buttonNeedsUpdate() {
		updateButtonImage();
	}

	private void updateButtonImage() { // pick the right button image according to the button status
		ImageView selfManagedButton = (ImageView) findViewById(R.id.self_managed_button);
        switch (GiftizSDK.Inner.getButtonStatus(this)) {
        case ButtonInvisible : selfManagedButton.setVisibility(View.GONE);break;
        case ButtonNaked : selfManagedButton.setImageResource(R.drawable.giftiz_logo_self);break;
        case ButtonBadge : selfManagedButton.setImageResource(R.drawable.giftiz_logo_badge_self);break;
        case ButtonWarning : selfManagedButton.setImageResource(R.drawable.giftiz_logo_warning_self);break;
        }
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