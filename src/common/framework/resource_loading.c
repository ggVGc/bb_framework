#include <stdlib.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>
#include <png.h>
#include <zip.h>
#include <unzip.h>
#include <physfs.h>
#include "resource_loading.h"
#include "rawbitmapdata.h"
#include "util.h"
#include "assets.c"


enum{
  TMP_PATH_SIZE = 4096
};


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


typedef struct BufFile{
  int size;
  int curPos;
  char *buf;
} BufFile;

void BufFileRead(char *out, BufFile *bf, int length){
  int bytesLeft = bf->size - bf->curPos;
  int count = length<bytesLeft?length:bytesLeft;
  memcpy(out, bf->buf+bf->curPos, count);
  bf->curPos+=count;
}

void png_buf_read(png_structrp png_ptr, png_bytep data, png_size_t length) {
  BufFile *bf = png_get_io_ptr(png_ptr);
  BufFileRead(data, bf, length);
}

void setResourcePath(const char* rootPath) {
  char msg[2048];
  char path[4096];
  sprintf(msg, "Setting resource path: %s", rootPath);
  trace(msg);
  sprintf(path, "%s", rootPath);
  PHYSFS_mount(path, "assets", 1);
  PHYSFS_mount(rootPath, NULL, 1); // for android, since the APK contains a folder called assets
  sprintf(path, "%s%sassets", rootPath, strlen(rootPath)==0?"":"/");
  PHYSFS_mount(path, "assets", 1);
  sprintf(path, "%s%sassets.zip", rootPath, strlen(rootPath)==0?"":"/");
  PHYSFS_mount(path, "assets", 1);
  sprintf(path, "%s%sassets_framework.zip", rootPath, strlen(rootPath)==0?"":"/");
  PHYSFS_mount(path, "assets", 1);
  sprintf(path, "%s%sframework_src", rootPath, strlen(rootPath)==0?"":"/");
  PHYSFS_mount(path, "assets", 1);
  PHYSFS_mount("assets.zip", "assets", 1);
  PHYSFS_mount("framework_src", "assets", 1);
  PHYSFS_mount("", "assets", 1);
  PHYSFS_mount("assets", "assets", 1);
  PHYSFS_mount("compiled", "assets", 1);
}

/*
int getFileSize(const char *path){
  PHYSFS_file* f = PHYSFS_openRead("myfile.txt");
  int sz = PHYSFS_fileLength(f);
  PHYSFS_close(f);
  return sz;
}
*/

unsigned char* loadBytes(const char* inPath, int* sz){
  unsigned char *outData = NULL;
  char path[TMP_PATH_SIZE];
  if(strlen(inPath)+8>=TMP_PATH_SIZE){
    trace("loadBytes - Path is too long");
    return NULL;
  }
  sprintf(path, "assets/%s", inPath);
  int i;
  if(PHYSFS_exists(path)){
    PHYSFS_file* f = PHYSFS_openRead(path);
    *sz = PHYSFS_fileLength(f);
    outData = malloc(*sz);
    int length_read = PHYSFS_readBytes(f, outData, *sz);
    PHYSFS_close(f);
  }else{
    for(i=0;i<ASSET_COUNT;++i){
      if(strcmp(inPath, ASSET_KEYS[i])==0){
        if (sz != 0) {
          *sz = ASSET_SIZES[i];
        }
        outData = (unsigned char*)malloc(ASSET_SIZES[i]);
        memcpy(outData, ASSET_DATA[i], ASSET_SIZES[i]);
      }
    }
  }
  if(!outData){
    trace("Could not locate file:");
    trace(inPath);
  }
  return outData;
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
  BufFile bf;
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
  RawBitmapData* d = NULL;
  int x,y;
  printf("loadimage: %s\n", inFilename);
  /*
  char filename[2048];
  sprintf(filename, "assets/%s", inFilename);
  */

  /*
  uf = unzOpen(apkPath);
  if(uf == NULL) {
    return NULL;
  }
  */

  /*
  ret = unzLocateFile(uf, filename, 0);
  if(ret != UNZ_OK) {
  */

  
  bf.buf = loadBytes(inFilename, &bf.size);
  bf.curPos = 0;
  if(!bf.buf){
    trace("loadImage - Could not locate file:");
    trace(inFilename);
    goto cleanup;
  }

  /*
  unzOpenCurrentFile(uf);
  */

  //read the header for testing if it is a png
  /*
  unzReadCurrentFile(uf, header, 8);
  */
  BufFileRead(header, &bf, sizeof(png_byte)*8);


  //test if png
  is_png = !png_sig_cmp(header, 0, 8);
  if (!is_png) {
    trace("Not a png file");
    goto cleanup;
  }

  //create png struct
  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png_ptr) {
    trace("Could not create PNG read struct");
    goto cleanup;
  }

  //create png info struct
  info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr) {
    trace("Could not create PNG info struct");
    png_destroy_read_struct(&png_ptr, (png_infopp) NULL, (png_infopp) NULL);
    //LOGE("Unable to create png info : %s", filename);
    goto cleanup;
  }

  //create png info struct
  end_info = png_create_info_struct(png_ptr);
  if (!end_info) {
    trace("Could not create PNG end info struct");
    png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp) NULL);
    //LOGE("Unable to create png end info : %s", filename);
    goto cleanup;
  }

  //png error stuff, not sure libpng man suggests this.
  if (setjmp(png_jmpbuf(png_ptr))) {
    trace("PNG: Failed setting error handler");
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    //LOGE("Error during setjmp : %s", filename);
    goto cleanup;
  }

  //init png reading
  png_set_read_fn(png_ptr, &bf, png_buf_read);

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
    goto cleanup;
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
    goto cleanup;
  }

  //row_pointers is for pointing to image_data for reading the png with libpng
  row_pointers = (png_bytep*)malloc(sizeof(png_bytep)*height);
  if (!row_pointers) {
    //clean up memory and close stuff
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    free(image_data);
    goto cleanup;
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

  for(x=0;x<width;++x){
    for(y=0;y<height;++y){
      multiplyPixelAt(x,y,height, d->data);
    }
  }

cleanup:
  if(bf.buf){
    free(bf.buf);
  }
  return d;
}


char* loadText(const char* path){
  int size;
  unsigned char* data = loadBytes(path, &size);
  if(!data){
    int i;
    for(i=0;i<ASSET_COUNT;++i){
      if(strcmp(path, ASSET_KEYS[i])==0){
        size = ASSET_SIZES[i];
        data = (unsigned char*)malloc(size);
        memcpy(data, ASSET_DATA[i], size);
        break;
      }
    }
  }
  if(data){
    data = realloc(data, size+1);
    if(data){
      data[size] = '\0';
    }
  }

  return (char*)data;
}
