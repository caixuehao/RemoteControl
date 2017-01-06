//
//  AppDelegate.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/3.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "AppDelegate.h"
#import "MonitorControl.h"
#import "StartController.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
   
    [[StartController share] autoStart];
    [[StartController share] hideDock];
    [[MonitorControl share] start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
