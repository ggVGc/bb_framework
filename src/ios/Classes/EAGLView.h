#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

@interface EAGLView : UIView<SKProductsRequestDelegate>{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    BOOL didInit;
    NSDate *lastTick;
    BOOL initialized;
    GLint framebufferWidth;
    GLint framebufferHeight;
    GLuint colorRenderBuffer;
}

@end

