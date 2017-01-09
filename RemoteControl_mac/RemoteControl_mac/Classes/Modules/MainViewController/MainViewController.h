//
//  MainViewController.h
//  RemoteControl_mac
//
//  Created by cxh on 17/1/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTextView *textView;

void Log(NSString *format, ...);

+(MainViewController*)getShareMainViewController;

@end
