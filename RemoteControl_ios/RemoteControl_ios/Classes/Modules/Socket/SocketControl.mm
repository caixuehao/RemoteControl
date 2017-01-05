//
//  SocketControl.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>//sockaddr_in
#include<arpa/inet.h>//inet_addr

#import "SocketControl.h"


static SocketControl* shareSocketControl = nil;

@implementation SocketControl{
    int connectreturn;
    NSOperationQueue* sendQueue;
}

+(instancetype)share{
    @synchronized (self) {
        if (!shareSocketControl) {
            shareSocketControl = [[SocketControl alloc] init];
        }
    }
    return shareSocketControl;
}

-(instancetype)init{
    if (self = [super init]) {
        _socketReturn = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        sendQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(NSString*)connectIP:(NSString *)ip Port:(int)port{
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_port = htons(port);
    socketParameters.sin_addr.s_addr = inet_addr([ip UTF8String]);
    //http://blog.csdn.net/cj83111/article/details/5364138
    /**
     *  connect函数通常用于客户端建立tcp连接。
     *
     *  @param socketReturn
     *  @param sockaddr
     *
     *  @return 成功则返回0，失败返回-1
     */
    connectreturn = connect(_socketReturn,(struct sockaddr *) &socketParameters, sizeof(socketParameters));
    
    if(connectreturn == 0)return nil;
    
    return [NSString stringWithFormat:@"connectreturn:%d errno:%d str:%s len:%lu",connectreturn,errno,strerror(errno), sizeof(socketParameters)];
}

-(void)sendMessageType:(int)messagetype datatype:(int)datatype data:(id)data{
   
 
    [sendQueue addOperationWithBlock:^{
        
        NSData* senddata;
        int offset = 0;
        switch (datatype) {
            case DataType_String:
                senddata = [data dataUsingEncoding:NSUTF8StringEncoding];
                offset = 1;
                break;
            case DataType_NSDictionary:
                senddata = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
                break;
            default:
                senddata = data;
                break;
        }
        NSDictionary* headdic = @{@"messageType":@(messagetype),@"dataType":@(datatype),@"dataSize":@(senddata.length)};
        NSData* headdata =  [NSJSONSerialization dataWithJSONObject:headdic options:NSJSONWritingPrettyPrinted error:nil];
        send(_socketReturn, [headdata bytes], headdata.length, 0);
//        NSLog(@"%lu",(unsigned long)senddata.length);
        send(_socketReturn, [senddata bytes], senddata.length, 0);
        
    }];

    
}
@end
