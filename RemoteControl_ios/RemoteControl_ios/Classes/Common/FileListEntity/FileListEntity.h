//
//  FileListEntity.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"
//http://blog.csdn.net/ouyangtianhan/article/details/42004741
//struct FileEntity{
//    __unsafe_unretained NSString *path;
//    NSInteger type;
//};

typedef enum : NSUInteger {
    FileType_Folder,
    FileType_File,
} FileType;

@interface FileEntity : NSObject

@property NSString* fileName;

@property FileType type;



@end

@interface FileListEntity : NSObject

@property(nonatomic,strong)NSString* tagPath;//标记路径（用来分辨是哪个视图请求的）

@property(nonatomic,strong)NSString* path;

@property(nonatomic,strong)NSMutableArray<FileEntity *>* files;

-(void)addFile:(NSString*)fileName type:(FileType)type;

@end
