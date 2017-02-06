//
//  ChooseUserViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "ChatObjectVo.h"

//来自的页面类型
typedef enum _ChooseUserType{
    ChooseUserAtType = 1,                     //选择@人
    ChooseUserCreateChatType,                 //创建讨论组
    ChooseUserUpdateChatType                  //修改讨论组成员
}ChooseUserType;

@protocol ChooseUserViewControllerDelegate <NSObject>
@optional
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser group:(GroupVo*)groupVo;//是否为讨论组
@end

@interface ChooseUserViewController : CommonViewController

@property(nonatomic,weak)id<ChooseUserViewControllerDelegate> delegate;
@property(nonatomic)ChooseUserType chooseUserType;   //来自的页面类型

@property (nonatomic, strong) NSString *strSearchText;

@property(nonatomic)NSUInteger nChooseUserNumber;               //用户已选数量

//User Data///////////////////////////////////////////////////////////////
@property (nonatomic, strong) NSMutableArray *aryUserDBData;                //原始数据
@property (nonatomic, strong) NSMutableArray *aryUserChoosed;               //用户已选数据

@property (nonatomic, strong) NSMutableArray *aryUserDBFirstLetter;         //DB 初始化的数据
@property (nonatomic, strong) NSMutableDictionary *dicUserDBData;           //DB 初始化的数据

@property (nonatomic, strong) NSMutableArray *aryUserTableFirstLetter;      //绑定tableView data
@property (nonatomic, strong) NSMutableDictionary *dicUserTableData;        //绑定tableView data

@property (nonatomic, strong) NSMutableArray *aryUserFilteredObject;        //筛选的数据

@property(nonatomic,strong)NSMutableArray *aryUserPreChoosed;     //之前选中的数据

//search

@property (nonatomic) BOOL bOnLineSearch;   //是否在线搜索(避免本地search 刷新)
@property (nonatomic) NSInteger m_curPageNum;

//聊天界面的数据///////////////////////////////////////////////////////////////////////
@property (nonatomic, strong)ChatObjectVo *m_chatObjectVo;

@end
