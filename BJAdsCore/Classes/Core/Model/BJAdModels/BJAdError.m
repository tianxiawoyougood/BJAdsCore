//
//  BJAdError.m
//  

#import "BJAdError.h"
#import "BJAdsService.h"

@interface BJAdError ()
@property (nonatomic, assign) BJAdErrorCode code;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) id obj;

@end

@implementation BJAdError

+ (instancetype)errorWithCode:(BJAdErrorCode)code {
    return [self errorWithCode:code obj:@""];
}

+ (instancetype)errorWithCode:(BJAdErrorCode)code obj:(nullable id)obj {
    BJAdError *advErr = [[BJAdError alloc] init];
    advErr.code = code;
    advErr.desc = [BJAdError errorCodeDescMap:code];
    advErr.obj = obj;
    [BJAdsService reportStateEvent_state:advErr.desc withEvent_type:@"com.bjads.error"];
    return advErr;
}

- (NSError *)toNSError {
    if (self.obj == nil) { self.obj = @""; }
    if (self.desc == nil) { self.desc = @""; }
    NSError *error = [NSError errorWithDomain:@"com.bjads.error" code:self.code userInfo:@{
        @"desc": self.desc,
        @"obj": self.obj,
    }];
    return error;
}

// 广告配置（ads info）  渠道(suppliers info)   策略（rules info） 渠道排序（suppliers sorts）
+ (NSString *)errorCodeDescMap:(BJAdErrorCode)code {
    NSDictionary *codeMap = @{
        
        @(BJAdErrorCode_2000) : @"appID is empty",                                   // 广告信息请求失败
        @(BJAdErrorCode_2001) : @"Ad Info request failed",                           // 广告信息请求失败
        @(BJAdErrorCode_2002) : @"Ad Info is empty",                                 // 广告信息为空
        @(BJAdErrorCode_2003) : @"Ad Info parsing failed",                           // 广告信息解析失败
        @(BJAdErrorCode_2004) : @"Rules Info is empty",                              // 策略为空
        @(BJAdErrorCode_2005) : @"Suppliers sorts Info is empty",                    // 策略 - 渠道排序为空
        @(BJAdErrorCode_2006) : @"All channels execution failed",                    // 策略 - 执行渠道失败
        @(BJAdErrorCode_2007) : @"Suppliers is empty",                               // 渠道为空
        @(BJAdErrorCode_2008) : @"The request exceeds the set total time",           // 请求超出设定总时长
        @(BJAdErrorCode_2009) : @"Exceeded maximum impression limit",                // 超出最大展示次数限制
        @(BJAdErrorCode_2010) : @"The prerequisites to load/display ads are not met",// 展示/加载 广告条件不足
        @(BJAdErrorCode_2011) : @"view controller does not exist",                   // 视图控制器不存在
        @(BJAdErrorCode_2012) : @"no ads",                                           // 无广告返回
        @(BJAdErrorCode_2013) : @"Block display ads",                                // 屏蔽展示广告
        @(BJAdErrorCode_2014) : @"Failed to build ad object",                        // 构建广告对象失败（广告数据为空）
        @(BJAdErrorCode_2015) : @"Ad display interval limit",                        // 广告展示间隔限制
        @(BJAdErrorCode_2016) : @"Other error",                                      // 其他错误
        @(BJAdErrorCode_2017) : @"environment mismatch",                             // 环境不匹配
    };
    
    return [codeMap objectForKey:@(code)];
}

@end
