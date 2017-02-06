//
//  UserDetailViewController.m
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/9.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "UserDetailViewController.h"
#import "UserKeyValueVo.h"
#import "Utils.h"
#import "UserDetailCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+WebCache.h"
#import "RegisterAndEditViewController.h"
#import "TichetServise.h"
#import "ServerURL.h"
#import "MBProgressHUD+GHQ.h"
@interface UserDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryUserInfoSection;
    UserVo *userVo;
    /** 计算等级cell的高度 */
    CGFloat cellHeight;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewUserDetail;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblRealName;
@property (weak, nonatomic) IBOutlet UILabel *lblJobNumber;

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initData) name:NSNotificationCenterEditInformation object:nil];
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:@"我的信息"];
    
    //左边按钮
    UIButton *btnBack = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_setting"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(showSideMenu)];
    [self setLeftBarButton:btnBack];
    
    UIButton *btnRight = [Utils buttonWithTitle:@"编辑" frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(editMyInfo)];
    [self setRightBarButton:btnRight];
}

- (void)initData
{
    
     userVo = [Common getCurrentUserVo];
     aryUserInfoSection = [NSMutableArray array];
 /*
    userVo.strRealName = @"王五";
    userVo.gender = 1;
    userVo.strBirthday = @"1992-12-03";
    userVo.strNation = @"汉";
    userVo.strHouseHold = @"上海";
    
    userVo.strEducation = @"本科";
    userVo.strSchool = @"上海大学";
    userVo.strSeniority = @"2年";
    
    userVo.strCompanyName = @"新日铁住金";
    userVo.strSignature = @"北宋，上海地区设立专门机构征收酒税。南宋景定、咸淳年间，上海地区的稻棉种植、渔盐蚕丝、棉纺织业日益发达，商贾云集，上海镇设立市舶提举司及榷货场。";
    userVo.strSignature = @"北宋，上海地区设立专门机构征收酒税。南宋景定、咸淳年间，上海地区的稻棉种植、渔盐蚕丝、棉纺织业日益发达，商贾云集，上海镇设立市舶提举司及榷货场。北宋，上海地区设立专门机构征收酒税。南宋景定、咸淳年间，上海地区的稻棉种植、渔盐蚕丝、棉纺织业日益发达，商贾云集，上海镇设立市舶提举司及榷货场。";
    //userVo.strSignature = @"To be, or not to be —that is the question, Whether'tis nobler in the mind to suffer. The slings and arrows of outrageous fortune Or to take arms against a sea of troubles, And by opposing end them. To die —to sleep";
    userVo.strPhoneNumber = @"13512345678";
    userVo.strSoftGrade = @"难";
    userVo.strHardGrade = @"中";
 */
    [TichetServise sendRequest:nil urlString:[ServerURL getUserDetailURLForMe] requestStyle:@"GET" result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess) {
            NSLog(@"%@",retInfo.data);
            [userVo setValuesForKeysWithDictionary:retInfo.data];
            userVo.strRealName = userVo.userLoginName;
//            userVo.gender = userVo.sex;
//            userVo.strBirthday = @"1992-12-03";
            userVo.strNation = userVo.nation;
            userVo.strHouseHold = userVo.householdRegister;
            userVo.strBirthday = userVo.birthday;
            userVo.strEducation = userVo.education;
            userVo.strSchool = userVo.graduationSchool;
            userVo.strSeniority = userVo.workingYears;
            
            userVo.strCompanyName = userVo.company;
            userVo.strSignature = userVo.selfIntroduction;
          
            userVo.strPhoneNumber = userVo.phoneNumber;
//            userVo.strSoftGrade = @"难";
//            userVo.strHardGrade = @"中";
            
            //    @"http://img23.huitu.com/res/20151201/841743_20151201155916349200_2.jpg",
            //    @"http://img21.huitu.com/res/20150928/617182_20150928234825571200_2.jpg",
            
            userVo.strGrade = @"综合评价";
            
            //基本信息
            NSMutableArray *aryBasicInfo = [NSMutableArray array];
            [aryBasicInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strRealName" title:@"姓　　名"]];
            [aryBasicInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"sex" title:@"性　　别"]];
            [aryBasicInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strBirthday" title:@"出生年月"]];
            [aryBasicInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strNation" title:@"民　　族"]];
            [aryBasicInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strHouseHold" title:@"户　　籍"]];
            [aryUserInfoSection addObject:aryBasicInfo];
            
            /** 计算等级cell的高度 */
            cellHeight = 40;
            /** 判断是否五个等级都为空 */
            BOOL isIn = NO;
            
            if (![self isNullToString:userVo.commonLevel1] ) {
                isIn = YES;
                cellHeight += 25;
            }
            if (![self isNullToString:userVo.commonLevel2] ) {
                isIn = YES;
                cellHeight += 25;
            }
            if (![self isNullToString:userVo.commonLevel3] ) {
                isIn = YES;
                cellHeight += 25;
            }
            if (![self isNullToString:userVo.commonLevel4] ) {
                isIn = YES;
                cellHeight += 25;
            }
            if (![self isNullToString:userVo.commonLevel5] ) {
                isIn = YES;
                cellHeight += 25;
            }
            if (isIn) {
                cellHeight -= 25;
            }
            
            //学历信息
            NSMutableArray *arySchoolInfo = [NSMutableArray array];
            [arySchoolInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strEducation" title:@"学　　历"]];
            [arySchoolInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strSchool" title:@"毕业学校"]];
            [arySchoolInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strSeniority" title:@"工作年数"]];
            [aryUserInfoSection addObject:arySchoolInfo];
            
            //其他信息
            NSMutableArray *aryOtherInfo = [NSMutableArray array];
            [aryOtherInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strCompanyName" title:@"所属公司"]];
            [aryOtherInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strSignature" title:@"自我介绍"]];
            [aryOtherInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strPhoneNumber" title:@"联系电话"]];
            [aryOtherInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"aryCertificate" title:@"持有证书"]];
            [aryOtherInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strGrade" title:@"综合评价"]];
            [aryOtherInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strSoftGrade" title:@"维修等级"]];
//            [aryOtherInfo addObject:[[UserKeyValueVo alloc]initWithKey:@"strHardGrade" title:@"硬件等级"]];
            [aryUserInfoSection addObject:aryOtherInfo];
            
            //header info
            [self.imgViewHeader sd_setImageWithURL:[NSURL URLWithString:@"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3084720760,288869075&fm=116&gp=0.jpg"]];
            self.lblRealName.text = userVo.strRealName;
            self.lblJobNumber.text = [NSString stringWithFormat:@"%@",userVo.strUserID];
            
            [self.tableViewUserDetail reloadData];


        }else {
            [MBProgressHUD showSuccess:retInfo.strErrorMsg toView:nil];
        }
    }];
    
    NSMutableDictionary *bodyDic1 = [[NSMutableDictionary alloc] init];
    //    [bodyDic1 setObject:@"ios" forKey:@"client_flag"];
    [bodyDic1 setObject:[Common getCurrentUserVo].strUserID forKey:@"malfunctionId"];
//    [bodyDic1 setObject:@( 20) forKey:@"no"];
    [bodyDic1 setObject:@"01" forKey:@"type"];
    [bodyDic1 setObject:@"2" forKey:@"pageNo"];
    [bodyDic1 setObject:@"10" forKey:@"lines"];
    
    
    [TichetServise sendRequest:bodyDic1 urlString:[ServerURL getWOImage] requestStyle:@"POST" result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess) {
//            NSLog(@"%@",retInfo.data[0][@"path"]);
            NSArray *array = retInfo.data;
            userVo.aryCertificate = [NSMutableArray array];
            for (int i = 0; i < array.count; i ++) {
                UserCertPictureVo *picVo = [[UserCertPictureVo alloc]init];
                picVo.bOld = YES;
                picVo.strImageURL = array[i][@"path"];
                [userVo.aryCertificate addObject:picVo];
            }
            
//            UserCertPictureVo *picVo = [[UserCertPictureVo alloc]init];
//            picVo.bOld = YES;
//            picVo.strImageURL = @"http://img23.huitu.com/res/20151203/133608_20151203190051888337_2.jpg";
//            [userVo.aryCertificate addObject:picVo];
//            
//            picVo = [[UserCertPictureVo alloc]init];
//            picVo.bOld = YES;
//            picVo.strImageURL = @"http://pic29.huitu.com/res/20150407/80570_20150407163212562200_1.jpg";
//            [userVo.aryCertificate addObject:picVo];
//            
//            picVo = [[UserCertPictureVo alloc]init];
//            picVo.bOld = YES;
//            picVo.strImageURL = @"http://img17.huitu.com/res/20150402/80570_20150402053859015200_2.jpg";
//            [userVo.aryCertificate addObject:picVo];
//            
//            picVo = [[UserCertPictureVo alloc]init];
//            picVo.bOld = YES;
//            picVo.strImageURL = @"http://img23.huitu.com/res/20151201/841743_20151201155916349200_2.jpg";
//            [userVo.aryCertificate addObject:picVo];
//            
//            picVo = [[UserCertPictureVo alloc]init];
//            picVo.bOld = YES;
//            picVo.strImageURL = @"http://img21.huitu.com/res/20150928/617182_20150928234825571200_2.jpg";
//            [userVo.aryCertificate addObject:picVo];

        }else {
            
        }
    }];
    
    
   
   
    
    //TODO test data
  
//    userVo.aryCertificate = [@[@"http://img23.huitu.com/res/20151203/133608_20151203190051888337_2.jpg",
//                               @"http://img18.huitu.com/res/20150407/80570_20150407163212562200_2.jpg",
//                               @"http://img17.huitu.com/res/20150402/80570_20150402053859015200_2.jpg"] mutableCopy];
    
  
}
- (BOOL )isNullToString:(id)string
{
    if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"00"])
    {
        return YES;
        
        
    }else
    {
        
        return NO;
    }
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
}
    
- (void)editMyInfo
{
    RegisterAndEditViewController *registerAndEditViewController = [[RegisterAndEditViewController alloc]initWithNibName:@"RegisterAndEditViewController" bundle:nil];
    //RegisterAndEditViewController *registerAndEditViewController = [[RegisterAndEditViewController alloc]init];
    registerAndEditViewController.m_userVo = userVo;
    registerAndEditViewController.viewType = EditUserType;
    [self.navigationController pushViewController:registerAndEditViewController animated:YES];
}
- (NSString *)classificationString:(NSString *)class{
    if ([class isEqualToString:@"commonLevel1"]) {
        return  @"网络";
    }else if ([class isEqualToString:@"commonLevel2"]){
        return @"服务器";
    }else if ([class isEqualToString:@"commonLevel3"]){
        return @"PC";
    }
    else if ([class isEqualToString:@"commonLevel4"]){
        return @"综合布线";
    }else{
        return @"其他";
    }
    
}
- (NSString *)classification:(NSString *)CLASS{
    if ([CLASS isEqualToString:@"10"]) {
        return  @"初级";
    }else if ([CLASS isEqualToString:@"20"]){
        return @"中级";
    }else {
        return @"高级";
    }

}

- (void)configureCell:(UserDetailCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    UserKeyValueVo *keyValueVo = aryUserInfoSection[indexPath.section][indexPath.row];
    keyValueVo.value = [userVo valueForKey:keyValueVo.strKey];
    
    /** 等级内容设定 */
    if (indexPath.section == 2 && indexPath.row == 5) {
        NSString *contentStr = @"";
        if (![self isNullToString:userVo.commonLevel1]) {

            contentStr = [[contentStr stringByAppendingString:[NSString stringWithFormat:@"网络: %@",[self classification:userVo.commonLevel1]]] stringByAppendingString:@"\n"];
        }
        if (![self isNullToString:userVo.commonLevel2]) {
            contentStr = [[contentStr stringByAppendingString:[NSString stringWithFormat:@"服务器: %@",[self classification:userVo.commonLevel2]]] stringByAppendingString:@"\n"];
        }
        if (![self isNullToString:userVo.commonLevel3]) {
            contentStr = [[contentStr stringByAppendingString:[NSString stringWithFormat:@"PC机: %@",[self classification:userVo.commonLevel3]]] stringByAppendingString:@"\n"];
        }
        if (![self isNullToString:userVo.commonLevel4]) {
            contentStr = [[contentStr stringByAppendingString:[NSString stringWithFormat:@"综合布线: %@",[self classification:userVo.commonLevel4]]] stringByAppendingString:@"\n"];
        }
        if (![self isNullToString:userVo.commonLevel5]) {
            contentStr = [[contentStr stringByAppendingString:[NSString stringWithFormat:@"其他: %@",[self classification:userVo.commonLevel5]]] stringByAppendingString:@""];
        }
        keyValueVo.value = contentStr;
    }
    [cell setEntity:keyValueVo];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryUserInfoSection.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryUserInfoSection[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailTextCell" forIndexPath:indexPath];
    cell.parentController = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 2) && (indexPath.row == 5)) {
        return  cellHeight;
    }
    
    //采用自动计算高度，并且带有缓存机制
    return [tableView fd_heightForCellWithIdentifier:@"UserDetailTextCell" cacheByIndexPath:indexPath configuration:^(UserDetailCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    CGFloat fHeight = 15;
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return CGFLOAT_MIN;
}

@end
