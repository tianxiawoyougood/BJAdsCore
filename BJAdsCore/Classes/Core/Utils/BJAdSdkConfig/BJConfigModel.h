//
//  BJConfigModel.h
//  BJAdsCore
//
//  Created by cc on 2022/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJConfigModel : NSObject

/// appID
@property(nonatomic, copy) NSString *appID;
/// 是否为调试模式
@property(nonatomic, assign) BOOL debugMode;
/// 是否为中国大陆地区
@property(nonatomic, assign) BOOL isCN;

@end

NS_ASSUME_NONNULL_END
