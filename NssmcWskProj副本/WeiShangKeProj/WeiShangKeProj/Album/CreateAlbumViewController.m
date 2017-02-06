//
//  CreateAlbumViewController.m
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-3-14.
//
//

#import "CreateAlbumViewController.h"

@interface CreateAlbumViewController ()

@end

@implementation CreateAlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat fHeight = NAV_BAR_HEIGHT + 30;
    
    UIImageView *imgViewTxtBK = [[UIImageView alloc] initWithFrame:CGRectMake(20, fHeight, kScreenWidth-40, 36)];
    imgViewTxtBK.image = [[UIImage imageNamed:@"txt_album_bk"]stretchableImageWithLeftCapWidth:145 topCapHeight:18];
    [self.view addSubview:imgViewTxtBK];
    
    self.txtAlbumName = [[UITextField alloc]initWithFrame:CGRectMake(24, fHeight, kScreenWidth-48, 36)];
    self.txtAlbumName.font = [UIFont boldSystemFontOfSize:16];
    self.txtAlbumName.delegate = self;
    self.txtAlbumName.placeholder = [Common localStr:@"Albums_Check_Name" value:@"请输入相册名称"];
    [self.view addSubview:self.txtAlbumName];
    fHeight += 36;
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight+10, kScreenWidth, 0.5)];
    viewLine.backgroundColor = COLOR(183, 183, 183, 1.0);
    viewLine.tag = 1001;
    [self.view addSubview:viewLine];
    fHeight += 10;
    
    UIButton *btnCreate = [[UIButton alloc] initWithFrame:CGRectMake(20, fHeight+10, kScreenWidth-40, 40)];
    [btnCreate setTitle:[Common localStr:@"Common_Create" value:@"创建"] forState:UIControlStateNormal];
    [btnCreate.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [btnCreate setTitleColor:COLOR(47,62,70,1.0) forState:UIControlStateNormal];
    [btnCreate setBackgroundImage:[UIImage imageNamed:@"album_btn_n.png"] forState:UIControlStateNormal];
    [btnCreate setBackgroundImage:[Common getImageWithColor:COLOR(220,220,220,1.0)] forState:UIControlStateHighlighted];
    [btnCreate addTarget:self action:@selector(createAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCreate];
    
    if (self.editAlbumType == CreateAlbumType)
    {
        [self setTopNavBarTitle:[Common localStr:@"Albums_Create_Title" value:@"创建相册"]];
        [btnCreate setTitle:[Common localStr:@"Common_Create" value:@"创建"] forState:UIControlStateNormal];
    }
    else
    {
        [self setTopNavBarTitle:[Common localStr:@"Albums_AlbumRename" value:@"更改相册名称"]];
        [btnCreate setTitle:[Common localStr:@"Documents_DirectoryRename" value:@"改名"] forState:UIControlStateNormal];
        
        self.txtAlbumName.text = self.m_albumInfoVO.albumFolderName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createAlbum
{
    if (self.editAlbumType == CreateAlbumType)
    {
        NSString *strAlbumName = self.txtAlbumName.text;
        if (strAlbumName == nil || strAlbumName.length == 0)
        {
            [Common tipAlert:[Common localStr:@"Albums_Name_Empty" value:@"相册名不能为空"]];
            return;
        }
        
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider createAlbumFolder:self.txtAlbumName.text andType:3 andTeamID:@"" andRemark:@""];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAlbumListData" object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self isHideActivity:YES];
                });
            }
        });
    }
    else
    {
        self.m_albumInfoVO.albumFolderName = self.txtAlbumName.text;
        NSString *strAlbumName = self.txtAlbumName.text;
        if (strAlbumName == nil || strAlbumName.length == 0)
        {
            [Common tipAlert:[Common localStr:@"Albums_Name_Empty" value:@"相册名不能为空"]];
            return;
        }
        
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider modifyAlbumFolder:self.m_albumInfoVO];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAlbumListData" object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self isHideActivity:YES];
                });
            }
        });
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
