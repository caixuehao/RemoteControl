//
//  AppDelegate.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/3.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "SocketControl.h"
#import "StartController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[StartController share] autoStart];
    [[StartController share] hideDock];
    [[SocketControl share] start];
    
//    NSData* data = [NSData dataWithContentsOfFile:@"/Users/cxh/Desktop/文稿"];
//    NSLog(@"%@",[[NSDictionary alloc] initWithContentsOfFile:@"/Users/cxh/Desktop/文稿"]);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
//点击Dock重新打开主窗口
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
    [[MainViewController getShareMainViewController].view.window makeKeyAndOrderFront:self];

    return YES;
}
@end
