//
//  FileInfoViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/12.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FileInfoViewController.h"
#import <Masonry.h>
#import "SocketControl.h"
#import "FileInfoEntity.h"
#import "FileDownload.h"
#import "MBProgressHUD.h"
#import "ShowMessage.h"

@interface FileInfoViewController ()

@end

@implementation FileInfoViewController{
    UILabel* fileNameLabel;
    UILabel* fileInfoLabel;
    UIButton* openBtn;
    UIButton* downloadBtn;
    NSString* _path;
    FileInfoEntity* _fileInfo;
}

-(instancetype)initWithPath:(NSString*)path{
    if (self = [super init]) {
        _path = path;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileInfoRecvSuccess:)  name:FileInfoRecvSuccess  object:nil];
        [[SocketControl share] sendMessageType:MessageType_FileInfo datatype:DataType_String data:_path];
    }
    return self;
}

-(void)fileInfoRecvSuccess:(NSNotification*) notification{
   
    FileInfoEntity* fileInfo = [FileInfoEntity mj_objectWithKeyValues:[notification object]];
    NSLog(@"%@ == %@",fileInfo.path,_path);
    if ([fileInfo.path isEqualToString:_path]) {
        _fileInfo = fileInfo;
        fileNameLabel.text = [_fileInfo.path lastPathComponent];
        float filesize = [_fileInfo.size floatValue];
        if (filesize<pow(1024.0,1)) {
            fileInfoLabel.text = [NSString stringWithFormat:@"文件路径:%@\n文件大小:%.1fB",_fileInfo.path,filesize];
        }else if(filesize<pow(1024,2)){
            filesize = filesize/1024;
            fileInfoLabel.text = [NSString stringWithFormat:@"文件路径:%@\n文件大小:%.1fKB",_fileInfo.path,filesize];
        }else if(filesize<pow(1024.0,3)){
           filesize = filesize/pow(1024.0,2);
            fileInfoLabel.text = [NSString stringWithFormat:@"文件路径:%@\n文件大小:%.1fMB",_fileInfo.path,filesize];
        }else if(filesize<pow(1024,4)){
             filesize = filesize/pow(1024.0,3);
            fileInfoLabel.text = [NSString stringWithFormat:@"文件路径:%@\n文件大小:%.1fG",_fileInfo.path,filesize];
        }
        
    }
}

-(void)OnDownloadClick{
    //只显示文字

    if([[FileDownload share] download:_fileInfo] == NO){
         [[ShowMessage share] showMessage:@"请勿重复下载" afterDelay:2];
    }else{
        [[ShowMessage share] showMessage:@"正在下载" afterDelay:2];
    }
    
}

-(void)OnOpenClick{
     [[SocketControl share] sendMessageType:MessageType_OpenFile datatype:DataType_String data:_path];
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
    
    fileNameLabel = ({
        UILabel* label = [[UILabel alloc] init];
        label.text = @"正在获取文件名字...";
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:20];
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:label];
        label;
    });
    
    fileInfoLabel = ({
        UILabel* label = [[UILabel alloc] init];
        label.text = @"正在获取文件信息...";
        label.numberOfLines = 5;
        label.font = [UIFont systemFontOfSize:15];
        label.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:label];
        label;
    });
    
    downloadBtn = ({
        UIButton* btn = [[UIButton alloc] init];
        [btn setTitle:@"下载" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor blueColor];
        btn.showsTouchWhenHighlighted = YES;
        [btn.layer setMasksToBounds:YES];
        [btn addTarget:self action:@selector(OnDownloadClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn;
    });
    
    openBtn = ({
        UIButton* btn = [[UIButton alloc] init];
        [btn setTitle:@"在MAC上打开" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor blueColor];
        btn.showsTouchWhenHighlighted = YES;
        [btn.layer setMasksToBounds:YES];
        [btn addTarget:self action:@selector(OnOpenClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn;
    });
    
    
    
    [fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.view).offset(80);
        make.height.equalTo(@50);
    }];
    
    [fileInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(fileNameLabel.mas_bottom).offset(10);
        make.height.equalTo(@100);
    }];
    
    [openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(downloadBtn.mas_left).offset(-10);
        make.bottom.equalTo(self.view).offset(-20);
        make.height.equalTo(@50);
    }];
    
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.width.equalTo(openBtn.mas_width);
        make.bottom.equalTo(self.view).offset(-20);
        make.height.equalTo(@50);
    }];
    
}

@end
