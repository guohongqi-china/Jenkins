//
//  AudioTipView.h
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/14/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioTipView : UIView

@property (nonatomic, strong) UIImageView *imgViewState;
@property (nonatomic, strong) UIImageView *imgViewSignal;
@property (nonatomic, strong) UILabel *lblNumber;//倒数计时
@property (nonatomic, strong) UILabel *lblTip;
@property (nonatomic) NSInteger m_nState;

- (void)updateView:(NSInteger)nState andValue:(float)fValue;

@end
