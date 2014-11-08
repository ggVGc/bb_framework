
#import <stdio.h>
#import <math.h>
#import <mach/mach_time.h>
#import "EAGLView.h"
#import "app.h"
#import "framework/input.h"
#import "framework/Camera.h"
#import "util_ios.h"
#import "framework/timing.h"


@implementation EAGLView
+ (Class)layerClass {
  return [CAEAGLLayer class];
}

- (void)setupLayer {
  _eaglLayer = (CAEAGLLayer*) self.layer;
  _eaglLayer.opaque = YES;
}

- (void)setupContext {   
  EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES1;
  _context = [[EAGLContext alloc] initWithAPI:api];
  if (!_context) {
    NSLog(@"Failed to initialize OpenGLES context");
    //exit(1);
  }

  if (![EAGLContext setCurrentContext:_context]) {
    NSLog(@"Failed to set current OpenGL context");
    //exit(1);
  }
}


-(void)setPaused:(BOOL pause){
  [touchArr removeAllObjects];
  self->paused = pause;
}

-(void) setupRenderBuffer{
  glGenRenderbuffers(1, &colorRenderBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);        
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];    
}


- (void)setupFrameBuffer {    
  [self setupRenderBuffer];
  GLuint framebuffer;
  glGenFramebuffers(1, &framebuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);   
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderBuffer);   
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);

  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
}

static mach_timebase_info_data_t timeBase;
static uint64_t timeZero;


double elapsedTime(){
return ((double)(mach_absolute_time() - timeZero))
        * ((double)timeBase.numer) / ((double)timeBase.denom) / 1000000000.0;
}

- (void)render:(CADisplayLink*)displayLink {
  static double bank = 0;
  double frameTime = displayLink.duration * displayLink.frameInterval;
  bank -= frameTime;
  if( bank > 0 ) {
    return;
  }
  if(paused){
    return;
  }
  if (![EAGLContext setCurrentContext:_context]) {
    NSLog(@"Failed to set current OpenGL context");
    return;
  }
  if(!didInit){
    didInit = true;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"assets" ofType:@"zip"];
    //NSLog(@"path: %@", path);
    //alert(@"Framebuffer size ", [NSString stringWithFormat:@"w:%i, h:%i", framebufferWidth, framebufferHeight ]);
    appInit(1,framebufferWidth, framebufferHeight, [path cStringUsingEncoding:1],1);
  }

  /*
  NSDate *now = [NSDate new];
  NSTimeInterval timespan = [now timeIntervalSinceDate:lastTick];
  */
  if(self->needsReload){
    appGraphicsReload(framebufferWidth, framebufferHeight);
    self->needsReload = false;
  }

  bank = 0;
  timeZero = mach_absolute_time();
  CFTimeInterval now = displayLink.timestamp;
  if(lastTick>0){
    appRender((now - lastTick)*1000);
  }else{
    appRender(1);
  }
  lastTick = now;
  double elapsed = elapsedTime();
  bank = elapsed;
  if(elapsed>frameTime){
    bank = frameTime+fmod(elapsed, frameTime);
  }

  [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Request failed with error %@", error);
    alert(@"", [NSString stringWithFormat:@"Request failed with error %@", error]);
}
- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"Request finished");
    alert(@"", @"Request finished");
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Product request finihsed");
    for(SKProduct *p in response.products){
      NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
      [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
      [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
      [numberFormatter setLocale:p.priceLocale];
      NSString *formattedString = [numberFormatter stringFromNumber:p.price];
      NSString *str = [NSString stringWithFormat:@"Product: %@, %@", p.productIdentifier, formattedString];
      NSLog(@"%@", str);
      alert(@"", str);
    }
  //self.products = response.products;

  for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
      NSLog(@"Invalid product: %@", invalidIdentifier);
      alert(@"", [NSString stringWithFormat:@"Invalid product: %@", invalidIdentifier]);
  }

  //[self displayStoreUI]; // Custom method
}


- (void)setupDisplayLink {
  CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
  displayLink.frameInterval = 1;
  //lastTick = [NSDate new];
  lastTick = -1;
  [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}


- (id)initWithCoder:(NSCoder*)coder {
  NSLog(@"EAGLView initWithCoder");
  self = [super initWithCoder:coder];
  if (self) {        
    touchArr = [[NSMutableArray alloc] init];
    self.multipleTouchEnabled = true;
    mach_timebase_info( &timeBase );
    self.backgroundColor = [UIColor blackColor];
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    didInit = false;
    needsReload = false;
    paused = false;
    CGSize s = self.bounds.size;
    //alert(@"Window size", [NSString stringWithFormat:@"w:%f, h:%f", s.width, s.height]);
    setScreenWidth(s.width);
    setScreenHeight(s.height);
    [self setupLayer];        
    [self setupContext];    
    [self setupFrameBuffer];     
    [self setupDisplayLink];
  }
  return self;
}


- (void)dealloc {
  _context = nil;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  NSLog(@"touchesBegan");
  for(UITouch *t in touches){
    CGPoint p = [t locationInView:self];
    int ind = -1;
    for(int i=0;i<touchArr.count;++i){
      if(touchArr[i] == [NSNull null]){
        ind = i;
        break;
      }
    }
    if(ind == -1){
      ind = touchArr.count;
      [touchArr addObject:t];
    }else{
      touchArr[ind] = t;
    }
    setCursorPos(ind, p.x, p.y);
    setCursorDownState(ind, 1);
  }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
  for(UITouch *thisTouch in touches){
    int ind = -1;
    for(int i=0;i<touchArr.count;++i){
      if(touchArr[i] == thisTouch){
        ind = i;
        break;
      }
    }
    if(ind>=0){
      CGPoint p = [thisTouch locationInView:self];
      setCursorPos(ind, p.x, p.y);
    }
  }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  NSLog(@"touchesEnded");
  for(UITouch *thisTouch in touches){
    int ind = -1;
    for(int i=0;i<touchArr.count;++i){
      if(touchArr[i] == thisTouch){
        ind = i;
        break;
      }
    }
    if(ind>=0){
      CGPoint p = [thisTouch locationInView:self];
      setCursorPos(ind, p.x, p.y);
      setCursorDownState(ind, 0);
      touchArr[ind] = [NSNull null];
    }
  }
}





@end






/*
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>

#import "EAGLView.h"
#import "app.h"
#import "framework/input.h"
#import "framework/Camera.h"
#import "util_ios.h"

//CONSTANTS:

#define kBrushOpacity		(1.0 / 3.0)
#define kBrushPixelStep		3
#define kBrushScale			2



@interface EAGLView()
{
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;
    
    // Buffer Objects
    GLuint vboId;
    
    BOOL initialized;
}

@end

@implementation EAGLView


// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass
{
	return [CAEAGLLayer class];
}


- (void)setupDisplayLink {
  CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
  lastTick = [NSDate new];
  [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

- (void)render:(CADisplayLink*)displayLink {
  if(!didInit){
    didInit = true;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"assets" ofType:@"zip"];
    NSLog(@"path: %@", path);
    alert(@"Framebuffer size ", [NSString stringWithFormat:@"w:%i, h:%i", backingWidth, backingHeight]);
    appInit(1,backingWidth, backingHeight, [path cStringUsingEncoding:1],1);
  }

  NSDate *now = [NSDate new];
  NSTimeInterval timespan = [now timeIntervalSinceDate:lastTick];
  appRender(timespan*1000);

  lastTick = now;

  [context presentRenderbuffer:GL_RENDERBUFFER];
}


// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
	
    if ((self = [super initWithCoder:coder])) {
      didInit = false;
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		// In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
        EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES1;
        context = [[EAGLContext alloc] initWithAPI:api];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
			return nil;
		}
        
        // Set the view's scale factor as you wish
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
	}
	
	return self;
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews {
	[EAGLContext setCurrentContext:context];
    
    if (!initialized) {
        initialized = [self initGL];
        if(initialized){
          [self setupDisplayLink];
        }
    }
    else {
        [self resizeFromLayer:(CAEAGLLayer*)self.layer];
        NSLog(@"RESIZE");
    }
}


- (BOOL)initGL {
    // Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffers(1, &viewFramebuffer);
	glGenRenderbuffers(1, &viewRenderbuffer);
	
	glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    NSLog(@"W:%i, H:%i", backingWidth, backingHeight);
	
	// For this sample, we do not need a depth buffer. If you do, this is how you can create one and attach it to the framebuffer:
//    glGenRenderbuffers(1, &depthRenderbuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		return NO;
	}
    
    // Setup the view port in Pixels
    glViewport(0, 0, backingWidth, backingHeight);
    
    // Create a Vertex Buffer Object to hold our data
    glGenBuffers(1, &vboId);
    
    // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    // Playback recorded path, which is "Shake Me"
    NSMutableArray* recordedPaths = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Recording" ofType:@"data"]];
    if([recordedPaths count])
        [self performSelector:@selector(playback:) withObject:recordedPaths afterDelay:0.2];
    
    return YES;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
    // For this sample, we do not need a depth buffer. If you do, this is how you can allocate depth buffer backing:
//    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
	
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
        NSLog(@"Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    // Update viewport
    glViewport(0, 0, backingWidth, backingHeight);
	
    return YES;
}

// Erases the screen
- (void)erase
{
	[EAGLContext setCurrentContext:context];
	
	// Clear the buffer
	glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Display the buffer
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
*/
