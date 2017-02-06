//
//  SocketIOManage.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 2/4/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "Reachability.h"

@interface SocketIOManage : NSObject<SocketIODelegate>

@property (nonatomic,strong)SocketIO *socketIO;
@property (nonatomic)NetworkStatus networkStatus;

@property (nonatomic,strong)NSMutableDictionary *dicParams;

+ (id)sharedSocketIOManage;
- (void)connectWebSocket:(BOOL)bForce;
- (void)disconnectWebSocket;

@end
