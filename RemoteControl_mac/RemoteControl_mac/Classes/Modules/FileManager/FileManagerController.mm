//
//  FileManagerController.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileManagerController.h"
#import "SocketMacro.h"
#import "FileListEntity.h"
#import "SocketControl.h"
#import "MainViewController.h"
#import "FileInfoEntity.h"

#define MaxSendSize 102400//1048576

static FileManagerController *shareFileManagerController;
@implementation FileManagerController

+(instancetype)share{
    @synchronized (self) {
        if (!shareFileManagerController) {
            shareFileManagerController = [[FileManagerController alloc] init];
        }
    }
    return shareFileManagerController;
}


-(void)sendFileList:(NSString*)path{
    FileListEntity* fileList = [[FileListEntity alloc] init];
    fileList.tagPath = path;
    
    if([path isEqualToString:CurrentUserDesktopPath]){
        path = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)[0];
    }else if([path isEqualToString:CurrentUserMainPath]){
        path = NSHomeDirectory();
    }
    fileList.path = path;
    Log(@"sendFileList:%@",path);
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * array = [fm contentsOfDirectoryAtPath:path error:nil];
    

    
    for(NSString *str in array){
        //字符串文件名预处理
        NSString *pathin = [[NSString alloc] initWithFormat:@"%@/%@",path,str];
        //判断文件类型
        BOOL isDir;
        if ([fm fileExistsAtPath:pathin isDirectory:&isDir] && isDir) {
            [fileList addFile:str type:FileType_Folder];//文件夹
        }else{
            [fileList addFile:str type:FileType_File];
        }
    }
    [[SocketControl share] sendMessageType:MessageType_FileList datatype:DataType_NSDictionary data:fileList.mj_keyValues];
}


-(void)sendFileInfo:(NSString *)path{
    Log(@"sendFileInfo:%@",path);
    FileInfoEntity* fileInfo = [[FileInfoEntity alloc] init];
    fileInfo.path = path;
    NSDictionary *fileAttributes =[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    //NSLog(@"%@",fileAttributes);
    fileInfo.size = [fileAttributes objectForKey:@"NSFileSize"];
    
    [[SocketControl share] sendMessageType:MessageType_FileInfo datatype:DataType_NSDictionary data:fileInfo.mj_keyValues];
    //判断文件类型http://blog.csdn.net/snowbueaty/article/details/14225627
}


-(void)sendFile:(int)tag path:(NSString *)path{
    
    Log(@"sendFile:tag:%d path:%@",tag,path);
    //再次发送文件信息
    FileInfoEntity* fileInfo = [[FileInfoEntity alloc] init];
    fileInfo.path = path;
    NSDictionary *fileAttributes =[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    fileInfo.size = [fileAttributes objectForKey:@"NSFileSize"];
    [[SocketControl share] sendMessageType:MessageType_DownloadFileStart datatype:DataType_NSDictionary tag:tag data:fileInfo.mj_keyValues];
    
//    NSMutableData* testdata = [[NSMutableData data] init];
    //发送文件信息
    NSFileHandle* filehandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    double maxint = ceil([fileInfo.size floatValue]/MaxSendSize);
    for (int i = 0;  i < maxint; i++) {
        [filehandle seekToFileOffset:MaxSendSize*i];
        NSData* data;
        if(i==maxint)
        data = [filehandle readDataToEndOfFile];
        else
        data = [filehandle readDataOfLength:MaxSendSize];
//        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:4]);
        [[SocketControl share] sendMessageType:MessageType_DownloadFileIng datatype:DataType_NSData tag:tag data:data];
       
//        [testdata appendData:data];
    }
//    NSLog(@"%@",[[NSString alloc] initWithData:testdata encoding:NSUTF8StringEncoding]);
    //发送结束消息
    [[SocketControl share] sendMessageType:MessageType_DownloadFileEnd datatype:DataType_String tag:tag data:@"发送完毕"];
}


@end
