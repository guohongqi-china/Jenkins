//
//  PageClassVo.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-5.
//
//

#import <Foundation/Foundation.h>

@interface PageClassVo : NSObject

@property(nonatomic,retain)NSString *strPageID;
@property(nonatomic,retain)NSString *strPageName;
@property(nonatomic,assign)int nPageType;//1:friend,2:group,3:tag
@property(nonatomic,assign)int nNewBlogCount;

@end
