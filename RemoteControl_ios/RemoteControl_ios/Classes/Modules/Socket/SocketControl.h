//
//  SocketControl.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketMacro.h"

@interface SocketControl : NSObject

@property(nonatomic,assign) int socketReturn;

+(instancetype)share;

-(NSString*)connectIP:(NSString*)ip Port:(int)port;

-(void)sendMessageType:(int)messagetype datatype:(int)datatype data:(id)data;

@end
