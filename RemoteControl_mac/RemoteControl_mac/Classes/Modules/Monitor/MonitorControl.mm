//
//  MonitorControl.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/3.
//  Copyright © 2017年 cxh. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>//sockaddr_in
#include<arpa/inet.h>//inet_addr


#import "MonitorControl.h"
#import "SocketMacro.h"
#import "CommandLineController.h"
#import "ShutDownController.h"

#define MAX_LISTEN_NUM 1 //最大监听数

static MonitorControl* shareMonitorControl = nil;
@implementation MonitorControl{
    int socketReturn;
    int acceptreturn;
    NSOperationQueue* monitorQueue;
}


+(instancetype)share{
    @synchronized (self) {
        if (!shareMonitorControl) {
            shareMonitorControl = [[MonitorControl alloc] init];
        }
    }
    return shareMonitorControl;
}

-(void)start{
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
    NSLog(@"socketReturn:%d",socketReturn);
    if (socketReturn == -1) {
        NSLog(@"erron:%d str:%s",errno,strerror(errno));
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
    NSLog(@"bindreturn:%d",bindreturn);
    if(bindreturn != 0){
        NSLog(@"erron:%d str:%s",errno,strerror(errno));
        return;
    }
    
    /**
     *  listen 处于监听状态的套接字socketReturn将维护一个客户连接请求队列，该队列最多容纳MAX_LISTEN_NUM个用户请求。
     *
     *  @param socketReturn
     *  @param MAX_LISTEN_NUM
     *
     *  @return 0──成功， -1──失败
     */
    int listenreturn = listen(socketReturn,MAX_LISTEN_NUM);
    NSLog(@"listenreturn:%d",listenreturn);
    if(listenreturn != 0){
        NSLog(@"erron:%d str:%s",errno,strerror(errno));
        return;
    }
    
    monitorQueue = [[NSOperationQueue alloc] init] ;
    [monitorQueue addOperationWithBlock:^{
        [self monitor];
    }];
}


-(void)monitor{
    
    
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
    NSLog(@"acceptreturn:%d",acceptreturn);
    if(acceptreturn < 0){
        NSLog(@"erron:%d str:%s",errno,strerror(errno));
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
        size_t recvreturn = recv(acceptreturn,message, 1024, 0);
        //判断是否断开连接 http://blog.csdn.net/god2469/article/details/8801356
        if(recvreturn<=0 && errno != EINTR){
            NSLog(@"erron:%d str:%s",errno,strerror(errno));
            close(acceptreturn);
            [self monitor];
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
                [self executeCommand:[[headdic objectForKey:@"messageType"] intValue] datatype:[[headdic objectForKey:@"dataType"] intValue] data:recvData];
                headdic = nil;
            }
        }
    }
}



-(void)executeCommand:(int)messagetype datatype:(int)datatype data:(id)data{
    //转化数据类型
    if(datatype == DataType_String){
        data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else if(datatype == DataType_NSDictionary){
        data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    //根据消息类型来执行命令
    if (messagetype==MessageType_TerminalCommand) {
        [[CommandLineController share] shellCommands:data];
    }else if(messagetype == MessageType_Shutdown){
        [ShutDownController shutdown:data];
    }
    
    
}
@end
