//
//  SocketControl.h
//  RemoteControl_mac
//
//  Created by cxh on 17/1/3.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketControl : NSObject

+(instancetype)share;

-(void)start;

-(void)sendMessageType:(int)messagetype datatype:(int)datatype data:(id)data;
-(void)sendMessageType:(int)messagetype datatype:(int)datatype tag:(int)tag data:(id)data;

@end
