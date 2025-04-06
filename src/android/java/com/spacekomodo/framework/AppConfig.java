package com.spacekomodo.framework;

public class AppConfig{
  public static final boolean development = false;
  public static final String packageName = "com.spacekomodo.framework";

  public static class iap{
    public static final String[] skuList = new String[]{"berry_bounce_no_ads"};
    public static final String publicKey = "";
    public static final boolean debugLogging = development;
  }

  public static class chartboost{
    public static final String appId = "";
    public static final String appSignature = "";
  }

  public static class AdBuddiz{
    //public static final String publisherKey = "TEST_PUBLISHER_KEY";
    public static final String publisherKey = "";
    public static final boolean testing = development;
  }

  public static class adFlake{
    public static final boolean testMode = development;
    public static final String sdkKey = "";
  }

  public static class facebook{
    public static final String description = "High Score - Berry Bounce";
    public static final String caption = "Try to beat me: www.berrybounce.com";
    //public static final String name = "726 Berries!";
    public static final String pictureUrl ="http://www.berrybounce.com/share_image.png"; 
    public static final String link = "http://www.berrybounce.com";
  }
}
