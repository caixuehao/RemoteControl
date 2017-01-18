//
//  CommandLineController.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "CommandLineController.h"
#import "MainViewController.h"


static CommandLineController* shareCommandLineController = nil;

@implementation CommandLineController{
   
}

+(instancetype)share{
    @synchronized (self) {
        if (!shareCommandLineController) {
            shareCommandLineController = [[CommandLineController alloc] init];
        }
    }
    return shareCommandLineController;
}

-(instancetype)init{
    if (self = [super init]) {
       
    }
    return self;
}

-(void)shellCommands:(NSString*)commands{
    NSLog(@"%@",commands);
    int systemReturn = system([commands UTF8String]);
    Log(@"systemReturn:%d",systemReturn);
}

@end
