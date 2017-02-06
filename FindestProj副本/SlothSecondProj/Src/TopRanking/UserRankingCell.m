//
//  UserRankingCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "UserRankingCell.h"
#import "UIViewExt.h"

@implementation UserRankingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.viewBK = [[UIView alloc]init];
        self.viewBK.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        self.viewBK.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        self.viewBK.layer.borderWidth = 0.5;
        self.viewBK.layer.masksToBounds = YES;
        self.viewBK.layer.cornerRadius = 5;
        [self.contentView addSubview:self.viewBK];
        
        self.lblIndex = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblIndex.backgroundColor = [UIColor clearColor];
        self.lblIndex.font = [UIFont fontWithName:@"HeitiSC-Light" size:20];
        self.lblIndex.textAlignment = NSTextAlignmentCenter;
        [self.viewBK addSubview:self.lblIndex];
        
        self.commonHeaderView = [[CommonHeaderView alloc]init];
        [self.viewBK addSubview:self.commonHeaderView];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        self.lblName.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        [self.viewBK addSubview:self.lblName];
        
        self.lblIntegralTip = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblIntegralTip.textColor = COLOR(239, 111, 88, 1.0);
        self.lblIntegralTip.textAlignment = NSTextAlignmentRight;
        self.lblIntegralTip.font = [UIFont systemFontOfSize:13];
        self.lblIntegralTip.text = @"积分";
        [self.viewBK addSubview:self.lblIntegralTip];
        
        self.lblIntegral = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblIntegral.textColor = COLOR(239, 111, 88, 1.0);
        self.lblIntegral.textAlignment = NSTextAlignmentRight;
        self.lblIntegral.font = [UIFont systemFontOfSize:16];
        [self.viewBK addSubview:self.lblIntegral];
        
        self.viewLine = [[UIView alloc]init];
        self.viewLine.backgroundColor = [SkinManage colorNamed:@"myLine_back_color"];
        [self.viewBK addSubview:self.viewLine];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)initWithData:(UserVo*)userVo
{
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.viewBK.frame = CGRectMake(12, 10, kScreenWidth-24, 60);
    
    //index
    NSInteger nIndex;
    if (self.nPageType == 2)
    {
        nIndex = self.indexPath.row+1;
    }
    else
    {
        nIndex = userVo.nIndex;
    }
    self.lblIndex.text = [NSString stringWithFormat:@"%li",(long)nIndex];
    self.lblIndex.frame = CGRectMake(0, 0, 46, 60);
    if (userVo.nIndex <= 3)
    {
        self.lblIndex.textColor = [SkinManage colorNamed:@"Tab_Item_Color_H"];
    }
    else
    {
        self.lblIndex.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    }
    
    //header img
    [self.commonHeaderView refreshViewWithImage:userVo.strHeadImageURL userID:nil];
    self.commonHeaderView.frame = CGRectMake(46,10,40,40);
    
    //label name
    self.lblName.text = userVo.strUserName;
    self.lblName.frame = CGRectMake(self.commonHeaderView.right+10,20,self.viewBK.width-96-65,20.5);
    
    if (self.nPageType == 1)
    {
        //1:积分排行榜
        self.lblIntegralTip.text = @"积分";
        self.lblIntegral.text = [NSString stringWithFormat:@"%g",userVo.fIntegrationCount];
    }
    else if(self.nPageType == 2)
    {
        //2:风云人物榜
        self.lblIntegralTip.text = @"当日积分";
        self.lblIntegral.text = [NSString stringWithFormat:@"%g",userVo.fIntegralDaily];
    }
    else
    {
        //3:我的排名
        self.lblIntegralTip.text = @"积分";
        self.lblIntegral.text = [NSString stringWithFormat:@"%g",userVo.fIntegrationCount];
        
        self.viewBK.frame = CGRectMake(0, 0, kScreenWidth, 60);
        self.viewBK.layer.borderWidth = 0;
        self.viewBK.layer.masksToBounds = NO;
        if ([userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            self.viewBK.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        }
        else
        {
            self.viewBK.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        }
        
        self.lblIndex.frame = CGRectMake(0, 0, 70, 60);
        self.commonHeaderView.frame = CGRectMake(70,10,40,40);
        self.lblName.frame = CGRectMake(self.commonHeaderView.right+10,20,self.viewBK.width-120-65,20.5);
        self.viewLine.frame = CGRectMake(70,self.viewBK.bottom-1,kScreenWidth-70,1);
    }
    
    self.lblIntegralTip.frame = CGRectMake(self.viewBK.width-60-10, 10, 60, 18);
    
    self.lblIntegral.frame = CGRectMake(self.viewBK.width-100-10, 30, 100, 22);
}

@end
