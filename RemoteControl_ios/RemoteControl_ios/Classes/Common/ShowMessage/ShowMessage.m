//
//  ShowMessage.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/17.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "ShowMessage.h"
static ShowMessage *shareShowMessage;
@implementation ShowMessage
+(instancetype)share{
    @synchronized (self) {
        if (!shareShowMessage) {
            shareShowMessage = [[ShowMessage alloc] init];
        }
    }
    return shareShowMessage;
}

-(void)showMessage:(NSString*)message afterDelay:(float)time{
   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
       hud.mode = MBProgressHUDModeText;
       hud.removeFromSuperViewOnHide = YES;
       hud.label.text = message;
       [hud hideAnimated:YES afterDelay:time];
   }];

    
}
@end
