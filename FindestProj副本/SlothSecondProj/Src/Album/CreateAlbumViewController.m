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
    
    [self setTopNavBarTitle:@"创建相册"];
    
    CGFloat fHeight = NAV_BAR_HEIGHT + 30;
    
    UIImageView *imgViewTxtBK = [[UIImageView alloc] initWithFrame:CGRectMake(20, fHeight, kScreenWidth-40, 36)];
    imgViewTxtBK.image = [[UIImage imageNamed:@"txt_album_bk"]stretchableImageWithLeftCapWidth:145 topCapHeight:18];
    [self.view addSubview:imgViewTxtBK];
    
    self.txtAlbumName = [[UITextField alloc]initWithFrame:CGRectMake(24, fHeight, kScreenWidth-48, 36)];
    self.txtAlbumName.font = [UIFont boldSystemFontOfSize:16];
    self.txtAlbumName.delegate = self;
    self.txtAlbumName.placeholder = @"请输入相册名称";
    [self.view addSubview:self.txtAlbumName];
    fHeight += 36;
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight+10, kScreenWidth, 0.5)];
    viewLine.backgroundColor = COLOR(183, 183, 183, 1.0);
    viewLine.tag = 1001;
    [self.view addSubview:viewLine];
    fHeight += 10;
    
    UIButton *btnCreate = [[UIButton alloc] initWithFrame:CGRectMake(20, fHeight+10, kScreenWidth-40, 40)];
    [btnCreate setTitle:@"创建" forState:UIControlStateNormal];
    [btnCreate.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [btnCreate setTitleColor:COLOR(47,62,70,1.0) forState:UIControlStateNormal];
    [btnCreate setBackgroundImage:[UIImage imageNamed:@"album_btn_n.png"] forState:UIControlStateNormal];
    [btnCreate setBackgroundImage:[Common getImageWithColor:COLOR(220,220,220,1.0)] forState:UIControlStateHighlighted];
    [btnCreate addTarget:self action:@selector(createAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCreate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createAlbum
{
    NSString *strAlbumName = self.txtAlbumName.text;
    if (strAlbumName == nil || strAlbumName.length == 0)
    {
        [Common tipAlert:@"相册名不能为空"];
        return;
    }
    
    [self isHideActivity:NO];
    [ServerProvider createAlbumFolder:self.txtAlbumName.text andType:3 andTeamID:@"" andRemark:@"" result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAlbumListData" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
