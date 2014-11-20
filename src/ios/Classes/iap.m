#import <StoreKit/StoreKit.h>
#import "RMStoreUserDefaultsPersistence.h"
#import "framework/iap.h"
#import "iap.h"
#import "util_ios.h"
#import "app.h"


/*
@interface StorePersistor:NSObject<RMStoreTransactionPersistor>{
  @public NSMutableSet *ownedProducts;
}
@end

@implementation StorePersistor
-(id)init{
  self = [super init];
  if(self){
    ownedProducts = [[NSMutableSet alloc] init];
  }
  return self;
}
- (void)persistTransaction:(SKPaymentTransaction*)transaction{
  NSString *str = transaction.payment.productIdentifier;
  alert(@"Persistor", [NSString stringWithFormat:@"Persisting: %@", str]);
  [ownedProducts addObject:str];
}
@end
*/


static NSArray *products = nil;
//static StorePersistor *persistor;
static RMStoreUserDefaultsPersistence *persistor;

@implementation IAP


-(id)init{
  self = [super init];
  if(self){
    persistor = [[RMStoreUserDefaultsPersistence alloc] init];
    RMStore *store = [RMStore defaultStore];
    store.transactionPersistor = persistor;
    NSSet *inProds = [NSSet setWithArray:@[@"berry_bounce_no_ads"]];
    products = nil;
    [store addStoreObserver:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [store requestProducts:inProds success:^(NSArray *outProds, NSArray *invalidProductIdentifiers) {
      products = outProds;
      //alert(@"", @"Products loaded");
      /*
      [[RMStore defaultStore] restoreTransactionsOnSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      }];
      [[RMStore defaultStore] refreshReceiptOnSuccess:^{
        alert(@"", @"Receipt refreshed");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      } failure:^(NSError *error) {
        NSLog(@"", @"Something went wrong");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      }];
      */

    } failure:^(NSError *error) {
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      //alert(@"", @"Something went wrong");
    }];
  }
  return self;
}

- (void)storePaymentTransactionFinished:(NSNotification*)notification {
    /*
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    */
  onPurchaseComplete(1);
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)storePaymentTransactionFailed:(NSNotification*)notification {
    /*
    NSError *error = notification.rm_storeError;
    NSString *productIdentifier = notification.rm_productIdentifier;
    SKPaymentTransaction *transaction = notification.rm_transaction;
    */
  alert(@"Error", @"Transaction failed");
  onPurchaseComplete(0);
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*
   - (void)storeRestoreTransactionsFinished:(NSNotification*)notification {
   }
   */

/*
   - (void)storeRestoreTransactionsFailed:(NSNotification*)notification; {
   NSError *error = notification.rm_storeError;
   }
   */

@end



/*
   @interface IAPRequestDelegate : NSObject<SKProductsRequestDelegate>
   @end

   @implementation IAPRequestDelegate
   - (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
   NSLog(@"Product request finihsed");
   for(NSString *s in response.products){
   NSLog(@"Product: %@", s);
   }
//self.products = response.products;

for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
NSLog(@"Invalid product: %@", invalidIdentifier);
}

//[self displayStoreUI]; // Custom method
}
@end

*/


int userOwnsProduct(const char *productId){
  /*
  for(NSString *s in persistor->ownedProducts){
    if(0 == strcmp([s UTF8String], productId)){
      return 1;
    }
  }
  */
  return [persistor countProductOfdentifier:[NSString stringWithUTF8String:productId]]>0;
}


void purchaseProduct(const char *productId){
  //alert(@"Purchasing", idStr);
  NSString *idStr = [NSString stringWithUTF8String:productId];
  appSetPaused(1, 1);
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *attempted = [defaults objectForKey:@"didAttemptPurchase"];
  if(attempted){
    [[RMStore defaultStore] addPayment:idStr success:^(SKPaymentTransaction *transaction) {
      //alert(@"", @"Product purchased");
      /*
      onPurchaseComplete(1);
      */
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
      NSLog(@"Something went wrong");
      onPurchaseComplete(0);
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
  }else{
    [defaults setObject:@"yeah" forKey:@"didAttemptPurchase"];
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^{
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      if(userOwnsProduct(productId)){
        onPurchaseComplete(1);
      }else{
        purchaseProduct(productId);
      }
    } failure:^(NSError *error) {
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      purchaseProduct(productId);
    }];
  }
}


const char* getProductPrice(const char *productId){
  /*
     if(products){
     for(SKProduct *p in products){
     if(0 == strcmp(productId, [p.productIdentifier UTF8String])){
     NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
     [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
     [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
     [numberFormatter setLocale:p.priceLocale];
     NSString *formattedString = [numberFormatter stringFromNumber:p.price];
     alert(@"price", formattedString);
     return strdup([formattedString UTF8String]);
     }
     }
     }
     */
  return "    ";
}

int iapCanRestorePurchases(void){
  return 1;
}

void iapRestorePurchases(void){
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:@"yeah" forKey:@"didAttemptPurchase"];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [[RMStore defaultStore] restoreTransactionsOnSuccess:^{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
      onPurchaseComplete(1);
  } failure:^(NSError *error) {
      onPurchaseComplete(0);
  }];
}

