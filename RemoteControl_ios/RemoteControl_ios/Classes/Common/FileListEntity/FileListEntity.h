//
//  FileListEntity.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
//http://blog.csdn.net/ouyangtianhan/article/details/42004741
//struct FileEntity{
//    __unsafe_unretained NSString *path;
//    NSInteger type;
//};

@interface FileEntity : NSObject

@property NSString* path;

@property NSInteger type;

@end

@interface FileListEntity : NSObject

@property(nonatomic,strong)NSString* path;

@property(nonatomic,strong)NSMutableArray<FileListEntity *>* files;

@end
