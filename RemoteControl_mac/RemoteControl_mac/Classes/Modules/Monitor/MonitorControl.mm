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

#define NetworkPort 1995 //端口号
#define MAX_LISTEN_NUM 1 //最大监听数

static MonitorControl* shareMonitorControl = nil;
@implementation MonitorControl{
    int socketReturn;
    int acceptreturn;
}


-(instancetype)share{
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
     *  @param 0           让系统自动为选择我们合适的协议
     *
     *  @return 返回该 socket 的文件描述符，如果描述符为 -1 表示创建失败
     */
    socketReturn = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
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
    if(bindreturn != -1){
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
    if(listenreturn != -1){
        NSLog(@"erron:%d str:%s",errno,strerror(errno));
        return;
    }
    
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
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
        while (true) {
            
        }
    }];
}
@end
