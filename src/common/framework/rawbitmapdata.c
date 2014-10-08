#include <stdlib.h>
#include "rawbitmapdata.h"


void rawBitmapDataCleanup(RawBitmapData* rawData) {
  free(rawData->data);
}
