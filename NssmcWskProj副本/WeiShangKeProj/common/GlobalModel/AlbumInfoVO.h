//
//  AlbumInfoVO.h
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import <Foundation/Foundation.h>

@interface AlbumInfoVO : NSObject

@property (nonatomic, retain) NSString *albumFolderID;          //相册id
@property (nonatomic, retain) NSString *albumFolderName;        //相册名称
@property (nonatomic, assign) int       nAlbumFolderType;       //相册类型	1为系统，2为群组，3为用户
@property (nonatomic, retain) NSString *albumFolderRemark;      //备注
@property (nonatomic, assign) BOOL      bIsDefault;             //是否是默认相册	0：非，1：是，默认相册不能删除
@property (nonatomic, retain) NSString *albumFolderCreator;     //创建者
@property (nonatomic, retain) NSString *albumGroupID;           //群组id
@property (nonatomic, retain) NSString *albumCreateDate;        //创建时间
@property (nonatomic, retain) NSArray  *albumImageList;         //图片集合
@property (nonatomic, retain) NSString *strAlbumImage;          //相册封面图片

@end
