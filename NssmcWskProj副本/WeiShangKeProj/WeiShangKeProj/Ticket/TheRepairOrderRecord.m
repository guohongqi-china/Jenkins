//
//  TheRepairOrderRecord.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TheRepairOrderRecord.h"
#import "UIView+Extension.h"
@implementation TheRepairOrderRecord
- (instancetype)init{
    if (self = [super init]) {
        
        _baseView = [[UIImageView alloc]init];
        _baseView.image = [UIImage imageNamed:@"ticket_trace_icon"];
        [self addSubview:_baseView];
        
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = COLOR(220, 220, 220, 1);
        _timeLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_timeLabel];
        
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = COLOR(159, 159, 159, 1);
        _contentLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_contentLabel];
        

        [self setModelFrame:nil];
    }
    return self;
}
- (void)setModelFrame:(modelForViewFrame *)modelFrame{
    modelForView *modelViwe = modelFrame.modelForView;
//    modelFrame.modelForView = modelViwe;
    _timeLabel.text = modelViwe.timeString;
    _timeLabel.frame = modelFrame.timeRect;
    _contentLabel.text =modelViwe.contentString;
    _contentLabel.frame = modelFrame.contentRect;
    _baseView.frame = modelFrame.imageFrame;
    self.height = CGRectGetMaxY(_contentLabel.frame);
    
}

@end
