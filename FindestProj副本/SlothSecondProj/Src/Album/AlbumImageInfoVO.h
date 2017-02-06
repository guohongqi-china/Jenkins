//
//  AlbumImageInfoVO.h
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import <Foundation/Foundation.h>

@interface AlbumImageInfoVO : NSObject

@property (nonatomic, retain) NSString *imageID;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *imageType;
@property (nonatomic, assign) int       nImageWidth;
@property (nonatomic, assign) int       nImageHeight;
@property (nonatomic, assign) int       nImgCommentCnt;
@property (nonatomic, assign) int       nImgPraiseCnt;
@property (nonatomic, retain) NSString *imageCreator;
@property (nonatomic, retain) NSString *imageCreateDate;
@property (nonatomic, retain) NSString *imageMinUrl;
@property (nonatomic, retain) NSString *imageMidUrl;
@property (nonatomic, retain) NSString *imageMaxUrl;
@property (nonatomic, retain) NSString *imageRemark;
@property (nonatomic, retain) NSString *imageDateFmt;

@end
