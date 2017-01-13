//
//  FileManagerController.h
//  RemoteControl_mac
//
//  Created by cxh on 17/1/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManagerController : NSObject

+(instancetype)share;

-(void)sendFileList:(NSString*)path;

-(void)sendFileInfo:(NSString *)path;

@end
