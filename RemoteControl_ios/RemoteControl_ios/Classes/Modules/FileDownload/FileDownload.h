//
//  FileDownload.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfoEntity.h"

@protocol FileDownloadDelegate;

@interface FileDownload : NSObject

@property(atomic,weak)id<FileDownloadDelegate> delegate;

//目前只能同时下载一个文件
+(instancetype)share;

-(BOOL)download:(FileInfoEntity*)fileInfo;

@end


@protocol FileDownloadDelegate

-(void)downloading:(int)tag fileInfoEntity:(FileInfoEntity*)fileInfo WholeSize:(long long)wholeSize PresentSize:(long long)PresentSize;

-(void)downloadFinished:(int)tag fileInfoEntity:(FileInfoEntity*)fileInfo;

-(void)downloadError:(NSString*)error;

@end