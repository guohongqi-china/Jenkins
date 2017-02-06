//
//  ChooseGroupCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-28.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChooseGroupCell.h"

@implementation ChooseGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.imgChk = [UIImage imageNamed:@"select_user_group"];
        self.imgUnChk = [UIImage imageNamed:@"unselect_user_group"];
        self.imgCanNotChk = [UIImage imageNamed:@"select_user_group_unedit"];
        
        self.imgViewBK = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewBK.image = [[UIImage imageNamed:@"group_cell_bk"] stretchableImageWithLeftCapWidth:0 topCapHeight:35];
        [self addSubview:self.imgViewBK];
        
        self.imgViewChkBtn = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.imgViewChkBtn.image = self.imgUnChk;
        [self addSubview:self.imgViewChkBtn];
        
        self.imgViewGroupType = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imgViewGroupType];
        
        self.lblGroupName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblGroupName.backgroundColor = [UIColor clearColor];
        self.lblGroupName.font = [UIFont systemFontOfSize:14];
        self.lblGroupName.textAlignment = NSTextAlignmentLeft;
        self.lblGroupName.textColor = COLOR(255,255,255,1);
        [self addSubview:_lblGroupName];
        
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
        
        self.lblGroupDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblGroupDetail.backgroundColor = [UIColor clearColor];
        self.lblGroupDetail.font = [UIFont systemFontOfSize:13];
        self.lblGroupDetail.textAlignment = NSTextAlignmentCenter;
        self.lblGroupDetail.textColor = COLOR(153,153,153,1);
        [self addSubview:self.lblGroupDetail];
        
        self.btnDetail = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnDetail.frame = CGRectZero;
        [self.btnDetail addTarget:self action:@selector(viewMemberDetail) forControlEvents:UIControlEventTouchUpInside];
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
    CGFloat fHeight = 0.0;
    self.m_groupVo = groupVo;
    
    //0.chk image
    if (groupVo.bCanNotCheck)
    {
        self.imgViewChkBtn.image = self.imgCanNotChk;
    }
    else
    {
        if (groupVo.bChecked)
        {
            self.imgViewChkBtn.image = self.imgChk;
        }
        else
        {
            self.imgViewChkBtn.image = self.imgUnChk;
        }
    }
    
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
    self.lblGroupName.frame = CGRectMake(43,6,268,26);
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
    NSUInteger nCount = 0;
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
    
    //4.bottom info
    self.lblMemberNum.frame = CGRectMake(10,fHeight,100,26);
    self.lblMemberNum.text = [NSString stringWithFormat:@"%@ %@",groupVo.strMemberNum,[Common localStr:@"UserGroup_Person" value:@"人"]];
    
    self.lblCreatorName.frame = CGRectMake(110,fHeight,100,26);
    self.lblCreatorName.text = groupVo.strCreatorName;
    
    self.lblGroupDetail.frame = CGRectMake(210,fHeight,100,26);
    if (groupVo.bIsExpanded)
    {
        self.lblGroupDetail.text = [NSString stringWithFormat:@"%@ ▲",[Common localStr:@"UserGroup_Detail" value:@"详情"]];
    }
    else
    {
        self.lblGroupDetail.text = [NSString stringWithFormat:@"%@ ▼",[Common localStr:@"UserGroup_Detail" value:@"详情"]];
    }
    //detail button
    self.btnDetail.frame = self.lblGroupDetail.frame;
    [self bringSubviewToFront:self.btnDetail];
    
    //5.image view bk
    fHeight += 26+5;
    self.imgViewBK.frame = CGRectMake(0,0,kScreenWidth,fHeight);
    self.viewNameContainer.frame= CGRectMake(0,0,kScreenWidth,fHeight);
    self.imgViewChkBtn.frame = CGRectMake(15,(fHeight-10)/2,10,10);
}

-(void)viewMemberDetail
{
    self.m_groupVo.bIsExpanded = !self.m_groupVo.bIsExpanded;
    UITableView *tableView = (UITableView *)self.superview;
    if (![tableView isKindOfClass:[UITableView class]])
    {
        tableView = (UITableView *)tableView.superview;
    }
    [tableView reloadData];
}

-(void)updateCheckImage:(BOOL)bChecked
{
    if (bChecked)
    {
        self.imgViewChkBtn.image = self.imgChk;
    }
    else
    {
        self.imgViewChkBtn.image = self.imgUnChk;
    }
}

+ (CGFloat)calculateCellHeight:(GroupVo*)groupVo
{
    CGFloat fHeight = 0.0;
    NSUInteger nCount = 0;
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
