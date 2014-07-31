#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <png.h>
#include <zip.h>
#include <unzip.h>
#include "resource_loading.h"
#include "rawbitmapdata.h"


//static struct zip* APKArchive;
static struct zip_file* file = 0;
static char apkPath[2048];
static int usingZip = 0;


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


unsigned char* loadBytesFromZip(const char* inPath, int* size){
  unzFile uf;

  // TODO: Should check for overflow.
  char path[2048];
  char msg[2048];
  sprintf(path, "assets/%s\0", inPath);
  
  /*
  sprintf(msg, "Loading from zip: %s", path);
  trace(msg);
  */
  uf = unzOpen(apkPath);

  if(!uf){
    sprintf(msg, "Invalid resource zip: %s", apkPath);
    trace(msg);
  }


  /*if (!file)*/
  /*{*/
   /*//LOGE("Error opening from APK: %s ", path);*/
   /*zip_fclose(file);*/

   /*return NULL;*/
  /*}*/
  /*else*/
  {
    char* data;
    unz_file_info* info = (unz_file_info*)malloc(sizeof(unz_file_info));

    if(unzLocateFile(uf, path, 0)){
      trace("Invalid file path");
	  return NULL;
	}
		
    unzGetCurrentFileInfo(uf, info, NULL, 0, NULL, 0, NULL, 0);


    data = (char*)malloc(info->uncompressed_size+1);
    unzOpenCurrentFile(uf);
    unzReadCurrentFile(uf, data, info->uncompressed_size);

    data[info->uncompressed_size] = '\0';
    
    free(info);
    unzCloseCurrentFile(uf);
    unzClose(uf);

    if (size != 0)
    {
      *size = info->uncompressed_size;
    }
  
    return data;
  }
}

unsigned char* loadBytesFromDisk(const char* inPath)
{
  // TODO: Should check for overflow.
  char path[2048];
  sprintf(path, "assets/%s\0", inPath);

  /*TODO: Implement!*/
  /*FILE* f = fopen(path);*/
  /*fclose(path);*/
  return "NOT IMPLEMENTED";
}

unsigned char* loadBytes(const char* path, int* sz){
  if(usingZip)
    return loadBytesFromZip(path, sz);
  else
    return loadBytesFromDisk(path);
}


int multiplyPixelAt(int x,int y, int height,unsigned char *data){
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

  if(uf == NULL)
  {
      return NULL;
  }

  ret = unzLocateFile(uf, filename, 0);
  if(ret != UNZ_OK)
  {
      unzClose(uf);
      return NULL;
  }

  unzOpenCurrentFile(uf);

  //header for testing if it is a png

  //read the header
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
  int sz;
  return (char*)loadBytes(path, &sz);
}
