//
//  MeetingRoomService.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/9.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "MeetingRoomService.h"
#import "MeetingPlaceVo.h"
#import "UserVo.h"
#import "VNetworkFramework.h"

@implementation MeetingRoomService

//通过TimeID转换为时间格式
+ (NSString *)getTimeStringByTimeID:(NSInteger)nTimeID
{
    NSString *strFirstTime = [NSString stringWithFormat:@"%li",(long)nTimeID];
    if (strFirstTime.length == 3)
    {
        strFirstTime = [NSString stringWithFormat:@"0%@",strFirstTime];
    }
    
    if (strFirstTime.length >= 4)
    {
        strFirstTime = [NSString stringWithFormat:@"%@:%@",[strFirstTime substringToIndex:2],[strFirstTime substringFromIndex:2]];
    }
    
    //second
    if (nTimeID % 100 == 0)
    {
        nTimeID += 30;
    }
    else
    {
        nTimeID = (nTimeID/100+1)*100;
    }
    NSString *strSecondTime = [NSString stringWithFormat:@"%li",(long)nTimeID];
    if (strSecondTime.length == 3)
    {
        strSecondTime = [NSString stringWithFormat:@"0%@",strSecondTime];
    }
    
    if (strFirstTime.length >= 4)
    {
        strSecondTime = [NSString stringWithFormat:@"%@:%@",[strSecondTime substringToIndex:2],[strSecondTime substringFromIndex:2]];
    }
    return [NSString stringWithFormat:@"%@-%@",strFirstTime,strSecondTime];
}

+(NSMutableArray*)getMeetingRoomListByJSONArray:(NSArray*)aryJSONList
{
    if (![aryJSONList isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSMutableArray *aryMeetingRoom = [NSMutableArray array];
    for (NSDictionary *dicRoom in aryJSONList)
    {
        MeetingRoomVo *roomVo = [[MeetingRoomVo alloc]init];
        id roomId = dicRoom[@"id"];
        if (roomId == [NSNull null] || roomId == nil)
        {
            roomVo.strID = @"";
        }
        else
        {
            roomVo.strID = [roomId stringValue];
        }
        
        roomVo.strName = [Common checkStrValue:dicRoom[@"room"]];
        roomVo.strDesc = [Common checkStrValue:dicRoom[@"roomDesc"]];
        
        id placeId = dicRoom[@"id"];
        if (placeId == [NSNull null] || placeId == nil)
        {
            roomVo.strPlaceID = @"";
        }
        else
        {
            roomVo.strPlaceID = [placeId stringValue];
        }
        
        id disabled = dicRoom[@"disabled"];
        if (disabled == [NSNull null] || disabled == nil)
        {
            roomVo.bEnable = NO;
        }
        else
        {
            roomVo.bEnable = ([disabled integerValue] == 0)?YES:NO;
        }
        
        roomVo.strBookDate = [Common checkStrValue:dicRoom[@"bookDate"]];
        
        id bookInfo = dicRoom[@"bookInfo"];
        if (bookInfo == [NSNull null] || ![bookInfo isKindOfClass:[NSArray class]])
        {
            roomVo.aryBookInfo = nil;
        }
        else
        {
            roomVo.aryBookInfo = [NSMutableArray array];
            for (NSDictionary *dicBookInfo in bookInfo)
            {
                MeetingBookVo *bookVo = [[MeetingBookVo alloc]init];
                
                id bookId = dicBookInfo[@"bookId"];
                if (bookId == [NSNull null] || bookId == nil)
                {
                    //不加入无效的会议记录
                    continue;
                }
                else
                {
                    bookVo.nID = [bookId integerValue];
                }
                
                id timeId = dicBookInfo[@"timeId"];
                if (timeId == [NSNull null] || timeId == nil)
                {
                    bookVo.nTimeID = 0;
                    bookVo.strTimeDesc = @"";
                }
                else
                {
                    bookVo.nTimeID = [timeId integerValue];
                    bookVo.strTimeDesc = [MeetingRoomService getTimeStringByTimeID:bookVo.nTimeID];
                }
                
                id disabled = dicBookInfo[@"disabled"];
                if (disabled == [NSNull null] || disabled == nil)
                {
                    bookVo.bEnable = NO;
                }
                else
                {
                    bookVo.bEnable = ([disabled integerValue] == 0)?YES:NO;
                }
                
                id userId = dicBookInfo[@"userId"];
                if (userId == [NSNull null] || userId == nil)
                {
                    bookVo.strUserID = @"";
                }
                else
                {
                    bookVo.strUserID = [userId stringValue];
                }
                
                bookVo.strTitle = [Common checkStrValue:dicBookInfo[@"title"]];
                bookVo.strUserName = [Common checkStrValue:dicBookInfo[@"userName"]];
                bookVo.strContact = [Common checkStrValue:dicBookInfo[@"contact"]];
                bookVo.strRemark = [Common checkStrValue:dicBookInfo[@"remark"]];
                
                //状态检测
                if (bookVo.bEnable)
                {
                    if (bookVo.strUserID.length == 0)
                    {
                        bookVo.nState = 4;
                    }
                    else if ([bookVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
                    {
                        bookVo.nState = 2;
                    }
                    else
                    {
                        bookVo.nState = 1;
                    }
                }
                else
                {
                    bookVo.nState = 0;
                }
                
                [roomVo.aryBookInfo addObject:bookVo];
            }
        }
        
        [aryMeetingRoom addObject:roomVo];
    }
    return aryMeetingRoom;
}

+ (void)getMeetingPlaceList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getMeetingPlaceListURL]];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSMutableArray *aryPlace = [NSMutableArray array];
            
            NSArray *aryJSONMeetingPlace = responseObject;
            for (NSDictionary *dicPlace in aryJSONMeetingPlace)
            {
                MeetingPlaceVo *placeVo = [[MeetingPlaceVo alloc]init];
                
                id placeId = dicPlace[@"id"];
                if (placeId == [NSNull null] || placeId == nil)
                {
                    placeVo.strID = @"";
                }
                else
                {
                    placeVo.strID = [placeId stringValue];
                }
                
                placeVo.strName = [Common checkStrValue:dicPlace[@"place"]];
                placeVo.strDesc = [Common checkStrValue:dicPlace[@"placeDesc"]];
                placeVo.bCheck = NO;
                
                [aryPlace addObject:placeVo];
            }
            
            retInfo.data = aryPlace;
        }
        resultBlock(retInfo);
    }];
}

+ (void)getMeetingRoomListByPlace:(NSString*)strPlaceID result:(ResultBlock)resultBlock
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",[ServerURL getMeetingRoomListByPlaceURL],strPlaceID];
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:strURL];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            retInfo.data = [MeetingRoomService getMeetingRoomListByJSONArray:responseObject];
        }
        resultBlock(retInfo);
    }];
}

+ (void)getMeetingRoomListByParameter:(MeetingBookVo*)book result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    dicBody[@"placeId"] = book.strPlaceID;
    dicBody[@"bookDate"] = book.strBookDate;
    
    if (book.strPersonNum.length > 0)
    {
        dicBody[@"peopleNumber"] = book.strPersonNum;
    }
    
    if (book.strDevice.length > 0)
    {
        dicBody[@"device"] = book.strDevice;
    }
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getMeetingRoomListByParameterURL]];
    [framework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            retInfo.data = [MeetingRoomService getMeetingRoomListByJSONArray:responseObject];
        }
        resultBlock(retInfo);
    }];
}

+ (void)getMeetingRoomDetail:(NSString*)strPlaceID room:(NSString*)strRoomID date:(NSString *)strDate result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [@{@"id":strRoomID} mutableCopy];
    if (strRoomID.length>0)
    {
        dicBody[@"bookDate"] = strDate;
    }
    else if (strPlaceID.length>0)
    {
        dicBody[@"placeId"] = strPlaceID;
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getMeetingRoomDetailURL]];
    [networkFramework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            retInfo.data = [MeetingRoomService getMeetingRoomListByJSONArray:responseObject];
        }
        resultBlock(retInfo);
    }];
}

+ (void)cancelReserveMeetingRoomParasms:(NSString *)booklistStr result:(ResultBlock)resultBlock
{
//    NSString *strURL = [NSString stringWithFormat:@"%@/%li",[ServerURL getCancelReserveMeetingRoomURL],(long)nBookID];
    
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getCancelReserveMeetingRoomURL]];
    [framework startRequestToServer:@"POST" parameter:@{@"booklist":booklistStr} result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

+ (void)reserveMeetingRoom:(NSString *)strRoomID
                      time:(NSMutableArray *)aryTimeID
                      date:(NSString *)strBookDate
                     title:(NSString *)strTitle
                      name:(NSString *)strName
                   contact:(NSString *)strContact
                    remark:(NSString *)strRemark
                    result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [@{
                                      @"id":strRoomID,
                                      @"bookDate":strBookDate,
                                      @"timeIdList":aryTimeID,
                                      } mutableCopy];
    
    if(strTitle != nil && strTitle.length > 0)
    {
        dicBody[@"title"] = strTitle;
    }
    
    if(strName != nil && strName.length > 0)
    {
        dicBody[@"userName"] = strName;
    }
    
    if(strContact != nil && strContact.length > 0)
    {
        dicBody[@"contact"] = strContact;
    }
    
    if(strRemark != nil && strRemark.length > 0)
    {
        dicBody[@"remark"] = strRemark;
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getReserveMeetingRoomURL]];
    [networkFramework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

+ (void)reserveMeetingRoomByBookVo:(MeetingBookVo *)bookVo result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [@{
                                      @"id":bookVo.roomVo.strID,
                                      @"bookDate":bookVo.strBookDate,
                                      @"timeIdList":bookVo.aryTimeSegment,
                                      } mutableCopy];
    
    if(bookVo.strTitle != nil && bookVo.strTitle.length > 0)
    {
        dicBody[@"title"] = bookVo.strTitle;
    }
    
    if(bookVo.strUserName != nil && bookVo.strUserName.length > 0)
    {
        dicBody[@"userName"] = bookVo.strUserName;
    }
    
    if(bookVo.strContact != nil && bookVo.strContact.length > 0)
    {
        dicBody[@"contact"] = bookVo.strContact;
    }
    
    if(bookVo.strRemark != nil && bookVo.strRemark.length > 0)
    {
        dicBody[@"remark"] = bookVo.strRemark;
    }
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getReserveMeetingRoomURL]];
    [networkFramework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}


//预定记录
+ (void)getMyReserveMeetingList:(ResultBlock)resultBlock
{
    VNetworkFramework *framework = [[VNetworkFramework alloc] initWithURLString:[ServerURL getMyReserveMeetingListURL]];
    [framework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSMutableArray *aryReserveList = [NSMutableArray array];
            NSArray *aryJSON = responseObject;
            for (NSDictionary *dicReserve in aryJSON)
            {
                MeetingBookVo *bookVo = [[MeetingBookVo alloc]init];
                
                bookVo.strTitle = [Common checkStrValue:dicReserve[@"title"]];
                
                id roomId = dicReserve[@"roomId"];
                if (roomId == [NSNull null] || roomId == nil)
                {
                    bookVo.strRoomID = @"";
                }
                else
                {
                    bookVo.strRoomID = [roomId stringValue];
                }
                bookVo.strRoomName = [Common checkStrValue:dicReserve[@"room"]];
                bookVo.strRoomDesc = [Common checkStrValue:dicReserve[@"roomDesc"]];
                
                bookVo.strBookDate = [Common checkStrValue:dicReserve[@"bookDate"]];
                
                bookVo.strPlaceName = [Common checkStrValue:dicReserve[@"place"]];
                bookVo.strPlaceDesc = [Common checkStrValue:dicReserve[@"placeDesc"]];
                bookVo.strTimeRange = [Common checkStrValue:dicReserve[@"time"]];
                bookVo.bookList = [Common checkStrValue:dicReserve[@"bookId"]];
                id minTimeId = dicReserve[@"minTimeId"];
                if (minTimeId == [NSNull null] || minTimeId == nil)
                {
                    bookVo.strStartTime = @"";
                    bookVo.nMinTimeId = 0;
                }
                else
                {
                    bookVo.nMinTimeId = [minTimeId integerValue];
                    
                    NSString *strTemp = [minTimeId stringValue];
                    if (strTemp.length == 3)
                    {
                        strTemp = [NSString stringWithFormat:@"0%@",strTemp];
                    }
                    
                    if (strTemp.length >= 4)
                    {
                        strTemp = [NSString stringWithFormat:@"%@:%@",[strTemp substringToIndex:2],[strTemp substringFromIndex:2]];
                    }
                    bookVo.strStartTime = strTemp;
                }
                
                id maxTimeId = dicReserve[@"maxTimeId"];
                if (maxTimeId == [NSNull null] || maxTimeId == nil)
                {
                    bookVo.strEndTime = @"";
                    bookVo.nMaxTimeId = 0;
                }
                else
                {
                    bookVo.nMaxTimeId = [maxTimeId integerValue];
                    
                    NSString *strTemp = [maxTimeId stringValue];
                    if (strTemp.length == 3)
                    {
                        strTemp = [NSString stringWithFormat:@"0%@",strTemp];
                    }
                    
                    if (strTemp.length >= 4)
                    {
                        strTemp = [NSString stringWithFormat:@"%@:%@",[strTemp substringToIndex:2],[strTemp substringFromIndex:2]];
                    }
                    bookVo.strEndTime = strTemp;
                }
                
                [aryReserveList addObject:bookVo];
            }
            
            retInfo.data = aryReserveList;
        }
        resultBlock(retInfo);
    }];
}

@end
