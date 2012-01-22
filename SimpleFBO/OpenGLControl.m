//
//  OpenGLControl.m
//  SimpleFBO
//
//  Created by alexey on 21.01.12.
//  Copyright (c) 2012  support@epicreal.com All rights reserved.
//

#import "OpenGLControl.h"

#define TextureWidth    512
#define TextureHeight   512

static void SwitchTo2DMode ( int Width, int Height )
{
    glMatrixMode ( GL_PROJECTION );
    glLoadIdentity ( );
    glOrtho ( 0, Width, Height, 0, -1, 1 );
    
    glMatrixMode ( GL_MODELVIEW );
    glLoadIdentity ( );		
}

@implementation OpenGLControl

- (id) init
{
    self = [ super init ];
    if ( self )
    {
        fboComplete =   NO;
        fboStatus   =   NO;
    }
    
    return self;
}

- (void) dealloc
{
    [ self clear ];
    
    [ super dealloc ];
}

- (void) clear
{
    [ _timer invalidate ];
    
    if ( -1 != textureId )
        glDeleteTextures(1, &textureId);
    
    if ( -1 != frameBufferId )
        glDeleteFramebuffersEXT(1, &frameBufferId);   
    
    fboStatus   =   NO;
}

- (void) drawRect : (NSRect)rect
{	
    if ( nil == _timer )
    {
        _timer = [ NSTimer timerWithTimeInterval : 0.001   //	a 1ms time interval
                                          target : self
                                        selector : @selector(timerFired:)
                                        userInfo : nil
                                         repeats : YES ];
        
        [ [ NSRunLoop currentRunLoop ] addTimer : _timer forMode : NSDefaultRunLoopMode ];
        [ [ NSRunLoop currentRunLoop ] addTimer : _timer forMode : NSEventTrackingRunLoopMode ]; 
    }
    
    if ( NO == fboComplete )
    {
        fboStatus       =   [ self initFBO ];
        
        fboComplete     =   YES;
    }
 	
    [ [ self openGLContext ] makeCurrentContext ];
    
    glClearColor ( 0.0f, 0.0f, 0.0f, 0.0f );
	glClear ( GL_COLOR_BUFFER_BIT ); 
    
    if ( fboStatus )
    {        
        glDisable ( GL_TEXTURE_2D );
        
        [ self drawWireTeapot : self.frame.size x : 2.0f y : 0.0f z : - 6.0f ];
        
        /*
         
         draw in to fbo
         
         */
        
        [ self changeFrameBuffer ];
        
        glClearColor ( 0.0f, 0.0f, 1.0f, 1.0f ); 
        glClear ( GL_COLOR_BUFFER_BIT );
        
        glDisable ( GL_TEXTURE_2D );
        
        [ self drawWireTeapot : CGSizeMake ( TextureWidth, TextureHeight ) x: 0.0f y : 0.0f z : -5.0f ];
        
        [ self changeMainBuffer ];
        
        
        /*
         
         draw fbo attached texture
         
         */
        
        SwitchTo2DMode ( self.frame.size.width, self.frame.size.height );
        
        glEnable ( GL_TEXTURE_2D );
        
        glActiveTextureARB ( GL_TEXTURE0  );
		glBindTexture ( GL_TEXTURE_RECTANGLE_EXT, textureId );		
  		glTexEnvi ( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL );
        
        float offset    =   35.0f;
        
        glBegin(GL_QUADS);
		
		glTexCoord2f(0, 1);
		glVertex2f(offset,  ( -TextureHeight + self.frame.size.height) * 0.5f);
		
		glTexCoord2f(1, 1);
		glVertex2f(TextureWidth + offset,  ( -TextureHeight + self.frame.size.height) * 0.5f);
		
		glTexCoord2f(1, 0);
		glVertex2f(TextureWidth + offset, ( +TextureHeight + self.frame.size.height) * 0.5f );
		
		glTexCoord2f(0, 0);
		glVertex2f(offset,  ( +TextureHeight + self.frame.size.height) * 0.5f);	
		
		glEnd();
        
    }
    
    [ [ self openGLContext ] flushBuffer ]; 
}

- (void) timerFired : (id)sender
{
   	[ self setNeedsDisplay : YES ];
}

#pragma mark -
#pragma mark framebuffer

- (BOOL) initFBO
{
    // check extension
    const GLubyte* extensions = glGetString ( GL_EXTENSIONS );
    if ( extensions )
    {   
        if ( 0 == gluCheckExtension((GLubyte*)("GL_EXT_framebuffer_object"), extensions ) )
        {
            NSLog(@"GL_EXT_framebuffer_object - not support");
            
            return NO;
        }
    }
    
    glEnable ( GL_TEXTURE_2D );	
    
    // create texture for fbo
    
    glGenTextures ( 1, &textureId );
    glBindTexture ( GL_TEXTURE_2D, textureId );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexImage2D ( GL_TEXTURE_2D, 0, 4, TextureWidth, TextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0 );
    
    // create framebuffer
    
    glGenFramebuffersEXT ( 1, &frameBufferId );
    glBindFramebufferEXT ( GL_FRAMEBUFFER_EXT, frameBufferId );
    glFramebufferTexture2DEXT ( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,  GL_TEXTURE_2D, textureId, 0 );   //  attach texture to framebuffer
    
    // check framebuffer
    
    GLenum status = glCheckFramebufferStatusEXT ( GL_FRAMEBUFFER_EXT );
    if ( status != GL_FRAMEBUFFER_COMPLETE_EXT )
    {
        switch ( status )
        {
            case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
                NSLog(@"FrameBuffer Error - GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
                NSLog(@"FrameBuffer Error - GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
                NSLog(@"FrameBuffer Error - GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
                NSLog(@"FrameBuffer Error - GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT");
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
                NSLog(@"FrameBuffer Error - GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT");                          
                break;
            case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
                NSLog(@"FrameBuffer Error - GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT");
                break;
            case GL_FRAMEBUFFER_UNSUPPORTED_EXT:
                NSLog(@"FrameBuffer Error - GL_FRAMEBUFFER_UNSUPPORTED_EXT");
                break;
            default:
                NSLog(@"FrameBuffer Error - Unknown error");
                
                break;
        }
       
        glBindFramebufferEXT ( GL_FRAMEBUFFER_EXT, 0 );      // off framebuffer
       
        return NO;
    }
   
    glBindFramebufferEXT ( GL_FRAMEBUFFER_EXT, 0 );      // off framebuffer
    
    return YES;
}

- (void) changeFrameBuffer
{
    glBindFramebufferEXT ( GL_FRAMEBUFFER_EXT, frameBufferId ); 
    
    glViewport ( 0, 0, TextureWidth, TextureHeight );
    SwitchTo2DMode ( TextureWidth, TextureHeight );
}

- (void) changeMainBuffer
{
    glBindFramebufferEXT ( GL_FRAMEBUFFER_EXT, 0 );      // off framebuffer
    
    glViewport ( 0, 0, self.frame.size.width, self.frame.size.height );
    SwitchTo2DMode ( self.frame.size.width, self.frame.size.height );
}

- (void) drawWireTeapot : (CGSize) size x : (CGFloat) x y : (CGFloat) y z : (CGFloat) z
{
    glMatrixMode(GL_PROJECTION);   glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);    glLoadIdentity();
    
    glMatrixMode(GL_PROJECTION);
    
    gluPerspective ( 45.0f, size.width / size.height, 1.0f, 100.0f );
    glViewport ( 0.0f, 0.0f, size.width, size.height ); 
    
    glTranslatef ( x, y, z );
    
    static float angle  =   0.0; 
    
    if ( _timer )
        angle += 300.0f * [ _timer timeInterval ];
    
    glRotatef(angle, 0, 1, 0);
    
    glColor3f(1,1,0);
    glutWireTeapot(1);
}


@end
