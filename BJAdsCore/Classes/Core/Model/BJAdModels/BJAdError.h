//
//  BJAdError.h
//  

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 策略相关
typedef NS_ENUM(NSUInteger, BJAdErrorCode) {
    
    BJAdErrorCode_2000  =  2000,  // appID为空或者错误
    BJAdErrorCode_2001  =  2001,  // 广告信息请求失败
    BJAdErrorCode_2002  =  2002,  // 广告信息为空
    BJAdErrorCode_2003  =  2003,  // 广告信息解析失败
    BJAdErrorCode_2004  =  2004,  // 策略为空
    BJAdErrorCode_2005  =  2005,  // 策略 - 渠道排序为空
    BJAdErrorCode_2006  =  2006,  // 策略 - 执行渠道失败
    BJAdErrorCode_2007  =  2007,  // 渠道为空
    BJAdErrorCode_2008  =  2008,  // 请求超出设定总时长
    BJAdErrorCode_2009  =  2009,  // 展示超出最大限制
    BJAdErrorCode_2010  =  2010,  // 展示/加载 广告条件不足
    BJAdErrorCode_2011  =  2011,  // 视图控制器不存在
    BJAdErrorCode_2012  =  2012,  // 无广告返回
    BJAdErrorCode_2013  =  2013,  // 地区屏蔽
    BJAdErrorCode_2014  =  2014,  // 构建广告对象失败（广告数据为空）
    BJAdErrorCode_2015  =  2015,  // 展示间隔限制
    BJAdErrorCode_2016  =  2016,  // 其他错误
    BJAdErrorCode_2017  =  2017,  // 环境不匹配
};

@interface BJAdError : NSObject

+ (instancetype)errorWithCode:(BJAdErrorCode)code;
+ (instancetype)errorWithCode:(BJAdErrorCode)code obj:(nullable id)obj;
- (NSError *)toNSError;

@end

NS_ASSUME_NONNULL_END
