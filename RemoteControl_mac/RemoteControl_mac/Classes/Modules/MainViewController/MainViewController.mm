//
//  MainViewController.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "MainViewController.h"



static MainViewController* shareMainViewController;

@implementation MainViewController{

}
+(MainViewController*)getShareMainViewController{
    return shareMainViewController;
}
-(instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        shareMainViewController = self;
        
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];

    [self.view.window setReleasedWhenClosed:NO];//设置关闭时不释放
}

//http://www.cnblogs.com/zenny-chen/p/5132200.html
void Log(NSString *format, ...){
    va_list args;
    va_start(args, format);
    NSString* logStr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"%@",logStr);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        shareMainViewController.textView.string = [NSString stringWithFormat:@"%@\n%@",shareMainViewController.textView.string,logStr];
    }];
}


@end
