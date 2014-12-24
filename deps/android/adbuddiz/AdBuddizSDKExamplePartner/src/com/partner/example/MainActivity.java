package com.partner.example;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;

//import AdBuddiz SDK
import com.purplebrain.adbuddiz.sdk.AdBuddiz;
import com.purplebrain.adbuddiz.sdk.AdBuddizDelegate;
import com.purplebrain.adbuddiz.sdk.AdBuddizError;
import com.purplebrain.adbuddiz.sdk.AdBuddizLogLevel;

public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		final Activity activity = this;

		AdBuddiz.setLogLevel(AdBuddizLogLevel.Info);    // log level
		AdBuddiz.setPublisherKey("TEST_PUBLISHER_KEY"); // replace with your app publisher key
		AdBuddiz.setTestModeActive();                   // to delete before submitting to store

		AdBuddiz.cacheAds(activity);                    // start caching ads

		findViewById(R.id.button).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// To call whenever you want to display an Ad.
				// Parameter is the current activity
				AdBuddiz.showAd(activity);
			}
		});

		// OPTIONAL, to get more info about the SDK behavior
		AdBuddiz.setDelegate(new AdBuddizDelegate() {
			@Override
			public void didCacheAd() {
				Toast.makeText(activity, "didCacheAd", Toast.LENGTH_SHORT).show();
			}
			@Override
			public void didShowAd() {
				Toast.makeText(activity, "didShowAd", Toast.LENGTH_SHORT).show();
			}
			@Override
			public void didFailToShowAd(AdBuddizError error) {
				Toast.makeText(activity, error.name(), Toast.LENGTH_SHORT).show();
			}
			@Override
			public void didClick() {
				Toast.makeText(activity, "didClick", Toast.LENGTH_SHORT).show();
			}
			@Override
			public void didHideAd() {
				Toast.makeText(activity, "didHideAd", Toast.LENGTH_SHORT).show();
			}
		});
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		AdBuddiz.onDestroy(); // to minimize memory footprint
	}
}