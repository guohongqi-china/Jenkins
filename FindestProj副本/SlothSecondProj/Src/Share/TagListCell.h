//
//  TagListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagVo.h"

@interface TagListCell : UITableViewCell

@property (nonatomic, strong) TagVo *entity;

- (void)updateCheckImage:(BOOL)bChecked;

@end
