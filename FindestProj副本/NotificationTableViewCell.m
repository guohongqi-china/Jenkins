//
//  NotificationTableViewCell.m
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//
#import "UIView+Extension.h"
#import "NotificationTableViewCell.h"
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@implementation NotificationTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpUI];
    }
    return self;
}
- (void)setUpUI{
    _baseView = [[UIView alloc]init];
    _baseView.backgroundColor = [UIColor whiteColor];
    _contentLabel = [self setUpLabel:15 color:RGBACOLOR(50, 50, 50, 1)];
    _contentLabel.numberOfLines = 0;
    
    _timeLabel = [self setUpLabel:14 color:RGBACOLOR(61, 112, 141, 1)];
    _timeLabel.contentMode = NSTextAlignmentRight;
    
    [self.contentView addSubview:_baseView];
    [_baseView addSubview:_timeLabel];
    [_baseView addSubview:_contentLabel];
    self.contentView.backgroundColor = RGBACOLOR(249, 246, 245, 1);
}
/**
 *  指定label的某些属性，并返回一个label
 */
- (UILabel *)setUpLabel:(CGFloat )font color:(UIColor *)color{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:font];
    label.textColor = color;
    return label;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setDataModel:(ManListModel *)dataModel{
    _dataModel = dataModel;
    _contentLabel.text = dataModel.noticeTitle;
    _timeLabel.text = dataModel.createDate;
    
    _contentLabel.x = 5;
    _contentLabel.y = 10;
    _contentLabel.width = KscreenWidth - 10;
     CGFloat lable2Rect = [dataModel.noticeTitle boundingRectWithSize:CGSizeMake(_contentLabel.width, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height;
    _contentLabel.height = lable2Rect;
    
    _timeLabel.y = CGRectGetMaxY(_contentLabel.frame);
    _timeLabel.width = 80;
    _timeLabel.height = 16;
    _timeLabel.x = KscreenWidth - 85;
    _baseView.x = 0;
    _baseView.width = KscreenWidth;
    _baseView.y = 1;
    _baseView.height = CGRectGetMaxY(_timeLabel.frame);
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
