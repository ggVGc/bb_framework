#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

@interface EAGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    BOOL didInit;
    NSDate *lastTick;
    GLint framebufferWidth;
    GLint framebufferHeight;
}

@end

