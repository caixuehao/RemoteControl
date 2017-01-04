//
//  CommandLineController.h
//  RemoteControl_mac
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandLineController : NSObject
+(instancetype)share;
-(void)shellCommands:(NSString*)commands;
@end
