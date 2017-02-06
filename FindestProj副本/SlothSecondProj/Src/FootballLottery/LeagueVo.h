//
//  LeagueVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 10/29/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeagueVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic)NSInteger nLeagueType;      //联赛类型,1-意甲；2-西甲；3-德甲；4-英超；5-法甲；6-中超；7-欧洲杯
@property(nonatomic,strong)NSString *strLeagueTypeName;         //联赛类型,1-意甲；2-西甲；3-德甲；4-英超；5-法甲；6-中超 7-欧洲杯
@property(nonatomic)NSInteger nCommitGuess;//当前用户准备提交比分 0:未竞猜;1:胜；2:平；3:负
@property(nonatomic)NSInteger nCurrGuess;//当前用户历史提交比分	0:未竞猜；1:胜；2:平；3:负
@property(nonatomic)NSInteger nCurrResult;//当前用是否猜中,0:未猜中；1:已猜中,
@property(nonatomic)double fIntegration;//获得积分
@property(nonatomic)NSInteger nConsumeIntegral;//押注积分
@property(nonatomic,strong)NSString *strTeam1;      //主场队伍
@property(nonatomic,strong)NSString *strTeam2;      //客场队伍
@property(nonatomic,strong)NSString *strDateTime;  //开赛日期时间
@property(nonatomic,strong)NSString *strDate;  //开赛日期
@property(nonatomic,strong)NSString *strTime;  //开赛时间
@property(nonatomic)NSInteger nStatus;//赛事状态，1:未塞；3:完赛

//胜平负赔率
@property(nonatomic)CGFloat fWinOdds;
@property(nonatomic)CGFloat fEqualOdds;
@property(nonatomic)CGFloat fLoseOdds;

//logo
@property(nonatomic,strong)NSString *strTeam1Logo;//主队logo
@property(nonatomic,strong)NSString *strTeam2Logo;//客队logo

////////////////////////////////////////////////////////////////////////////////////////////////

@property(nonatomic,strong)NSString *strBlogID;//分享ID
@property(nonatomic,strong)NSString *strTitle;//完赛后会带比分
@property(nonatomic,strong)NSString *strSeason;//年度
@property(nonatomic)NSInteger nRound;//联赛轮次
@property(nonatomic)NSInteger nHot; //是否热门，0:否；1:是
@property(nonatomic)NSInteger nHomeScore;//主场队得分
@property(nonatomic)NSInteger nAwayScore;//客场队得分
@property(nonatomic,strong)NSString *strCity;//比赛城市
@property(nonatomic,strong)NSString *strWinNames;//猜中人名	昵称


@end
