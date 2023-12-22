//
//  BJDataJsonManager.h
//  BJAdsCore
//
//  Created by cc on 2022/10/9.
//

#import <Foundation/Foundation.h>
#import "BJAdSdkConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJDataJsonManager : NSObject

+ (instancetype)shared;
- (NSDictionary *)loadAdDataWithType:(adsType)type;

@end

NS_ASSUME_NONNULL_END
