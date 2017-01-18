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
#define MessageType_OpenFile 4 //打开文件
#define MessageType_FileList 5 //获取文件列表
#define MessageType_FileInfo 6 //文件简介
#define MessageType_DownloadFile 7 //下载文件
#define MessageType_DownloadFileStart 8//文件下载开始
#define MessageType_DownloadFileIng 9 //文件下载中
#define MessageType_DownloadFileEnd 10 //文件下载结束

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
#define ConnectDisconnect @"ConnectDisconnect"
#define FileListRecvSuccess @"FileListRecvSuccess"
#define FileInfoRecvSuccess @"FileInfoRecvSuccess"

#pragma 其他
#define CurrentUserDesktopPath  @"CurrentUserDesktopPath"
#define CurrentUserMainPath     @"CurrentUserMainPath"
//#define MessageHeadLenght 16

struct socketTCPhead {
    int messageType;//消息类型
    int dataType;//数据类型
    int tag;//消息编号 一般都是0
    long int dataSize;//数据大小
};

#endif /* SocketMacro_h */
