//
//  FileManagerViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/10.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "SocketControl.h"
#import "FileManagerViewController.h"
#import "MBProgressHUD.h"
#import <Masonry.h>

@interface FileManagerViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation FileManagerViewController{
    MBProgressHUD *_hud;
    UITableView* _mainTableView;
}

-(instancetype)initWithPath:(NSString*)path{
    if (self = [super init]) {
        _path = path;
        _currentFiles = @[];
        [[SocketControl share] sendMessageType:MessageType_FileManager datatype:DataType_String data:_path];
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadSubView{
    _hud = ({
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"正在获取文件列表";
        hud.removeFromSuperViewOnHide = YES;// 隐藏时候从父控件中移除
        hud.tag = 2008;
        [self.view bringSubviewToFront:hud];
        hud;
    });
    
    _mainTableView = ({
        UITableView *tableview = [[UITableView alloc] init];
        tableview.delegate = self;
        tableview.dataSource = self;
        [self.view addSubview:tableview];
        tableview;
    });
    
    [_mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(0);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        default:
            break;
    }
}

#pragma mark -  UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _currentFiles.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = _currentFiles[indexPath.row];
    return cell;
}

@end
