//
//  LocalFileManagerViewController.m
//  RemoteControl_ios
//
//  Created by cxh on 17/1/17.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Masonry.h>
#import "FileListEntity.h"
#import "LocalFileManagerViewController.h"
#import "FileDownload.h"

@interface LocalFileManagerViewController()<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
@property(nonatomic,retain)UIDocumentInteractionController *documentInteractionController;
@end

@implementation LocalFileManagerViewController{
    UITableView* _mainTableView;
    NSMutableArray<NSString *>* fileArr;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadFileData];
    [self loadSubView];
    
}

-(void)loadFileData{
    //先不显示正在下载的
    NSArray * arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:FileDownLoadFolder  error:nil];
    fileArr = [[NSMutableArray alloc] initWithArray:arr];
    NSLog(@"%@",fileArr);
    NSMutableIndexSet *indexset = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < fileArr.count;i++) {
        NSString* fileName = fileArr[i];
        if(fileName.length>FileDowload_Identifier.length){
            if ([[fileName substringToIndex:FileDowload_Identifier.length] isEqualToString:FileDowload_Identifier]) {
                [indexset addIndex:i];
            }
        }
    }
    [fileArr removeObjectsAtIndexes:indexset];
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

}



#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"打开:%@",[FileDownLoadFolder stringByAppendingPathComponent:fileArr[indexPath.row]]);
    NSURL *url = [NSURL fileURLWithPath:[FileDownLoadFolder stringByAppendingPathComponent:fileArr[indexPath.row]]];
    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    [_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       
         [[NSFileManager defaultManager] removeItemAtPath:[FileDownLoadFolder stringByAppendingPathComponent:fileArr[indexPath.row]] error:nil];
         [fileArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}
#pragma mark -  UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return fileArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = fileArr[indexPath.row];
    return cell;
}
@end
