//
//  CommandLineViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "CommandLineViewController.h"
#import "SocketControl.h"
@interface CommandLineViewController ()

@end

@implementation CommandLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)shutdown:(id)sender {
    [[SocketControl share] sendMessageType:MessageType_Shutdown datatype:DataType_String data:ShutDown];
}
- (IBAction)logout:(id)sender {
    [[SocketControl share] sendMessageType:MessageType_Shutdown datatype:DataType_String data:Logout];
}
- (IBAction)sleep:(id)sender {
    [[SocketControl share] sendMessageType:MessageType_Shutdown datatype:DataType_String data:Sleep];
}
- (IBAction)restart:(id)sender {
    [[SocketControl share] sendMessageType:MessageType_Shutdown datatype:DataType_String data:Restart];
    
}
- (IBAction)shutdown2:(id)sender {
    [[SocketControl share] sendMessageType:MessageType_TerminalCommand datatype:DataType_String data:@"sudo halt"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
