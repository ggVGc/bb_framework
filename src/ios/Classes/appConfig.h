struct ChartboostConfig_T{
  const NSString * const appId;
  const NSString * const appSignature;
};
struct AppConfig_T{
  struct ChartboostConfig_T cb;
};

struct AppConfig_T AppConfig={
  {
    @"53e2817b89b0bb7a9909427d", //AppID
    @"57f6d5ff55b433c3eb75b0fd9261ef781c5e4f26" //AppSignature
  }
};
