#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <png.h>
#include <zip.h>
#include <unzip.h>
#include "resource_loading.h"
#include "rawbitmapdata.h"
#include "util.h"


#include "assets.c"


static char apkPath[2048];
static int usingZip = 0;



/*

   unsigned long hex2int(char *a, unsigned int len){
   int i;
   unsigned long val = 0;

   for(i=0;i<len;i++)
   if(a[i] <= 57){
   val += (a[i]-48)*(1<<(4*(len-1-i)));
   }else{
   val += (a[i]-87)*(1<<(4*(len-1-i)));
   }
   return val;
   }

   char* hexDecode(const char *hexStr){
   int i;
   int len = strlen(hexStr);
   char* ret = (char*)malloc(sizeof(char)*len/2+1);
   for(i=0;i<len/2;++i){
   ret[i] = hex2int(hexStr+i*2, 2);
   }
   ret[len/2] = '\0';
   return ret;
   }

*/


void resourcesCleanUp(void)
{
  //if(APKArchive)
  //{
  //  zip_close(APKArchive);
  //  APKArchive = 0;
  //}
}


unzFile guf;

void png_zip_read(png_structp png_ptr, png_bytep data, png_size_t length) {
  png_ptr = png_ptr;
  unzReadCurrentFile(guf, data, length);
}

void setResourcePath(const char* p, int useZip)
{
  char msg[2048];
  sprintf(msg, "Setting resource path: %s", p);
  trace(msg);
  sprintf(apkPath, "%s", p);
  usingZip = useZip;
}


/*void loadAPK (const char* apk) */
/*{*/
/*//int i;*/
/*//int numFiles;*/
/*//unzFile uf;*/
/*//struct zip* APKArchive;*/

/*apkPath = (char*)malloc(2048);*/
/*strcpy(apkPath,apk);*/

/*//uf = unzOpen(apkPath);*/
/*//unzClose(uf);*/
/*//resourcesCleanUp();*/

/*//LOGI("Loading APK %s", apkPath);*/
/*//APKArchive = zip_open(apkPath, 0, NULL);*/
/*//if (APKArchive == NULL) {*/
/*//  //LOGE("Error loading APK");*/
/*//    printf("ERROR LOADING APK");*/
/*//  return;*/
/*//}*/

/*////Just for debug, print APK contents*/
/*//numFiles = zip_get_num_files(APKArchive);*/
/*//for (i=0; i<numFiles; i++) {*/
/*//  const char* name = zip_get_name(APKArchive, i, 0);*/
/*//  if (name == NULL) {*/
/*//    //LOGE("Error reading zip file name at index %i : %s", zip_strerror(APKArchive));*/
/*//    return;*/
/*//  }*/
/*[>LOGI("File %i : %s\n", i, name);<]*/
/*//}*/

/*//zip_close(APKArchive);*/
/*}*/


int getFileSizeFromZip(const char* inPath){
  unzFile uf;
  unz_file_info info;

  // TODO: Should check for overflow.
  char path[2048];
  char msg[2048];
  sprintf(path, "assets/%s", inPath);

  uf = unzOpen(apkPath);

  if(!uf){
    sprintf(msg, "Invalid resource zip: %s", apkPath);
    trace(msg);
    return 0;
  }

  if(unzLocateFile(uf, path, 0)){
    // Invalid file path
    return 0;
  }

  
  info.uncompressed_size = -1;
  unzGetCurrentFileInfo(uf, &info, NULL, 0, NULL, 0, NULL, 0);
  return info.uncompressed_size;
}


int getFileSize(const char *path){
  if(usingZip){
    return getFileSizeFromZip(path);
  }else{
    return -1;
  }
}

int loadBytesIntoBuffer(const char *inPath, unsigned char *data, int bufferSize){
  // TODO: Should check for overflow.
  char path[2048];

  unzFile uf = unzOpen(apkPath);

  sprintf(path, "assets/%s", inPath);

  if(unzLocateFile(uf, path, 0)){
    // Invalid file path
    return -1;
  }
  unzOpenCurrentFile(uf);
  unzReadCurrentFile(uf, data, bufferSize);

  unzCloseCurrentFile(uf);
  unzClose(uf);
  return 0;
}




unsigned char* loadBytesFromZip(const char* inPath, int* outSize){
  unsigned char* data;
  int size = getFileSizeFromZip(inPath);
  if(size<=0){
    return NULL;
  }
  data = (unsigned char*)malloc(size);
  if(loadBytesIntoBuffer(inPath, data, size) !=0){
    return NULL;
  }

  if (outSize != 0) {
    *outSize = size;
  }

  return data;
}

unsigned char* loadBytesFromDisk(const char* inPath) {
  // TODO: Should check for overflow.
  char path[2048];
  sprintf(path, "assets/%s", inPath);

  /*TODO: Implement!*/
  /*FILE* f = fopen(path);*/
  /*fclose(path);*/
  return (unsigned char*)"NOT IMPLEMENTED";
}



unsigned char* loadBytes(const char* path, int* sz){
  int i;
  unsigned char *ret;

  if(usingZip)
    ret = loadBytesFromZip(path, sz);
  else
    ret = loadBytesFromDisk(path);

  if(!ret){
    for(i=0;i<ASSET_COUNT;++i){
      if(strcmp(path, ASSET_KEYS[i])==0){
        if (sz != 0) {
          *sz = ASSET_SIZES[i];
        }
        ret = (unsigned char*)malloc(sizeof(unsigned char)*(ASSET_SIZES[i]));
        memcpy(ret, ASSET_DATA[i], sizeof(unsigned char)*ASSET_SIZES[i]);
      }
    }
  }
  return ret;
}


void multiplyPixelAt(int x,int y, int height,unsigned char *data){
  int off = (x*height+y)*4;
  float r = data[off];
  float g = data[off+1];
  float b = data[off+2];
  float a = data[off+3];
  a = a/255;
  data[off] = r*a;
  data[off+1] = g*a;
  data[off+2] = b*a;
  /*printf("%u %u %u %u\n", data[off], data[off+1], data[off+2], data[off+3]);*/
}

RawBitmapData* loadImage(const char* inFilename){
  unzFile uf;
  png_structp png_ptr;
  png_infop info_ptr;
  png_infop end_info;

  int rowbytes;

  //variables to pass to get info
  int bit_depth, color_type;
  png_uint_32 twidth, theight;

  int is_png;

  png_byte header[8];
  int ret;
  png_bytep * row_pointers;
  png_byte *image_data;
  int i, width, height;
  RawBitmapData* d;
  char filename[2048];
  int x,y;
  sprintf(filename, "assets/%s", inFilename);


  uf = unzOpen(apkPath);

  if(uf == NULL) {
    return NULL;
  }

  ret = unzLocateFile(uf, filename, 0);
  if(ret != UNZ_OK) {
    unzClose(uf);
    return NULL;
  }

  unzOpenCurrentFile(uf);

  //read the header for testing if it is a png
  unzReadCurrentFile(uf, header, 8);

  //test if png
  is_png = !png_sig_cmp(header, 0, 8);
  if (!is_png) {
    unzCloseCurrentFile(uf);
    unzClose(uf);
    //LOGE("Not a png file : %s", filename);
    return NULL;
  }

  //create png struct
  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL,
      NULL, NULL);
  if (!png_ptr) {
    unzCloseCurrentFile(uf);
    unzClose(uf);
    //LOGE("Unable to create png struct : %s", filename);
    return NULL;
  }

  //create png info struct
  info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr) {
    png_destroy_read_struct(&png_ptr, (png_infopp) NULL, (png_infopp) NULL);
    //LOGE("Unable to create png info : %s", filename);
    unzCloseCurrentFile(uf);
    unzClose(uf);
    return NULL;
  }

  //create png info struct
  end_info = png_create_info_struct(png_ptr);
  if (!end_info) {
    png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp) NULL);
    //LOGE("Unable to create png end info : %s", filename);
    unzCloseCurrentFile(uf);
    unzClose(uf);
    return NULL;
  }

  //png error stuff, not sure libpng man suggests this.
  if (setjmp(png_jmpbuf(png_ptr))) {
    unzCloseCurrentFile(uf);
    unzClose(uf);
    //LOGE("Error during setjmp : %s", filename);
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    return NULL;
  }

  //init png reading
  //png_init_io(png_ptr, fp);
  guf = uf;
  png_set_read_fn(png_ptr, NULL, png_zip_read);

  //let libpng know you already read the first 8 bytes
  png_set_sig_bytes(png_ptr, 8);

  // read all the info up to the image data
  png_read_info(png_ptr, info_ptr);

  // get info about png
  png_get_IHDR(png_ptr, info_ptr, &twidth, &theight, &bit_depth, &color_type,
      NULL, NULL, NULL);

  if(color_type != 6){
    char msg[4096];
    sprintf(msg, "ERROR: Invalid PNG color type: %d (we only support type 6) - %s", color_type, inFilename);
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    trace(msg);
    unzCloseCurrentFile(uf);
    unzClose(uf);
    return NULL;
  }


  //update width and height based on png info
  width = twidth;
  height = theight;

  // Update the png info struct.
  png_read_update_info(png_ptr, info_ptr);

  // Row size in bytes.
  rowbytes = png_get_rowbytes(png_ptr, info_ptr);

  // Allocate the image_data as a big block, to be given to opengl
  image_data = (png_byte*)malloc(sizeof(png_byte)*rowbytes * height);
  if (!image_data) {
    //clean up memory and close stuff
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    //LOGE("Unable to allocate image_data while loading %s ", filename);
    unzCloseCurrentFile(uf);
    unzClose(uf);
    return NULL;
  }

  //row_pointers is for pointing to image_data for reading the png with libpng
  row_pointers = (png_bytep*)malloc(sizeof(png_bytep)*height);
  if (!row_pointers) {
    //clean up memory and close stuff
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    free(image_data);
    //LOGE("Unable to allocate row_pointer while loading %s ", filename);
    unzCloseCurrentFile(uf);
    unzClose(uf);
    return NULL;
  }
  // set the individual row_pointers to point at the correct offsets of image_data
  for (i = 0; i < height; ++i)
    row_pointers[height - 1 - i] = image_data + i * rowbytes;


  png_read_image(png_ptr, row_pointers);

  d = (RawBitmapData*)malloc(sizeof(RawBitmapData));
  d->width = width;
  d->height = height;

  d->data = image_data;

  png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);

  free(row_pointers);

  unzCloseCurrentFile(uf);
  unzClose(uf);

  for(x=0;x<width;++x){
    for(y=0;y<height;++y){
      multiplyPixelAt(x,y,height, d->data);
    }
  }

  return d;
}


char* loadText(const char* path){
  int i;
  unsigned char* data = 0;
  int size = getFileSizeFromZip(path);
  if(size>0){
    data = (unsigned char*)malloc(size+1);
    if(loadBytesIntoBuffer(path, data, size) !=0){
      free(data);
      return NULL;
    }
  }else{
    for(i=0;i<ASSET_COUNT;++i){
      if(strcmp(path, ASSET_KEYS[i])==0){
        size = ASSET_SIZES[i];
        data = (unsigned char*)malloc(sizeof(unsigned char)*(size+1));
        memcpy(data, ASSET_DATA[i], sizeof(unsigned char)*size);
        break;
      }
    }
  }
  if(data){
    data[size] = '\0';
  }

  return (char*)data;
}
