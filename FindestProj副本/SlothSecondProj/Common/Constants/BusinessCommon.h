//
//  BusinessCommon.h
//  Sloth
//
//  Created by 焱 孙 on 13-7-3.
//
//

#import <Foundation/Foundation.h>
#import "ServerProvider.h"
#import "ShareInfoVo.h"
#import "UploadFileVo.h"
#import "IntegralInfoVo.h"

@interface BusinessCommon : NSObject

+ (NSString*)getChatImgURLString:(NSString*)strText;
+ (void)setJPUSHAliasAndTags;
+ (BOOL)getRunningUpdateState;
+ (void)setRunningUpdateState:(BOOL)bState;
+ (void)updateServerGroupAndUserData:(void(^)(void))finished;
+ (RoleType)getUserRealRole:(NSString*)strSum;
+ (void)clearJPUSHAliasAndTags;
+ (NSString*)getScheduleMemberByType:(int)nType andArray:(NSMutableArray*)aryMemList;
+ (NSString*)getImageNameByMessageState:(int)nState;
+ (NSString*)getReceiverListString:(NSMutableArray*)aryReceiverList andType:(NSString*)strType;
+ (NSString*)getAttachmentListString:(NSMutableArray*)aryAttachmentList;
+ (void)shareContentToThirdPlatform:(UIViewController*)vcContainer shareVo:(ShareInfoVo*)shareInfoVo shareList:(NSArray*)aryShareType;
+ (NSString*)getLeagueTypeName:(NSInteger)nType;
+ (UIImage*)getHeaderBKImageByIntegral:(double)fNum andSuffix:(NSString*)strSuffix;
+ (UIImage*)getBadgeImage:(NSInteger)nBadge;
+ (void)addAnimation:(double)fIntegral sum:(double)fSumIntegral view:(UIView*)viewContainer;

+ (void)checkShareURLJump:(NSString *)strURL parent:(UIViewController*)viewController;

+ (void)presentVideoViewController:(NSURL *)urlVideo controller:(UIViewController*)parentController;
+ (void)jumpToNotifyListByJPUSH:(NSInteger)nMainType viewController:(UIViewController*)viewControllerParent;

//根据图片路径生成Img标签
+ (NSString *)getHtmlImgByImageURL:(UploadFileVo *)uploadFileVo;
+ (NSString *)getCollectionNumByInt:(NSInteger)nNum;
+ (NSString *)getMonthDayWeekStringByDate:(NSDate *)date;

+ (void)playingOpeningMusic;

+ (IntegralInfoVo *)getIntegralInfo:(double)fNum;
+ (void)getReportUserInfoList:(UIView *)view result:(void(^)(NSMutableArray *aryReportInfo))resultBlock;

@end
