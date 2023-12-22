//
//  BJAdsService.h
//  BURelyFoundation
//
//  Created by cc on 2022/5/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^requestSuccessBlock)(NSDictionary * _Nullable resp);
typedef void(^requestFailBlcok)(NSError * _Nullable error);

@interface BJAdsService : NSObject

/// 获取广告规则
/// @param parame 入参
/// @param successBlock 成功回调
/// @param failBlock 失败回调
+ (void)getAdsRouter:(NSDictionary *)parame
        successBlock:(requestSuccessBlock)successBlock
                fail:(requestFailBlcok)failBlock;

/// 上报状态
/// event_state : 事件描述
/// event_type: 事件类型
+ (void)reportStateEvent_state:(NSString *)event_state
                withEvent_type:(NSString *)event_type;

/// 从oss拉取默认配置文件
/// path 下载路径
/// savePath 保存路径
/// @param successBlock 成功回调
/// @param failBlock 失败回调
+ (void)downloadOSSFileWithPath:(NSString *)path
                       savePath:(NSString *)savePath
                   successBlock:(requestSuccessBlock)successBlock
                           fail:(requestFailBlcok)failBlock;

@end

NS_ASSUME_NONNULL_END
