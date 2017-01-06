//
//  MainViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "MainViewController.h"
#import "CommandLineViewController.h"
#import "SocketControl.h"

@interface MainViewController ()

@end

@implementation MainViewController{

    __weak IBOutlet UIButton *shutdownButton;

}

-(instancetype)init{
    if (self = [super init]) {
        self.isConnect = YES;
        [[SocketControl share] connect];
    }
    return self;
}

-(void)setIsConnect:(BOOL)isConnect{
    _isConnect = isConnect;
    shutdownButton.hidden = isConnect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
- (IBAction)shell:(id)sender {
    [self.navigationController pushViewController:[[CommandLineViewController alloc] init] animated:YES];
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
