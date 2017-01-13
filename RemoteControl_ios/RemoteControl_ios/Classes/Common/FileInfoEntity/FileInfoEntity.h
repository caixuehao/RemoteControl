//
//  FileInfoEntity.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface FileInfoEntity : NSObject

@property(nonatomic,strong)NSString* path;

@property(nonatomic,assign)NSNumber* size;

@property(nonatomic,strong)NSString* type;

@end
