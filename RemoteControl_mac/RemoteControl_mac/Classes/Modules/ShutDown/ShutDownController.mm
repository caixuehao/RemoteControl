//
//  ShutDownController.m
//  RemoteControl_mac
//
//  Created by cxh on 17/1/5.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "ShutDownController.h"
#import "SocketMacro.h"
#include <stdio.h>
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
//参考资料  https://developer.apple.com/library/content/qa/qa1134/_index.html

static OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend);

@implementation ShutDownController


+(void)shutdown:(NSString *)str{
    if([str isEqualToString:ShutDown]){
        SendAppleEventToSystemProcess(kAEShutDown);
    }else if([str isEqualToString:Restart]){
     SendAppleEventToSystemProcess(kAERestart);
    }else if([str isEqualToString:Logout]){
        SendAppleEventToSystemProcess(kAEReallyLogOut);
    }else if([str isEqualToString:Sleep]){
        SendAppleEventToSystemProcess(kAESleep);
    }
   
}





OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend)
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
    
    OSStatus error = noErr;
    
    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess,
                         sizeof(kPSNOfSystemProcess), &targetDesc);
    
    if (error != noErr)
    {
        return(error);
    }
    
    error = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetDesc,
                               kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
    
    AEDisposeDesc(&targetDesc);
    if (error != noErr)
    {
        return(error);
    }
    
    error = AESend(&appleEventToSend, &eventReply, kAENoReply,
                   kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
    
    AEDisposeDesc(&appleEventToSend);
    if (error != noErr)
    {
        return(error);
    }
    
    AEDisposeDesc(&eventReply);
    
    return(error);
}

@end
