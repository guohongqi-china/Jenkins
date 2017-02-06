//
//  FAQListCell.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/20/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAQVo.h"
#import "MGSwipeTableCell.h"

@interface FAQListCell : MGSwipeTableCell

@property(nonatomic,strong)UIView *viewLineTop;
@property(nonatomic,strong)UILabel *lblTitle;
@property(nonatomic,strong)UIImageView *imgViewArrow;

@property(nonatomic,strong)UIView *viewMiddle;
@property(nonatomic,strong)UIView *viewLineMiddle;
@property(nonatomic,strong)UILabel *lblContent;
@property(nonatomic,strong)UIImageView *imgViewContent;

@property(nonatomic,strong)UIButton *btnLink;
@property(nonatomic,strong)UIView *viewLineBottom;
@property(nonatomic,strong)UIView *viewSeperate;

@property(nonatomic,strong)FAQVo *m_faqVo;
@property(nonatomic,weak)UIViewController *parentViewController;

-(void)initWithData:(FAQVo*)faqVo andExpandID:(NSString*)strExpandID;
+ (CGFloat)calculateCellHeight:(FAQVo *)faqVo andExpandID:(NSString*)strExpandID;

@end
