//
//  BJAdSupplierModel.h
//

#import <Foundation/Foundation.h>

@class BJAdSupplierModel;
@class BJAdSetting;
@class BJAdSupplier;
typedef NS_ENUM(NSUInteger, BJAdSdkSupplierRepoType) {
   
    /// 广告下载成功
    BJAdSdkSupplierRepoTypeLoadSuccess,
    /// 广告下载失败
    BJAdSdkSupplierRepoTypeLoadFail,
    /// 广告展示成功
    BJAdSdkSupplierRepoTypeShowSuccess,
    /// 广告展示失败
    BJAdSdkSupplierRepoTypeShowFail,
    /// 广告点击
    BJAdSdkSupplierRepoTypeClick,
};

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BJAdSupplierModel : NSObject
@property (nonatomic, strong) NSMutableArray<BJAdSetting *> *rules;
@property (nonatomic, strong) NSMutableArray<BJAdSupplier *> *suppliers;
@property (nonatomic, copy)   NSString *sortTag;

@end

@interface BJAdSetting : NSObject
@property (nonatomic, strong) NSMutableArray<NSNumber *> *sort;
@property (nonatomic, assign) NSInteger percent;
@property (nonatomic, copy)   NSString *tag;

@end

@interface BJAdSupplier : NSObject
@property (nonatomic, copy)   NSString *appId;
@property (nonatomic, copy)   NSString *adspotId;
@property (nonatomic, copy)   NSString *tag;
@property (nonatomic, strong)   NSNumber *index;

@end

NS_ASSUME_NONNULL_END
