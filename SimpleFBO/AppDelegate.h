//
//  AppDelegate.h
//  SimpleFBO
//
//  Created by alexey on 21.01.12.
//  Copyright (c) 2012 support@epicreal.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OpenGLControl.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet OpenGLControl *render;

@end
