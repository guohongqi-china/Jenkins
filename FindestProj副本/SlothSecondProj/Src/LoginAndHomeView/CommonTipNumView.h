//
//  CommonTipNumView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-4.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTipNumView : UIView

@property(nonatomic,strong) UIImageView *imgViewNotice;
@property(nonatomic,strong) UILabel *lblNoticeNum;

- (void)updateTipNum:(NSInteger)nTipNum;

@end
