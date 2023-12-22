//
//  BJAdsService.m
//  BURelyFoundation
//
//  Created by cc on 2022/5/4.
//

#import "BJAdsService.h"
#import "BJNetwork.h"
#import "BJRequestURL.h"
#import <BJAdsCore/BJDatabaseManager.h>
#import "BJAES.h"
#import "BJEncryptionHelper.h"

@implementation BJAdsService

/// 获取广告规则
/// @param parame 入参
/// @param successBlock 成功回调
/// @param failBlock 失败回调
+ (void)getAdsRouter:(NSDictionary *)parame
        successBlock:(requestSuccessBlock)successBlock
                fail:(requestFailBlcok)failBlock {
    
    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * mainUrl = [BJDatabaseManager sharedInstance].configModel.isCN ? BaseURL : BaseURLOS;
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?appId=%@&adsType=%@&sdkVer=%@&appVer=%@",mainUrl,URL_ADS_RULE,parame[@"appId"],parame[@"adsType"],parame[@"sdkVer"],app_Version]];
    [[BJNetwork new] getURL:url headers:@{} queue:dispatch_queue_create(0, 0) usingBackgroundSession:YES completionHandler:^(NSHTTPURLResponse * _Nullable response, NSDictionary * _Nullable data, NSError * _Nullable error) {
        
        if (error) {
            failBlock ? failBlock(error) : nil;
            return;
        }
        
        if(!data) {
            failBlock ? failBlock([NSError errorWithDomain:@"com.bjads.error" code:-201 userInfo:@{@"error":@"data is nil"}]) : nil;
            return;
        }
        
        NSDictionary * parameDict = [BJDataConversionUtils parameterWithURL:response.URL];
        NSString * p_adsType = [parameDict objectForKey:@"adsType"];
        NSInteger code = [[data objectForKey:@"code"] intValue];
        
        NSString * dataStr = [data objectForKey:@"data"];
        NSDictionary * dic = @{};
        
        NSString * shieldAdsKey = [NSString stringWithFormat:@"%@_%@",kIsShieldAds,p_adsType];
        [[BJDatabaseManager sharedInstance] saveDataToUserDefaults:@(0) key:shieldAdsKey];

        if(dataStr.length > 0 && code == 200) {
            
            NSString * key = [BJDataConversionUtils getCharactersEvenPositionsWithStr:[BJDatabaseManager sharedInstance].appID];
            NSString * md5 = [[BJEncryptionHelper getmd5Str:key]lowercaseString];
            NSString * jsonStr = [BJAES MIUAESDecrypt:[data objectForKey:@"data"] mode:MIUModeCBC key:md5 keySize:MIUKeySizeAES256 iv:md5 padding:MIUCryptorPKCS7Padding];
            dic = [BJDataConversionUtils dictionaryWithJsonString:jsonStr];
        }else if (code == 10045) {
            [[BJDatabaseManager sharedInstance] saveDataToUserDefaults:@(1) key:shieldAdsKey];
        }

        successBlock ? successBlock(@{@"adsType":p_adsType,@"dataDict":dic}) : nil;
    }];
}

/// 上报状态
+ (void)reportStateEvent_state:(NSString *)event_state
                withEvent_type:(NSString *)event_type {
        
//    NSLog(@"日志：event_type = %@ , event_state = %@",event_type,event_state);
    // 当状态为 NO 时上报状态
    // 取反目的： isUpdateState 属性默认为NO  为了第一次 能进入 所以全部按反规则判断
    if ([BJDatabaseManager sharedInstance].isUpdateState) {
        return;
    }
    
    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:[BJDataConversionUtils getDeviceID] forKey:@"device_code"];
    [dict setValue:@((NSInteger)[[NSDate date] timeIntervalSince1970] * 1000) forKey:@"report_time"];
    [dict setValue:[NSString stringWithFormat:@"%@_%@",event_type,event_state] forKey:@"event_state"];
    [dict setValue:event_type forKey:@"event_type"];
    [dict setValue:[BJDatabaseManager sharedInstance].appID forKey:@"app_id"];
    [dict setValue:@"iOS" forKey:@"client_system"];
    [dict setValue:app_Version forKey:@"app_version"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict.copy options:NSJSONWritingPrettyPrinted error:nil];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURLAlert,URL_ADS_REPORTSTATE]];
    [[BJNetwork new]postURL:url payload:data queue:dispatch_queue_create(0, 0) usingBackgroundSession:YES completionHandler:^(NSHTTPURLResponse * _Nullable response, NSDictionary * _Nullable data, NSError * _Nullable error) {
        if(error) {
            return;
        }
        if ([data[@"code"] intValue] == 200) {
            // "data": 服务器 ： 0 表示未开启上报  1 表示开启上报
            // 取反目的： isUpdateState 属性默认为NO  为了第一次能进入所以全部按反规则判断
            [BJDatabaseManager sharedInstance].isUpdateState = ![data[@"data"] boolValue];
        }
    }];
}

/// 从oss拉取默认配置文件
/// path 下载路径
/// @param successBlock 成功回调
/// @param failBlock 失败回调
+ (void)downloadOSSFileWithPath:(NSString *)path
                       savePath:(NSString *)savePath
                   successBlock:(requestSuccessBlock)successBlock
                           fail:(requestFailBlcok)failBlock {
    
    [[BJNetwork new]downloadFileWihtPath:path savePath:savePath usingBackgroundSession:YES completionHandler:^(NSHTTPURLResponse * _Nullable response, NSDictionary * _Nullable data, NSError * _Nullable error) {
        if (error) {
            failBlock ? failBlock(error) : nil;
            return;
        }
        successBlock ? successBlock(data) : nil;
    }];
}


@end

