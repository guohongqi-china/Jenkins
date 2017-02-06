//
//  ServerReturnInfo.h
//  Sloth
//
//  Created by 焱 孙 on 12-11-16.
//
//

#import <Foundation/Foundation.h>

@class ServerReturnInfo;
typedef void (^ResultBlock)(ServerReturnInfo *retInfo);

@interface ServerReturnInfo : NSObject

@property(nonatomic)BOOL bSuccess;           //服务器访问成功与失败
@property(nonatomic,strong)NSString *strErrorMsg;   //失败时的错误信息
@property(nonatomic,strong)id data;                 //返回的数据
@property(nonatomic,strong)id data2;                //返回的数据2
@property(nonatomic,strong)id data3;                //返回的数据3
@property(nonatomic,strong)id data4;
@property(nonatomic,strong)id data5;

@end
