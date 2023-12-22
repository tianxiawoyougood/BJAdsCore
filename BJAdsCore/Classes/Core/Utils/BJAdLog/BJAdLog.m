//
//  BJAdLog.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "BJAdLog.h"
#import <BJAdsCore/BJAdSdkConfig.h>
#import <CommonCrypto/CommonDigest.h>

NSString *const LOG_LEVEL_NONE_SCHEME   = @"0";
NSString *const LOG_LEVEL_FATAL_SCHEME  = @"ad_LEVE_FATAL";
NSString *const LOG_LEVEL_ERROR_SCHEME  = @"ad_LEVEL_ERROR";
NSString *const LOG_LEVEL_WARING_SCHEME = @"ad_LEVE_WARNING";
NSString *const LOG_LEVEL_INFO_SCHEME   = @"ad_LEVE_INFO";
NSString *const LOG_LEVEL_DEBUG_SCHEME  = @"ad_LEVE_DEBUG";

@interface NSString (MD5)

- (NSString *)md5;

@end

@implementation NSString (MD5)

- (NSString *)md5 {
    const char* character = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(character, (CC_LONG)strlen(character), result);
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x",result[i]];
    }
    return md5String;
}
@end

@implementation BJAdLog

+ (void)customLogWithFormatString:(NSString *)formatString {}

+ (void)customLogWithFormatString:(NSString *)formatString
                            level:(BJAdLogLevel)level {

    NSString *scheme = [self convertLogTypeToStringWithLevel:level];
    if (level <= [BJAdSdkConfig shareInstance].level) {
        [self customLogWithLogString:formatString
                              scheme:scheme];
    }
}

+ (void)customLogWithLogString:(NSString *)formatString
                        scheme:(NSString *)scheme {

    formatString = [formatString stringByRemovingPercentEncoding];
    
    if ([formatString containsString:@"[JSON]"]) {
        formatString = [formatString stringByReplacingOccurrencesOfString:@" " withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    NSLog(@" - [BJAds SDK] %@", formatString);
}

+ (void)logJsonData:(NSData *)data {
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *md5 = [[res description] md5];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:md5];
    BJ_LEVEL_INFO_LOG(@"%@", res);
}


#pragma mark - private

/// 日志类型转换成字符串
/// @param level 日志等级
+ (NSString *)convertLogTypeToStringWithLevel:(BJAdLogLevel)level {
    
    NSString *scheme = @"";
    switch (level) {
        case 1:{
            scheme = LOG_LEVEL_FATAL_SCHEME;
        }
            break;
        case 2: {
            scheme = LOG_LEVEL_ERROR_SCHEME;
        }
            break;
        case 3: {
            scheme = LOG_LEVEL_WARING_SCHEME;
        }
            break;
        case 4: {
            scheme = LOG_LEVEL_INFO_SCHEME;
        }
            break;
        case 5: {
            scheme = LOG_LEVEL_DEBUG_SCHEME;
        }
            break;
        default:
            break;
    }
    return scheme;
}

@end
