//
//  VoteVo.h
//  Sloth
//
//  Created by 焱 孙 on 12-12-24.
//
//

#import <Foundation/Foundation.h>

@interface VoteVo : NSObject

@property(nonatomic,retain)NSString *strID;                     //投票ID
@property(nonatomic,assign)NSInteger nVoteType;                 //投票类型 (单选0多选1)
@property(nonatomic,assign)NSInteger nVoteTotal;                //投票总数（多选）
@property(nonatomic,assign)NSInteger nVotePersonTotal;          //投票人总数
@property(nonatomic,assign)BOOL bAlreadVote;                    //当前用户是否投过票（YES,NO）
@property(nonatomic,retain)NSString *strVoterName;              //投票人员姓名（格式:姓名&姓名）
@property(nonatomic,retain)NSMutableArray *aryVoteOption;       //投票选项  (投票项>=2)

@property(nonatomic)NSInteger nMinOption;                      //多选题 - 最少选项
@property(nonatomic)NSInteger nMaxOption;                      //多选题 - 最多选项,0:不限
@property(nonatomic)NSInteger nVoteDeadline;                    //投票有限期，一天、一周、一个月

@property(nonatomic)NSInteger nContentType;                    //1:图片投票、2:文字投票

@property(nonatomic)BOOL bOverdue;            //是否过期

@end
