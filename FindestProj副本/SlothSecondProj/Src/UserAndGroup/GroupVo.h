//
//  GroupVo.h
//  Sloth
//
//  Created by Ann Yao on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupVo : NSObject

@property (nonatomic, strong) NSString *strGroupID;                 //群组ID
@property (nonatomic, strong) NSString *strGroupNodeID;
@property (nonatomic, strong) NSString *strGroupName;               //群组名称
@property (nonatomic, strong) NSString *strGroupDesc;               //群组描述
@property (nonatomic, strong) NSString *strGroupImage;               //群组头像
@property (nonatomic) int nAllowJoin;                   //允许加入1,0:否

@property (nonatomic) int nAllowSee;                //群外人可以看到本群1,0:否
@property (nonatomic, strong) NSString *strQP;                  //全拼
@property (nonatomic, strong) NSString *strJP;                  //简拼
@property (nonatomic, strong) NSString *strCreatorID;        //群主(群管理员)ID
@property (nonatomic, strong) NSString *strCreatorName;      //群主(群管理员)姓名

@property (nonatomic) int nIsGroupMember;               //是否是群组成员(1,0)
@property (nonatomic, strong) NSMutableArray *aryMemberVo;        //群组成员
@property (nonatomic, strong) NSString *strArticleNum;          //群组下文章数量
@property (nonatomic, strong) NSString *strMemberNum;           //群组下成员数量
@property (nonatomic) int nGroupType;               //1:我创建的，2:我参与的，3:其他群组

@property (nonatomic, strong) NSString *strMemListJSON;     //userlist json

//编程需要字段/////////////////////////////////////////////////////////////////////////
@property (nonatomic) BOOL bIsExpanded;                 //展开(YES)还是闭合(NO)

//用于选择群组
@property (nonatomic) BOOL bChecked;                    //群组是否选择了
@property (nonatomic) BOOL bCanNotCheck;                //不能选择标识

//标记搜索群组,搜索到了:YES ,没有为NO
@property (nonatomic) BOOL bSearched;

//是否为讨论组
@property (nonatomic) BOOL bDiscussion;

@end
