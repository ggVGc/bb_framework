#ifndef UTIL_IOS_H_HYRPMONU
#define UTIL_IOS_H_HYRPMONU




#import <UIKit/UIKit.h>

static void alert(NSString *title, NSString *msg){

 UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                      message:msg
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [av show];
}

#endif /* end of include guard: UTIL_IOS_H_HYRPMONU */
