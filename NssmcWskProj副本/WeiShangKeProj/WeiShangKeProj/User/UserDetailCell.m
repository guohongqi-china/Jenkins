//
//  UserDetailCell.m
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/9.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "UserDetailCell.h"
#import "UIImageView+WebCache.h"
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "UserDetailViewController.h"
#import "UserVo.h"

@interface UserDetailCell ()
{
    UIView *viewCertContainer;
}

@property (weak, nonatomic) IBOutlet UILabel *lblUserInfoKey;
@property (weak, nonatomic) IBOutlet UILabel *lblUserInfoValue;

@end

@implementation UserDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Fix the bug in iOS7 - initial constraints warning
    self.contentView.bounds = [UIScreen mainScreen].bounds;
}

- (void)setEntity:(UserKeyValueVo *)userKeyValueVo
{
    _entity = userKeyValueVo;
    
    self.lblUserInfoKey.text = _entity.strTitle;
    if ([_entity.strKey isEqualToString:@"sex"])
    {
        
        self.lblUserInfoValue.text = _entity.value ;
        
        [viewCertContainer removeFromSuperview];
    }
    else if ([_entity.strKey isEqualToString:@"aryCertificate"])
    {
        if (viewCertContainer != nil)
        {
            [viewCertContainer removeFromSuperview];
        }
        viewCertContainer = [[UIView alloc]init];
        viewCertContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:viewCertContainer];
        
        NSArray *aryHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_lblUserInfoKey]-18-[viewCertContainer]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblUserInfoKey,viewCertContainer)];
        [self.contentView addConstraints:aryHConstraint];
        
        NSArray *aryVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[viewCertContainer(50)]-12-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewCertContainer)];
        [self.contentView addConstraints:aryVConstraint];
        
        NSMutableArray *aryImage = _entity.value;
        if (aryImage.count>0)
        {
            //内部采用Constraints
            for (int i=0;i<aryImage.count;i++)
            {
                NSString *strImageURL = ((UserCertPictureVo*)aryImage[i]).strImageURL;
                UIImageView *imgViewCert = [[UIImageView alloc]init];
                imgViewCert.clipsToBounds = YES;
                imgViewCert.contentMode = UIViewContentModeScaleAspectFill;
                imgViewCert.translatesAutoresizingMaskIntoConstraints = NO;
                imgViewCert.userInteractionEnabled = YES;
                imgViewCert.tag = 1000+i;
                [imgViewCert sd_setImageWithURL:[NSURL URLWithString:strImageURL]];
                [viewCertContainer addSubview:imgViewCert];
                
                if (i == 0)
                {
                    NSArray *aryHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imgViewCert(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgViewCert)];
                    [viewCertContainer addConstraints:aryHConstraint];
                }
                else
                {
                    UIImageView *imgViewLast = [viewCertContainer viewWithTag:imgViewCert.tag-1];
                    
                    NSArray *aryHConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imgViewLast]-5-[imgViewCert(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgViewLast,imgViewCert)];
                    [viewCertContainer addConstraints:aryHConstraint];
                }
                
                NSArray *aryVConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[imgViewCert(40)]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgViewCert)];
                [viewCertContainer addConstraints:aryVConstraint];
                
                //添加详情功能
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCertImage:)];
                [imgViewCert addGestureRecognizer:tapGesture];
            }
            
//            //内部采用Frame
//            for (int i=0;i<aryImage.count;i++)
//            {
//                NSString *strImageURL = aryImage[i];
//                UIImageView *imgViewCert = [[UIImageView alloc]initWithFrame:CGRectMake(i*(40+5), 5, 40, 40)];
//                [imgViewCert sd_setImageWithURL:[NSURL URLWithString:strImageURL]];
//                [viewCertContainer addSubview:imgViewCert];
//            }
        }
        self.lblUserInfoValue.text = nil;
    }
    else
    {
        self.lblUserInfoValue.text = _entity.value;
        [viewCertContainer removeFromSuperview];
    }
}

- (void)tapCertImage:(UITapGestureRecognizer *)gesture
{
    //预览图像
    NSInteger nIndex = gesture.view.tag-1000;
    NSMutableArray *aryImage = _entity.value;
    NSMutableArray *aryPreviewPic = [NSMutableArray array];
    for (UserCertPictureVo *picVo in aryImage)
    {
        //取大图
        NSURL *urlMax,*urlMin;
        if (picVo.bOld)
        {
            urlMax = [NSURL URLWithString:picVo.strImageURL];
            urlMin = urlMax;
        }
        else
        {
            urlMax = [NSURL fileURLWithPath:picVo.strImagePath];
            urlMin = urlMax;
        }
        
        if (urlMax == nil || urlMin == nil)
        {
            continue;
        }
        
        NSArray *ary = @[urlMax,urlMin];
        [aryPreviewPic addObject:ary];
    }
    
    SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
    dataSource.images_ = aryPreviewPic;
    KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                              initWithDataSource:dataSource
                                                              andStartWithPhotoAtIndex:nIndex];
    photoScrollViewController.bShowImageNumBarBtn = YES;
    [self.parentController.navigationController pushViewController:photoScrollViewController animated:YES];
    
//    if (nIndex<aryImage.count)
//    {
//        NSString *strImageURL = aryImage[nIndex];
//        
//        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
//        dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:strImageURL]]];
//        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
//                                                                  initWithDataSource:dataSource
//                                                                  andStartWithPhotoAtIndex:0];
//        photoScrollViewController.bShowImageNumBarBtn = YES;
//        [self.parentController.navigationController pushViewController:photoScrollViewController animated:YES];
//        
//    }
}

@end
