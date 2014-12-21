#include "framework/iap.h"

int userOwnsProduct(const char *id){
  return 0;
}

void purchaseProduct(const char *id){
  onPurchaseComplete(0);
}

const char* getProductPrice(const char *id){
  return 0;
}


int iapCanRestorePurchases(){
  return 0;
}

void iapRestorePurchases(void){
  onPurchaseComplete(1);
}

int iapAvailable(){
  return 0;
}
