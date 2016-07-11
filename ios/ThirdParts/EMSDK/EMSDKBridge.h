//
//  EMSDKBridge.h
//  UMengRN
//
//  Created by 苍小米 on 16/7/4.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
//EMSDK
#import "EMSDK.h"

@interface EMSDKBridge : NSObject<RCTBridgeModule, EMChatManagerDelegate>


@end
