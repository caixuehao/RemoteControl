//
//  FileInfoViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/12.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileInfoViewController.h"
#import <Masonry.h>
@interface FileInfoViewController ()

@end

@implementation FileInfoViewController{
    UILabel* fileName;
    UILabel* fileInfo;
    UIButton* downloadBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadsubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadsubView{
    self.view.backgroundColor = [UIColor yellowColor];
    
    fileName = ({
        UILabel* label = [[UILabel alloc] init];
        label.text = @"123456123456123456123456123456123456";
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:20];
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:label];
        label;
    });
    
    fileInfo = ({
        UILabel* label = [[UILabel alloc] init];
        label.text = @"大小：1234\n所有者：1234\n日期:1234\n文件类型:1234";
        label.numberOfLines = 5;
        label.font = [UIFont systemFontOfSize:15];
        label.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:label];
        label;
    });
    
    downloadBtn = ({
        UIButton* btn = [[UIButton alloc] init];
        [btn addTarget:self action:@selector(OnDownloadClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn;
    });
    
    [fileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.view).offset(80);
        make.height.equalTo(@50);
    }];
    
    [fileInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(fileName.mas_bottom).offset(10);
        make.height.equalTo(@100);
    }];
}
-(void)OnDownloadClick{
    NSLog(@"123455");
}
@end
