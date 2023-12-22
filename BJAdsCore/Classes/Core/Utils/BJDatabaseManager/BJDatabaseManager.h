//
//  WKDatabaseManager.h
//  BJAdsSDK
//
//  Created by cc on 2022/4/24.
//

#import <Foundation/Foundation.h>
#import <BJAdsCore/BJAdSdkConfig.h>
#import <BJAdsCore/BJDataConversionUtils.h>
#import <BJAdsCore/BJConfigModel.h>

NS_ASSUME_NONNULL_BEGIN

#define kIsShieldAds @"isShieldAds"
#define kBJAPPID @"BJAPPID"
#define kBJ_ISDEBUG @"BJ_ISDEBUG"


@interface BJDatabaseManager : NSObject

+ (nonnull BJDatabaseManager *)sharedInstance;
/// 是否需要上报日志
@property(nonatomic, assign) BOOL isUpdateState;
/// 是否屏蔽广告展示
@property(nonatomic, assign) BOOL isShieldAds;
/// BJConfigModel
@property(nonatomic, strong) BJConfigModel *configModel;
/// appID
@property(nonatomic, strong) NSString *appID;


- (NSDictionary *)readLocalDataWithPath:(NSString *)path;

#pragma mark - 本地存取
/// 存 （NSUserDefaults）
- (void)saveDataToUserDefaults:(id)value
                           key:(NSString *)key;
/// 取 （NSUserDefaults）
- (id)getDataForKey:(NSString *)key;

#pragma mark - 广告数据读取
/// 写入广告数据
- (BOOL)writeDataToLocal:(NSDictionary *)data
                    type:(adsType)type
                  isShow:(BOOL)isShow;
/// 读取广告数据
- (id)readLocalDataWithAdsType:(adsType)adsType
                         isShow:(BOOL)isShow;


#pragma mark - 接口数据读取
// 保存最后一次请求时间
- (void)saveLastRequestTimeWithAdsType:(adsType)adsType;
// 获取最后一次请求时间
- (id)getLastRequestTimeWithAdsType:(adsType)adsType;

#pragma mark - 接口判断
/// 是否隔天
- (BOOL)isRequestAllowedWithAdsType:(adsType)adsType;


#pragma mark - 展现限制
/// 获取是否可以展示广告
- (NSDictionary *)isShowAdWithAdsType:(adsType)adsType
                    withTag:(NSString *)tag;
/// 写入展现成功数据
- (void)recordAdWithAdsType:(adsType)adsType
                    withTag:(NSString *)tag;


/// 获取保存路径
/// type 广告类型
/// isShow 是否过滤文件
- (NSString *)completeRoutePathWithType:(adsType)type
                                 isShow:(BOOL)isShow;


- (NSString *)getFilePath;

- (NSString *)getFileNameWithType:(adsType)type isShow:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
