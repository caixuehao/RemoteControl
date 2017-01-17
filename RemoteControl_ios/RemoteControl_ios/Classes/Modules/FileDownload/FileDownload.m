//
//  FileDownload.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileDownload.h"

#import "SocketControl.h"
#import "MBProgressHUD.h"
#import "ShowMessage.h"

#define InitialTag 100



static FileDownload* shareFileDownload = nil;
@implementation FileDownloadTask

@end
@implementation FileDownload{
    
    int currenttag;
}

+(instancetype)share{
    @synchronized (self) {
        if (!shareFileDownload) {
            shareFileDownload = [[FileDownload alloc] init];
        }
    }
    return shareFileDownload;
}


-(instancetype)init{
    if (self = [super init]) {
        currenttag = InitialTag;
        _downloadTaskArr = [[NSMutableArray alloc] init];
        NSArray * fileArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:FileDownLoadFolder  error:nil];
        
        for (NSString *fileName in fileArr) {
            if(fileName.length>FileDowload_Identifier.length)
            if ([[fileName substringToIndex:FileDowload_Identifier.length] isEqualToString:FileDowload_Identifier]) {
                [[NSFileManager defaultManager] removeItemAtPath:[FileDownLoadFolder stringByAppendingPathComponent:fileName] error:nil];
            }
        }
    }
    return self;
}

-(BOOL)download:(FileInfoEntity*)fileInfo{
    //检查是否已经在下载
    for (FileDownloadTask* task in _downloadTaskArr) {
        if ([task.fileInfo.path isEqualToString:fileInfo.path]) {
            return NO;
        }
    }
    
    
    [[SocketControl share] sendMessageType:MessageType_DownloadFile datatype:DataType_String tag:currenttag data:fileInfo.path];
    
    FileDownloadTask* task = [[FileDownloadTask alloc] init];
    task.fileInfo = fileInfo;
    task.wholeSize = [fileInfo.size floatValue];
    task.presentSize = 0;
    task.savePath = FileDownLoadFolder;
    //创建目录
    [[NSFileManager defaultManager] createDirectoryAtPath:task.savePath withIntermediateDirectories:YES attributes:nil error:nil];
    task.savePath = [task.savePath stringByAppendingPathComponent:[self getSaveFileName:[fileInfo.path lastPathComponent]]];
    //创建文件
    task.tmpPath = [NSString stringWithFormat:@"%@%d",FileDowload_Identifier,currenttag];
    task.tmpPath = [FileDownLoadFolder stringByAppendingPathComponent:task.tmpPath];
    [[NSFileManager defaultManager] createFileAtPath:task.tmpPath contents:nil attributes:nil];
    task.fileHandle = [NSFileHandle fileHandleForWritingAtPath:task.tmpPath];
    [task.fileHandle seekToEndOfFile];
    task.tag = currenttag;
    task.state = TaskState_Pause;

    
    [_downloadTaskArr addObject:task];
    currenttag++;
    return YES;
}
//防止命名重复
-(NSString*)getSaveFileName:(NSString*)path{
    NSArray * fileArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:FileDownLoadFolder  error:nil];
    NSString* returnPath = path;
    
    int suffix = 1;
    for (int i = 0; i < fileArr.count+1; i++) {
        //查看是否重复
        BOOL bl = NO;
        for (NSString* str in fileArr) {
            if ([returnPath isEqualToString:str]) {
                bl = YES;
            }
        }
        
        if (bl) {
            returnPath = [NSString stringWithFormat:@"%@(%d)",path,suffix++];
        }else{
            return returnPath;
        }
    }
    return returnPath;
}

-(void)download_revcStart:(int)tag info:(NSDictionary*)info{
    NSLog(@"download_revcStart:%d",tag);
    int index =tag-InitialTag;
    if (index>=0&&index<_downloadTaskArr.count) {
        //刷新一下大小
        _downloadTaskArr[index].wholeSize = [[FileInfoEntity mj_objectWithKeyValues:info].size floatValue];
         _downloadTaskArr[index].state = TaskState_DownloadIng;
    }
    
}

-(void)download_revcIng:(int)tag data:(NSData*)data{
    NSLog(@"download_revcIng:%d",tag);
    int index =tag-InitialTag;
    if (index>=0&&index<_downloadTaskArr.count) {
        FileDownloadTask* task = _downloadTaskArr[index];
        [task.fileHandle seekToEndOfFile];
        [task.fileHandle writeData:data];
        task.presentSize+=data.length;
        
        if(_delegate)[_delegate downloading:tag fileInfoEntity:task.fileInfo WholeSize:task.wholeSize PresentSize:task.presentSize];
    }
}

-(void)download_revcFinished:(int)tag info:(NSString*)info{
    NSLog(@"download_revcFinished:%@ tag:%d",info,tag);
    int index =tag-InitialTag;
    if (index>=0&&index<_downloadTaskArr.count) {
        FileDownloadTask* task = _downloadTaskArr[index];
        NSLog(@"\"%@\"下载到\"%@\"的任务完成",task.fileInfo.path,task.savePath);
        task.state = TaskState_DownloadEnd;
        [task.fileHandle closeFile];
        task.fileHandle = nil;
        
        [[NSFileManager defaultManager] moveItemAtPath:task.tmpPath toPath:task.savePath error:nil];
        if(_delegate)[_delegate downloadFinished:tag fileInfoEntity:task.fileInfo];
        
        
        NSString* str = [NSString stringWithFormat:@"\"%@\"下载完成",[task.savePath lastPathComponent]];
        [[ShowMessage share] showMessage:str afterDelay:2];
    }
}
@end
