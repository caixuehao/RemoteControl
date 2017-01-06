//
//  StartController.h
//  RemoteControl_mac
//
//  Created by cxh on 17/1/6.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartController : NSObject

+(instancetype)share;

-(void)autoStart;

-(void)hideDock;

@end
