//
//  StartController.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/6.
//  Copyright © 2017年 cxh. All rights reserved.
//



#import "StartController.h"
#import "SavePath.h"


static StartController* shareStartController;

@implementation StartController


+(instancetype)share{
    @synchronized (self) {
        if (!shareStartController) {
            shareStartController = [[StartController alloc] init];
        }
    }
    return shareStartController;
}

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}
//隐藏Dock
//http://blog.csdn.net/lihe2008125/article/details/4864391
-(void)hideDock{
    //系统配置的
}


//自动启动
//http://www.cocoachina.com/bbs/read.php?tid-16770-page-1.html
-(void)autoStart{
    NSMutableDictionary* mainplistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[[SavePath share] mainPlistPath]];
    if (mainplistDic == nil)mainplistDic = [[NSMutableDictionary alloc] init];
    NSString* saveAppPath = [mainplistDic objectForKey:@"appPath"];
    NSString* nowAppPath =  [[SavePath share] appPath];
    NSLog(@"%@",[[SavePath share] appPath]);
    NSLog(@"%@",[[SavePath share] mainPlistPath]);
    
    if([nowAppPath isEqualToString:saveAppPath] == NO){
 
        
        //创建启动项
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:nowAppPath];
        /**
         *  获取启动项列表
         *
         *  @param inAllocator - CFAllocatorRef,用于创建LSSharedFileListRef . 如果使用NULL则意思是采用默认的创建方法
         *  @param  inListType  - 创建的列表类型 (在这里会是 kLSSharedFileListSessionLoginItems(当前用户的启动项列表) 或者 kLSSharedFileListGlobalLoginItems (所有用户的启动项列表)).
         *  @param listOptions  -其他选项,一般来说就是NULL啦~                               
         *
         *  @return 启动项列表
         */
        LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems, NULL);
        
        
        
        
        
        
        if (loginItems) {
            
            //删除原来的启动项
            if(saveAppPath.length){
                CFURLRef oldurl = (__bridge CFURLRef)[NSURL fileURLWithPath:saveAppPath];
                if (loginItems) {
                    //获取启动项列表并转换为NSArray,这样方便取其中的项
                    
                    UInt32 seedValue;
                    NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
                    for(int i = 0; i< [loginItemsArray count]; i++){
                        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
                        //用URL来解析项
                        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &oldurl, NULL) == noErr) {
                            NSString * urlPath = [(__bridge NSURL*)oldurl path];
                            if ([urlPath compare:saveAppPath] == NSOrderedSame){
                                /**
                                 *     inList – 我们想要删除启动项的列表.
                                 *     inItem – 要删除的项
                                 */
                                LSSharedFileListItemRemove(loginItems,itemRef);
                            }
                            
                        }
                    }
                    
                }
            }
            
            
            /**
             *  将项目插入启动表中.
             *
             *  @param inList                我们想要插入启动项的列表.
             *  @param insertAfterThisItem - 指定在哪插,kLSSharedFileListItemBeforeFirst表示最前,kLSSharedFileListItemLast表示最后
             *  @param inDisplayName – 项目的显示明,如果是NULL的话则为应用程序的名字
             *  @param inIconRef –项目的显示图标,如果是NULL的话则为应用程序的图标
             *  @param inURL – 项目的URL,即程序XXX.app的完整地址,包括XXX.app
             *  @param 另外两个你大可不管,留个NULL就好了
             *
             *  @return
             */
            LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
            
            if (item)CFRelease(item);
        }
        CFRelease(loginItems);
        //更新数据
        [mainplistDic setObject:nowAppPath forKey:@"appPath"];
        [mainplistDic writeToFile:[SavePath share].mainPlistPath atomically:YES];
     
    }
}





@end
