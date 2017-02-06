//
//  TransferInfoVo.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-1-2.
//
//

#import <Foundation/Foundation.h>

@interface TransferInfoVo : NSObject

@property(nonatomic,retain)NSString *strTransferID;         //转发消息ID
@property(nonatomic,retain)NSString *strAuthorID;           //作者ID
@property(nonatomic,retain)NSString *strAuthorName;         //作者姓名
@property(nonatomic,retain)NSString *strAuthorImg;          //作者头像
@property(nonatomic,retain)NSString *strContent;            //转发内容
@property(nonatomic,retain)NSString *strTransferDate;       //转发日期
@property(nonatomic,assign)BOOL bCouldRead;                 //是否有查看权限
@property(nonatomic,assign)int nDeleteFlag;                 //是否已经删除(1:已删除,0:未删除)

@end
