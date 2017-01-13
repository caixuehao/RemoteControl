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
        
        BOOL bl = YES;
        while (bl) {
            memset(message, 0, sizeof(message));
            socketParameters.sin_addr.s_addr = htonl(INADDR_ANY);
            socklen_t sin_len = sizeof(socketParameters);
            recvfrom(udpSocketReturn,message,sizeof(message),0,(struct sockaddr *)&socketParameters,&sin_len);
            NSLog(@"UDP_message:%s  IP:%s",message,inet_ntoa(socketParameters.sin_addr));
            
            
            if ([[NSString stringWithFormat:@"%s",message] isEqualToString:[NSString stringWithFormat:@"%s",IAmHere]]) {
                connectreturn = connect(_socketReturn,(struct sockaddr *) &socketParameters, sizeof(socketParameters));
                if(connectreturn==0){
                    _serverIP = [NSString stringWithFormat:@"%s",inet_ntoa(socketParameters.sin_addr)];
                    NSLog(@"链接成功");
                    bl = NO;
                    [self tcpRecvMessage];
                    //主机有回应
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connect) object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:ConnectSuccess object:nil];
                    }];
                }else{
                    NSLog(@"connectreturn:%d errno:%d str:%s len:%lu",connectreturn,errno,strerror(errno), sizeof(socketParameters));
                }
            }
        }
    }];
}
-(void)tcpRecvMessage{
    
    
    [tcpQueue addOperationWithBlock:^{
        struct socketTCPhead head;
        memset(&head,0,sizeof(head));//清空结构体
        NSMutableData* recvData = nil;
        
        int maxsize = 1024;
        char message[2014];
        memset(message,0,strlen(message));
        bool recvbool= true;
        
        
        size_t restSize = 0;//剩下的数据
        while (recvbool) {
            size_t recvreturn = recv(_socketReturn,message+restSize, maxsize, 0);
           // size_t messageSize = strlen(message);
            NSLog(@"recvreturn:%zu restSize:%zu",recvreturn,restSize);
                //读取信息
                if(head.dataSize == 0){
                    //读取头
                    if (recvreturn>=sizeof(head)){
                        memcpy(&head,message,sizeof(head));
                        //将剩下的数据前移动并清空后面的数据用于下一次储存
                        memcpy(message,message+sizeof(head),recvreturn-sizeof(head));
                        memset(message+recvreturn-sizeof(head),0,maxsize);
                        restSize = recvreturn - sizeof(head);
                        NSLog(@"messageType:%d datasize:%zu dataType:%d tag:%d ",head.messageType,head.dataSize,head.dataType,head.tag);
                        recvData = nil;
                    }
                }else{
                    //读取数据
                    if (recvreturn+restSize<(head.dataSize-recvData.length)) {
                        if(recvData == nil){
                            recvData = [NSMutableData dataWithBytes: message length:recvreturn+restSize];
                        }else{
                            [recvData appendBytes:message length:recvreturn+restSize];
                        }
                        restSize=0;
                        memset(message,0,maxsize);
                    }else{
                        size_t length = head.dataSize-recvData.length;
                        if(recvData == nil){
                            recvData = [NSMutableData dataWithBytes: message length:length];
                        }else{
                            [recvData appendBytes:message length:length];
                        }
                        [self executeCommand:head.messageType datatype:head.dataType data:recvData];
                        memcpy(message,message+length,recvreturn+restSize-length);
                        memset(message+recvreturn+restSize-length,0,maxsize);
                        memset(&head,0,sizeof(head));
                        restSize = recvreturn+restSize-length;
                    }
                }
            
        }
    }];
    
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
    [self sendMessageType:messagetype datatype:datatype tag:0 data:data];
}

-(void)sendMessageType:(int)messagetype datatype:(int)datatype tag:(int)tag data:(id)data{
    
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
        
        struct socketTCPhead head = {messagetype,datatype,tag,static_cast<long>(senddata.length)};
        send(_socketReturn, &head, sizeof(head), 0);
        send(_socketReturn, [senddata bytes], senddata.length, 0);
        
    }];
    
    
}




-(void)executeCommand:(int)messagetype datatype:(int)datatype data:(id)data{
    //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    //转化数据类型
    if(datatype == DataType_String){
        data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else if(datatype == DataType_NSDictionary){
        //data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
       
    }
    if(data==nil){NSLog(@"空数据或者，数据解析错误。");}
    //根据消息类型来执行命令
    if(messagetype == MessageType_FileList){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FileListRecvSuccess object:data];
        }];
    }else if(messagetype == MessageType_FileInfo){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FileInfoRecvSuccess object:data];
        }];
    }
    
}
@end
