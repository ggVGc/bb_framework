#ifndef IAP_H_E25DMUWI
#define IAP_H_E25DMUWI

int userOwnsProduct(const char *id);
void purchaseProduct(const char *id);
const char* getProductPrice(const char *id);
void onPurchaseComplete(int success);
int iapCanRestorePurchases(void);
void iapRestorePurchases(void);
int iapAvailable(void);



#endif /* end of include guard: IAP_H_E25DMUWI */

