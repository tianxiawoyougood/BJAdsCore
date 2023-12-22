//
//  BJAdSdkConfig.h
//  

#import <Foundation/Foundation.h>
#import <BJAdsCore/BJConfigModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,BJAdLogLevel) {
    BJAdLogLevel_None  = 0, // 不打印
    BJAdLogLevel_Fatal,
    BJAdLogLevel_Error,
    BJAdLogLevel_Warning,
    BJAdLogLevel_Info,
    BJAdLogLevel_Debug,
};

// 广告类型
typedef NS_ENUM(NSInteger, adsType){
    adsTypeSplash = 1,                // 开屏广告
    adsTypeBanner ,                   // 横幅广告
    adsTypeInterstitial ,             // 插页式广告
    adsTypeRewardedInterstitialVideo, // 插页式激励视频广告
    adsTypeNative ,                   // 原生广告
    adsTypeRewardVideo ,              // 激励视频广告
    adsTypeInformationFlow,           // 信息流
    adsTypeNativeBanner,              // 原生横幅广告
};

#pragma mark - SDK
extern NSString *const AdvanceSdkVersion;

extern NSString *const SDK_TAG_GDT;
extern NSString *const SDK_TAG_CSJ;
extern NSString *const SDK_TAG_KS;
extern NSString *const SDK_TAG_BAIDU;
extern NSString *const SDK_TAG_GG;
extern NSString *const SDK_TAG_IS;
extern NSString *const SDK_TAG_FB;


extern NSString *const BJAdSdkTypeAdName;
extern NSString *const BJAdSdkTypeAdNameSplash;
extern NSString *const BJAdSdkTypeAdNameBanner;
extern NSString *const BJAdSdkTypeAdNameInterstitial;
extern NSString *const BJAdSdkTypeAdNameFullScreenVideo;
extern NSString *const BJAdSdkTypeAdNameNativeExpress;
extern NSString *const BJAdSdkTypeAdNameRewardVideo;

/// 屏幕宽高
#define kScreenWith      [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight    [[UIScreen mainScreen] bounds].size.height
#define WeakSelf(weakSelf)  __weak __typeof(self) weakSelf = self;
// Tabbar safe bottom margin.
#define  K_TabbarSafeBottomMarginBJ       (kIsSafeArea ? 34.f : 0.f)
#define k_Height_TabBar (kIsSafeArea ? 83.0 : 49.0)
#define k_Height_NavBar (kIsSafeArea ? 88.0 : 64.0)

// 带有安全区域
#define kIsSafeArea (\
{\
BOOL isPhoneX = NO;\
isPhoneX = [UIApplication sharedApplication].getCurrentWindow.safeAreaInsets.bottom > 0.0;\
(isPhoneX);}\
)
@interface BJAdSdkConfig : NSObject

+ (instancetype)shareInstance;

/// 初始化SDK add 20221021
/// appID: 应用ID
/// @parame config 配置model
- (void)registerAppID:(NSString *)appID
           withConfig:(BJConfigModel * __nullable)config;

/// 获取SDK版本
+ (NSString *)sdkVersion;

/*
 判断是否是简体中文
 */
+ (BOOL)isSimplifiedChinese;

/// 控制台log级别
/// 0 不打印
/// 1 打印fatal
/// 2 fatal + error
/// 3 fatal + error + warning
/// 4 fatal + error + warning + info
/// 5 全部打印
@property (nonatomic, assign) BJAdLogLevel level;

@end

NS_ASSUME_NONNULL_END
