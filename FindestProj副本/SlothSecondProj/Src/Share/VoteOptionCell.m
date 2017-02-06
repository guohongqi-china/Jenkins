//
//  VoteOptionCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/1.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "VoteOptionCell.h"
#import "VoteOptionViewController.h"

@interface VoteOptionCell ()
{
    VoteOptionVo *optionVo;
}

@property (weak, nonatomic) IBOutlet UIView *viewItemContainer;
@property (weak, nonatomic) IBOutlet UIView *viewItemContainerNew;
@property (weak, nonatomic) IBOutlet UILabel *newoptionLabel;
@property (weak, nonatomic) IBOutlet UIView *sepLine;

@property (weak, nonatomic) IBOutlet UIView *viewNewOption;
@property (weak, nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldContent;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelLeading;

@end

@implementation VoteOptionCell

- (void)awakeFromNib
{
    //    // Initialization code
    [self.btnAddImage setImage:[SkinManage imageNamed:@"add_vote_image"] forState:UIControlStateNormal];
    [self.btnRemove setImage:[SkinManage imageNamed:@"history_delete"] forState:UIControlStateNormal];
    self.txtFieldContent.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"请输入10字以内的描述" attributes:@{NSForegroundColorAttributeName:[SkinManage colorNamed:@"Wire_Frame_Color"]}];
    self.txtFieldContent.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.btnAddImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.btnAddImage.clipsToBounds = YES;
    [self.btnAddImage setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
    [self.btnAddImage setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
    
    
    
    _sepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewItemContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewItemContainerNew.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewNewOption.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.newoptionLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)initWithData:(VoteOptionVo *)entity row:(NSInteger)nRow
{
    self.txtFieldContent.delegate = self.parentController;
    
    optionVo = entity;
    
    self.btnAddImage.tag = nRow+1000;
    self.btnRemove.tag = nRow+3000;
    
    if (entity.nOptionId == 0)
    {
        _viewItemContainer.hidden = YES;
        _viewNewOption.hidden = NO;
    }
    else
    {
        _viewItemContainer.hidden = NO;
        _viewNewOption.hidden = YES;
        
        if (self.parentController.voteVo.nContentType == 1)
        {
            _constraintLabelLeading.constant = 68;
            _btnAddImage.hidden = NO;
            
            if (entity.strImage != nil && entity.strImage.length > 0)
            {
                [_btnAddImage setImage:[UIImage imageWithContentsOfFile:entity.strImage] forState:UIControlStateNormal];
                
            }
            else
            {
                [_btnAddImage setImage:[SkinManage imageNamed:@"add_vote_image"] forState:UIControlStateNormal];
            }
        }
        else
        {
            _constraintLabelLeading.constant = 12;
            _btnAddImage.hidden = YES;
        }
        [self.contentView layoutIfNeeded];
        
        _txtFieldContent.text = entity.strOptionName;
    }
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    optionVo.strOptionName = textField.text;
}

- (IBAction)removeVoteItem:(UIButton *)sender
{
    [self.parentController removeVoteOption:sender];
}

- (IBAction)addImageAction:(UIButton *)sender
{
    [self.parentController addIconButton:sender];
}

@end
