//
//  BusinessCardCell.h
//  TaoZhiHuiProj
//
//  Created by fujunzhi on 16/5/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessCardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
+(instancetype) businessCardCellWithTableView:(UITableView *)tableView;
@end
