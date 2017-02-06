//
//  CustomLabel.h
//  TestOpenFlowView
//
//  Created by Sunyan on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StrokeLabel : UILabel

@property(nonatomic,assign)double fStrokeLineWidth;
@property(nonatomic,retain)UIColor *colorStroke;
@property(nonatomic,assign)CGRect rectStroke;

@end
