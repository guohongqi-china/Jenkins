//
//  DetailTableViewCell.m
//  FindestProj
//
//  Created by MacBook on 16/7/19.
//  Copyright © 2016年 visionet. All rights reserved.
//
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#import "DetailTableViewCell.h"

@implementation DetailTableViewCell


- (void)setDataModel:(ManListModel *)dataModel{
    _dataModel = dataModel;
    _timeLabel.text = dataModel.createDate;
    _contentLabel.text = dataModel.commentText;
    NSMutableAttributedString *strm = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc]initWithString:dataModel.userName];
    [str2 addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(58, 108, 174, 1) range:NSMakeRange(0, str2.length)];
    [strm appendAttributedString:str2];
    NSLog(@"%@",dataModel.parentUserName);
    if (!(dataModel.parentUserName.length==0 || dataModel.parentUserName==nil ||[dataModel.parentUserName isEqualToString:@"(null)"])) {
        NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" 回复 %@",dataModel.parentUserName]];
        [str3 addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(58, 108, 174, 1) range:NSMakeRange(3, str3.length - 3)];
        [strm appendAttributedString:str3];

    }
    _titleLabel.attributedText = strm;
    if ([dataModel.praiseCount isEqualToString:@"2"]) {
        _praiseButton.selected = YES;
    }
}



- (IBAction)praiseButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}



- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
