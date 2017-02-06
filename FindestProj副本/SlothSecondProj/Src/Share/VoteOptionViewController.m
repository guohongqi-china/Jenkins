//
//  VoteOptionViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/1.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "VoteOptionViewController.h"
#import "VoteOptionCell.h"
#import "ResizeImage.h"
#import "Utils.h"
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "VoteSettingVo.h"
#import "KeyValueVo.h"
#import "VoteSettingCell.h"
#import "CustomPicker.h"

@interface VoteOptionViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,CustomPickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSIndexPath *selectedIndexPath;
    
    UIBarButtonItem *rightItem;
    
    VoteSettingVo *voteSettingMultiple; //支持多选
    
    VoteSettingVo *voteSettingMin;      //最少需投票项
    VoteSettingVo *voteSettingMax;      //最多可投票项
    
    VoteSettingVo *voteSettingDeadline; //投票有效期
    
    //最少需投票项
    CustomPicker *pickerMinNum;
    
    //最多可投票项
    CustomPicker *pickerMaxNum;
}

@property (weak, nonatomic) IBOutlet UIButton *btnPicVote;
@property (weak, nonatomic) IBOutlet UIButton *btnTextVote;

@property (weak, nonatomic) IBOutlet UITableView *tableViewVote;
@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIView *sepLine1;


@end

@implementation VoteOptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"投票选项";
    
    rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeVoteOption)];
    rightItem.tintColor = [UIColor whiteColor];
    //rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self registerForKeyboardNotifications];
    
    [self.tableViewVote registerNib:[UINib nibWithNibName:@"VoteOptionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"VoteOptionCell"];
    [self.tableViewVote registerNib:[UINib nibWithNibName:@"VoteSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"VoteSettingCell"];
    [self.tableViewVote reloadData];
    
    self.tableViewVote.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewVote.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //最少几项
    pickerMinNum = [[CustomPicker alloc] initWithFrame:CGRectZero andDelegate:self];
    [self.view addSubview:pickerMinNum];
    
    [pickerMinNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.and.bottom.equalTo(@0);
        make.height.equalTo(@0);
    }];
    
    //最多几项
    pickerMaxNum = [[CustomPicker alloc] initWithFrame:CGRectZero andDelegate:self];
    [self.view addSubview:pickerMaxNum];
    
    [pickerMaxNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.and.bottom.equalTo(@0);
        make.height.equalTo(@0);
    }];
    
    self.topContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.sepLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    [self.btnPicVote setTitleColor:[SkinManage colorNamed:@"Wire_Frame_Color"] forState:UIControlStateNormal];
    [self.btnTextVote setTitleColor:[SkinManage colorNamed:@"Wire_Frame_Color"] forState:UIControlStateNormal];
    
    [self.btnPicVote setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateSelected];
    [self.btnTextVote setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateSelected];
}

- (void)initData
{
    _voteVo = [[VoteVo alloc]init];
    _voteVo.nContentType = 1;
    _voteVo.nVoteType = 0;
    _voteVo.nVoteDeadline = 7;
    _voteVo.nMinOption = 2;
    _voteVo.nMaxOption = 0;
    _voteVo.aryVoteOption = [NSMutableArray array];
    
    VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = 1;
    [_voteVo.aryVoteOption addObject:voteOptionVo];
    
    voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = 1;
    [_voteVo.aryVoteOption addObject:voteOptionVo];
    
    //新建投票项
    voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = 0;
    [_voteVo.aryVoteOption addObject:voteOptionVo];
    
    //投票设置数据
    voteSettingMultiple = [[VoteSettingVo alloc]init];
    voteSettingMultiple.nID = 0;
    voteSettingMultiple.strTitle = @"支持多选";
    voteSettingMultiple.strValue = @"0";
    
    voteSettingMin = [[VoteSettingVo alloc]init];
    voteSettingMin.nID = 1;
    voteSettingMin.strTitle = @"最少需投票项";
    voteSettingMin.strValue = @"1";
    voteSettingMin.nNumValue = 1;
    voteSettingMin.nRow = 0;
    
    voteSettingMax = [[VoteSettingVo alloc]init];
    voteSettingMax.nID = 2;
    voteSettingMax.strTitle = @"最多可投票项";
    voteSettingMax.strValue = @"不限";
    voteSettingMax.nNumValue = 0;
    voteSettingMax.nRow = 0;
    
    voteSettingDeadline = [[VoteSettingVo alloc]init];
    voteSettingDeadline.nID = 3;
    voteSettingDeadline.strTitle = @"投票有效期";
    voteSettingDeadline.strValue = @"一周";
}

//生成最少和最多选项数据
- (void)generateMinMaxData
{
    
}

- (void)refreshWithVoteVo:(VoteVo *)voteVoData
{
    if (voteVoData == nil)
    {
        _voteVo.nContentType = 1;
        _voteVo.nVoteType = 0;
        _voteVo.nVoteDeadline = 7;
        _voteVo.nMinOption = 2;
        _voteVo.nMaxOption = 0;
        
        [_voteVo.aryVoteOption removeAllObjects];
        VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
        voteOptionVo.nOptionId = 1;
        [_voteVo.aryVoteOption addObject:voteOptionVo];
        
        voteOptionVo = [[VoteOptionVo alloc]init];
        voteOptionVo.nOptionId = 1;
        [_voteVo.aryVoteOption addObject:voteOptionVo];
    }
    else
    {
        _voteVo.nContentType = voteVoData.nContentType;
        _voteVo.nVoteType = voteVoData.nVoteType;
        _voteVo.nVoteDeadline = voteVoData.nVoteDeadline;
        _voteVo.nMinOption = voteVoData.nMinOption;
        _voteVo.nMaxOption = voteVoData.nMaxOption;
        
        [_voteVo.aryVoteOption removeAllObjects];
        [_voteVo.aryVoteOption addObjectsFromArray:voteVoData.aryVoteOption];
    }
    
    //新建投票项
    VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = 0;
    [_voteVo.aryVoteOption addObject:voteOptionVo];
    
    //图片投票、文字投票
    if (_voteVo.nContentType == 1)
    {
        self.btnPicVote.selected = YES;
        self.btnTextVote.selected = NO;
    }
    else
    {
        self.btnPicVote.selected = NO;
        self.btnTextVote.selected = YES;
    }
    
    //单选、多选
    voteSettingMultiple.strValue = [NSString stringWithFormat:@"%li",(unsigned long)_voteVo.nVoteType];
    
    //最少项
    voteSettingMin.nNumValue = _voteVo.nMinOption;
    voteSettingMin.strValue = [NSString stringWithFormat:@"%li",(unsigned long)voteSettingMin.nNumValue];
    
    //最多项
    voteSettingMax.nNumValue = _voteVo.nMaxOption;
    if (voteSettingMax.nNumValue == 0)
    {
        voteSettingMax.strValue = @"不限";
    }
    else
    {
        voteSettingMax.strValue = [NSString stringWithFormat:@"%li",(unsigned long)voteSettingMax.nNumValue];
    }
    
    //投票期限
    voteSettingDeadline.nNumValue = _voteVo.nVoteDeadline;
    if (voteSettingDeadline.nNumValue == 1)
    {
        voteSettingDeadline.strValue = @"一日";
    }
    else if (voteSettingDeadline.nNumValue == 7)
    {
        voteSettingDeadline.strValue = @"一周";
    }
    else
    {
        voteSettingDeadline.strValue = @"一月";
    }
    
    [self.tableViewVote reloadData];
}

//删除Cell
- (void)removeVoteOption:(UIButton*)btnRemove
{
    NSInteger nTag = btnRemove.tag-3000;
    if (nTag < _voteVo.aryVoteOption.count)
    {
        [_voteVo.aryVoteOption removeObjectAtIndex:btnRemove.tag-3000];
        
        //更新最少和最多选项
        if ((_voteVo.aryVoteOption.count-1) < voteSettingMin.nNumValue)
        {
            voteSettingMin.strValue = @"1";
            voteSettingMin.nNumValue = 1;
        }
        
        if ((_voteVo.aryVoteOption.count-1) < voteSettingMax.nNumValue)
        {
            voteSettingMax.strValue = @"不限";
            voteSettingMax.nNumValue = 0;
        }
        
        [self.tableViewVote reloadData];
    }
}

//add option cell
-(void)addOption
{
    //add option vo
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = 1;
    [_voteVo.aryVoteOption insertObject:voteOptionVo atIndex:_voteVo.aryVoteOption.count-1];
    
    [self.tableViewVote reloadData];
}

//键盘侦听事件
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableViewVote.contentInset.top, 0.0, kbSize.height, 0.0);
    self.tableViewVote.contentInset = contentInsets;
    self.tableViewVote.scrollIndicatorInsets = contentInsets;
    [self.tableViewVote scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableViewVote.contentInset.top, 0.0, 0.0, 0.0);
    self.tableViewVote.contentInset = contentInsets;
    self.tableViewVote.scrollIndicatorInsets = contentInsets;
    [self.tableViewVote scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [UIView commitAnimations];
}

- (void)addIconButton:(UIButton *)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    VoteOptionVo *voteOption = [_voteVo.aryVoteOption objectAtIndex:sender.tag-1000];
    
    if (voteOption.strImage != nil && voteOption.strImage.length >0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"预览", @"移除", nil];
        actionSheet.tag = sender.tag+888;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"用户相册", nil];
        actionSheet.tag = 5000;
        [actionSheet showInView:self.view];
    }
    self.nButtonTag = sender.tag;
}

- (void)completeVoteOption
{
    VoteVo *voteVo = [[VoteVo alloc]init];
    voteVo.nContentType = _voteVo.nContentType;
    voteVo.nVoteType = _voteVo.nVoteType;
    voteVo.nVoteDeadline = _voteVo.nVoteDeadline;
    voteVo.nMinOption = voteSettingMin.nNumValue;
    voteVo.nMaxOption = voteSettingMax.nNumValue;
    
    voteVo.aryVoteOption = [NSMutableArray array];
    [voteVo.aryVoteOption addObjectsFromArray:_voteVo.aryVoteOption];
    [voteVo.aryVoteOption removeLastObject];
    
    //条件判断
    if (voteVo.aryVoteOption.count == 0)
    {
        [Common bubbleTip:@"请添加投票项" andView:self.view];
        return;
    }
    
    for (VoteOptionVo *optionVo in voteVo.aryVoteOption)
    {
        if (optionVo.strOptionName.length == 0)
        {
            [Common bubbleTip:@"投票项内容不能为空" andView:self.view];
            return;
        }
        else if (voteVo.nContentType == 1 && optionVo.strImage.length == 0)
        {
            [Common bubbleTip:@"图片投票时图片不能为空" andView:self.view];
            return;
        }
    }
    
    [self.delegate completeVoteAction:voteVo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)swichValueChanged:(BOOL)bOn
{
    //支持多选
    if (bOn)
    {
        self.voteVo.nVoteType = 1;
        voteSettingMultiple.strValue = @"1";
    }
    else
    {
        self.voteVo.nVoteType = 0;
        voteSettingMultiple.strValue = @"0";
    }
    [self.tableViewVote reloadData];
}

- (IBAction)changeVoteType:(UIButton *)sender
{
    if(sender.tag == 100)
    {
        //图片投票
        _voteVo.nContentType = 1;
        self.btnPicVote.selected = YES;
        self.btnTextVote.selected = NO;
    }
    else
    {
        //文字投票
        _voteVo.nContentType = 2;
        self.btnPicVote.selected = NO;
        self.btnTextVote.selected = YES;
    }
    
    [self.tableViewVote reloadData];
}

//显示隐藏弹出控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    CGFloat fFirstH=0,fSecondH=260;
    if (hidden)
    {
        fFirstH = 260;
        fSecondH = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [pickerViewCtrl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(fSecondH);
        }];
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)showPickerView:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:NO];
    [pickerViewCtrl.pickerView reloadAllComponents];
    
    //初始选中pickerView
    if(pickerViewCtrl == pickerMinNum)
    {
        if(voteSettingMin.nNumValue <= self.voteVo.aryVoteOption.count)
        {
            [pickerViewCtrl.pickerView selectRow:voteSettingMin.nRow inComponent:0 animated:YES];
        }
    }
    else
    {
        if(voteSettingMax.nNumValue <= self.voteVo.aryVoteOption.count)
        {
            [pickerViewCtrl.pickerView selectRow:voteSettingMax.nRow inComponent:0 animated:YES];
        }
    }
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == self.nButtonTag + 888)
    {
        //投票项的图片
        VoteOptionVo *voteOption = [self.voteVo.aryVoteOption objectAtIndex:self.nButtonTag-1000];
        if (buttonIndex == 0)
        {
            //预览
            SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
            dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL fileURLWithPath:voteOption.strImage]]];
            
            KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                      initWithDataSource:dataSource
                                                                      andStartWithPhotoAtIndex:0];
            photoScrollViewController.bShowToolBarBtn = NO;
            [self presentViewController:photoScrollViewController animated:YES completion: nil];
        }
        else if (buttonIndex == 1)
        {
            //移除
            if (voteOption.strImage)
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL fileExists = [fileManager fileExistsAtPath:voteOption.strImage];
                if (fileExists)
                {
                    [fileManager removeItemAtPath:voteOption.strImage error:nil];
                }
                
                VoteOptionVo *voteOption = [self.voteVo.aryVoteOption objectAtIndex:self.nButtonTag-1000];
                voteOption.strImage = nil;
                [self.tableViewVote reloadData];
            }
        }
    }
    else if(actionSheet.tag == 5000)
    {
        //投票选择图片
        if (buttonIndex == 0)
        {
            //拍照
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
            {
                return;
            }
            self.photoController = [[UIImagePickerController alloc] init];
            self.photoController.delegate = self;
            self.photoController.mediaTypes = @[(NSString*)kUTTypeImage];
            self.photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self.photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:self.photoController animated:YES completion: nil];
        }
        else if (buttonIndex == 1)
        {
            //用户相册
            self.photoAlbumController = [[UIImagePickerController alloc]init];
            self.photoAlbumController.delegate = self;
            self.photoAlbumController.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
            self.photoAlbumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.photoAlbumController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self.photoAlbumController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:self.photoAlbumController animated:YES completion: nil];
        }
    }
    else if(actionSheet.tag == 6000)
    {
        if (buttonIndex == 0)
        {
            self.voteVo.nVoteDeadline = 1;
            voteSettingDeadline.strValue = @"一天";
        }
        else if (buttonIndex == 1)
        {
            self.voteVo.nVoteDeadline = 7;
            voteSettingDeadline.strValue = @"一周";
        }
        else if (buttonIndex == 2)
        {
            self.voteVo.nVoteDeadline = 30;
            voteSettingDeadline.strValue = @"一月";
        }
        
        [self.tableViewVote reloadData];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //2:投票附件(相册和拍照)
        UIImage *imageToSave = originalImage;
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        //当图片尺寸过大，进行缩放处理
        CGSize sizeImage = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.8f);
        NSString *imagePath = [[Utils tmpDirectory] stringByAppendingPathComponent:[Common createImageNameByDateTime]];
        [imageData writeToFile:imagePath atomically:YES];
        
        VoteOptionVo *voteOption = [_voteVo.aryVoteOption objectAtIndex:self.nButtonTag-1000];
        voteOption.strImage = imagePath;
        [self.tableViewVote reloadData];
    }
    [picker  dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker  dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self indexPathFromView:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    selectedIndexPath = nil;
}

- (void)indexPathFromView:(UIView *)view
{
    UITableViewCell *cell = nil;
    if (iOSPlatform >= 8 )
    {
        cell = (UITableViewCell*)view.superview.superview;
    }
    else if (iOSPlatform == 7 )
    {
        cell = (UITableViewCell*)view.superview.superview.superview;
    }
    else
    {
        cell = (UITableViewCell*)view.superview.superview;
    }
    
    selectedIndexPath = [self.tableViewVote indexPathForCell:cell];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRowNum = 0;
    if (section == 0)
    {
        nRowNum = _voteVo.aryVoteOption.count;
    }
    else if (section == 1)
    {
        if(self.voteVo.nVoteType == 0)
        {
            nRowNum = 1;    //单选
        }
        else
        {
            nRowNum = 3;    //多选
        }
    }
    else
    {
        nRowNum = 1;
    }
    return nRowNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 0.0;
    if (indexPath.section == 0)
    {
        fHeight = 62;
    }
    else
    {
        fHeight = 46;
    }
    return fHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        //选项内容
        VoteOptionCell *cell = (VoteOptionCell *)[tableView dequeueReusableCellWithIdentifier:@"VoteOptionCell"];
        cell.parentController = self;
        [cell initWithData:_voteVo.aryVoteOption[indexPath.row] row:indexPath.row];
        return cell;
    }
    else if (indexPath.section == 1)
    {
        VoteSettingCell *cell = (VoteSettingCell *)[tableView dequeueReusableCellWithIdentifier:@"VoteSettingCell"];
        cell.parentController = self;
        if(indexPath.row == 0)
        {
            cell.entity = voteSettingMultiple;
        }
        else if(indexPath.row == 1)
        {
            cell.entity = voteSettingMin;
        }
        else
        {
            cell.entity = voteSettingMax;
        }
        return cell;
    }
    else
    {
        //投票有效期
        VoteSettingCell *cell = (VoteSettingCell *)[tableView dequeueReusableCellWithIdentifier:@"VoteSettingCell"];
        cell.parentController = self;
        cell.entity = voteSettingDeadline;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        VoteOptionVo *optionVo = _voteVo.aryVoteOption[indexPath.row];
        if (optionVo.nOptionId == 0)
        {
            //添加选项
            [self addOption];
        }
    }
    else if (indexPath.section == 1)
    {
        if(indexPath.row == 1)
        {
            //最少投票
            [self showPickerView:pickerMinNum];
            
        }
        else if(indexPath.row == 2)
        {
            //最多投票
            [self showPickerView:pickerMaxNum];
        }
    }
    else
    {
        //投票有效期
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"投票有效期"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"一天", @"一周", @"一月",nil];
        actionSheet.tag = 6000;
        [actionSheet showInView:self.view];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001;//section头部高度
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 2)
    {
        return 258;
    }
    else
    {
        return 10;//section尾部高度
    }
}

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    NSInteger row = [pickerViewCtrl getSelectedRowNum];
    if (pickerViewCtrl == pickerMinNum)
    {
        voteSettingMin.strValue = [NSString stringWithFormat:@"%li",(unsigned long)(row+1)];
        voteSettingMin.nNumValue = row+1;
        voteSettingMin.nRow = row;
        
        if (voteSettingMin.nNumValue > voteSettingMax.nNumValue && voteSettingMax.nNumValue != 0)
        {
            voteSettingMax.strValue = @"不限";
            voteSettingMax.nNumValue = 0;
        }
    }
    else
    {
        voteSettingMax.nRow = row;
        if (row == 0)
        {
            voteSettingMax.strValue = @"不限";
            voteSettingMax.nNumValue = 0;
        }
        else
        {
            voteSettingMax.strValue = [NSString stringWithFormat:@"%li",(unsigned long)(voteSettingMin.nNumValue+row-1)];
            voteSettingMax.nNumValue = voteSettingMin.nNumValue+row-1;
        }
    }
    [self setPickerHidden:pickerViewCtrl andHide:YES];
    
    [self.tableViewVote reloadData];
}

- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
}

#pragma mark Picker Data Source Methods
//1 选取器组件的个数，也就是滚轮的个数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//2 每个组件的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger nRowNum = 0;
    NSInteger nOptionNum = self.voteVo.aryVoteOption.count - 1;
    if (pickerView == pickerMinNum.pickerView)
    {
        nRowNum = nOptionNum;
    }
    else
    {
        NSInteger nTemp = nOptionNum - voteSettingMin.nNumValue;
        if (nTemp >= 0)
        {
            nTemp += 2;//包含minValue本身以及不限
        }
        nRowNum = nTemp;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText;
    if (pickerView == pickerMinNum.pickerView)
    {
        strText = [NSString stringWithFormat:@"%li",(unsigned long)(row+1)];
    }
    else
    {
        if(row == 0)
        {
            strText = @"不限";
        }
        else
        {
            strText = [NSString stringWithFormat:@"%li",(unsigned long)(voteSettingMin.nNumValue+row-1)];
        }
    }
    return strText;
}

@end
