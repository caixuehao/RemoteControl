//
//  ShowMessage.h
//  RemoteControl_ios
//
//  Created by cxh on 17/1/17.
//  Copyright © 2017年 cxh. All rights reserved.
//


#import "MBProgressHUD.h"

@interface ShowMessage : NSObject
@property(nonatomic,strong)MBProgressHUD *hud;;
+(instancetype)share;

-(void)showMessage:(NSString*)message afterDelay:(float)time;

-(void)showHub:(NSString*)message;

-(void)hide;
@end
