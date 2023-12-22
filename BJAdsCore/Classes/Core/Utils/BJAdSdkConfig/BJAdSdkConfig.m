//
//  BJAdSdkConfig.m
//

#import "BJAdSdkConfig.h"
#import "BJAdLog.h"
#import "BJAdsService.h"
#import <BJAdsCore/BJDatabaseManager.h>
#import <BJAdsCore/BJDataConversionUtils.h>
#import <BJAdsCore/BJDataJsonManager.h>
#import "BJHelper.h"
#import "BJRequestURL.h"
#import "BJAdError.h"


@implementation BJAdSdkConfig

#pragma mark - sdk版本信息
NSString *const AdvanceSdkVersion = @"1.9.1";

#pragma mark - 广告商tag名称
NSString *const SDK_TAG_GDT = @"ylh";
NSString *const SDK_TAG_CSJ = @"csj";
NSString *const SDK_TAG_KS = @"ks";
NSString *const SDK_TAG_BAIDU = @"bd";
NSString *const SDK_TAG_GG = @"gg";
NSString *const SDK_TAG_IS = @"is";
NSString *const SDK_TAG_FB = @"fb";

#pragma mark - 广告位类型名称
NSString * const BJAdSdkTypeAdName = @"ADNAME";
NSString * const BJAdSdkTypeAdNameSplash = @"SPLASH_AD";
NSString * const BJAdSdkTypeAdNameBanner = @"BANNER_AD";
NSString * const BJAdSdkTypeAdNameInterstitial = @"INTERSTAITIAL_AD";
NSString * const BJAdSdkTypeAdNameFullScreenVideo = @"FULLSCREENVIDEO_AD";
NSString * const BJAdSdkTypeAdNameNativeExpress = @"NATIVEEXPRESS_AD";
NSString * const BJAdSdkTypeAdNameRewardVideo = @"REWARDVIDEO_AD";

static BJAdSdkConfig *instance = nil ;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

//保证从-alloc-init和-new方法返回的对象是由shareInstance返回的
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [BJAdSdkConfig shareInstance];
}

//保证从copy获取的对象是由shareInstance返回的
- (id)copyWithZone:(struct _NSZone *)zone {
    return [BJAdSdkConfig shareInstance];
}

//保证从mutableCopy获取的对象是由shareInstance返回的
- (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [BJAdSdkConfig shareInstance];
}

#pragma mark - public
// 构造方法
- (void)registerAppID:(NSString *)appID
           withConfig:(BJConfigModel * __nullable)config {
    
    if (appID.length <= 0 || !appID) {
        BJ_LEVEL_ERROR_LOG(@"%@",[BJAdError errorWithCode:BJAdErrorCode_2000].toNSError);
        return;
    }
    
    if (!config) {
        config = [[BJConfigModel alloc]init];
    }
    
    config.appID = appID;
    [BJDatabaseManager sharedInstance].configModel = config;
    [BJDatabaseManager sharedInstance].appID = appID;
    
    [BJAdsService reportStateEvent_state:@"调用" withEvent_type:@"初始化"];
    [self updateConfigurationFile];
    [[BJDatabaseManager sharedInstance] saveDataToUserDefaults:appID key:kBJAPPID];
}

// 获取版本号
+ (NSString *)sdkVersion {
    return AdvanceSdkVersion;
}

+ (BOOL)isSimplifiedChinese {
    NSString *currentLanguageRegion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    if ([currentLanguageRegion isEqualToString:@"zh-Hans-CN"]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - private
///  更新配置文件
- (void)updateConfigurationFile {
    
    NSString * oldAppID = [[BJDatabaseManager sharedInstance] getDataForKey:kBJAPPID];
    NSString * newAppID = [BJDatabaseManager sharedInstance].appID;
    
    for (id type in [BJDataConversionUtils getAllAdsType]) {
        
        adsType adsType = [type intValue];
        
        /*
         本地配置文件
         
         判断条件：
         1.判断本地是否存在过滤文件,如果无过滤文件才需要获取本地文件
         2.appId 不一致
         
         实施：
         1.将本地文件写入到过滤文件中
         */

        if([self isUpdateDefaultFileWithNewAppId:newAppID
                                    withOldAppId:oldAppID
                                     withAdsType:adsType]) {


            NSString *configPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"bjads_info_%@",[BJDataConversionUtils returnsStringBasedOnType:adsType]] ofType:@"txt"];
            if (!configPath || configPath.length <= 0) {
                
            } else {
                NSDictionary * dict = [[BJDatabaseManager sharedInstance]readLocalDataWithPath:configPath];
                if(!dict || dict.count <= 0) {
                    BJ_LEVEL_ERROR_LOG(@"appid is error");
                } else {
                    [self writeFilterData:dict];
                }
            }
            
        }
      
        
        /*
         过滤文件
       
         判断条件：
         1.判断本地是否存在过滤文件,如果无过滤文件才需要获取本地文件
         2.appId 不一致
         3.一天一次
         
         执行：
         1.code = 200 且 有值
         2.覆盖过滤文件中release 字段内容
        
         */
        if([self isUpdateFilterFileWithNewAppId:newAppID
                                   withOldAppId:oldAppID
                                    withAdsType:adsType]) {

            [self downloadFilterFileWithAdsType:adsType withAPPID:newAppID];
        }
    }
}

/// 判断默认文件是否需要更新
/// 条件：隔天/更换APPID/本地不存在
- (BOOL)isUpdateDefaultFileWithNewAppId:(NSString *)newAPPID
                           withOldAppId:(NSString *)oldAPPID
                            withAdsType:(adsType)adsType {
    // 比较新旧appId 是否一致
    if(![newAPPID isEqualToString:oldAPPID]) {
        return YES;
    }
        
    // 本地是否存在
    NSString * path = [[BJDatabaseManager sharedInstance]completeRoutePathWithType:adsType isShow:YES];
    if(![BJHelper isPathExistWithPath:path]) {
        return YES;
    }
    
    return NO;
}

/// 判断过滤文件是否需要更新
/// 条件：更换APPID/本地不存在
- (BOOL)isUpdateFilterFileWithNewAppId:(NSString *)newAPPID
                          withOldAppId:(NSString *)oldAPPID
                           withAdsType:(adsType)adsType {
    // 比较新旧appId 是否一致
    if(![newAPPID isEqualToString:oldAPPID]) {
        return YES;
    }
    
    // 是否隔天
    if ([[BJDatabaseManager sharedInstance]isRequestAllowedWithAdsType:adsType]) {
        return YES;
    }
    
    return NO;
}

// 写入过滤数据
- (void)writeFilterData:(NSDictionary *)data {
    
    if (data.count <= 0 || !data) {
        return;
    }
    
    NSString * adsType = [data objectForKey:@"adsType"];
    [[BJDatabaseManager sharedInstance]writeDataToLocal:data type:[BJDataConversionUtils returnsTypeBasedOnString:adsType] isShow:YES];
}

#pragma mark - network
/// 下载过滤配置文件
- (void)downloadFilterFileWithAdsType:(adsType)adsType
                            withAPPID:(NSString *)appID {
    
    // 先取出对应过滤文件 替换 release
    NSString * path = [[BJDatabaseManager sharedInstance]completeRoutePathWithType:adsType isShow:YES];
    // 取出现在过滤文件 组装成新的过滤文件
    NSDictionary * tempDict = [[BJDatabaseManager sharedInstance]readLocalDataWithPath:path];
    BOOL is_cn = [[tempDict objectForKey:@"isCN"] boolValue];
    [BJDatabaseManager sharedInstance].configModel.isCN = is_cn;
    
    WeakSelf(weakSelf);
    [BJAdsService getAdsRouter:@{@"appId":appID,
                                 @"adsType":[BJDataConversionUtils returnsStringBasedOnType:adsType],
                                 @"sdkVer":AdvanceSdkVersion}
                  successBlock:^(NSDictionary * _Nullable resp) {
       
        NSString * tempAdsType = [resp objectForKey:@"adsType"];
        NSDictionary * dataDict = [resp objectForKey:@"dataDict"];
        enum adsType nAdsType = [BJDataConversionUtils returnsTypeBasedOnString:tempAdsType];
        // 记录请求的时间
        [[BJDatabaseManager sharedInstance]saveLastRequestTimeWithAdsType:nAdsType];

        // 写日志
        [weakSelf successLogWithType:nAdsType withResp:dataDict];
        
        if(dataDict.count <= 0) {
            // 如果没有数据就不操作了
            return;
        }
        
        // 先取出对应过滤文件 替换 release
//        NSString * tempPath = [[BJDatabaseManager sharedInstance]completeRoutePathWithType:[BJDataConversionUtils returnsTypeBasedOnString:tempAdsType]
//                                                                                    isShow:YES];
        // 取出现在过滤文件 组装成新的过滤文件
//        NSMutableDictionary * mDict = [[BJDatabaseManager sharedInstance]readLocalDataWithPath:tempPath].mutableCopy;
//        [mDict setValue:dataDict forKey:@"release"];
        [weakSelf writeFilterData:dataDict.copy];
        
    } fail:^(NSError * _Nullable error) {
        [self getOssFile:adsType];
        [weakSelf failureLogWithType:adsType];
        BJ_LEVEL_ERROR_LOG(@"get ads info fail = %@",error.description);
    }];
}

- (void)getOssFile: (adsType)adsType {
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",BaseURLOSS,[BJDatabaseManager sharedInstance].appID,[BJDataConversionUtils returnsStringBasedOnType:adsType]];
    NSString *savePath = [NSString stringWithFormat:@"%@/%@",[[BJDatabaseManager sharedInstance] getFilePath],[[BJDatabaseManager sharedInstance] getFileNameWithType:adsType isShow:YES]];
    
    [BJAdsService downloadOSSFileWithPath:path
                                 savePath:savePath
                             successBlock:^(NSDictionary * _Nullable resp) {
        BJ_LEVEL_INFO_LOG(@"get ads oss file success");
    }
                                     fail:^(NSError * _Nullable error) {
        BJ_LEVEL_ERROR_LOG(@"get ads oss file fail = %@",error.description);
    }];
}

#pragma mark - Log
// 成功Log
- (void)successLogWithType1:(adsType)type
                   withResp:(NSDictionary *)resp {
    
    NSString * adsStr = [BJDataConversionUtils returnsStringBasedOnTypev2:type];
    NSString * str = @"无数据";
    if (resp.count > 0) {
        str = @"成功";
    }
    [BJAdsService reportStateEvent_state:[NSString stringWithFormat:@"%@_%@",str,adsStr] withEvent_type:@"oss广告信息"];
}

/// 失败log
- (void)failureLogWithType1:(adsType)type {
    NSString * str = [NSString stringWithFormat:@"失败_%@",[BJDataConversionUtils returnsStringBasedOnTypev2:type]];
    [BJAdsService reportStateEvent_state:str withEvent_type:@"oss广告信息"];
}

// 成功Log
- (void)successLogWithType:(adsType)type
                  withResp:(NSDictionary *)resp {
    
    NSString * adsStr = [BJDataConversionUtils returnsStringBasedOnTypev2:type];
    NSString * str = @"无数据";
    if (resp.copy > 0) {
        str = @"成功";
    }
    [BJAdsService reportStateEvent_state:[NSString stringWithFormat:@"%@_%@",str,adsStr] withEvent_type:@"广告信息"];
}

/// 失败log
- (void)failureLogWithType:(adsType)type {
    NSString * str = [NSString stringWithFormat:@"失败_%@",[BJDataConversionUtils returnsStringBasedOnTypev2:type]];
    [BJAdsService reportStateEvent_state:str withEvent_type:@"广告信息"];
}

#pragma mark - set/get
- (void)setLevel:(BJAdLogLevel)level {
    _level = level;
}

@end
