package com.spacekomodo.berrybounce;


public class AppConfig{
  public static final boolean development = false;

  public static class iap{
    public static final String publicKey = "";
  }

  public static class chartboost{
    public static final String appId = "53e2817b89b0bb7a9909427d";
    public static final String appSignature = "57f6d5ff55b433c3eb75b0fd9261ef781c5e4f26";
  }
  public static class adFlake{
    public static final boolean testMode = development;
    public static final String sdkKey = "541ee0b3a391bc8b063e453a";
  }
  public static class facebook{
    public static final String name = "BerryBounceTest";
    public static final String caption = "BBCaption";
    public static final String description = "Playing Berry Bounce like a pro";
    public static final String pictureUrl ="http://www.berrybounce.com/share_image.png"; 
    public static final String link = "http://www.berrybounce.com";
  }
}
