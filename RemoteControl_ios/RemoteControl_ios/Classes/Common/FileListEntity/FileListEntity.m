//
//  FileListEntity.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileListEntity.h"


@implementation FileEntity
-(instancetype)initWithFileName:(NSString*)fileName type:(FileType)type{
    if (self = [super init]) {
        self.fileName = fileName;
        self.type = type;
    }
    return self;
}
@end


@implementation FileListEntity


+(NSDictionary *)mj_objectClassInArray{
    return @{@"files":NSStringFromClass([FileEntity class])};
}


-(void)addFile:(NSString*)fileName type:(FileType)type{
    if(_files == nil){
        _files = [[NSMutableArray alloc] init];
    }
    [_files addObject:[[FileEntity alloc] initWithFileName:fileName type:type]];
}


@end
