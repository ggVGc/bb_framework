#ifndef IAP_H_E25DMUWI
#define IAP_H_E25DMUWI

int userOwnsProduct(const char *id);
void purchaseProduct(const char *id);
void onPurchaseComplete(const char *id, int success);



#endif /* end of include guard: IAP_H_E25DMUWI */

