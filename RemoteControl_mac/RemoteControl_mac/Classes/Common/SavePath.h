//
//  SavePath.h
//  RemoteControl_mac
//
//  Created by cxh on 17/1/6.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavePath : NSObject

+(instancetype)share;

@property(nonatomic,strong,readonly)NSString* mainPlistPath;

@property(nonatomic,strong,readonly)NSString* appPath;

@end
