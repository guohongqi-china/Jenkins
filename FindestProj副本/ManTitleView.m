//
//  ManTitleView.m
//  FindestProj
//
//  Created by MacBook on 16/7/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ManTitleView.h"
#import "UIView+Extension.h"
#import "VNetworkFramework.h"
#import "ServerURL.h"
#import "MBProgressHUD+GHQ.h"
@implementation ManTitleView
-(void)awakeFromNib{
    _iconView.layer.masksToBounds = YES;
    _iconView.layer.cornerRadius = 17.5;
    _button.layer.masksToBounds = YES;
    _button.layer.cornerRadius = 3;
    self.height = 80;
}
/**
 * 收藏按钮点击事件
 */
- (IBAction)buttonAction:(UIButton *)sender {
    if (!sender.isSelected) {
   
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getCollectionRUL]];
    [framework startRequestToServer:@"POST" parameter:@{@"refId":_dataModel.ID,@"refType":@"1"} result:^(id responseObject, NSError *error) {
        if (error) {
            [MBProgressHUD showSuccess:@"收藏失败" toView:nil];

        }else{
            if ([responseObject[@"code"] isEqualToString:@"10000"]) {
                [MBProgressHUD showSuccess:@"收藏成功" toView:nil];
                sender.selected = !sender.isSelected;
            }else{
                [MBProgressHUD showSuccess:responseObject[@"code"] toView:nil];

            }
        }
    }];
    }else{
        
        VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[NSString stringWithFormat:@"%@%@",[ServerURL doNotCollectionRUL],_dataModel.ID]];
        [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
            if (error) {
                [MBProgressHUD showSuccess:@"取消失败" toView:nil];
                
            }else{
                if ([responseObject[@"code"] isEqualToString:@"10000"]) {
                    [MBProgressHUD showSuccess:@"取消成功" toView:nil];

                    sender.selected = !sender.isSelected;
                }else{
                    [MBProgressHUD showSuccess:responseObject[@"code"] toView:nil];
                    
                }
            }

        }];
    }
    
}
- (IBAction)iconViewTap:(UITapGestureRecognizer *)sender {
    NSLog(@"fsafda");
}
- (void)setDataModel:(ManListModel *)dataModel{
    _dataModel = dataModel;
    _titleLabel.text = dataModel.titleName;
    _timeLabel.text = [dataModel.createDate substringToIndex:10];
    _commentLabel.text = [NSString stringWithFormat:@"评论：%@",dataModel.commentCount];
    if ([dataModel.hasStore isEqualToString:@"0"]) {
        _collectionButton.selected = NO;
    }else{
        _collectionButton.selected = YES;

    }
}

@end
