#import "EAGLView.h"
#import "app.h"
#import "framework/input.h"
#import "framework/Camera.h"

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


-(GLuint) setupRenderBuffer{
  GLuint colorRenderBuffer;
  glGenRenderbuffers(1, &colorRenderBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);        
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];    
  return colorRenderBuffer;
}

- (void)setupFrameBuffer {    
  GLuint renderBuf = [self setupRenderBuffer];
  GLuint framebuffer;
  glGenFramebuffers(1, &framebuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);   
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuf);

  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
}

- (void)render:(CADisplayLink*)displayLink {
  if(!didInit){
    didInit = true;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"assets" ofType:@"zip"];
    NSLog(@"path: %@", path);
    appInit(1,framebufferWidth, framebufferHeight, [path cStringUsingEncoding:1],1);
  }

  NSDate *now = [NSDate new];
  NSTimeInterval timespan = [now timeIntervalSinceDate:lastTick];
  appRender(timespan*1000);

  lastTick = now;

  [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupDisplayLink {
  CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
  lastTick = [NSDate new];
  [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}


- (id)initWithCoder:(NSCoder*)coder {
  NSLog(@"EAGLView initWithCoder");
  self = [super initWithCoder:coder];
  if (self) {        
    self.backgroundColor = [UIColor blackColor];
    didInit = false;
    setScreenWidth(self.frame.size.width);
    setScreenHeight(self.frame.size.height);
    [self setupLayer];        
    [self setupContext];    
    [self setupFrameBuffer];     
    [self setupDisplayLink];
  }
  return self;
}

- (void)dealloc {
  [_context release];
  _context = nil;
  [super dealloc];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  NSLog(@"touchesBegan");
  CGPoint p = [[touches anyObject] locationInView:self];
  setCursorPos(0, p.x, p.y);
  setCursorDownState(0, 1);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
  NSLog(@"touchesMoved");
  CGPoint p = [[touches anyObject] locationInView:self];
  setCursorPos(0, p.x, p.y);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  NSLog(@"touchesEnded");
  CGPoint p = [[touches anyObject] locationInView:self];
  setCursorPos(0, p.x, p.y);
  setCursorDownState(0, 0);
}



@end

