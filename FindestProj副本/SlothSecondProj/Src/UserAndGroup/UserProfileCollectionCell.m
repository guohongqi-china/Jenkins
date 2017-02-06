//
//  UserProfileCollectionCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/12.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserProfileCollectionCell.h"
#import "HMWaterflowLayout.h"
#import "StoreCollectionCell.h"
#import "BlogVo.h"
#import "ShareDetailViewController.h"
#import "UserProfileViewController.h"
#import "UIViewExt.h"
#import "ProfileCollectionReusableView.h"

@interface UserProfileCollectionCell ()<StoreCollectionCellDelegate,HMWaterflowLayoutDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *aryShare;
    CGFloat fCellWidth;
    BOOL isHideClearButton;
    UserVo *userVo;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewStore;
@property (weak, nonatomic) IBOutlet HMWaterflowLayout *waterFlowLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCollectionH;

@end

@implementation UserProfileCollectionCell

- (void)dealloc
{
    [self.collectionViewStore removeObserver:self forKeyPath:@"contentSize" context:NULL];
}

- (void)awakeFromNib {
    // Initialization code
    
    self.waterFlowLayout.colCount = 2;
    self.waterFlowLayout.delegate = self;
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.collectionViewStore.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self.collectionViewStore registerNib:[UINib nibWithNibName:@"StoreCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"StoreCollectionCell"];
    [self.collectionViewStore registerNib:[UINib nibWithNibName:@"ProfileCollectionReusableView" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileCollectionReusableView"];

    //KVO
    [self.collectionViewStore addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
    
    
    fCellWidth = (kScreenWidth-12*2-7)/2;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
{
    // You will get here when the reloadData finished 
    NSInteger nHeight = self.collectionViewStore.contentSize.height+5;
    if (self.parentController.nCellHeight != nHeight)
    {
        self.parentController.nCellHeight = nHeight;
        self.constraintCollectionH.constant = nHeight;
        [self layoutIfNeeded];
        [self.parentController.tableViewList reloadData];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSMutableArray *)aryData userVo:(UserVo*)userInfo
{
    aryShare = aryData;
    userVo = userInfo;
    isHideClearButton = ![userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID];
    [self.collectionViewStore reloadData];
}

#pragma mark - StoreCollectionCellDelegate
- (void)cancelStoreCollection:(BlogVo *)blogVo
{
    [aryShare removeObject:blogVo];
    [self.collectionViewStore reloadData];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return aryShare.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StoreCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StoreCollectionCell" forIndexPath:indexPath];
    cell.entity = aryShare[indexPath.row];
    cell.isHideClearButton = isHideClearButton;
    cell.delegate = self;
    return cell;
}

- (CGFloat)waterflowLayout:(HMWaterflowLayout *)waterflowLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath
{
    BlogVo *blogVo = aryShare[indexPath.row];
    CGFloat fHeight = 0;
    if (blogVo.aryPictureUrl.count > 0)
    {
        fHeight += fCellWidth+12;
    }
    else
    {
        fHeight += 41;
    }
    
    //title
    CGSize sizeLbl = [Common getStringSize:blogVo.strTitle font:[Common fontWithName:@"PingFangSC-Medium" size:14] bound:CGSizeMake(fCellWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if(sizeLbl.height > 31.5)
    {
        sizeLbl.height = 31.5;
    }
    fHeight += sizeLbl.height;
    
    //content
    fHeight += 10;
    sizeLbl = [Common getStringSize:blogVo.strText font:[Common fontWithName:@"PingFangSC-Light" size:13] bound:CGSizeMake(fCellWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    if(sizeLbl.height > 31.5)
    {
        sizeLbl.height = 31.5;
    }
    fHeight += sizeLbl.height;
    fHeight += 9.5;
    
    //bottom
    fHeight += 54;
    
    return fHeight;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
    BlogVo *blog = [aryShare objectAtIndex:[indexPath row]];
    shareDetailViewController.m_originalBlogVo = blog;
    if (blog.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    
    [self.parentController.navigationController pushViewController:shareDetailViewController animated:YES];
}

@end
