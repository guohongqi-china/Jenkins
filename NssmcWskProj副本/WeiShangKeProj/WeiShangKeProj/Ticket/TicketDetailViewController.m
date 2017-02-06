//
//  TicketDetailViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/28.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "TicketTraceListCell.h"
#import "TicketTraceVo.h"
#import "Utils.h"
#import "TicketTypeVo.h"
#import "UIViewExt.h"
#import "TicketTypeVo.h"
#import "TagVo.h"

@interface TicketDetailViewController ()

@end

@implementation TicketDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    self.bBackRefresh = NO;
    self.aryTicket = [NSMutableArray array];
    
    //分类数据(缓存数据)
    self.aryType = [BusinessCommon getTicketTypeArray];
    if (self.aryType == nil)
    {
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            ServerReturnInfo *retInfo = [ServerProvider getTicketTypeList];
            if (retInfo.bSuccess)
            {
                self.aryType = retInfo.data;
                [BusinessCommon setTicketTypeArray:self.aryType];
            }
            else
            {
                self.aryType = [NSMutableArray array];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pickerType.pickerView reloadAllComponents];
                [self isHideActivity:YES];
            });
        });
    }
    
    if (self.ticketDetailType == TicketDetailAddType)
    {
        [self refreshView];
    }
    else
    {
        //工单详情
        [self getTicketDetail];
    }
}

- (void)initView
{
    [self setTopNavBarTitle:self.m_ticketVo.strTicketNum];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    [self.m_scrollView addGestureRecognizer:tapGestureRecognizer1];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    [self.view addGestureRecognizer:tapGestureRecognizer2];
    
    //title
    self.txtTitle = [[InsetsTextField alloc]init];
    self.txtTitle.background = [[UIImage imageNamed:@"txt_bk"]stretchableImageWithLeftCapWidth:30 topCapHeight:10];
    self.txtTitle.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtTitle.placeholder = @"标题";
    self.txtTitle.textColor = COLOR(0, 0, 0, 1.0);
    self.txtTitle.delegate = self;
    [self.m_scrollView addSubview:self.txtTitle];
    
    self.viewLineTitle = [[UIView alloc]init];
    self.viewLineTitle.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.m_scrollView addSubview:self.viewLineTitle];
    
    //content
    self.txtViewContent = [[SZTextView alloc]init];
    self.txtViewContent.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtViewContent.delegate = self;
    self.txtViewContent.placeholder = @"工单描述";
    [self.m_scrollView addSubview:self.txtViewContent];
    
    self.viewLineContent = [[UIView alloc]init];
    self.viewLineContent.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.m_scrollView addSubview:self.viewLineContent];
    
    //选择类型
    self.txtType = [[InsetsTextField alloc]init];
    self.txtType.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtType.textColor = COLOR(0, 0, 0, 1.0);
    self.txtType.placeholder = @"请选择工单类型";
    self.txtType.delegate = self;
    [self.m_scrollView addSubview:self.txtType];
    
    self.imgViewTypeArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-44.5, 17, 10.5, 5.5)];
    self.imgViewTypeArrow.image = [UIImage imageNamed:@"dropdown_icon"];
    [self.txtType addSubview:self.imgViewTypeArrow];
    
    self.viewLineType = [[UIView alloc]init];
    self.viewLineType.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.m_scrollView addSubview:self.viewLineType];
    
    //tag view
    self.viewTag = [[UIView alloc]init];
    [self.m_scrollView addSubview:self.viewTag];
    
    self.btnAddTag = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddTag.frame =  CGRectMake(kScreenWidth-57, 0, 57, 37);
    [self.btnAddTag setImage:[UIImage imageNamed:@"btn_add_receiver"] forState:UIControlStateNormal];
    [self.btnAddTag addTarget:self action:@selector(addTag) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTag addSubview:self.btnAddTag];
    
    self.lblTagPlaceHolder = [[UILabel alloc]init];
    self.lblTagPlaceHolder.textColor = COLOR(199, 199, 205, 1.0);
    self.lblTagPlaceHolder.font = [UIFont systemFontOfSize:15];
    [self.viewTag addSubview:self.lblTagPlaceHolder];
    
    self.viewLineTag = [[UIView alloc]init];
    self.viewLineTag.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewTag addSubview:self.viewLineTag];
    
    //工单操作记录
    self.tableViewRecord = [[UITableView alloc]init];
    self.tableViewRecord.dataSource = self;
    self.tableViewRecord.delegate = self;
    self.tableViewRecord.scrollEnabled = NO;
    self.tableViewRecord.scrollsToTop = NO;
    self.tableViewRecord.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.m_scrollView addSubview:self.tableViewRecord];
    
    //底部按钮
    self.viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    self.viewBottom.backgroundColor = COLOR(249, 249, 249, 1.0);
    self.viewBottom.hidden = YES;
    [self.view addSubview:_viewBottom];
    
    UIImageView *imgViewTabLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.5)];
    imgViewTabLine.image = [[UIImage imageNamed:@"tab_line"]stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.viewBottom addSubview:imgViewTabLine];
    
    CGFloat fTabW = kScreenWidth/4;
    //合并
    self.btnMerge = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnMerge.frame = CGRectMake(0, 0, fTabW, 50);
    [self.btnMerge setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [self.btnMerge setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnMerge.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnMerge setTitle:@"合并" forState:UIControlStateNormal];
    [self.btnMerge addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnMerge];
    
    //关闭
    self.btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnClose.frame = CGRectMake(fTabW, 0, fTabW, 50);
    [self.btnClose setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [self.btnClose setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnClose.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnClose setTitle:@"关闭工单" forState:UIControlStateNormal];
    [self.btnClose addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnClose];
    
    //发送
    self.btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSend.frame = CGRectMake(fTabW*2, 0, fTabW, 50);
    [self.btnSend setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [self.btnSend setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnSend.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnSend setTitle:@"发送" forState:UIControlStateNormal];
    [self.btnSend addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnSend];
    
    //添加
    self.btnAddRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddRecord.frame = CGRectMake(fTabW*3, 0, fTabW, 50);
    [self.btnAddRecord setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [self.btnAddRecord setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnAddRecord.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnAddRecord setTitle:@"添加" forState:UIControlStateNormal];
    [self.btnAddRecord addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnAddRecord];
    
    //picker type
    self.pickerType = [[CustomPicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    self.pickerType.delegate = self;
    [self.view addSubview:self.pickerType];
    
    self.pickerTicket = [[CustomPicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    self.pickerTicket.delegate = self;
    [self.view addSubview:self.pickerTicket];
}

- (void)refreshView
{
    CGFloat fHeight = 0;
    //title
    self.txtTitle.text = self.m_ticketVo.strTitle;
    self.txtTitle.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    fHeight += self.txtTitle.height;
    
    self.viewLineTitle.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    fHeight += 0.5;
    
    //content
    self.txtViewContent.text = self.m_ticketVo.strContent;
    self.txtViewContent.frame = CGRectMake(10, fHeight, kScreenWidth-20, 100);
    fHeight += self.txtViewContent.height + 10;
    
    self.viewLineContent.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    fHeight += 0.5;
    
    //ticket type
    self.txtType.text = self.m_ticketVo.strTypeName;
    self.txtType.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    fHeight += self.txtType.height;
    
    self.viewLineType.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    fHeight += 0.5;
    
    //tag
    CGFloat fTagHeight = 6;
    fTagHeight += [self bindTagList:fTagHeight];
    fTagHeight += 6;
    if (fTagHeight<40)
    {
        fTagHeight = 40;
    }
    self.viewLineTag.frame = CGRectMake(0, fTagHeight-0.5, kScreenWidth, 0.5);
    
    self.viewTag.frame = CGRectMake(0, fHeight, kScreenWidth, fTagHeight);
    self.lblTagPlaceHolder.frame = CGRectMake(15, 0, kScreenWidth-30, 40);//tag place holder
    self.btnAddTag.frame =  CGRectMake(kScreenWidth-57, 0, 57, 40);
    fHeight += fTagHeight;

    //ticket record list
    self.tableViewRecord.frame = CGRectMake(0, fHeight+1, kScreenWidth, self.tableViewRecord.contentSize.height);
    fHeight +=30+self.tableViewRecord.contentSize.height + 50;//30:table header view
    
    //scrollview
    fHeight = (fHeight>self.m_scrollView.height)?fHeight:(self.m_scrollView.height+0.5);
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth,fHeight)];
    
    
    if (self.ticketDetailType == TicketDetailAddType)
    {
        [self setTopNavBarTitle:@"创建工单"];
        //保存按钮
        UIButton *btnEdit = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_save"] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doSave)];
        [self setRightBarButton:btnEdit];
        
        self.viewBottom.hidden = YES;
        self.tableViewRecord.hidden = YES;
        self.m_scrollView.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
    }
    else
    {
        [self setTopNavBarTitle:self.m_ticketVo.strTicketNum];
        self.tableViewRecord.hidden = NO;
        
        if(self.m_ticketVo.nStatus == 4)
        {
            //工单已处理
            self.viewBottom.hidden = YES;
            self.m_scrollView.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
            
            //保存按钮置空
            [self setRightBarButton:nil];
            
            //设置相关按钮无效
            self.txtTitle.enabled = NO;
            self.txtViewContent.userInteractionEnabled = NO;
            self.txtType.enabled = NO;
            self.btnAddTag.enabled = NO;
        }
        else
        {
            self.viewBottom.hidden = NO;
            self.m_scrollView.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT-50);
            
            //保存按钮
            UIButton *btnEdit = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_save"] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doSave)];
            [self setRightBarButton:btnEdit];
            
            //设置相关按钮无效
            self.txtTitle.enabled = YES;
            self.txtViewContent.userInteractionEnabled = YES;
            self.txtType.enabled = YES;
            self.btnAddTag.enabled = YES;
        }
    }
}

//工单详情
-(void)getTicketDetail
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        ServerReturnInfo *retInfo = [ServerProvider getTicketDetail:self.m_ticketVo.strID];
        if (retInfo.bSuccess)
        {
            self.m_ticketVo = retInfo.data;
            self.strTypeID = self.m_ticketVo.strTypeID;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewRecord reloadData];
                
                [self refreshView];
                [self isHideActivity:YES];
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

//保存工单
- (void)doSave
{
    TicketVo *ticketVo = [[TicketVo alloc]init];
    ticketVo.strID = self.m_ticketVo.strID;
    ticketVo.strTitle = self.txtTitle.text;
    if (ticketVo.strTitle.length == 0)
    {
        [Common tipAlert:@"工单标题不能为空"];
    }
    
    ticketVo.strContent = self.txtViewContent.text;
    
    ticketVo.strTypeID = self.strTypeID;
    
    ticketVo.strSessionID = self.m_ticketVo.strSessionID;
    
    ticketVo.aryTag = self.m_ticketVo.aryTag;
    
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider saveTicket:ticketVo];
        self.m_ticketVo = retInfo.data;
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isHideActivity:YES];
                self.bBackRefresh = YES;
                if (self.ticketDetailType == TicketDetailAddType)
                {
                    //新增才刷新
                    self.ticketDetailType = TicketDetailModifyType;
                    [self refreshView];
                }
                
                [self hideKeyboard];
                [Common bubbleTip:@"保存工单成功" andView:self.view];
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

//添加标签
-(void)addTag
{
    //保存数据
    [self saveTempDate];
    
    if(self.chooseTagViewController == nil)
    {
        self.chooseTagViewController = [[ChooseTagViewController alloc]init];
        self.chooseTagViewController.delegate = self;
        self.chooseTagViewController.strTagType = @"W";
        self.chooseTagViewController.bFirstLoad = YES;
    }
    else
    {
        self.chooseTagViewController.bFirstLoad = NO;
    }
    
    [self.chooseTagViewController initBindChoosedData:self.m_ticketVo.aryTag];
    [self.navigationController pushViewController:self.chooseTagViewController animated:YES];
}

//查找待合并的工单列表操作
-(void)requestTicketList
{
    if(self.aryTicket.count>0)
    {
        [self setPickerHidden:self.pickerTicket andHide:NO];
    }
    else
    {
        //判断是否外部传过来了工单列表
        if(self.aryOutTicket != nil)
        {
            [self.aryTicket addObjectsFromArray:self.aryOutTicket];
            //移除当前工单
            [self removeCurrTicket];
            
            if (self.aryTicket.count == 0)
            {
                //没有待合并工单
                self.btnMerge.enabled = NO;
                [self.btnMerge setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateNormal];
                [Common bubbleTip:@"没有待合并的工单" andView:self.view];
            }
            else
            {
                [self.pickerTicket.pickerView reloadAllComponents];
                //弹出工单选择视图
                [self setPickerHidden:self.pickerTicket andHide:NO];
            }
        }
        else
        {
            //重新查询
            [self isHideActivity:NO];
            dispatch_async(dispatch_get_global_queue(0,0),^{
//                ServerReturnInfo *retInfo = [ServerProvider getTicketList:nil page:1 pageSize:10000 status:0 custId:self.m_ticketVo.strCustomerID];;
//                if (retInfo.bSuccess)
//                {
//                    [self.aryTicket addObjectsFromArray:retInfo.data];
//                    //移除当前工单
//                    [self removeCurrTicket];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self isHideActivity:YES];
//                        if (self.aryTicket.count == 0)
//                        {
//                            //没有待合并工单
//                            self.btnMerge.enabled = NO;
//                            [self.btnMerge setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateNormal];
//                            [Common bubbleTip:@"没有待合并的工单" andView:self.view];
//                        }
//                        else
//                        {
//                            [self.pickerTicket.pickerView reloadAllComponents];
//                            //弹出工单选择视图
//                            [self setPickerHidden:self.pickerTicket andHide:NO];
//                        }
//                    });
//                }
//                else
//                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [Common tipAlert:retInfo.strErrorMsg];
//                        [self isHideActivity:YES];
//                    });
//                }
            });
        }
    }
}

-(void)removeCurrTicket
{
    for (TicketVo *ticketVo in self.aryTicket)
    {
        if ([ticketVo.strID isEqualToString:self.m_ticketVo.strID])
        {
            [self.aryTicket removeObject:ticketVo];
            break;
        }
    }
}

//绑定标签
-(CGFloat)bindTagList:(CGFloat)fTopHeight
{
    if (self.viewTagContainer != nil)
    {
        [self.viewTagContainer removeFromSuperview];
    }
    
    self.viewTagContainer = [[UIView alloc]init];
    self.viewTagContainer.backgroundColor = [UIColor clearColor];
    
    CGFloat upX=0;
    CGFloat upY=0;
    
    CGFloat fLineHeight = 25;
    CGFloat maxWidth = kScreenWidth-10-45;
    
    for(TagVo *tagVo in self.m_ticketVo.aryTag)
    {
        //UILabel
        UILabel *lblTag = [[UILabel alloc]init];
        lblTag.font = [UIFont systemFontOfSize:15.0];
        [lblTag.layer setBorderWidth:0];
        [lblTag.layer setCornerRadius:3];
        lblTag.layer.borderColor = [[UIColor clearColor] CGColor];
        [lblTag.layer setMasksToBounds:YES];
        lblTag.backgroundColor = COLOR(60, 140, 197, 1.0);
        lblTag.textColor = [UIColor whiteColor];
        lblTag.text = tagVo.strTagName;
        lblTag.textAlignment = NSTextAlignmentCenter;
        lblTag.lineBreakMode = NSLineBreakByCharWrapping;
        [self.viewTagContainer addSubview:lblTag];
        
        //add label
        CGSize size=[Common getStringSize:lblTag.text font:lblTag.font bound:CGSizeMake(MAXFLOAT, fLineHeight) lineBreakMode:NSLineBreakByCharWrapping];
        size.width += 10;
        if ((upX+size.width) > maxWidth)
        {
            //当大于一行最大宽度，进行换行
            upY += fLineHeight+7;
            upX = 0;
            
            lblTag.frame = CGRectMake(upX, upY, size.width, fLineHeight);
            
            upX += size.width+7;
        }
        else
        {
            lblTag.frame = CGRectMake(upX, upY, size.width, fLineHeight);
            upX += size.width+7;
        }
    }
    
    CGFloat fHeight = fLineHeight+upY;
    self.viewTagContainer.frame = CGRectMake(10, fTopHeight, maxWidth, fHeight);
    [self.viewTag addSubview:self.viewTagContainer];
    
    //place holder
    if (self.m_ticketVo.aryTag.count>0)
    {
        self.lblTagPlaceHolder.text = @"";
    }
    else
    {
        self.lblTagPlaceHolder.text = @"请选择标签";
    }
    [self.viewTag bringSubviewToFront:self.lblTagPlaceHolder];
    
    return fHeight;
}

//底部按钮事件
- (void)bottomButtonAction:(UIButton*)sender
{
    if (sender == self.btnMerge)
    {
        //合并
        [self requestTicketList];
    }
    else if (sender == self.btnClose)
    {
        //关闭工单
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您确定要关闭该工单？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1001;
        [alertView show];
        
    }
    else if (sender == self.btnSend)
    {
        //发送邮件
        //if (self.emailInputView == nil)
//        {
//            
//            }
        EmailInputView *emailInputView = [[EmailInputView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        emailInputView.titleStr = @"添加邮件地址";
        emailInputView.delegate = self;
        [emailInputView initView];
        [emailInputView initInputViewControlValue];
        [self.view addSubview:emailInputView];
    }
    else if (sender == self.btnAddRecord)
    {
        //添加记录
        if (self.inPutView == nil)
        {
            self.inPutView = [[InPutView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            self.inPutView.titleStr = @"添加跟踪记录";
            self.inPutView.delegate = self;
            self.inPutView.parentController = self;
            [self.inPutView initView];
            self.inPutView.btnFace.hidden = YES;
            self.inPutView.btnAttach.hidden = YES;
        }
        [self.inPutView initInputViewControlValue];
        [self.view addSubview:self.inPutView];
    }
}

- (void)selelctTicketType
{
    
}

//显示隐藏PickerView控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, nHeight);
    pickerViewCtrl.transform = transform;
    if (!hidden)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, (kScreenHeight-NAV_BAR_HEIGHT-260+44));
    }
    else
    {
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, kScreenHeight-NAV_BAR_HEIGHT);
    }
}

//选择工单分类
-(void)doSelectPickerView:(UITextField*)txtField
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if (txtField == self.txtType)
    {
        //建议类别
        [self setPickerHidden:self.pickerType andHide:NO];
        
        //初始选中
        if (self.m_ticketVo.strTypeID != nil && self.m_ticketVo.strTypeID.length>0)
        {
            for (int i=0; i<self.aryType.count; i++)
            {
                TicketTypeVo *ticketTypeVo = [self.aryType objectAtIndex:i];
                if ([ticketTypeVo.strID isEqualToString:self.m_ticketVo.strTypeID])
                {
                    [self.pickerType.pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
}

-(void)backgroundTap
{
    for(UIView*view in[self.m_scrollView subviews])
    {
        if([view isFirstResponder])
        {
            [view resignFirstResponder];
            return;
        }
    }
    
    [self setPickerHidden:self.pickerType andHide:YES];
    [self setPickerHidden:self.pickerTicket andHide:YES];
}

- (void)backButtonClicked
{
    if (self.bBackRefresh)
    {
        //refresh list view
        self.refreshTicketBlock();
    }
    
    [super backButtonClicked];
}

//保存临时数据
-(void)saveTempDate
{
    self.m_ticketVo.strTitle = self.txtTitle.text;
    self.m_ticketVo.strContent = self.txtViewContent.text;
    self.m_ticketVo.strTypeID = self.strTypeID;
    self.m_ticketVo.strTypeName = self.txtType.text;
}

//隐藏键盘
-(void)hideKeyboard
{
    [self.txtTitle resignFirstResponder];
    [self.txtViewContent resignFirstResponder];
    [self setPickerHidden:self.pickerType andHide:YES];
    [self setPickerHidden:self.pickerTicket andHide:YES];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        if (buttonIndex==1)
        {
            //关闭工单
            [self isHideActivity:NO];
            dispatch_async(dispatch_get_global_queue(0,0),^{
                //do thread work
                ServerReturnInfo *retInfo = [ServerProvider closeTicket:self.m_ticketVo.strID];
                if (retInfo.bSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self isHideActivity:YES];
                        self.bBackRefresh = YES;
                        [self backButtonClicked];
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
}

#pragma mark - InPutSendDelegateWithAttach
-(void)completeSend:(NSString*)strText
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider addTicketRecord:self.m_ticketVo.strID record:strText];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //增加记录，刷新列表
                TicketTraceVo *traceVo = retInfo.data;
                
                if ([traceVo isKindOfClass:[TicketTraceVo class]])
                {
                    [self.m_ticketVo.aryTrace addObject:traceVo];
                    [self.tableViewRecord reloadData];
                    [self saveTempDate];
                    [self refreshView];
                }
                
                [self isHideActivity:YES];
                [self.inPutView doCancel];
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

#pragma mark - InPutSendDelegateWithAttach
-(void)completeEditEmail:(EmailInputView*)emailInputView email:(NSMutableArray*)aryEmail
{
    //发送邮件
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        ServerReturnInfo *retInfo = [ServerProvider transferTicketToEmail:self.m_ticketVo.strID session:self.m_ticketVo.strSessionID email:aryEmail];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Common bubbleTip:@"您已成功发送工单" andView:self.view];
                [emailInputView dismissEmailView];
                [self isHideActivity:YES];
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

-(void)cancelEditEmail:(EmailInputView*)emailInputView
{
    [emailInputView dismissEmailView];
}

#pragma mark - ChooseTagViewControllerDelegate
-(void)completeChooseTagAction:(NSMutableArray*)aryChoosedTag
{
    self.m_ticketVo.aryTag = aryChoosedTag;
    //刷新视图
    [self refreshView];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.txtType)
    {
        [self doSelectPickerView:textField];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setPickerHidden:self.pickerType andHide:YES];
    [self setPickerHidden:self.pickerTicket andHide:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self setPickerHidden:self.pickerType andHide:YES];
    [self setPickerHidden:self.pickerTicket andHide:YES];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_ticketVo.aryTrace count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"TicketTraceListCell";
    TicketTraceListCell *cell = (TicketTraceListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[TicketTraceListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TicketTraceVo *ticketTraceVo = self.m_ticketVo.aryTrace[indexPath.row];
    [cell initWithData:ticketTraceVo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TicketTraceListCell calculateCellHeight:self.m_ticketVo.aryTrace[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-10, 29.5)];
    label.textColor = COLOR(51,51,51,1.0);
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"工单操作记录";
    [headerView addSubview:label];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 29.5, kScreenWidth, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [headerView addSubview:viewLine];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
    if (pickerViewCtrl == self.pickerType)
    {
        TicketTypeVo *ticketTypeVo = [self.aryType objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
        self.strTypeID = ticketTypeVo.strID;
        self.txtType.text = ticketTypeVo.strName;
    }
    else if (pickerViewCtrl == self.pickerTicket)
    {
        //合并工单操作
        TicketVo *ticketVo = [self.aryTicket objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider mergeTicket:self.m_ticketVo.strID toTicket:ticketVo.strID];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    //刷新数据，合并工单后，流水记录会被合并
                    [self getTicketDetail];
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

- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
}

#pragma mark Picker Data Source Methods
//1 选取器组件的个数，也就是滚轮的个数
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//2 每个组件的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger nRowNum = 0;
    if (pickerView == self.pickerType.pickerView)
    {
        nRowNum = self.aryType.count;
    }
    else if (pickerView == self.pickerTicket.pickerView)
    {
        nRowNum = self.aryTicket.count;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == self.pickerType.pickerView)
    {
        TicketTypeVo *ticketTypeVo = [self.aryType objectAtIndex:row];
        strText = ticketTypeVo.strName;
    }
    else if (pickerView == self.pickerTicket.pickerView)
    {
        TicketVo *ticketVo = [self.aryTicket objectAtIndex:row];
        strText = [NSString stringWithFormat:@"%@ %@",ticketVo.strTicketNum,ticketVo.strTitle];
    }
    return strText;
}

@end
