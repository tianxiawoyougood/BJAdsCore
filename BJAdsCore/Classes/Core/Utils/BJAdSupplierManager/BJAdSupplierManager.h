//
//  BJAdSupplierManager.h
//

#import <Foundation/Foundation.h>
#import <BJAdsCore/BJAdSupplierModel.h>
#import <BJAdsCore/BJDatabaseManager.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJAdSupplierManagerDelegate <NSObject>

#pragma mark - 策略回调
/// 加载策略Model成功
/// @param model 策略模型
- (void)ad_supplierManagerLoadSuccess:(BJAdSupplierModel *)model;
/// 加载策略Model失败
/// @param error 错误信息
- (void)ad_supplierManagerLoadError:(NSError *)error;
/// 返回下一个渠道的参数
/// @param supplier 配置模型
/// @param error 错误信息
- (void)ad_supplierLoadSuppluer:(nullable BJAdSupplier *)supplier error:(nullable NSError *)error;
/// 被选中的选择的sort标志
/// @param tag 选中tag
- (void)ad_supplierManagerLoadSortTag:(NSString *)tag;

@end

@interface BJAdSupplierManager : NSObject

/// 代理
@property (nonatomic, weak) id<BJAdSupplierManagerDelegate> delegate;
/// 数据管理对象
+ (instancetype)manager;
/// 加载配置文件
- (void)loadDataWithJsonDic:(NSDictionary *)jsonDic adsType:(adsType)adsType;
/// 加载下个渠道
- (void)loadNextSupplierIfHas;

@end

NS_ASSUME_NONNULL_END
