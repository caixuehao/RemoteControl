//
//  FileManagerViewController.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileManagerViewController : UIViewController
/**
 *  CurrentUserDesktopPath 保留字段表示当前用户的桌面路径
 */
@property(nonatomic,strong,readonly)NSString* path;


-(instancetype)initWithPath:(NSString*)path;

@end
