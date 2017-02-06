//
//  TichetServise.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TichetServise.h"
#import "ServerURL.h"
#import "DNENetworkFramework.h"
@implementation TichetServise


+ (void)uploadSound:(NSString *)fileName body:(NSDictionary *)bodyDic numberOfTimer:(NSInteger )timer  result:(ResultBlock)resultBlock
{

    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHssmm"];
    NSString *dateString = [formatter stringFromDate:date];
//    NSString *urlString = [[ServerURL setRecordImageURL] stringByAppendingString:[dateString stringByAppendingString:@".amr"]];
        NSString *urlString = [[[ServerURL setRecordImageURL] stringByAppendingString:[NSString stringWithFormat:@"?fn=%ld*duration%@.amr",(long)timer,dateString]] stringByAppendingString:@"&client_flag=ios"];

    VNetworkFramework *networkFrameworkFile = [[VNetworkFramework alloc]initWithURLString:urlString];
    [networkFrameworkFile uploadBatchFileToServer:@[fileName] parameter:bodyDic result:^(NSArray *aryResult, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            UploadFileVo *uploadFileVo = aryResult[0];
            retInfo.data = uploadFileVo;
            
        }
        
        resultBlock(retInfo);
    }];
   
}
+ (void)uploadImageToServer:(NSDictionary *)bodyDic imageData:(NSData *)imageData result:(ResultBlock)resultBlock{
   
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
  
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
    retInfo.bSuccess = NO;
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHssmm"];
    NSString *dateString = [formatter stringFromDate:date];
    NSString *urlString;
    
    
    urlString = [[[ServerURL setRecordImageURL] stringByAppendingString:[NSString stringWithFormat:@"?fn=%@.jpg",dateString]] stringByAppendingString:@"&client_flag=ios"];
        

    
    [DNENetworkFramework uploadPicWithUrl:urlString andParams:bodyDic andPicData:imageData result:^(id resultObj) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
       

        if ([resultObj isKindOfClass:[NSError class]])
        {
            //错误
            retInfo.strErrorMsg = ERROR_TO_SERVER;
            
        }
        else
        {
         
            retInfo.bSuccess = YES;
            //
        }
        resultBlock(retInfo);
             });
    }];
        
    });

}
+ (void)sendRequest:(NSDictionary *)bodyDicty urlString:(NSString *)urlString requestStyle:(NSString *)requestStyle result:(ResultBlock)resultBlock{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
    retInfo.bSuccess = NO;
    VNetworkFramework *networkFramework= [[VNetworkFramework alloc]initWithURLString:urlString];
    [networkFramework startRequestToServer:requestStyle parameter:bodyDicty result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
            
            retInfo.data = responseObject;
        }
        
        resultBlock(retInfo);

    }];

}
+ (void)sendRequest:(NSDictionary *)bodyDicty result:(ResultBlock)resultBlock{
    ServerReturnInfo *retInfo = [[ServerReturnInfo alloc] init];
    retInfo.bSuccess = NO;
    VNetworkFramework *networkFramework= [[VNetworkFramework alloc]initWithURLString:[ServerURL getQiangTicketList]];
    [networkFramework  startRequestToServer:@"POST" parameter:bodyDicty result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
           
            retInfo.data = responseObject;
        }
        
        resultBlock(retInfo);

    }];

}

@end
