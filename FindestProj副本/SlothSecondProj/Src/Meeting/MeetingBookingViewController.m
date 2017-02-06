//
//  MeetingBookingViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingBookingViewController.h"
#import "MeetingRoomViewController.h"
#import "MeetingPlaceViewController.h"
#import "BookingRecordViewController.h"
#import "MeetingPlaceVo.h"
#import "MeetingPlaceDao.h"
#import "MeetingCalendarView.h"
#import "CustomPicker.h"
#import "MeetingDeviceView.h"
#import "MeetingRoomVo.h"

@interface MeetingBookingViewController ()<MeetingPlaceViewDelegate,CustomPickerDelegate,MeetingCalendarDelegate,MeetingDeviceDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    //会议地点
    MeetingPlaceVo *placeVo;
    MeetingPlaceViewController *meetingPlaceViewController;
    
    //会议日期
    NSDate *dateMeeting;
    MeetingCalendarView *meetingCalendarView;
    
    //会议人数
    CustomPicker *pickerNum;
    NSArray *aryNum;
    NSString *strPersonNum;
    
    //device
    MeetingDeviceView *meetingDeviceView;
    NSString *strDeviceList;
}

@property (weak, nonatomic) IBOutlet UILabel *lblPlace;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceDesc;
@property (weak, nonatomic) IBOutlet UIButton *btnPlace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPlaceTop;

@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetingTime;

@property (weak, nonatomic) IBOutlet UIButton *btnPersonNum;
@property (weak, nonatomic) IBOutlet UILabel *lblPersonNum;

@property (weak, nonatomic) IBOutlet UIButton *btnDevice;
@property (weak, nonatomic) IBOutlet UILabel *lblDeviceDesc;

@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (weak, nonatomic) IBOutlet UIView *MeetingPlaceView;

@property (weak, nonatomic) IBOutlet UIView *MeetingTimeView;

@property (weak, nonatomic) IBOutlet UIView *PersonNumberView;

@property (weak, nonatomic) IBOutlet UIView *DeviceView;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;

@property (weak, nonatomic) IBOutlet UILabel *deviceLab;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewImg;

@end

@implementation MeetingBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    
    //设置颜色
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    
    self.backgroundView.backgroundColor = [SkinManage colorNamed:@"meeting_view_bg"];
    
    
    
    
    self.lblPlaceDesc.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    self.lblPlace.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    self.lblMeetingTime.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    self.lblPersonNum.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    self.lblDeviceDesc.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
    
    
    self.numLab.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.timeLab.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.deviceLab.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    
    self.MeetingPlaceView.backgroundColor = [SkinManage colorNamed:@"other_color"];
    self.MeetingTimeView.backgroundColor = [SkinManage colorNamed:@"other_color"];
    self.PersonNumberView.backgroundColor = [SkinManage colorNamed:@"other_color"];
    self.DeviceView.backgroundColor = [SkinManage colorNamed:@"other_color"];
    SkinType skinType = [SkinManage getCurrentSkin];
    //没有找到边框设置，所以采用这种方式解决皮肤
    if (skinType == SkinNightType)
    {
        self.MeetingPlaceView.layer.borderColor = [SkinManage colorNamed:@"other_color"].CGColor;
        self.MeetingTimeView.layer.borderColor = [SkinManage colorNamed:@"other_color"].CGColor;
        self.PersonNumberView.layer.borderColor = [SkinManage colorNamed:@"other_color"].CGColor;
        self.DeviceView.layer.borderColor = [SkinManage colorNamed:@"other_color"].CGColor;
    }
    
    
    
    
    self.isNeedBackItem = YES;
    [self setTitle:@"会议室预订"];
    
    self.navigationItem.rightBarButtonItem = [self rightBtnItemWithImage:@"nav_my_reserve"];
    
    //place
    [_btnPlace setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
    
    //会议时间
    [_btnTime setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
    
    //选择会议人数
    [_btnPersonNum setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
    
    pickerNum = [[CustomPicker alloc] initWithFrame:CGRectZero andDelegate:self];
    [self.view addSubview:pickerNum];
    
    [pickerNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.and.bottom.equalTo(@0);
        make.height.equalTo(@0);
    }];
    
    //设备
    [_btnDevice setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
    
    //完成按钮
    [_btnDone setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateNormal];
    [_btnDone setBackgroundImage:[Common getImageWithColor:COLOR(221, 208, 204, 1.0)] forState:UIControlStateDisabled];
    
    
    [self.contentView insertSubview:self.backgroundView atIndex:0];
    self.tableViewImg.image = [SkinManage imageNamed:@"table_accessory"];
}

- (void)initData
{
    //place vo
    placeVo = [MeetingPlaceDao getMeetingPlaceVo];
    [self refreshPlaceView];
    
    //会议时间
    dateMeeting = [NSDate date];
    _lblMeetingTime.text = [BusinessCommon getMonthDayWeekStringByDate:dateMeeting];
    
    //选择会议人数
    aryNum = @[@"不限",@"5",@"10",@"15",@"20",@"30",@"40"];
}

- (void)refreshPlaceView
{
    if (placeVo)
    {
        _lblPlace.text = placeVo.strName;
        _lblPlace.textColor = [SkinManage colorNamed:@"IntegrationTitleOther_color"];
        _constraintPlaceTop.constant = 12;
        
        _lblPlaceDesc.text = placeVo.strDesc;
        _lblPlaceDesc.hidden = NO;
        
        _btnDone.enabled = YES;
    }
    else
    {
        _lblPlace.text = @"请选择会议所在公司";
        _lblPlace.textColor = COLOR(166, 143, 136, 1.0);
        _constraintPlaceTop.constant = 23.5;
        
        _lblPlaceDesc.hidden = YES;
        
        _btnDone.enabled = NO;
    }
}

- (IBAction)buttonAction:(UIButton *)sender
{
    if (sender.tag == 101)
    {
        //地点
        if (meetingPlaceViewController == nil)
        {
            meetingPlaceViewController = [[UIStoryboard storyboardWithName:@"MeetingBooking" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MeetingPlaceViewController"];
            meetingPlaceViewController.delegate  = self;
        }
        [meetingPlaceViewController refreshView];
        [self.navigationController pushViewController:meetingPlaceViewController animated:YES];
        
    }
    else if (sender.tag == 103)
    {
        //会议时间
        if (meetingCalendarView == nil)
        {
            meetingCalendarView = [[MeetingCalendarView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            meetingCalendarView.delegate = self;
        }
        [self.view.window addSubview:meetingCalendarView];
        [meetingCalendarView showWithAnimation];
    }
    else if (sender.tag == 104)
    {
        //人数
        [self setPickerHidden:pickerNum andHide:NO];
    }
    else if (sender.tag == 105)
    {
        //设备
        if(meetingDeviceView == nil)
        {
            meetingDeviceView = [[MeetingDeviceView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            meetingDeviceView.delegate = self;
        }
        [meetingDeviceView refreshView];
        [self.view.window addSubview:meetingDeviceView.view];
        [meetingDeviceView showWithAnimation];
    }
    else if (sender.tag == 106)
    {
        //查询
        MeetingBookVo *bookVo = [[MeetingBookVo alloc]init];
        bookVo.strPlaceID = placeVo.strID;
        bookVo.strPlaceName = placeVo.strName;
        bookVo.strPlaceDesc = placeVo.strDesc;
        bookVo.strBookDate = [Common getDateTimeStrFromDate:dateMeeting format:@"yyyy-MM-dd"];
        bookVo.dateBook = dateMeeting;
        bookVo.strPersonNum = strPersonNum;
        bookVo.strDevice = strDeviceList;
        
        MeetingRoomViewController *meetingRoomViewController = [[UIStoryboard storyboardWithName:@"MeetingBooking" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MeetingRoomViewController"];
        meetingRoomViewController.bookVo = bookVo;
        [self.navigationController pushViewController:meetingRoomViewController animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

- (void)righBarClick
{
    BookingRecordViewController *bookingRecordViewController = [[UIStoryboard storyboardWithName:@"MeetingBooking" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"BookingRecordViewController"];
    [self.navigationController pushViewController:bookingRecordViewController animated:YES];
}

#pragma - mark MeetingDeviceDelegate
- (void)completedChooseDevice:(NSString *)strDevice name:(NSString *)strName
{
    strDeviceList = strDevice;
    _lblDeviceDesc.text = strName;
}

#pragma - mark MeetingPlaceViewDelegate
- (void)completedMeetingPlace:(MeetingPlaceVo *)meetingPlaceVo
{
    placeVo = meetingPlaceVo;
    [MeetingPlaceDao setMeetingPlaceVo:placeVo];
    [self refreshPlaceView];
}

#pragma - mark MeetingCalendarDelegate
- (void)completedChooseDate:(NSDate *)date
{
    dateMeeting = date;
    _lblMeetingTime.text = [BusinessCommon getMonthDayWeekStringByDate:dateMeeting];
}

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    if (pickerViewCtrl == pickerNum)
    {
        if (aryNum.count>0)
        {
            _lblPersonNum.text = aryNum[[pickerViewCtrl getSelectedRowNum]];
            if ([pickerViewCtrl getSelectedRowNum] == 0)
            {
                strPersonNum = nil;
            }
            else
            {
                strPersonNum = _lblPersonNum.text;
            }
        }
        [self setPickerHidden:pickerNum andHide:YES];
    }
}

- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerNum andHide:YES];
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
    if (pickerView == pickerNum.pickerView)
    {
        nRowNum = aryNum.count;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == pickerNum.pickerView)
    {
        strText = aryNum[row];
    }
    return strText;
}

@end
