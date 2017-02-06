//
//  Common.h
//  CorpKnowlGroup
//
//  Created by yuson on 11-4-28.
//  Copyright 2011 DNE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerProvider.h"

#define PAGE_ITEM_COUNT			500
#define POST_TEMP_DIRECTORY @"TempFile"
#define CHAT_TEMP_DIRECTORY @"ChatFile"

//extern 是外部全局变量的声明而不是定义
extern int iOSPlatform;
extern CGFloat kScreenWidth;
extern CGFloat kScreenHeight;
extern CGFloat kStatusBarHeight;
extern CGFloat kTabBarHeight;
extern CGFloat NAV_BAR_HEIGHT;
extern NSString *NAV_BG_IMAGE;

@interface Common : NSObject 
+(NSString*)createFileNameByDateTime:(NSString*)strExtension;
+(void) warningAlert:(NSString *)str;
+(void) tipAlert:(NSString *) str;
+(void) tipAlert:(NSString *)strContent andTitle:(NSString *)strTitle;

+(NSString *) getKey:(int)index;
+(BOOL) IsSubString:(NSString *)srcString subString:(NSString *)destString;

//信息提示
+(NSString *) ask: (NSString *) question withTextPrompt: (NSString *) prompt;
+(NSUInteger) ask: (NSString *) question withCancel: (NSString *) cancelButtonTitle withButtons: (NSArray *) buttons;
+(void) say: (id)formatstring,...;
+(BOOL) ask: (id)formatstring,...;
+(BOOL) confirm: (id)formatstring,...;
+(BOOL) alert: (id)formatstring,...;

+(NSString *) getMD5Value:(NSString *)str;
+(NSString *)getStringByKey:(NSString *)key;
+(void) saveString:(NSString *)object withKey:(NSString *)key;
+(void) removeStringByKey:(NSString *)key;
+(void) saveImage:(UIImage *)image ToDocumentFile:(NSString *)file;
+(NSMutableDictionary *) getFileInfo:(NSString *)fileName;
+(NSString *) getFilePathFromName:(NSString *)fileName;

+(void)setUserPwd:(NSString *)strPwd;
+(NSString *)getUserPwd;
+ (NSString*) GetIOSUUID;
+(BOOL)checkIsSelf:(NSString*)strOtherVestID;
+(UIImage*)getImageWithColor: (UIColor *) color;
+(NSString*)htmlTextToPlainText:(NSString*)strHtmlText;
+(NSString*)getFileIconImageByName:(NSString*)strFileName;
+(NSString*)createImageNameByDateTime:(NSString*)strExtension;
+(NSString*)createVideoNameByDateTime;
+(UIImage*)getThumbnailFromVideo:(NSURL*)strVideoUrl;
+(float)getTextViewHeight:(int)nWidth andText:(NSString*)strText andViewController:(UIViewController*)tempViewController;
+(NSString *)doSimpleHtmlText:(NSString*)strHtmlText;
+(NSString*)replaceLineBreak:(NSString*)strText;
+(UIImage *)rotateImage:(UIImage *)aImage;
+(NSString*)dataToHexString:(NSData*)data;
+(NSString*)getCurrentDateTime;
+(UIImage *)getImageFromView:(UIView *)orgView;
+(NSString*)getDateStrFromDateTimeStr:(NSString*)strDateTime;
+(NSDate*)getDateFromDateStr:(NSString*)strDateTime;
+(NSString*)getChatTimeStr:(NSString*)strDateTime;
+(NSString*)getChatDateTime:(NSDate*)dateTime;
+(NSString*)getChatTimeStr2:(NSString*)strDateTime;
+(NSString*)getDateTimeStrByDate:(NSDate*)dateTime;
+(NSString*)getDateTimeStrStyle1:(NSString*)strDateTime;
+(NSString*)getDateTimeStrStyle2:(NSString*)strDateTime andFormatStr:(NSString*)strFormat;
+ (NSString *)getDateTimeStringFromTimeStamp:(unsigned long long)llTimeInterval;
+ (NSDate *)getDateFromTimeStamp:(unsigned long long)llTimeInterval;
+(NSString *)minAndSec:(int)seconds;
+(UITableView*)getTableViewByCell:(UITableViewCell*)tableViewCell;
+(CGFloat)measureHeight:(UITextView*)textView;
+(void)initGlobalValue;
+(NSString*)getDateTimeAndNoSecond:(NSString*)strDateTime;

+(void)setSessionID:(NSString *)strSessionID;
+(NSString *)getSessionID;
+(void)setChatSessionID:(NSString *)strSessionID;
+(NSString *)getChatSessionID;
+(void)setCurrentUserVo:(UserVo*)userVo;
+(UserVo*)getCurrentUserVo;
+ (void)setFirstEnterAppState:(BOOL)bFirstEnterApp;
+ (BOOL)getFirstEnterAppState;
+(void)showProgressView:(NSString*)strText view:(UIView*)view modal:(BOOL)bModal;
+(void)hideProgressView:(UIView*)view;

+(NSString*)checkStrValue:(NSString*)strValue;
+(BOOL)checkIsImageOrNot:(NSString*)strFileName;
+(NSString *)getFileNameFromPath:(NSString *)path;
+(NSString *)getAppVersion;
+(NSString *)getAppName;

+(NSString*)createImageNameByDateTimeAndPara:(int)nPara;
+(NSString*)getDevicePlatform;
+(BOOL)isImageValid:(UIImage*)image;

+(NSString *)localStr:(NSString *)strKey value:(NSString*)strValue;
+(NSString *)localImagePath:(NSString *)strImageName;
+(NSString*)getFileSizeFormatString:(unsigned long long)lFileSize;
+(BOOL)checkDoSupportByWebView:(NSString*)strFileName;
+(NSString*)createVideoNamePlusExtension:(NSString*)strExtension;
+(CGSize)getStringSize:(NSString*)strContent font:(UIFont*)font bound:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
+(NSDate*)getDateFromString:(NSString*)strDateTime andFormatStr:(NSString*)strFormat;
+(void)bubbleTip:(NSString*)strText andView:(UIView*)viewParent;
+(NSString*)createImageNameByDateTime;

+ (void)setButtonImageTitlePosition:(UIButton*)button spacing:(CGFloat)fSpace;
+ (void)setButtonImageLeftTitleRight:(UIButton*)button spacing:(CGFloat)fSpace;
+ (void)setButtonImageRightTitleLeft:(UIButton*)button spacing:(CGFloat)fSpace;

@end
