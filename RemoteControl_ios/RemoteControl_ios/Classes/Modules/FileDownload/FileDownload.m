//
//  FileDownload.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileDownload.h"

#import "SocketControl.h"

#define InitialTag 100



static FileDownload* shareFileDownload = nil;

@implementation FileDownload{
    NSMutableArray<FileInfoEntity*>* fileInfoArr;
//    NSMutableArray<NSNumber *>* fileSizeArr;
    NSMutableArray<NSNumber *>* currentFileSizeArr;
    NSMutableArray<NSFileHandle *>* fileHandleArr;
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
        fileInfoArr = [[NSMutableArray alloc] init];
//        fileSizeArr = [[NSMutableArray alloc] init];
        currentFileSizeArr = [[NSMutableArray alloc] init];
        fileHandleArr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)download:(FileInfoEntity*)fileInfo{
    
    [[SocketControl share] sendMessageType:MessageType_DownloadFile datatype:DataType_String tag:currenttag data:fileInfo.path];
    [fileInfoArr addObject:fileInfo];
    [currentFileSizeArr addObject:@(0)];
    [[NSFileManager defaultManager] createFileAtPath:fileInfo.path contents:nil attributes:nil];
    [fileHandleArr addObject:[NSFileHandle fileHandleForWritingAtPath:fileInfo.path]];
    [[fileHandleArr lastObject] seekToEndOfFile];
    currenttag++;

}
-(void)download_revcStart:(int)tag info:(NSDictionary*)info{
    NSLog(@"download_revcStart:%d",tag);
 
}

-(void)download_revcIng:(int)tag data:(NSData*)data{
    NSLog(@"download_revcIng:%d",tag);
    int index =tag-InitialTag;
    if (index>=0&&index<currentFileSizeArr.count) {
       
    }
}

-(void)download_revcFinished:(int)tag info:(NSString*)info{
    NSLog(@"download_revcFinished:%@ tag:%d",info,tag);
    int index =tag-InitialTag;
    if (index>=0&&index<fileDataArr.count) {
        NSLog(@"%@",[[NSString alloc] initWithData:fileDataArr[index] encoding:NSUTF8StringEncoding]);
    }
}
@end
