//
//  HomeTableViewCell.h
//  FindestProj
//
//  Created by MacBook on 16/7/15.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManListModel.h"
@class HomeTableViewCell;
@protocol HomeTableViewCellDelegate <NSObject>

- (void)homeTableViewCellPraiseButton:(NSString *)ID;

@end

@interface HomeTableViewCell : UITableViewCell

@property (nonatomic, assign) id<HomeTableViewCellDelegate> delegate;/** <#注释#> */
@property (nonatomic, strong) UIView *firstView;/** <#注释#> */
@property (nonatomic, strong) UIView *secondView;/** <#注释#> */
@property (nonatomic, strong) UIView *thirdView;/** <#注释#> */


@property (nonatomic, strong) UIImageView *iconImage;/** <#注释#> */

@property (nonatomic, strong) UILabel *createLabel;/** 创始人 */

@property (nonatomic, strong) UILabel *timeLabel;/** 创建时间 */

@property (nonatomic, strong) UILabel *subtitleLabel;/** 推荐语 */

@property (nonatomic, strong) UILabel *titileLabel;/** 副标题 */

@property (nonatomic, strong) UILabel *contntLabel;/** 主要内容 */

@property (nonatomic, strong) UIImageView *contentImage;/** 分享图片 */

@property (nonatomic, strong) UIButton *praiseButton;/** 赞button */

@property (nonatomic, strong) UIButton *commentButton;/** 评论 */


@property (nonatomic, strong) ManListModel *dataModel;/** model类 */

@property (nonatomic, strong) UILabel *auditLabel;/** <#注释#> */

@end
