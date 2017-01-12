//
//  MainViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/4.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "MainViewController.h"

#import "SocketControl.h"

#import <Masonry.h>
#import <MBProgressHUD.h>

#import "CommandLineViewController.h"
#import "OpenURLViewController.h"
#import "FileManagerViewController.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView* mainTableView;

@property(nonatomic,strong)NSArray<NSString*>* titlesArr;

@end

struct sockethead {
    long int size;
    int typeid;
    int messageid;
};

@implementation MainViewController{

 UIImageView* backgroundImage;

}

-(instancetype)init{
    if (self = [super init]) {
       
    }
    return self;
}

-(void)setIsConnect:(BOOL)isConnect{
    _isConnect = isConnect;
    if(isConnect){
        MBProgressHUD *hud = [self.view viewWithTag:2008];
        [hud hideAnimated:YES];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"正在查找主机";
        hud.removeFromSuperViewOnHide = YES;// 隐藏时候从父控件中移除
        hud.tag = 2008;
        [self.view bringSubviewToFront:hud];
    }
  
}

-(void)connectSuccess{
    self.isConnect = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //不加这个没网络
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.baidu.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }] resume];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess)  name:ConnectSuccess  object:nil];
    [[SocketControl share] connect];
    _titlesArr = @[@"关机",@"打开网页",@"资源管理器"];
    [self loadSubView];

     self.isConnect = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
-(void)loadSubView{
    _mainTableView = ({
        UITableView *tableview = [[UITableView alloc] init];
        tableview.delegate = self;
        tableview.dataSource = self;
        tableview.alpha = 0.7;
        [self.view addSubview:tableview];
        tableview;
    });
    
    backgroundImage = ({
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background1.jpg"]];
        [self.view addSubview:imageView];
        [self.view sendSubviewToBack:imageView];
        imageView;
    });
    
    
    [_mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(0);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(0);
        make.left.right.bottom.equalTo(self.view);
    }];

}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[[CommandLineViewController alloc] init] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[[OpenURLViewController alloc] init] animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:[[FileManagerViewController alloc] initWithTagPath:CurrentUserDesktopPath] animated:YES];
            break;
        default:
            [self.navigationController pushViewController:[[UIViewController alloc] init] animated:YES];
            break;
    }
    
}
#pragma mark -  UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titlesArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = _titlesArr[indexPath.row];
    return cell;
}

@end
