//
//  MainViewTableViewCell.m
//  FindestProj
//
//  Created by MacBook on 16/7/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MainViewTableViewCell.h"
#import "ManListModel.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extension.h"
@implementation MainViewTableViewCell


/**
 *  Model的赋值方法
 */
- (void)setDataModel:(ManListModel *)dataModel{
    _dataModel = dataModel;
    _IconView.image = [UIImage imageNamed:@"default_m@2x"];
    _createLabel.text = dataModel.createName;
    _timeLabel.text = dataModel.createDate;
    _subtitleLabel.text = dataModel.subtitle;
    _titlelabel.text = dataModel.titleName;
    _contentLabel.text = dataModel.streamText;
    [_contentLabel sizeToFit];
//    CGFloat lable2Rect = [dataModel.streamText boundingRectWithSize:CGSizeMake(_contentLabel.width, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size.height;
    if (!(_dataModel.userImgUrl.length == 0 || _dataModel.userImgUrl == nil)) {
        [_contentImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vn-functional.chinacloudapp.cn/vx/%@",dataModel.userImgUrl]]];
        
    }else{
    
        
    }
    _contentHeight.constant = 0;
    _Hhhhh.constant =  CGRectGetMaxY(_contentLabel.frame);
    
    
    //判断第三个视图是否显示出来
    if (!(dataModel.commentVoList.count == 0 || dataModel.commentVoList == nil)) {
        NSLog(@"=======%ld",(unsigned long)_thirdView.subviews.count);
        for (id mod in _thirdView.subviews) {
            if ([mod isKindOfClass:[UILabel class]]) {
                [mod removeFromSuperview];
            }
        }
        for (int i = 0; i < dataModel.commentVoList.count; i ++) {
            Model *mo = dataModel.commentVoList[i];
            UILabel *textLabel = [[UILabel alloc]init];
            textLabel.backgroundColor = [UIColor blueColor];
            textLabel.font = [UIFont systemFontOfSize:14];
            textLabel.text = [NSString stringWithFormat:@"%@ :%@",mo.userName,mo.commentText];
            [self.thirdView  addSubview:textLabel];
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.thirdView.mas_left).offset(10);
                make.right.equalTo(self.thirdView.mas_right).offset(-10);
                make.height.equalTo(15);
                make.top.equalTo(i * 15);
            }];
        }
//        self.thirdView.hidden = NO;
    }else{
        NSLog(@"subViews=======%ld",(unsigned long)_thirdView.subviews.count);
//        self.thirdView.hidden = YES;
    }
    [self layoutIfNeeded];
    
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
