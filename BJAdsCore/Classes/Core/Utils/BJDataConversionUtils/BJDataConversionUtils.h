//
//  BJDataConversionUtils.h
//  BURelyFoundation
//
//  Created by cc on 2022/5/11.
//

#import <Foundation/Foundation.h>
#import <BJAdsCore/BJAdSdkConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJDataConversionUtils : NSObject

/// 根据类型返回字符
/// @param type 传入的广告类型
/// @return 类型对应字符串
+ (NSString *)returnsStringBasedOnType:(adsType)type;

/// 根据类型返回字符
/// @param type 传入的广告类型
/// @return 类型对应字符串
+ (NSString *)returnsStringBasedOnTypev2:(adsType)type;

/// 根据字符返回类型
/// @param string 传入的key值
/// @return 对应广告类型
+ (adsType)returnsTypeBasedOnString:(NSString *)string;

/// 获取所支持的所有广告类型
+ (NSArray *)getAllAdsType;

// 获取配置广告展现间隔
+ (NSInteger)getIntervalWithAdsType:(adsType)adsType
                            withTag:(NSString *)tag;
// 获取配置广告展现最大次数
+ (NSInteger)getShowMaxCountWithAdsType:(adsType)adsType
                                withTag:(NSString *)tag;

//返回16位大小写字母和数字
+ (NSString *)return16LetterAndNumber;
// 返回唯一标识 会本地存储 卸载后重新生成
+ (NSString *)getDeviceID;

/// json字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/// 截取偶数位字符
+ (NSString *)getCharactersEvenPositionsWithStr:(NSString *)str;
/// 字典转json字符串
+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dict;
/**
 获取url的所有参数

 @param url 需要提取参数的url
 @return NSDictionary
 */
+ (NSDictionary *)parameterWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
