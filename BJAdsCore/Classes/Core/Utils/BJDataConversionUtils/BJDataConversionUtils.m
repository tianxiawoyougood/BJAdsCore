//
//  BJDataConversionUtils.m
//  BURelyFoundation
//
//  Created by cc on 2022/5/11.
//

#import "BJDataConversionUtils.h"
#import "BJDatabaseManager.h"
#import "BJConfigModel.h"

@implementation BJDataConversionUtils

// 根据类型返回字符
+ (NSString *)returnsStringBasedOnType:(adsType)type {
    switch (type) {
        case adsTypeSplash:{
            // 开屏
            return @"adsTypeSplash";
        }
        case adsTypeBanner:{
            // 横幅
            return @"adsTypeBanner";
        }
        case adsTypeInterstitial:{
            // 插屏
            return @"adsTypeInterstitial";
        }
        case adsTypeNative:{
            // 原生
            return @"adsTypeNative";
        }
        case adsTypeRewardVideo:{
            // 激励视频广告
            return @"adsTypeRewardVideo";
        }
        case adsTypeRewardedInterstitialVideo: {
            // 插页式激励视频广告
            return @"adsTypeRewardedInterstitialVideo";
        }
        case adsTypeInformationFlow: {
            // 信息流
            return @"adsTypeInformationFlow";
        }
        case adsTypeNativeBanner: {
            // 原生横幅
            return @"adsTypeNativeBanner";
        }
        default:
            NSLog(@"没有找到相应的广告类型");
            break;
    }
    return @"";
}

// 根据类型返回字符
+ (NSString *)returnsStringBasedOnTypev2:(adsType)type {
    switch (type) {
        case adsTypeSplash:{
            // 开屏
            return @"开屏广告";
        }
        case adsTypeBanner:{
            // 横幅
            return @"横幅广告";
        }
        case adsTypeInterstitial:{
            // 插屏
            return @"插屏广告";
        }
        case adsTypeNative:{
            // 原生
            return @"原生广告";
        }
        case adsTypeRewardVideo:{
            // 激励视频广告
            return @"激励视频广告";
        }
        case adsTypeRewardedInterstitialVideo: {
            // 插页式激励视频广告
            return @"插页式激励视频广告";
        }
        case adsTypeInformationFlow: {
            // 信息流
            return @"信息流广告";
        }
        case adsTypeNativeBanner: {
            // 原生横幅
            return @"原生横幅广告";
        }
        default:
            NSLog(@"没有找到相应的广告类型");
            break;
    }
    return @"";
}

// 根据字符返回类型
+ (adsType)returnsTypeBasedOnString:(NSString *)string {
    
    if ([string isEqualToString:@"adsTypeSplash"]) {
        return adsTypeSplash;
    }
    if ([string isEqualToString:@"adsTypeBanner"]) {
        return adsTypeBanner;
    }
    if ([string isEqualToString:@"adsTypeRewardedInterstitialVideo"]) {
        return adsTypeRewardedInterstitialVideo;
    }
    if ([string isEqualToString:@"adsTypeInterstitial"]) {
        return adsTypeInterstitial;
    }
    if ([string isEqualToString:@"adsTypeNative"]) {
        return adsTypeNative;
    }
    if ([string isEqualToString:@"adsTypeRewardVideo"]) {
        return adsTypeRewardVideo;
    }
    if ([string isEqualToString:@"adsTypeInformationFlow"]) {
        return adsTypeInformationFlow;
    }
    if ([string isEqualToString:@"adsTypeNativeBanner"]) {
        return adsTypeNativeBanner;
    }
    return 0;
}

/// 获取所支持的所有广告类型
+ (NSArray *)getAllAdsType {
    return @[
        @(adsTypeSplash),
        @(adsTypeBanner),
        @(adsTypeInterstitial),
        @(adsTypeNative),
        @(adsTypeRewardVideo),
//        @(adsTypeRewardedInterstitialVideo),
//        @(adsTypeInformationFlow),
//        @(adsTypeNativeBanner)
    ];
}

// 获取配置广告展现间隔
+ (NSInteger)getIntervalWithAdsType:(adsType)adsType
                            withTag:(NSString *)tag {
//    switch (adsType) {
//        case adsTypeSplash:{
//            return @"adsTypeSplash";
//        }
//        case adsTypeBanner:{
//            return @"adsTypeBanner";
//        }
//        case adsTypeInterstitial:{
//            return @"adsTypeInterstitial";
//        }
//        case adsTypeNative:{
//            return @"adsTypeNative";
//        }
//        case adsTypeRewardVideo:{
//            return @"adsTypeRewardVideo";
//        }
//        case adsTypeRewardedInterstitialVideo: {
//            return @"adsTypeRewardedInterstitialVideo";
//        }
//        case adsTypeInformationFlow: {
//            return @"adsTypeInformationFlow";
//        }
//        case adsTypeNativeBanner: {
//            return @"adsTypeNativeBanner";
//        }
//        default:
//            NSLog(@"没有找到相应的广告类型");
//            break;
//    }
    return 50;
}
// 获取配置广告展现最大次数
+ (NSInteger)getShowMaxCountWithAdsType:(adsType)adsType
                                withTag:(NSString *)tag {
    return 3;
}



//返回16位大小写字母和数字
+ (NSString *)return16LetterAndNumber {
    //定义一个包含数字，大小写字母的字符串
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    //定义一个结果
    NSString * result = [[NSMutableString alloc]initWithCapacity:16];
    for (int i = 0; i < 16; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    
    return [NSString stringWithFormat:@"%@%ld",result, (long)([[NSDate date] timeIntervalSince1970] * 1000)];
}

+ (NSString *)getDeviceID {
    
    NSString * deviceID =[[BJDatabaseManager sharedInstance]getDataForKey:@"BJDeviceID"];
    if (deviceID.length > 0) {
        return deviceID;
    }
    deviceID = [self return16LetterAndNumber];
    [[BJDatabaseManager sharedInstance]saveDataToUserDefaults:deviceID key:@"BJDeviceID"];
    return deviceID;
}

// 截取偶数位字符
+ (NSString *)getCharactersEvenPositionsWithStr:(NSString *)str {
    if (str.length <= 0) {
        return @"";
    }
    
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableString * mStr = [NSMutableString string];
    for (int i = 0; i < str.length; i ++) {
        if ((i + 1) % 2 == 0) {
            NSString * temp = [str substringWithRange: NSMakeRange(i, 1)];
            if (![temp containsString:@" "]) {
                [mStr appendString:temp];
                if(mStr.length == 6) {
                    break;
                }
            }
        }
    }
    return mStr;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
     return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSString *log = [NSString stringWithFormat:@"%d, %s | json解析失败：%@", __LINE__, __func__, err];
        NSLog(log);
        return nil;
    }
    return dic;
}

+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dict {
    if(dict.count <= 0 || !dict) {
        return @"";
    }
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/**
 获取url的所有参数

 @param url 需要提取参数的url
 @return NSDictionary
 */
+ (NSDictionary *)parameterWithURL:(NSURL *)url {

    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];

    //传入url创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];

    //回调遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];

    return parm;
}

@end
