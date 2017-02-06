//
//  BusinessCardCell.m
//  TaoZhiHuiProj
//
//  Created by fujunzhi on 16/5/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "BusinessCardCell.h"

@interface BusinessCardCell()
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageVIew;

@end

@implementation BusinessCardCell

- (void)awakeFromNib {
    // Initialization code
}

+(instancetype) businessCardCellWithTableView:(UITableView *)tableView
{
    static NSString *identifer = @"BusinessCardCell";
    BusinessCardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:identifer owner:nil options:nil] lastObject];
        cell.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        cell.accessoryImageVIew.image = [SkinManage imageNamed:@"table_accessory"];
        
        UIView *view = [[UIView alloc] initWithFrame:cell.frame];
        view.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
        cell.selectedBackgroundView = view;
        cell.titleLabel.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    }
    return cell;
}

@end
