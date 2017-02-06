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

@interface BusinessCommon : NSObject

+ (NSMutableArray*)getTicketTypeArray;
+ (void)setTicketTypeArray:(NSMutableArray*)aryType;

+ (NSString*)getChatImgURLString:(NSString*)strText;
+ (void)setJPUSHAliasAndTags;
+ (BOOL)getRunningUpdateState;
+ (void)setRunningUpdateState:(BOOL)bState;
+ (void)updateServerGroupAndUserData;
+ (RoleType)getUserRealRole:(NSString*)strSum;
+ (void)clearJPUSHAliasAndTags;
+ (NSString*)getScheduleMemberByType:(int)nType andArray:(NSMutableArray*)aryMemList;
+ (NSString*)getImageNameByMessageState:(int)nState;
+ (NSString*)getReceiverListString:(NSMutableArray*)aryReceiverList andType:(NSString*)strType;
+ (NSString*)getAttachmentListString:(NSMutableArray*)aryAttachmentList;
+ (void)updateAppImageAction:(NSArray*)aryImageList;
+ (void)showShareActionSheet:(UIViewController*)vcContainer andShareVo:(ShareInfoVo*)shareInfoVo;
+(NSString*)getSessionHeadBySource:(NSInteger)nSource;

@end
