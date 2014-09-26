#include "framework/iap.h"

int userOwnsProduct(const char *id){
  return 0;
}

void purchaseProduct(const char *id){
  onPurchaseComplete(id, 0);
}

const char* getProductPrice(const char *id){
  return 0;
}
