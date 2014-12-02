#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#import "MJGStack.h"
#import "iap.h"

@interface EAGLView : UIView{
    @public BOOL needsReload;
    BOOL paused;
    NSMutableArray *touchArr;
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    BOOL didInit;
    //NSDate *lastTick;
    CFTimeInterval lastTick;
    BOOL initialized;
    GLint framebufferWidth;
    GLint framebufferHeight;
    GLuint colorRenderBuffer;
    IAP *iap;
    BOOL ignoreLastTick;
}

-(void)setPaused:(BOOL)paused;

@end

