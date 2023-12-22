//
//  BJDataJsonManager.m
//  BJAdsCore
//
//  Created by cc on 2022/10/9.
//

#import "BJDataJsonManager.h"
#import "BJAdSdkConfig.h"

@implementation BJDataJsonManager
static BJDataJsonManager *manager = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BJDataJsonManager alloc] init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
   static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(manager == nil) {
            manager = [super allocWithZone:zone];
        }
    });
    return manager;
}

//自定义初始化方法
- (instancetype)init {
    self = [super init];
    if(self) {

    }
    return self;
}

//覆盖该方法主要确保当用户通过copy方法产生对象时对象的唯一性
- (id)copy {
    return self;
}

//覆盖该方法主要确保当用户通过mutableCopy方法产生对象时对象的唯一性
- (id)mutableCopy {
    return self;
}

/* * * * * * * * * * * 方法 * * * * * * * * * * */
- (NSDictionary *)loadAdDataWithType:(adsType)type {
    NSString *jsonName = nil;
    
    switch (type) {
        case adsTypeSplash:
            jsonName = @"bj_splas";
            break;
        case adsTypeBanner:
            jsonName = @"bj_banner";
            break;
        case adsTypeInterstitial:
            jsonName = @"bj_interstitial";
            break;
        case adsTypeNative:
            jsonName = @"bj_native";
            break;
        case adsTypeRewardVideo:
            jsonName = @"bj_reward";
            break;
        default:
            break;
    }
    
    return [self loadAdDataWithJsonName:jsonName];
}

- (NSDictionary *)loadAdDataWithJsonName:(NSString *)jsonName {
    if (!jsonName) {
        return nil;
    }
    
    @try {
        NSString *path = [[NSBundle mainBundle] pathForResource:jsonName ofType:@"json"];
        if (path.length <= 0 || !path) {
            return @{};
        }
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

    } @catch (NSException *exception) {}
}


@end
