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
#import "FileListEntity.h"

@interface FileManagerViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation FileManagerViewController{
    MBProgressHUD *_hud;
    UITableView* _mainTableView;
    
    FileListEntity *_fileList;
}
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
-(instancetype)initWithTagPath:(NSString*)tagPath{
    if (self = [super init]) {
        _tagPath = tagPath;

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileListRecvSuccess:)  name:FileListRecvSuccess  object:nil];
        [[SocketControl share] sendMessageType:MessageType_FileList datatype:DataType_String data:_tagPath];
      
    }
    return self;
}

-(void)fileListRecvSuccess:(NSNotification*) notification{
   
    FileListEntity *fileList = [FileListEntity mj_objectWithKeyValues:[notification object]];

    if ([fileList.tagPath isEqualToString:_tagPath]) {
        NSLog(@"%@",fileList.tagPath);
        _fileList = fileList;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [_mainTableView reloadData];
                [_hud hideAnimated:YES];
        }];
    }
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

    
    _mainTableView = ({
        UITableView *tableview = [[UITableView alloc] init];
        tableview.delegate = self;
        tableview.dataSource = self;
        [self.view addSubview:tableview];
        tableview;
    });
    
    [_mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    _hud = ({
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"正在获取文件列表";
        hud.removeFromSuperViewOnHide = YES;// 隐藏时候从父控件中移除
        hud.tag = 2008;
        [self.view bringSubviewToFront:hud];
        hud;
    });
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileEntity* file = _fileList.files[indexPath.row];
    if (file.type == FileType_Folder) {
        FileManagerViewController* fmvc = [[FileManagerViewController alloc] initWithTagPath:[_fileList.path stringByAppendingPathComponent:file.fileName]];
        [self.navigationController pushViewController:fmvc animated:YES];
    }

}

#pragma mark -  UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fileList?_fileList.files.count:0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    FileEntity* file = _fileList.files[indexPath.row];
    cell.textLabel.text = file.fileName;
    switch (file.type) {
        case FileType_Folder:
            cell.textLabel.textColor = [UIColor blueColor];
            break;
        default:
            cell.textLabel.textColor = [UIColor blackColor];
            break;
    }
    return cell;
}

@end
