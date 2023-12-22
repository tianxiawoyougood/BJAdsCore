//
//  BJAdLog.h
//

#import <Foundation/Foundation.h>

#if __has_include(<BJAdsCore/BJAdSdkConfig.h>)
#import <BJAdsCore/BJAdSdkConfig.h>
#else
#import "BJAdSdkConfig.h"
#endif

#define BJ_LEVEL_FATAL_LOG(format,...)  [BJAdLog customLogWithFormatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:BJAdLogLevel_Fatal]
#define BJ_LEVEL_ERROR_LOG(format,...)  [BJAdLog customLogWithFormatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:BJAdLogLevel_Error]
#define BJ_LEVEL_WARING_LOG(format,...)  [BJAdLog customLogWithFormatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:BJAdLogLevel_Warning]
#define BJ_LEVEL_INFO_LOG(format,...)  [BJAdLog customLogWithFormatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:BJAdLogLevel_Info]
#define BJ_LEVEL_DEBUG_LOG(format,...)  [BJAdLog customLogWithFormatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:BJAdLogLevel_Debug]

#define BJAdLog(format,...)  [BJAdLog customLogWithFormatString:[NSString stringWithFormat:format, ##__VA_ARGS__]]
#define BJAdLogJSONData(data)  [BJAdLog logJsonData:data]

NS_ASSUME_NONNULL_BEGIN


@interface BJAdLog : NSObject

/// 日志输出方法
/// @param formatString 内容
/// @param level  日志等级
+ (void)customLogWithFormatString:(NSString *)formatString
                            level:(BJAdLogLevel)level;

/// 日志输出方法
/// @param formatString 内容
+ (void)customLogWithFormatString:(NSString *)formatString;

/// 记录data类型数据
/// @param data 数据
+ (void)logJsonData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
