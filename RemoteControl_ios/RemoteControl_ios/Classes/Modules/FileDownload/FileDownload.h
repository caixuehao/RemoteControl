//
//  FileDownload.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfoEntity.h"

#define FileDownLoadFolder [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"DownLoads"]
#define FileDowload_Identifier @".downloadFile"

typedef enum :NSUInteger{
    TaskState_Pause,
    TaskState_DownloadIng,
    TaskState_DownloadEnd
} TaskState;
@interface FileDownloadTask : NSObject

@property(nonatomic,strong)FileInfoEntity *fileInfo;
@property(nonatomic,assign)float wholeSize;
@property(nonatomic,assign)float presentSize;
@property(nonatomic,strong)NSString* tmpPath;
@property(nonatomic,strong)NSString* savePath;
@property(nonatomic,strong)NSFileHandle* fileHandle;
@property(nonatomic,assign)int tag;
@property(nonatomic,assign)TaskState state;
@end



@protocol FileDownloadDelegate;

@interface FileDownload : NSObject

@property(atomic,weak)id<FileDownloadDelegate> delegate;

@property(nonatomic,strong,readonly)NSMutableArray<FileDownloadTask*>* downloadTaskArr;

+(instancetype)share;

-(BOOL)download:(FileInfoEntity*)fileInfo;

-(void)download_revcStart:(int)tag info:(NSDictionary*)info;

-(void)download_revcIng:(int)tag data:(NSData*)data;

-(void)download_revcFinished:(int)tag info:(NSString*)info;

@end


@protocol FileDownloadDelegate
@optional
-(void)downloading:(int)tag fileInfoEntity:(FileInfoEntity*)fileInfo WholeSize:(float)wholeSize PresentSize:(float)presentSize;

-(void)downloadFinished:(int)tag fileInfoEntity:(FileInfoEntity*)fileInfo;

-(void)downloadError:(NSString*)error;

@end