//
//  ManListModel.h
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "PraiseModel.h"
@interface ManListModel : NSObject

@property (nonatomic, copy) NSString *noticeTitle;/** <#注释#> */
@property (nonatomic, copy) NSString *commentText;/** <#注释#> */
@property (nonatomic, copy) NSString *createDate;/** <#注释#> */
@property (nonatomic, copy) NSString *userName;/** <#注释#> */
@property (nonatomic, copy) NSString *updateDate;/** <#注释#> */
@property (nonatomic, copy) NSString *userImgUrl;/** <#注释#> */
@property (nonatomic, copy) NSString *orderId;/** <#注释#> */
@property (nonatomic, copy) NSString *createName;/** <#注释#> */
@property (nonatomic, copy) NSString *titleName;/** <#注释#> */
@property (nonatomic, copy) NSString *streamText;/** 内容 */
@property (nonatomic, copy) NSString *subtitle;/** 推荐语 */
@property (nonatomic, copy) NSString *ID;/** <#注释#> */
@property (nonatomic, copy) NSString *praiseCount;/** 点赞数 */
@property (nonatomic, copy) NSString *commentCount;/** 评论数 */
@property (nonatomic, strong) NSMutableArray * commentVoList;/** <#注释#> */

@property (nonatomic, copy) NSString *isDraft;/** <#注释#> */
@property (nonatomic, copy) NSString *hasStore;/** 收藏状态0-1， */
@property (nonatomic, copy) NSString *totalPages;/** 总页数 */
@property (nonatomic, copy) NSString *userNickname;/** <#注释#> */

@property (nonatomic, strong) NSMutableArray *mentionList;/** <#注释#> */

@property (nonatomic, strong) NSMutableArray *tagVoList;/** <#注释#> */

@property (nonatomic, copy) NSString *parentUserName;/** <#注释#> */
- (CGFloat)returenCellHeight;
- (CGFloat)getHeight;
@end
