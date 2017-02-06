//
//  PublishVo.h
//  ChinaMobileSocialProj
//
//  Created by dne on 13-11-29.
//
//

#import <Foundation/Foundation.h>
#import "VoteVo.h"

@interface PublishVo : NSObject

@property (nonatomic, strong) NSString *strRefID;

@property (nonatomic, strong) NSString *streamTitle;                //消息标题
@property (nonatomic) NSInteger nType;  //0:分享,1:投票,2:问答
@property (nonatomic, strong) NSString *streamContent;              //消息内容
@property (nonatomic, strong) NSMutableAttributedString *attriContent;      //消息内容图片
@property (nonatomic, strong) NSMutableArray *aryAttriRange;                //富文本的Range

@property (nonatomic, strong) NSMutableArray *attaList;             //附件信息
@property (nonatomic, strong) NSMutableArray *imgList;              //图片信息
@property (nonatomic, strong) NSMutableArray *aryTag;               //图片信息
@property (nonatomic, strong) NSMutableArray *aryAT;                //手动选人 @list
@property (nonatomic, strong) NSString *strVideoPath;               //视频文件路径
@property (nonatomic, strong) VoteVo *voteVo;
@property (nonatomic) int streamComefrom;
@property (nonatomic) int isDraft;

@property (nonatomic, strong) NSString *strShareLink;               //分享的超链接

@end
