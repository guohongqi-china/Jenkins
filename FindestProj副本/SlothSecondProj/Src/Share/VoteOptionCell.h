//
//  VoteOptionCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/1.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoteOptionVo.h"

@class VoteOptionViewController;

@interface VoteOptionCell : UITableViewCell

@property (nonatomic,weak) VoteOptionViewController *parentController;

- (void)initWithData:(VoteOptionVo *)entity row:(NSInteger)nRow;

@end
