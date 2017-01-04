//
//  Macro.h
//  XHPlayerVideo
//
//  Created by C on 16/8/27.
//  Copyright © 2016年 C. All rights reserved.
//

#ifndef Macro_h
#define Macro_h


#pragma Notification 

#define SendNotification(name,userinfo)  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:name object:nil userInfo:userinfo]]



#endif /* Macro_h */
