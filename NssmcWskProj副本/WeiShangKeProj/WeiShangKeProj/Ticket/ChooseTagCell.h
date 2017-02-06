//
//  ChooseTagCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/24/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagVo.h"

@interface ChooseTagCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imgViewChkBtn;
@property(nonatomic,strong)UILabel *lblTagName;

@property(nonatomic,strong)UIImage *imgChk;
@property(nonatomic,strong)UIImage *imgUnChk;

-(void)initWithTagVo:(TagVo*)tagVo;
-(void)updateCheckImage:(BOOL)bChecked;
+(CGFloat)calculateCellHeight:(TagVo*)tagVo;

@end
