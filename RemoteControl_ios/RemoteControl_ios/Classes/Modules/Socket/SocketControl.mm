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

#include <sys/types.h>
#include <sys/ioctl.h>

#import "SocketControl.h"


static SocketControl* shareSocketControl = nil;

@implementation SocketControl{
    int connectreturn;
    int udpSocketReturn;
    NSOperationQueue* sendQueue;
    NSOperationQueue* udpQueue;
    NSOperationQueue* tcpQueue;
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
        connectreturn = -1;
        sendQueue = [[NSOperationQueue alloc] init];
        udpQueue = [[NSOperationQueue alloc] init];
        tcpQueue = [[NSOperationQueue alloc] init];
        [self UDPinit];
    }
    return self;
}

-(void)UDPinit{
    udpSocketReturn = socket(AF_INET,SOCK_DGRAM,0);
    NSLog(@"udpSocketReturn:%d",udpSocketReturn);
    //接收信息
    
    [udpQueue addOperationWithBlock:^{
        char message[256];
        struct sockaddr_in socketParameters;
        socketParameters.sin_family = AF_INET;
        socketParameters.sin_port = htons(NetworkPort);
        
        while (true) {
            memset(message, 0, sizeof(message));
            socketParameters.sin_addr.s_addr = htonl(INADDR_ANY);
            socklen_t sin_len = sizeof(socketParameters);
            recvfrom(udpSocketReturn,message,sizeof(message),0,(struct sockaddr *)&socketParameters,&sin_len);
            NSLog(@"UDP_message:%s  IP:%s",message,inet_ntoa(socketParameters.sin_addr));
            
            if ([[NSString stringWithFormat:@"%s",message] isEqualToString:[NSString stringWithFormat:@"%s",IAmHere]]) {
                
                //主机有回应
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connect) object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectSuccess object:nil];
                }];
                connectreturn = connect(_socketReturn,(struct sockaddr *) &socketParameters, sizeof(socketParameters));
                if(connectreturn==0){
                    NSLog(@"链接成功");
                    [self tcpRecvMessage];
                }else{
                    NSLog(@"connectreturn:%d errno:%d str:%s len:%lu",connectreturn,errno,strerror(errno), sizeof(socketParameters));
                }
            }
        }
    }];
}
-(void)tcpRecvMessage{
    
    NSDictionary* headdic = nil;
    NSMutableData* recvData = nil;
    
    char message[1024];
    bool recvbool = true;
    while (recvbool) {
        //        char *message =  (char*)malloc(1024*sizeof(char));;
        memset(message,0,sizeof(message));
        size_t recvreturn = recv(connectreturn,message, sizeof(message), 0);
        //判断是否断开连接 http://blog.csdn.net/god2469/article/details/8801356
        if(recvreturn<=0 && errno != EINTR){
            NSLog(@"链接断开了 erron:%d str:%s",errno,strerror(errno));
            close(connectreturn);
            [self UDPinit];
            recvbool = false;
        }
        
        //读取信息
        
        if(headdic == nil){
            //读取头
            NSData *data = [NSData dataWithBytes: message length:strlen(message)];
            headdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"recvreturn:%zu headdic:%@",recvreturn,headdic);
            recvData = nil;
        }else{
            NSLog(@"recvreturn:%zu recvData:%s\n\n",recvreturn,message);
            //读取数据
            if(recvData == nil){
                recvData = [NSMutableData dataWithBytes: message length:strlen(message)];
            }else{
                [recvData appendBytes:message length:strlen(message)];
            }
            
            if(recvData.length >= [[headdic objectForKey:@"dataSize"] integerValue]){
                
                headdic = nil;
            }
        }
        
    }
}

-(void)connect{
    
    /**
     *  用udp发送信息
     *
     *  @param socketReturn 一个标识套接口的描述字
     *  @param message      包含待发送数据的缓冲区
     *  @param message      缓冲区中数据的长度
     *  @param message      调用方式标志位
     *  @param message      指针，指向目的套接口的地址
     *  @param message      所指地址的长度
     *
     *  @return 如果成功就返回发送的字节数，如果失败就返回SOCKET_ERROR
     */
   
    //发现速度挺快就不搞别的了
    [[[NSOperationQueue alloc] init]addOperationWithBlock:^{
        NSLog(@"%s",AnybodyHere);
        char message[100] = AnybodyHere;
        struct sockaddr_in socketParameters;
        socketParameters.sin_family = AF_INET;
        socketParameters.sin_port = htons(NetworkPort);
        for(int i = 0;i < 256;i++){
            for (int ii = 0; ii < 256; ii++) {
                NSString* str = [NSString stringWithFormat:@"192.168.%d.%d",i,ii];
                socketParameters.sin_addr.s_addr = inet_addr([str UTF8String]);
                sendto(udpSocketReturn,message,strlen(message)+1,0,(struct sockaddr *) &socketParameters, sizeof(socketParameters));
            }
        }
        //UDP可能发送失败，每1秒就重试一遍
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           if(connectreturn)[self performSelector:@selector(connect) withObject:nil afterDelay:1.0f];
        }];
    }];
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
     *  @param 套接字s想要连接的主机地址和端口号。
     *  @param name缓冲区的长度。
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
