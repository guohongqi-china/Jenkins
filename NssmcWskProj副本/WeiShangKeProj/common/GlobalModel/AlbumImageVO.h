//
//  AlbumImageVO.h
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import <Foundation/Foundation.h>
#import "AlbumInfoVO.h"
#import "AlbumImageInfoVO.h"

@interface AlbumImageVO : NSObject

@property (nonatomic, retain) AlbumInfoVO *albumInfo;
@property (nonatomic, retain) NSString    *userID;
@property (nonatomic, retain) NSArray     *imageList;

@end
