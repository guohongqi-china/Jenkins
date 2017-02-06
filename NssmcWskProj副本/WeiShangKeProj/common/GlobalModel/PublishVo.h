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

@property (nonatomic, strong) NSString *streamTitle;                //消息标题
@property (nonatomic, strong) NSString *streamContent;              //消息内容
@property (nonatomic, strong) NSMutableArray *attaList;             //附件信息
@property (nonatomic, strong) NSMutableArray *imgList;              //图片信息
@property (nonatomic, strong) NSMutableArray *aryTag;              //图片信息
@property (nonatomic, strong) VoteVo *voteVo;
@property (nonatomic) int streamComefrom;
@property (nonatomic) int isDraft;

@end
