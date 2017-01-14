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
    NSMutableArray<NSMutableData*>* fileDataArr;
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
        fileDataArr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)download:(FileInfoEntity*)fileInfo{
    
    [[SocketControl share] sendMessageType:MessageType_DownloadFile datatype:DataType_String tag:currenttag data:fileInfo.path];
    [fileInfoArr addObject:fileInfo];
    [fileDataArr addObject:[[NSMutableData alloc] init]];
    currenttag++;

}
-(void)download_revcStart:(int)tag info:(NSDictionary*)info{
    NSLog(@"download_revcStart:%d",tag);
}

-(void)download_revcIng:(int)tag data:(NSData*)data{
    NSLog(@"download_revcIng:%d",tag);
    int index =tag-InitialTag;
    if (index>=0&&index<fileDataArr.count) {
        [fileDataArr[index] appendData:data];
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
