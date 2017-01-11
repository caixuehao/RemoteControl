//
//  SocketControl.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/3.
//  Copyright © 2017年 cxh. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>//sockaddr_in
#include<arpa/inet.h>//inet_addr


#import "SocketControl.h"
#import "SocketMacro.h"
#import "CommandLineController.h"
#import "ShutDownController.h"

#import "MainViewController.h"
#import "FileManagerController.h"
#define MAX_LISTEN_NUM 1 //最大监听数

static SocketControl* shareSocketControl = nil;
@implementation SocketControl{
    int socketReturn;
    int acceptreturn;
    NSOperationQueue* SocketQueue;
    NSOperationQueue* udpQueue;
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

-(void)start{
    
    
    udpQueue = [[NSOperationQueue alloc] init] ;
    sendQueue = [[NSOperationQueue alloc] init];
    
    
    /**
     *  socket  创建并初始化 socket，返回该 socket 的文件描述符，如果描述符为 -1 表示创建失败。
     *
     *  @param AF_INET     通常参数 IPv4(AF_INET) 或 IPv6(AF_INET6)
     *  @param SOCK_STREAM http://blog.csdn.net/nancy530421/article/details/6714974
     *  @param 0           让系统自动为选择我们合适的协议 IPPROTO_TCP 阻塞
     *
     *  @return 返回该 socket 的文件描述符，如果描述符为 -1 表示创建失败
     */
    socketReturn = socket(AF_INET, SOCK_STREAM, 0);
    Log(@"socketReturn:%d",socketReturn);
    if (socketReturn == -1) {
        Log(@"erron:%d str:%s",errno,strerror(errno));
        return;
    }
    
    /**
     *  bind 将 socket 与特定主机地址与端口号绑定
     *
     *  @param socketReturn
     *  @param sockaddr
     *
     *  @return 成功绑定返回0，失败返回 -1。
     */
    //http://blog.csdn.net/samulelin/article/details/4431351
    struct sockaddr_in servaddr;
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(NetworkPort);//端口
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);//INADDR_ANY表示任何IP
    int bindreturn = bind(socketReturn, (struct sockaddr *) &servaddr, sizeof(servaddr));
    Log(@"bindreturn:%d",bindreturn);
    if(bindreturn != 0){
        Log(@"erron:%d str:%s",errno,strerror(errno));
        return;
    }
    
    //UDP
    struct sockaddr_in udpSocketAddr;
    udpSocketAddr.sin_family = AF_INET;
    udpSocketAddr.sin_port = htons(NetworkPort);
    udpSocketAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    int udpSocketReturn = socket(AF_INET, SOCK_DGRAM, 0);
    Log(@"udpSocketReturn:%d",udpSocketReturn);
    int udpbindreturn = bind(udpSocketReturn, (struct sockaddr *) &udpSocketAddr, sizeof(udpSocketAddr));
    Log(@"udpbindreturn:%d",udpbindreturn);
    
    

    [udpQueue addOperationWithBlock:^{
        char message[256];
        socklen_t sin_len = sizeof(udpSocketAddr);
        while (1) {
            memset(message,0,sizeof(message));
            /**
             *  udp接收信息
             *
             *  @param  一个标识套接口的描述字
             *  @param  包含待接收数据的缓冲区
             *  @param  缓冲区中数据的长度
             *  @param  调用方式标志位
             *  @param  指针，指向目的套接口的地址
             *  @param  所指地址的长度
             *
             *  @return 成功则返回接收到的字符数,失败返回-1.
             */
            recvfrom(udpSocketReturn,message,sizeof(message),0,(struct sockaddr *)&udpSocketAddr,&sin_len);
            Log(@"UDP_message:%s  IP:%s",message,inet_ntoa(udpSocketAddr.sin_addr));
            if([[NSString stringWithFormat:@"%s",message] isEqualToString:[NSString stringWithFormat:@"%s",AnybodyHere]]){
                char sendmessage[] = IAmHere;
                Log(@"UDP_sendMessage:%s  IP:%s",sendmessage,inet_ntoa(udpSocketAddr.sin_addr));
                sendto(udpSocketReturn,sendmessage,strlen(sendmessage)+1,0,(struct sockaddr *) &udpSocketAddr, sizeof(udpSocketAddr));
            }
        }
    }];

    
    
    
    
    
    /**
     *  listen 处于监听状态的套接字socketReturn将维护一个客户连接请求队列，该队列最多容纳MAX_LISTEN_NUM个用户请求。
     *
     *  @param socketReturn
     *  @param MAX_LISTEN_NUM
     *
     *  @return 0──成功， -1──失败
     */
    int listenreturn = listen(socketReturn,MAX_LISTEN_NUM);
    Log(@"listenreturn:%d",listenreturn);
    if(listenreturn != 0){
        Log(@"erron:%d str:%s",errno,strerror(errno));
        return;
    }
    
    SocketQueue = [[NSOperationQueue alloc] init] ;
    [SocketQueue addOperationWithBlock:^{
        [self listenTCPConnect];
    }];
}




-(void)listenTCPConnect{
    
    /**
     *  accept 默认会阻塞进程
     *
     *  @param socketReturn
     *  @param sockaddr    与返回值关联的套接字
     *
     *  @return 一个新可用的套接字 非负描述字——成功， -1——失败
     */
    struct sockaddr_in  acceptaddr;
    socklen_t len = sizeof(acceptaddr);
    
    acceptreturn = accept(socketReturn, (struct sockaddr *) &acceptaddr, &len);
    Log(@"acceptreturn:%d",acceptreturn);
    if(acceptreturn < 0){
        Log(@"erron:%d str:%s",errno,strerror(errno));
        return;
    }
    
    
    NSDictionary* headdic = nil;
    NSMutableData* recvData = nil;
    

    char message[1024];
    //接收并打印客户端数据
    bool recvbool = true;
    while (recvbool) {
//        char *message =  (char*)malloc(1024*sizeof(char));;
        memset(message,0,sizeof(message));
        size_t recvreturn = recv(acceptreturn,message, sizeof(message), 0);
        //判断是否断开连接 http://blog.csdn.net/god2469/article/details/8801356
        if(recvreturn<=0 && errno != EINTR){
            Log(@"链接断开了 erron:%d str:%s",errno,strerror(errno));
            close(acceptreturn);
            [self listenTCPConnect];
            recvbool = false;
        }
        
        //读取信息
        
        if(headdic == nil){
            //读取头
            NSData *data = [NSData dataWithBytes: message length:strlen(message)];
            headdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            Log(@"recvreturn:%zu headdic:%@",recvreturn,headdic);
            recvData = nil;
        }else{
            Log(@"recvreturn:%zu recvData:%s\n\n",recvreturn,message);
            //读取数据
            if(recvData == nil){
                recvData = [NSMutableData dataWithBytes: message length:strlen(message)];
            }else{
                [recvData appendBytes:message length:strlen(message)];
            }
            
            if(recvData.length >= [[headdic objectForKey:@"dataSize"] integerValue]){
                [self executeCommand:[[headdic objectForKey:@"messageType"] intValue] datatype:[[headdic objectForKey:@"dataType"] intValue] data:recvData];
                headdic = nil;
            }
        }
    }
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
        send(acceptreturn, [headdata bytes], headdata.length, 0);
        //        NSLog(@"%lu",(unsigned long)senddata.length);
        send(acceptreturn, [senddata bytes], senddata.length, 0);
        
    }];
    
    
}





-(void)executeCommand:(int)messagetype datatype:(int)datatype data:(id)data{
    //转化数据类型
    if(datatype == DataType_String){
        data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else if(datatype == DataType_NSDictionary){
        data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    //根据消息类型来执行命令
    if (messagetype == MessageType_TerminalCommand) {
        [[CommandLineController share] shellCommands:data];
    }else if(messagetype == MessageType_Shutdown){
        [ShutDownController shutdown:data];
    }else if(messagetype == MessageType_OpenURL){
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:data]];
    }else if(messagetype == MessageType_FileManager){
        [[FileManagerController share] sendFileList:data];
    }
    
}
@end
