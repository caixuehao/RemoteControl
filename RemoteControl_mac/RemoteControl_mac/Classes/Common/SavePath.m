//
//  SavePath.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/6.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "SavePath.h"
static SavePath* shareSavePath;

@implementation SavePath{
    NSString* _path;
    NSString* _mainPlistPath;
}

+(instancetype)share{
    @synchronized (self) {
        if (!shareSavePath) {
            shareSavePath = [[SavePath alloc] init];
        }
    }
    return shareSavePath;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];//NSDesktopDirectory
        _path = [_path stringByAppendingPathComponent: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
        
        NSArray<NSString*>* paths = @[self.mainPlistPath];
        for (NSString* path in paths) {
            BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            if (bo==NO) NSLog(@"%@文件夹创建失败！",path);
        }
    }
    return self;
}


-(NSString*)mainPlistPath{
    if(_mainPlistPath.length == 0){
        _mainPlistPath = [_path stringByAppendingPathComponent:@"mainList.plist"];
    }
    return _mainPlistPath;
}

//程序路径
-(NSString*)appPath{
    return [[NSBundle mainBundle] bundlePath];
}
@end
