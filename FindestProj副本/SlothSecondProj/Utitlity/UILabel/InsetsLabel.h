//
//  InsetsLabel.h
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/31/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsetsLabel : UILabel

@property(nonatomic) UIEdgeInsets insets;
-(id) initWithFrame:(CGRect)frame andInsets: (UIEdgeInsets) insets;
-(id) initWithInsets: (UIEdgeInsets) insets;

@end
