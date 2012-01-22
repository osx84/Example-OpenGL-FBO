//
//  AppDelegate.m
//  SimpleFBO
//
//  Created by alexey on 21.01.12.
//  Copyright (c) 2012 support@epicreal.com. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize render = _render;

- (void)dealloc
{
    [super dealloc];
}

- (void) applicationDidFinishLaunching : (NSNotification *) aNotification
{
   [ self.window setDelegate : (id <NSWindowDelegate>) (self) ];   //  bad off (((
}

- (BOOL)windowShouldClose:(id)sender
{
    //  [ NSApp terminate : self ];         
    
    return YES;
}

// reopen window from dock

- (BOOL) applicationShouldHandleReopen : (NSApplication *) theApplication hasVisibleWindows : (BOOL)flag
{
    [ self.window makeKeyAndOrderFront : nil ];
    [ NSApp activateIgnoringOtherApps : YES ];
    
	return YES;
}

@end
