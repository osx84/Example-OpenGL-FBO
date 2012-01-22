//
//  OpenGLControl.h
//  SimpleFBO
//
//  Created by alexey on 21.01.12.
//  Copyright (c) 2012 support@epicreal.com All rights reserved.
//

#import <AppKit/AppKit.h>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <OpenGL/glext.h>
#import <GLUT/glut.h>

@interface OpenGLControl : NSOpenGLView
{
    NSTimer*    _timer;
    BOOL        fboComplete;
    BOOL        fboStatus;
    
    GLuint textureId;
    GLuint frameBufferId;
}

- (BOOL) initFBO;
- (void) clear;
- (void) changeFrameBuffer;
- (void) changeMainBuffer;

- (void) drawWireTeapot : (CGSize) size x : (CGFloat) x y : (CGFloat) y z : (CGFloat) z;

@end
