package com.spacekomodo.berrybounce;


public class AppConfig{
  public static final boolean development = true;
  public static final String packageName = "com.spacekomodo.berrybounce";

  public static class iap{
    public static final String[] skuList = new String[]{"berry_bounce_no_ads"};
    public static final String publicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu8zjSsJyqGzpBVzDCdmd0aPoaNq/VMmo/jpoDm4GPskuVa1X47FoVJELfohb431Iy9uZHOvrM8mbXtonB0LJyDo/LGPgLgWRw8Jmhf+uMsD8ZUIs1MKC2QZg9q7B4wsZOIsZeEUEizDxAKb2lXETjBll+jGJYlS7g0Jw1sDI4utCwUNgsNoIuO7syWJAhZpD6vnqPMmfSD+wY86qsrQvK4/cbhj5CuQPQBe4N1iJPtDlegmQPI0S/DVyIk7tbogp9EaQUJIqkqBgii+Jlx8HlKbzMJ45ZvZShz8nCI9k3LuVQk/Gp7SKZe/rk2qFfpQgKRm1IkGUZaHhk5elwAMqAwIDAQAB";
    public static final boolean debugLogging = development;
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
    public static final String name = "Berry Bounce";
    public static final String caption = "BBCaption";
    public static final String description = "Playing Berry Bounce like a pro";
    public static final String pictureUrl ="http://www.berrybounce.com/share_image.png"; 
    public static final String link = "http://www.berrybounce.com";
  }
}
