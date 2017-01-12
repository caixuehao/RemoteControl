//
//  SocketMacro.h
//  RemoteControl_mac
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#ifndef SocketMacro_h
#define SocketMacro_h

#define NetworkPort 1995 //端口号


#pragma 数据类型
#define DataType_String 1
#define DataType_NSData 2
#define DataType_NSDictionary 3


#pragma 消息类型
#define MessageType_TerminalCommand 1 //终端命令
#define MessageType_Shutdown 2 //关机
#define MessageType_OpenURL 3  //打开网页
#define MessageType_FileManager 4 //文件管理器

#pragma 关机命令参数
#define ShutDown @"ShutDown"
#define Restart  @"Restart"
#define Logout   @"Logout"
#define Sleep    @"Sleep"


#pragma 对话字符串
#define AnybodyHere "Anybody here?"
#define IAmHere "I am here."


#pragma 通知字符串
#define ConnectSuccess @"ConnectSuccess"
#define FileListRecvSuccess @"FileListRecvSuccess"

#pragma 其他
#define CurrentUserDesktopPath @"CurrentUserDesktopPath"

//#define MessageHeadLenght 16

struct socketTCPhead {
    int messageType;
    int dataType;
    long int dataSize;
};

#endif /* SocketMacro_h */
