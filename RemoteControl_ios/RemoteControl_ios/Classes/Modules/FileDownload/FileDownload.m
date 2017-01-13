//
//  FileDownload.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileDownload.h"

#import "SocketControl.h"
static FileDownload* shareFileDownload = nil;

@implementation FileDownload{
    int tag;
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
        tag = NetworkPort;
    }
    return self;
}

-(void)download:(FileInfoEntity*)fileInfo Downloading:(void(^)(long long PresentSize,long long WholeSize))downloadingBlock Finished:(void(^)(void))finishedBlock error:(void(^)(NSString* error))errorBlock{


}

@end
