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
    Log(@"%@",path);
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
    NSLog(@"%@",path);
    FileInfoEntity* fileInfo = [[FileInfoEntity alloc] init];
    fileInfo.path = path;
    NSDictionary *fileAttributes =[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSLog(@"%@",fileAttributes);
    fileInfo.size = [fileAttributes objectForKey:@"NSFileSize"];
    
    [[SocketControl share] sendMessageType:MessageType_FileInfo datatype:DataType_NSDictionary data:fileInfo.mj_keyValues];
    //判断文件类型http://blog.csdn.net/snowbueaty/article/details/14225627
}
@end
