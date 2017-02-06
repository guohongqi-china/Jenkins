//
//  GroupListCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-26.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "GroupListCell.h"
#import "GroupDetailViewController.h"
#import "GroupListViewController.h"

@implementation GroupListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.imgViewBK = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewBK.image = [[UIImage imageNamed:@"group_cell_bk"] stretchableImageWithLeftCapWidth:0 topCapHeight:35];
        [self addSubview:self.imgViewBK];
        
        self.imgViewGroupType = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imgViewGroupType];
        
        self.lblGroupName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblGroupName.backgroundColor = [UIColor clearColor];
        self.lblGroupName.font = [UIFont systemFontOfSize:14];
        self.lblGroupName.textAlignment = NSTextAlignmentLeft;
        self.lblGroupName.textColor = COLOR(255,255,255,1);
        [self addSubview:_lblGroupName];
        
        self.lblAllowJoin = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAllowJoin.backgroundColor = [UIColor clearColor];
        self.lblAllowJoin.font = [UIFont systemFontOfSize:13];
        self.lblAllowJoin.textAlignment = NSTextAlignmentCenter;
        self.lblAllowJoin.textColor = COLOR(153,153,153,1);
        [self addSubview:_lblAllowJoin];
        
        self.lblMemberNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblMemberNum.backgroundColor = [UIColor clearColor];
        self.lblMemberNum.font = [UIFont systemFontOfSize:13];
        self.lblMemberNum.textAlignment = NSTextAlignmentCenter;
        self.lblMemberNum.textColor = COLOR(153,153,153,1);
        [self addSubview:_lblMemberNum];
        
        self.lblCreatorName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblCreatorName.backgroundColor = [UIColor clearColor];
        self.lblCreatorName.font = [UIFont systemFontOfSize:13];
        self.lblCreatorName.textAlignment = NSTextAlignmentCenter;
        self.lblCreatorName.textColor = COLOR(153,153,153,1);
        [self addSubview:_lblCreatorName];
        
        self.btnDetail = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnDetail.frame = CGRectMake(1, 1, 1, 1);
//        [self.btnDetail setBackgroundImage:[Common getImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
//        [self.btnDetail setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
        [self.btnDetail addTarget:self action:@selector(viewGroupDetail) forControlEvents:UIControlEventTouchUpInside];
        [self.btnDetail.layer setBorderWidth:1.0];
        [self.btnDetail.layer setCornerRadius:3];
        self.btnDetail.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.btnDetail.layer setMasksToBounds:YES];
        [self addSubview:self.btnDetail];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithGroupVo:(GroupVo*)groupVo
{
    self.m_groupVo = groupVo;
    
    CGFloat fHeight = 0.0;
    //1.group type img
    self.imgViewGroupType.frame = CGRectMake(19,15,7,7);
    if (groupVo.nGroupType == 1)
    {
        self.imgViewGroupType.image = [UIImage imageNamed:@"group_type_create"];
    }
    else if (groupVo.nGroupType == 2)
    {
        self.imgViewGroupType.image = [UIImage imageNamed:@"group_type_join"];
    }
    else if (groupVo.nGroupType == 3)
    {
        self.imgViewGroupType.image = [UIImage imageNamed:@"group_type_other"];
    }
    
    //2.label group name
    self.lblGroupName.frame = CGRectMake(43,6,kScreenWidth-52,26);
    self.lblGroupName.text = groupVo.strGroupName;
    
    //3.view name container
    int i = 0;
    if (self.viewNameContainer != nil)
    {
        [self.viewNameContainer removeFromSuperview];
    }
    self.viewNameContainer = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewNameContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewNameContainer];
    
    for (; i<groupVo.aryMemberVo.count; i++)
    {
        UserVo *userVo = [groupVo.aryMemberVo objectAtIndex:i];
        UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(37+(i%4)*65, 45+(i/4)*16.5, 53, 16.5)];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont systemFontOfSize:13];
        lblName.textAlignment = NSTextAlignmentLeft;
        lblName.textColor = COLOR(51,51,51,1);
        lblName.text = userVo.strUserName;
        lblName.lineBreakMode = NSLineBreakByClipping;
        [self.viewNameContainer addSubview:lblName];
        if (!groupVo.bIsExpanded)
        {
            //when row isn't expanded,then show eight names
            if (i == 7)
            {
                lblName.text = @"...";
                break;
            }
        }
    }
    
    //calculate height
    NSInteger nCount = 0;//不能定义为NSUInteger,因为(nCount-1)无穷大
    if (groupVo.bIsExpanded)
    {
        //expanded
        nCount = groupVo.aryMemberVo.count;
    }
    else
    {
        if (groupVo.aryMemberVo.count>8)
        {
            nCount = 8;
        }
        else
        {
            nCount = groupVo.aryMemberVo.count;
        }
    }
    fHeight += 45+((nCount-1)/4+1)*16.5+13;
    
    //detail button
    self.btnDetail.frame = CGRectMake(190, 32, 120, fHeight-32);
    [self bringSubviewToFront:self.btnDetail];
    
    //4.bottom info
    CGFloat fBottomW = (kScreenWidth-20)/3;
    self.lblAllowJoin.frame = CGRectMake(10,fHeight,fBottomW,26);
    self.lblAllowJoin.text = (groupVo.nAllowJoin == 1)?[Common localStr:@"UserGroup_AllowJoin" value:@"允许加入"]:[Common localStr:@"UserGroup_NotAllowJoin" value:@"不允许加入"];
    
    self.lblMemberNum.frame = CGRectMake(10+fBottomW,fHeight,fBottomW,26);
    self.lblMemberNum.text = [NSString stringWithFormat:@"%@ %@",groupVo.strMemberNum,[Common localStr:@"UserGroup_Person" value:@"人"]];
    
    self.lblCreatorName.frame = CGRectMake(10+fBottomW*2,fHeight,fBottomW,26);
    self.lblCreatorName.text = groupVo.strCreatorName;
    
    //5.image view bk
    fHeight += 26+5;
    self.imgViewBK.frame = CGRectMake(0,0,kScreenWidth,fHeight);
    self.viewNameContainer.frame= CGRectMake(0,0,kScreenWidth,fHeight);
}

-(void)viewGroupDetail
{
    GroupDetailViewController *groupDetailViewController = [[GroupDetailViewController alloc]init];
    groupDetailViewController.m_groupVo = self.m_groupVo;
    [self.parentView.navigationController pushViewController:groupDetailViewController animated:YES];
}

+ (CGFloat)calculateCellHeight:(GroupVo*)groupVo
{
    CGFloat fHeight = 0.0;
    NSInteger nCount = 0;//不能定义为NSUInteger,因为(nCount-1)无穷大
    if (groupVo.bIsExpanded)
    {
        //expanded
        nCount = groupVo.aryMemberVo.count;
    }
    else
    {
        if (groupVo.aryMemberVo.count>8)
        {
            nCount = 8;
        }
        else
        {
            nCount = groupVo.aryMemberVo.count;
        }
    }
    
    fHeight += 45+((nCount-1)/4+1)*16.5+13;
    fHeight += 26;
    fHeight += 5;
    return fHeight;
}

@end
