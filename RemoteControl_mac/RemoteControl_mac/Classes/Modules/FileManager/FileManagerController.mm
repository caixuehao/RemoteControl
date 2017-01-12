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
    
    NSDictionary* data_dic = fileList.mj_keyValues;
    //NSLog(@"%@",data_dic);
    [[SocketControl share] sendMessageType:MessageType_FileManager datatype:DataType_NSDictionary data:data_dic];
}

@end
