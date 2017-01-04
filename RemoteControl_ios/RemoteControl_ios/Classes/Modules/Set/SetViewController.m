//
//  SetViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//
#import "SocketMacro.h"
#import "SocketControl.h"

#import "SetViewController.h"
#import "MainViewController.h"
#import "MainNavigationController.h"

@interface SetViewController ()

@end

@implementation SetViewController{

    __weak IBOutlet UITextField *IPTextField;
    
    
    __weak IBOutlet UITextField *portTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}
- (IBAction)connect:(id)sender {
   NSString* str = [[SocketControl share] connectIP:IPTextField.text Port:[portTextField.text intValue]];
    if(str){
        NSLog(@"%@",str);
    }else{
        MainViewController* mainViewController = [[MainViewController alloc] init];
        self.view.window.rootViewController = [[MainNavigationController alloc] initWithRootViewController:mainViewController];
    }
   
}


-(void)loadSubViews{
    IPTextField.text = @"192.168.1.91";
    portTextField.text = [NSString stringWithFormat:@"%d",NetworkPort];
}

@end
