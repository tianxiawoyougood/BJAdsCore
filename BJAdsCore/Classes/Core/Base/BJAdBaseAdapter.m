//
//  BJAdBaseAdapter.m
//

#import "BJAdBaseAdapter.h"
#import "BJAdSupplierManager.h"
#import "BJAdSupplierDelegate.h"
#import <BJAdsCore/BJAdSdkConfig.h>

@interface BJAdBaseAdapter () <BJAdSupplierManagerDelegate, BJAdSupplierDelegate>

/// Supplier管理类
@property (nonatomic, strong) BJAdSupplierManager *mgr;
/// 代理
@property (nonatomic, weak) id<BJAdSupplierDelegate> baseDelegate;
/// 策略信息Json
@property (nonatomic, strong) NSDictionary *jsonDic;
/// 是否使用加载+展示模式
@property (nonatomic, assign) BOOL isLoadAndShow;
/// 使用的广告类型
@property(nonatomic, assign) adsType useAdsType;
@end

@implementation BJAdBaseAdapter

- (instancetype)initWithJsonDic:(NSDictionary *)jsonDic adsType:(adsType)adsType {
    
    if (!jsonDic || jsonDic.count <= 0) {
        BJ_LEVEL_ERROR_LOG(@"%@",[BJAdError errorWithCode:BJAdErrorCode_2014].toNSError);
        return nil;
    }
    
    if (self = [super init]) {
        _jsonDic = jsonDic;
        _useAdsType = adsType;
    }
    return self;
}

- (void)loadAd {
    if([self uploadLog:1]) {
        return;
    }
    _isLoadAndShow = NO;
    [self.mgr loadDataWithJsonDic:_jsonDic adsType:_useAdsType];
}

- (void)loadAndShowAd {
    if([self uploadLog:2]) {
        return;
    }
    _isLoadAndShow = YES;
    [self.mgr loadDataWithJsonDic:_jsonDic adsType:_useAdsType];
}

- (void)showAd {
    if([self uploadLog:3]) {
        return;
    }
}

/// 控制器是否为空
- (BOOL)uploadLog:(int)isLoad {
    NSString * str = @"调用";
    
    if(isLoad == 2) {
        str = @"调用和展示";
    }
    
    if(isLoad == 3) {
        str = @"展示";
    }
    
    NSString * adsStr = [BJDataConversionUtils returnsStringBasedOnTypev2:_useAdsType];
    [BJAdsService reportStateEvent_state:str withEvent_type:adsStr];

    if(!self.viewController) {
        [BJAdsService reportStateEvent_state:@"视图为空" withEvent_type:adsStr];
        BJ_LEVEL_ERROR_LOG(@"view is empty");
        if([_baseDelegate respondsToSelector:@selector(ad_AdBaseAdapterLoadError:)]) {
            [_baseDelegate ad_AdBaseAdapterLoadError:[BJAdError errorWithCode:BJAdErrorCode_2011].toNSError];
        }
        return YES;
    }
    return NO;
}

- (void)loadNextSupplierIfHas {
    [_mgr loadNextSupplierIfHas];
}

- (void)reportWithType:(BJAdSdkSupplierRepoType)repoType supplier:(BJAdSupplier *)supplier error:(NSError *)error {
    // 1.这里可以进行根据自身需求添加BJAdSdkSupplierRepoType 记录广告的生命周期并添加到每个adapter里
    // 2.关于广告的生命周期相关的操作都可以在这里进行, 比如成功失败 点击的上报
    
    // 失败了 并且不是并行才会走下一个渠道
    if (repoType == BJAdSdkSupplierRepoTypeLoadFail || repoType == BJAdSdkSupplierRepoTypeShowFail) {
        // 搜集各渠道的错误信息
        [self collectErrorWithSupplier:supplier error:error];
        // 执行下一个渠道
        [_mgr loadNextSupplierIfHas];
    } else if (repoType == BJAdSdkSupplierRepoTypeLoadSuccess) {
        if ([_baseDelegate respondsToSelector:@selector(ad_AdBaseAdapterLoadAndShow)] && _isLoadAndShow) {
            [_baseDelegate ad_AdBaseAdapterLoadAndShow];
        }
    }
}

- (void)collectErrorWithSupplier:(BJAdSupplier *)supplier error:(NSError *)error {
    // key: 渠道名-index
    if (error) {
        NSString *key = [NSString stringWithFormat:@"%@-%@",supplier.tag, supplier.index];
        [self.errorDescriptions setObject:error forKey:key];
    }
}

- (void)deallocAdapter {
    self.mgr = nil;
    self.baseDelegate = nil;
}

#pragma mark - BJAdSupplierManagerDelegate
/// 加载策略Model成功
- (void)ad_supplierManagerLoadSuccess:(BJAdSupplierModel *)model {
    if ([_baseDelegate respondsToSelector:@selector(ad_AdBaseAdapterLoadSuccess:)]) {
        [_baseDelegate ad_AdBaseAdapterLoadSuccess:model];
    }
}

/// 加载策略Model失败
- (void)ad_supplierManagerLoadError:(NSError *)error {
    if ([_baseDelegate respondsToSelector:@selector(ad_AdBaseAdapterLoadError:)]) {
        [_baseDelegate ad_AdBaseAdapterLoadError:error];
    }
}

- (void)ad_supplierManagerLoadSortTag:(NSString *)tag {
    if ([_baseDelegate respondsToSelector:@selector(ad_AdBaseAdapterLoadSortTag:)]) {
        [_baseDelegate ad_AdBaseAdapterLoadSortTag:tag];
    }
}

/// 返回下一个渠道的参数
- (void)ad_supplierLoadSuppluer:(nullable BJAdSupplier *)supplier error:(nullable NSError *)error {

    // 初始化渠道参数
    NSString *clsName = @"";
    if ([supplier.tag isEqualToString:SDK_TAG_GDT]) {
        clsName = @"GDTSDKConfig";
    } else if ([supplier.tag isEqualToString:SDK_TAG_CSJ]) {
        clsName = @"BUAdSDKManager";
    } else if ([supplier.tag isEqualToString:SDK_TAG_KS]) {
        clsName = @"KSAdSDKManager";
    } else if ([supplier.tag isEqualToString:SDK_TAG_BAIDU]){
        clsName = @"BaiduMobAdSetting";
    } else if ([supplier.tag isEqualToString:SDK_TAG_GG]){
        clsName = @"GADMobileAds";
    } else if([supplier.tag isEqualToString:SDK_TAG_IS]) {
        clsName = @"IronSource";
    } else if([supplier.tag isEqualToString:SDK_TAG_FB]){
        clsName = @"FBAdInitManager";
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

    if ([supplier.tag isEqualToString:SDK_TAG_GDT]) {
        // 优量汇SDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(registerAppId:) withObject:supplier.appId];
        });
    } else if ([supplier.tag isEqualToString:SDK_TAG_CSJ]) {
        // 穿山甲SDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(setAppID:) withObject:supplier.appId];
        });
    } else if ([supplier.tag isEqualToString:SDK_TAG_KS]) {
        // 快手
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(setAppId:) withObject:supplier.appId];
        });

    } else if ([supplier.tag isEqualToString:SDK_TAG_BAIDU]) {
        // 百度
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id bdSetting = ((id(*)(id,SEL))objc_msgSend)(NSClassFromString(clsName), @selector(sharedInstance));
            [bdSetting performSelector:@selector(setSupportHttps:) withObject:nil];
        });
    } else if ([supplier.tag isEqualToString:SDK_TAG_GG]){
        // 谷歌
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id ggSetting = ((id(*)(id,SEL))objc_msgSend)(NSClassFromString(clsName), @selector(sharedInstance));
            [ggSetting performSelector:@selector(startWithCompletionHandler:) withObject:nil];
        });
    } else if ([supplier.tag isEqualToString:SDK_TAG_IS]) {
        // ironsource
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(initWithAppKey:) withObject:supplier.appId];
        });
    } else if([supplier.tag isEqualToString:SDK_TAG_FB]) {
        // FB
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(initializeWithSettings:) withObject:supplier.appId];
        });
    }

#pragma clang diagnostic pop

    // 加载渠道
    if ([_baseDelegate respondsToSelector:@selector(ad_AdBaseAdapterLoadSuppluer:error:)]) {
        [_baseDelegate ad_AdBaseAdapterLoadSuppluer:supplier error:error];
    }
}

- (void)setSDKVersion {
    [self setGdtSDKVersion];
    [self setCsjSDKVersion];
    [self setMerSDKVersion];
    [self setKsSDKVersion];
    [self setGGSDKVersion];
}

- (void)setGGSDKVersion {
//    id cls = NSClassFromString(@"GDTSDKConfig");
//    NSString *gdtVersion = [cls performSelector:@selector(sdkVersion)];
//
//    [self setSDKVersionForKey:@"gg_v" version:gdtVersion];
}

- (void)setGdtSDKVersion {
    id cls = NSClassFromString(@"GDTSDKConfig");
    NSString *gdtVersion = [cls performSelector:@selector(sdkVersion)];
    
    [self setSDKVersionForKey:@"gdt_v" version:gdtVersion];
}

- (void)setCsjSDKVersion {
    id cls = NSClassFromString(@"BUAdSDKManager");
    NSString *csjVersion = [cls performSelector:@selector(sdkVersion)];
    
    [self setSDKVersionForKey:@"csj_v" version:csjVersion];
}

- (void)setMerSDKVersion {
    id cls = NSClassFromString(@"MercuryConfigManager");
    NSString *merVersion = [cls performSelector:@selector(sdkVersion)];

    [self setSDKVersionForKey:@"mry_v" version:merVersion];
}

- (void)setKsSDKVersion {
    id cls = NSClassFromString(@"KSAdSDKManager");
    NSString *ksVersion = [cls performSelector:@selector(sdkVersion)];
    
    [self setSDKVersionForKey:@"ks_v" version:ksVersion];
}


- (void)setSDKVersionForKey:(NSString *)key
                    version:(NSString *)version {
    if (version) {
//        [_ext setValue:version forKey:key];
    }
}

- (NSString *)typeToStrWithType:(BJAdSdkSupplierRepoType)type {
    
    NSString * str = @"";
    switch (type) {
        case BJAdSdkSupplierRepoTypeLoadSuccess:
            /// 广告下载成功
            str = @"广告下载成功";
            break;
        case BJAdSdkSupplierRepoTypeLoadFail:
            /// 广告下载失败
            str = @"广告下载失败";
            break;
        case BJAdSdkSupplierRepoTypeShowSuccess:
            /// 广告展示成功
            str = @"广告展示成功";
            break;
        case BJAdSdkSupplierRepoTypeShowFail:
            /// 广告展示失败
            str = @"广告展示失败";
            break;
        case BJAdSdkSupplierRepoTypeClick:
            /// 广告点击
            str = @"广告点击";
            break;
        default:
            break;
    }
    return str;
}

#pragma mark - get
- (BJAdSupplierManager *)mgr {
    if (!_mgr) {
        _mgr = [BJAdSupplierManager manager];
        _mgr.delegate = self;
        _baseDelegate = self;
    }
    return _mgr;
}

- (NSMutableDictionary *)errorDescriptions {
    if (!_errorDescriptions) {
        _errorDescriptions = [NSMutableDictionary dictionary];
    }
    return _errorDescriptions;
}

@end
