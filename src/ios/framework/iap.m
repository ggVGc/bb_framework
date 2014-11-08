#import <StoreKit/StoreKit.h>
#import "iap.h"


@implementation IAP

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


int userOwnsProduct(const char *id){
  /*NSSet *productIds = [[NSSet alloc] initWithObjects:@"berry_bounce_no_ads", nil];
  SKProductsRequest *req = [[SKProductsRequest alloc]
    initWithProductIdentifiers:[NSSet setWithObject: @"berry_bounce_no_ads"]];
  req.delegate = self;
  NSLog(@"Starting product request");
  [req start];
  */
    return 0;
}
void purchaseProduct(const char *id){
  onPurchaseComplete(0);
}


const char* getProductPrice(const char *id){
  return "";
}

