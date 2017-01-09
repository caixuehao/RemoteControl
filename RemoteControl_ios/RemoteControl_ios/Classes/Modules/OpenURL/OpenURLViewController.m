//
//  OpenURLViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "OpenURLViewController.h"
#import "SocketControl.h"
#import "SocketMacro.h"

@interface OpenURLViewController ()

@end

@implementation OpenURLViewController{

    __weak IBOutlet UITextView *urlTextView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)open:(id)sender {
    [[SocketControl share] sendMessageType:MessageType_OpenURL datatype:DataType_String data:urlTextView.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
