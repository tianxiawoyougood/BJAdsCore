//
//  WKDatabaseManager.m
//  BJAdsSDK
//

#import "BJDatabaseManager.h"
#import <BJAdsCore/BJAdLog.h>
#import "BJAdsInfoModel.h"
#import "BJDataJsonManager.h"
#import "BJAES.h"
#import "BJEncryptionHelper.h"
#import "BJHelper.h"
#import "BJRequestURL.h"

#define LASTREQUESTTIMEKEY @"lastRequestTimeKey"
#define BJFrequencyModel   @"BJFrequencyModel"

@interface BJDatabaseManager ()

/// 数据源
@property(nonatomic, strong) NSArray *adsArray;
/// 所有广告数据 （展示 + 不展示）
@property(nonatomic, strong) NSMutableDictionary *allAdsData;
/// 展示广告数据 （展示）
@property(nonatomic, strong) NSMutableDictionary *showAdsData;

@end

@implementation BJDatabaseManager

static BJDatabaseManager *instance = nil;
static dispatch_once_t onceToken;
+ (nonnull BJDatabaseManager *)sharedInstance {
    dispatch_once(&onceToken, ^{
        instance = [[BJDatabaseManager alloc] init];
        [instance createPath:[instance getFilePath]];
    });
    return instance;
}

#pragma mark -- public
#pragma mark - 写入文件
// 写入本地文件
- (BOOL)writeDataToLocal:(NSDictionary *)data
                    type:(adsType)type
                  isShow:(BOOL)isShow {
    // 保存到本地
    BOOL jsonData = [self writeDataToLcal:data withPath:[self getFileNameWithType:type isShow:isShow]];
    
    // 同步更新到内存
    if(jsonData) {
        [self syncDataToMemory:data type:type isShow:isShow];
        return YES;
    }
    return NO;
}

/// 同步到本地
- (BOOL)writeDataToLcal:(NSDictionary *)data
               withPath:(NSString *)path {
    
    if(!data || data.count <= 0) {
        BJ_LEVEL_ERROR_LOG(@"data is empty and cannot be written");
        return nil;
    }
    
    if (path.length <= 0 || !path) {
        BJ_LEVEL_ERROR_LOG(@"path is empty and cannot be written");
        return nil;
    }

    //创建文件夹
    NSString *patientPhotoFolder = [self getFilePath];

    //储存文件名称+格式
    NSError * err = nil;
    NSString *savePath = [patientPhotoFolder stringByAppendingPathComponent:path];

    // 将数据加密后存储到本地
    NSString * key = [BJDataConversionUtils getCharactersEvenPositionsWithStr:[BJDatabaseManager sharedInstance].appID];
    NSString * md5 = [[BJEncryptionHelper getmd5Str:key]lowercaseString];
    NSString * jsonString = [BJDataConversionUtils jsonStringWithDictionary:data];
    
    if (jsonString.length <= 0 || !jsonString) {
        return NO;
    }
    
    NSString * tempJsonString = [BJAES MIUAESEncrypt:jsonString mode:MIUModeCBC key:md5 keySize:MIUKeySizeAES256 iv:md5 padding:MIUCryptorPKCS7Padding];
    
    BOOL state = [tempJsonString writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    return state;
}

/// 同步到内存
- (void)syncDataToMemory:(NSDictionary *)jsonData
                    type:(adsType)type
                  isShow:(BOOL)isShow {
    
    if(jsonData.count <= 0 || !jsonData) {
        return;
    }
//    NSString * key = self.configModel.debugMode ? @"debug" : @"release";
//    jsonData = [jsonData objectForKey:key];
    [isShow ? self.showAdsData : self.allAdsData setValue:jsonData forKey:[BJDataConversionUtils returnsStringBasedOnType:type]];
}

#pragma mark - 读取文件
// 读取本地data
- (id)readLocalDataWithAdsType:(adsType)adsType
                        isShow:(BOOL)isShow {
        
    NSDictionary * dataDict = nil;
    // 从内存获取
    dataDict = [self getDataSourceWithType:adsType isShow:isShow];
    if(dataDict.count > 0 && dataDict) {
        return dataDict;
    }

    // 从本地文件获取
    dataDict = [self getLocalFileWithType:adsType isShow:isShow];
    if(dataDict.count > 0 && dataDict) {
//        NSString * key = self.configModel.debugMode ? @"debug" : @"release";
//        dataDict = [dataDict objectForKey:key];
        return dataDict;
    }
    
    return dataDict;
}

/// 从内存中获取
- (NSDictionary *)getMemoryFileWithType:(adsType)adsType
                                 isShow:(BOOL)isShow {
    NSDictionary * dict = [self getDataSourceWithType:adsType isShow:isShow];
    if(dict.count > 0 && dict) {
        return dict;
    }
    return @{};
}

/// 从本地文件读取
- (NSDictionary *)getLocalFileWithType:(adsType)adsType
                                isShow:(BOOL)isShow {
    
    NSDictionary * tempData = [self readLocalDataWithPath:[self completeRoutePathWithType:adsType isShow:isShow]];
    if (tempData && tempData.count > 0) {
        [self syncDataToMemory:tempData type:adsType isShow:isShow];
    }
    return tempData;
}

// 从本地文件获取
- (NSDictionary *)readLocalDataWithPath:(NSString *)path {
    
    if (path.length <= 0 || !path) {
        return nil;
    }
    NSError * err = nil;
    NSString *contentString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (contentString <= 0 ||!contentString) {
        return @{};
    }
    
    // 解密 并返回字典给上层
    NSString * key = [BJDataConversionUtils getCharactersEvenPositionsWithStr:[BJDatabaseManager sharedInstance].appID];
    NSString * md5 = [[BJEncryptionHelper getmd5Str:key]lowercaseString];
    NSString * jsonStr = [BJAES MIUAESDecrypt:contentString mode:MIUModeCBC key:md5 keySize:MIUKeySizeAES256 iv:md5 padding:MIUCryptorPKCS7Padding];
    NSDictionary * dic = [BJDataConversionUtils dictionaryWithJsonString:jsonStr];
    
    return dic;
}

// 根据type 从内存中获取数据源
- (NSDictionary *)getDataSourceWithType:(adsType)type isShow:(BOOL)isShow{
    
    NSString * key = [BJDataConversionUtils returnsStringBasedOnType:type];
    if(key.length <= 0 || !key) {
        return @{};
    }
    return isShow ? self.showAdsData[key] : self.allAdsData[key];
}

#pragma mark - 记录
/// 根据类型获取模型
- (BJAdsInfoModel *)getAdsModelWithTag:(NSString *)tag
                           withAdsType:(adsType)adsType {
    
    NSData * data = [self getDataForKey:BJFrequencyModel];
    NSDictionary * frequencyModelDict = [NSDictionary dictionary];
    if(data) {
        frequencyModelDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    NSString * tempTag = [NSString stringWithFormat:@"%@_%@",tag,[BJDataConversionUtils returnsStringBasedOnType:adsType]];
    // 通过 tag + adsTyep 从本地取出 对应模型
    BJAdsInfoModel * model = [frequencyModelDict objectForKey:tempTag];
    return model;
}

/// 获取本地数据 suppliers 信息位
- (NSDictionary *)getSuppliersDictWithTag:(NSString *)tag
                              withAdsType:(adsType)adsType {
    
    NSDictionary * showDict = [self readLocalDataWithAdsType:adsType isShow:YES];
    NSArray * suppliers = [showDict objectForKey:@"suppliers"];
    
    NSMutableDictionary * mShowDict = [NSMutableDictionary dictionaryWithDictionary:showDict];
    NSMutableArray * mSuppliers = [NSMutableArray arrayWithArray:suppliers];
    
    __block NSDictionary * mSuppliersDict ;
    __block NSInteger count = 0;
    [suppliers enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([[obj objectForKey:@"tag"] isEqualToString:tag]) {
            count = idx;
            mSuppliersDict = [NSMutableDictionary dictionaryWithDictionary:obj];
            *stop = YES;
        }
    }];
    return mSuppliersDict;
}

/// 更新信息模型
- (void)updateAdsInfoModelWithModel:(BJAdsInfoModel *)model
                            withTag:(NSString *)tag
                        withAdsType:(adsType)adsType {
    
    
    NSData * data = [self getDataForKey:BJFrequencyModel];
    NSDictionary * frequencyModelDict = [NSDictionary dictionary];
    NSString * tempTag = [NSString stringWithFormat:@"%@_%@",tag,[BJDataConversionUtils returnsStringBasedOnType:adsType]];

    if(data) {
        frequencyModelDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    // 插入到本地
    NSMutableDictionary * mFrequencyModelDict = frequencyModelDict.mutableCopy;
    [mFrequencyModelDict setValue:model forKey:tempTag];
    
    NSData * tempData = [NSKeyedArchiver archivedDataWithRootObject:mFrequencyModelDict.copy];
    [self saveDataToUserDefaults:tempData key:BJFrequencyModel];
}

// 写入展现成功数据
- (void)recordAdWithAdsType:(adsType)adsType
                    withTag:(NSString *)tag {
    
    
    NSDictionary * mSuppliersDict = [self getSuppliersDictWithTag:tag withAdsType:adsType];
    BJAdsInfoModel * model = [self getAdsModelWithTag:tag withAdsType:adsType];
    
    if (!mSuppliersDict || mSuppliersDict.count <= 0) {
        return;
    }
  
    model.currShowCount += 1;
    model.lastDisplayedTime = [[NSDate date]timeIntervalSince1970];
    [self updateAdsInfoModelWithModel:model withTag:tag withAdsType:adsType];
}

// 获取是否可以展示广告
- (NSDictionary *)isShowAdWithAdsType:(adsType)adsType
                              withTag:(NSString *)tag {
    
    NSDictionary * mSuppliersDict = [self getSuppliersDictWithTag:tag withAdsType:adsType];
    BJAdsInfoModel * model = [self getAdsModelWithTag:tag withAdsType:adsType];

    if (!mSuppliersDict || mSuppliersDict.count <= 0) {
        return @{@"state":@(NO),@"event":@"1"};
    }
  
    long nowTime = [[NSDate date]timeIntervalSince1970];
    if(!model) {
        // 本地限制为空说明是第一次
        model = [[BJAdsInfoModel alloc]init];
        model.currShowCount = 0;
        model.lastDisplayedTime = nowTime;
        model.frequency = [[mSuppliersDict objectForKey:@"frequency"] integerValue];
        model.interval = [[mSuppliersDict objectForKey:@"interval"] integerValue];
        model.tag = tag;
        [self updateAdsInfoModelWithModel:model withTag:tag withAdsType:adsType];
        
        return @{@"state":@(YES),@"event":@"4"};
    }
    
    // 隔天 需要更新数据
    if (![BJHelper isSameDay:model.lastDisplayedTime withTime2:nowTime]) {
        model.currShowCount = 0;
        model.lastDisplayedTime = nowTime;
        // 写入回本地
        [self updateAdsInfoModelWithModel:model withTag:tag withAdsType:adsType];
        
        return @{@"state":@(YES),@"event":@"0"};
    }

    
    // 如果返回的时间间隔 或者 次数为负数 就认为直接不拦截
    if(model.interval < 0 || model.frequency < 0) {
        return @{@"state":@(YES),@"event":@"5"};
    }
    
    // 展示间隔限制
    if ((([[NSDate date]timeIntervalSince1970] - model.lastDisplayedTime) <= model.interval)) {
        return @{@"state":@(NO),@"event":@"2"};
    }
    
    // 次数限制
    if(model.frequency <= model.currShowCount) {
        return @{@"state":@(NO),@"event":@"3"};
    }
    
    return @{@"state":@(YES),@"event":@"0"};
}

/// 获取记录调用广告时间
- (NSInteger)getOpenAdTimeWithAdsType:(adsType)adsType withTag:(NSString *)tag {
    return [[self getDataForKey:[NSString stringWithFormat:@"%@-%@",[BJDataConversionUtils returnsStringBasedOnType:adsType],tag]] integerValue];
}


// 保存最后一次请求时间
- (void)saveLastRequestTimeWithAdsType:(adsType)adsType {
    NSString * key = [NSString stringWithFormat:@"%@_%@",LASTREQUESTTIMEKEY,[BJDataConversionUtils returnsStringBasedOnType:adsType]];
    [self saveDataToUserDefaults:@([[NSDate date] timeIntervalSince1970]) key:key];
}

// 获取最后一次请求时间
- (id)getLastRequestTimeWithAdsType:(adsType)adsType {
    return [self getDataForKey:[NSString stringWithFormat:@"%@_%@",LASTREQUESTTIMEKEY,[BJDataConversionUtils returnsStringBasedOnType:adsType]]];
}

#pragma mark - 判断
// 判断是否隔天
- (BOOL)isRequestAllowedWithAdsType:(adsType)adsType {

    // 是否隔天
    long lastTime = [[self getLastRequestTimeWithAdsType:adsType]longValue];
    long nowTime = [[NSDate date]timeIntervalSince1970];
    if (![BJHelper isSameDay:lastTime withTime2:nowTime]) {
        return YES;
    }
    return NO;
}

#pragma mark - 数据存取
/// 存 （NSUserDefaults）
- (void)saveDataToUserDefaults:(id)value key:(NSString *)key {
    if (!value || !key) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}
/// 取 （NSUserDefaults）
- (id)getDataForKey:(NSString *)key {
    if (!key) {
        return @"";
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

#pragma mark - private
#pragma mark - 路径相关
/// 获取文件路径
- (NSString *)getFilePath {
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [documentPath stringByAppendingPathComponent:@"BJ"];
    return path;
}

// 获取文件名
- (NSString *)getFileNameWithType:(adsType)type isShow:(BOOL)isShow {
    
    NSString *suffix = isShow ? @"_f" : @"";
    NSString *fileName = [BJDataConversionUtils returnsStringBasedOnType:type];
    
    if (fileName.length <= 0 || !fileName) {
        return @"";
    }
    return [fileName stringByAppendingFormat:@"%@_config",suffix];
}

// 完整保存路径
- (NSString *)completeRoutePathWithType:(adsType)type isShow:(BOOL)isShow {
    NSString *path = [[self getFilePath] stringByAppendingPathComponent:[self getFileNameWithType:type isShow:isShow]];
    return path;
}

// 创建文件夹
- (BOOL)createPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        
        return [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    return YES;
}

#pragma mark - setter/getter
- (NSMutableDictionary *)allAdsData{
    if(!_allAdsData){
        _allAdsData = [NSMutableDictionary dictionary];
    }
    return _allAdsData;
}

- (NSMutableDictionary *)showAdsData{
    if(!_showAdsData){
        _showAdsData = [NSMutableDictionary dictionary];
    }
    return _showAdsData;
}

@end
