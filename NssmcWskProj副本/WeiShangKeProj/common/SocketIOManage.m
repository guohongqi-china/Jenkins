//
//  SocketIOManage.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 2/4/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "SocketIOManage.h"
#import "SocketIOPacket.h"
#import "ServerURL.h"
#import "UserVo.h"
#import "DNENetworkFramework.h"
#import "ServerProvider.h"
#import "ChatContentVo.h"

@implementation SocketIOManage

static SocketIOManage *sharedSocketIOManageObj = nil;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
}

//单例模式
+ (id)sharedSocketIOManage
{
    //直接返回，因为需要登录后才能操作
    return sharedSocketIOManageObj;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        //params
        self.dicParams = [NSMutableDictionary dictionary];
        [self.dicParams setObject:[Common getCurrentUserVo].strUserID forKey:@"toUserId"];
        [self.dicParams setObject:@"kefu" forKey:@"from"];
        [self.dicParams setObject:[Common getCurrentUserVo].strCompanyID forKey:@"companyId"];
        
        self.socketIO = [[SocketIO alloc] initWithDelegate:self];
        [self.socketIO connectToHost:SERVER_CHAT_IP onPort:SERVER_CHAT_PORT.integerValue withParams:self.dicParams];
        
        self.networkStatus = ReachableViaWiFi;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    }
    sharedSocketIOManageObj = self;
    return self;
}

//重新连接WebSocket(是否强制重连)
-(void)connectWebSocket:(BOOL)bForce
{
    if(self.networkStatus != NotReachable)
    {
        //如果是强制重连，或者socketIO没有连接并且没有正在连接
        if(bForce || (!self.socketIO.isConnected && !self.socketIO.isConnecting))
        {
            [self.socketIO disconnect];
            [self.socketIO connectToHost:SERVER_CHAT_IP onPort:SERVER_CHAT_PORT.integerValue withParams:self.dicParams];
        }
    }
}

//断开WebSocket的连接
-(void)disconnectWebSocket
{
    [self.socketIO disconnect];
}

//网络发生变化
-(void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = [notification object];
    self.networkStatus = [reachability currentReachabilityStatus];
    switch (self.networkStatus)
    {
        case NotReachable:
        {
            NSLog(@"SocketIOManage - NotReachable");
            [self disconnectWebSocket];
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"ReachableViaWWAN");
            [self connectWebSocket:YES];
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"ReachableViaWiFi");
            [self connectWebSocket:YES];
            break;
        }
        default:
        {
            NSLog(@"Unknow network");
            [self connectWebSocket:YES];
            break;
        }
    }
}

#pragma mark - SocketIODelegate
//消息类别为idx=5,event(NodeJS现在只发送event,5:::{...})
- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSString *receiveData=packet.data;
    NSDictionary *dicPushJson = [DNENetworkFramework JSONValueFromString:receiveData];
    if (dicPushJson != nil && [dicPushJson isKindOfClass:[NSDictionary class]])
    {
        NSString *strType = [Common checkStrValue:[dicPushJson objectForKey:@"name"]];
        if([strType isEqualToString:@"whisper"])
        {
            //私信
            NSArray *aryContent = [dicPushJson objectForKey:@"args"];
            if(aryContent != nil && [aryContent isKindOfClass:[NSArray class]] && aryContent.count>0)
            {
                NSDictionary *dicContent = aryContent[0];
                ChatContentVo *chatContentVo;
                
                //message
                NSDictionary *dicMessageJSON = [dicContent objectForKey:@"message"];
                //NSDictionary *dicMessageJSON = [DNENetworkFramework JSONValueFromString:[dicContent objectForKey:@"message"]];
                if(dicMessageJSON != nil)
                {
                    NSMutableArray *aryMessage = [ServerProvider getSessionDetailByJSONArray:@[dicMessageJSON]];
                    if (aryMessage.count>0)
                    {
                        chatContentVo = aryMessage[0];
                    }
                }
                
                //session
                //NSDictionary *dicSessionJSON = [DNENetworkFramework JSONValueFromString:[dicContent objectForKey:@"talk"]];
                NSDictionary *dicSessionJSON = [dicContent objectForKey:@"talk"];
                if(dicSessionJSON != nil)
                {
                    NSMutableArray *arySession = [ServerProvider getSessionListByJSONArray:@[dicSessionJSON]];
                    if (arySession.count>0)
                    {
                        ChatObjectVo *chatObjectVo = arySession[0];
                        chatObjectVo.chatContentVo = chatContentVo;
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:WS_RECEIVE_MSG object:chatObjectVo];
                    }
                }
            }
        }
        else
        {
            //其他 web socket 推送
        }
    }
}

//已经连接成功
- (void)socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"SocketIOManage -- socketIODidConnect");
}

//已经断开连接
- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"SocketIOManage -- socketIODidDisconnect,error:%@",error);
    //[self reconnectWebSocket];//当网络发生问题时，socketIO :onError方法会调用
    //TODO:尝试重新连接的操作
}

//SocketIO发生错误
- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"SocketIOManage -- socketIO:onError,error:%@",error);
    //TODO:尝试重新连接的操作
}

@end
