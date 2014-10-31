//
//  frameworkViewController.m
//  framework
//
//  Created by Walt on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "frameworkViewController.h"
#import "EAGLView.h"

#import "app.h"

@interface frameworkViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation frameworkViewController


NSDate *lastTick = 0;



@synthesize animating, context, displayLink;

- (void)awakeFromNib {
    /*
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    self->didInit = false;
    */
}

- (void)dealloc {
    
    /*
    // Tear down context.
    if ([EAGLContext currentContext] == context){
      [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
    */
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    /*
    [self stopAnimation];
    */
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  /*
  
  // Tear down context.
  if ([EAGLContext currentContext] == context){
    [EAGLContext setCurrentContext:nil];
  }
  self.context = nil;	
  */
}

- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    /*
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
    */
}

- (void)stopAnimation
{
    /*
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
    */
}

- (void)drawFrame {
/*
    [(EAGLView *)self.view setFramebuffer];

    if(!self->didInit){
      self->didInit = true;
      NSString *path = [[NSBundle mainBundle] pathForResource:@"assets" ofType:@"zip"];
      NSLog(@"path: %@", path);
      [self startAnimation];

      appInit([path cStringUsingEncoding:1], 1);
    }
    
    NSDate *now = [NSDate new];
    NSTimeInterval timespan;
    if(lastTick){
        timespan = [now timeIntervalSinceDate:lastTick];
    }else{
        timespan = 0;
    }
    appRender(timespan*1000, ((EAGLView *)self.view)->framebufferWidth, ((EAGLView *)self.view)->framebufferHeight);

    lastTick = now;
    
    [(EAGLView *)self.view presentFramebuffer];
*/
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

@end
