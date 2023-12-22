//
//  BJAdSupplierManager.m
//  

#import "BJAdSupplierManager.h"
#import <BJAdsCore/BJAdSdkConfig.h>
#import <BJAdsCore/BJAdSupplierModel.h>
#import <BJAdsCore/BJAdError.h>
#import <BJAdsCore/BJAdLog.h>
#import <BJAdsCore/BJAdModel.h>
#import <BJAdsCore/NSObject+BJAdModel.h>

#define SWeakSelf(type) __weak typeof(type) weak##type = type;
#define SStrongSelf(type) __strong typeof(weak##type) strong##type = weak##type;

@interface BJAdSupplierManager ()

@property (nonatomic, strong) BJAdSupplierModel *model;
/// 可执行渠道
@property (nonatomic, strong) NSMutableArray<BJAdSupplier *> *supplierM;
/// setting
@property (nonatomic, strong) NSMutableArray *setting;
/// 排序
@property (nonatomic, copy) NSString *sortTag;
/// 当前执行广告类型
@property(nonatomic, assign) adsType useAdsType;

@end

@implementation BJAdSupplierManager

+ (instancetype)manager {
    BJAdSupplierManager *mgr = [BJAdSupplierManager new];
    return mgr;
}

- (void)loadDataWithJsonDic:(NSDictionary *)jsonDic adsType:(adsType)adsType{
    if (jsonDic.count <= 0 || !jsonDic) {
        // 广告配置为空
        BJAdError * error =[BJAdError errorWithCode:BJAdErrorCode_2002];
        BJ_LEVEL_ERROR_LOG(@"%@",error.toNSError);
        if ([_delegate respondsToSelector:@selector(ad_supplierManagerLoadError:)]) {
            [_delegate ad_supplierManagerLoadError:error.toNSError];
        }
        return;
    }
    _model = [BJAdSupplierModel ad_modelWithDictionary:jsonDic];
    _useAdsType = adsType;
    
    if (!_model) {
        BJAdError * error = [BJAdError errorWithCode:BJAdErrorCode_2003];
        BJ_LEVEL_ERROR_LOG(@"%@",error.toNSError);
        // 回调外界加载配置文件失败
        if ([_delegate respondsToSelector:@selector(ad_supplierManagerLoadError:)]) {
            [_delegate ad_supplierManagerLoadError:error.toNSError];
        }
        return;
    }

    // 回调外界加载配置文件成功
    if ([_delegate respondsToSelector:@selector(ad_supplierManagerLoadSuccess:)]) {
        [_delegate ad_supplierManagerLoadSuccess:_model];
    }
    
    _supplierM = [_model.suppliers mutableCopy];
    [self sortSupplierMByPercent];
}

- (void)loadNextSupplierIfHas {
    // 执行渠道逻辑
    [self loadNextSupplier];
}

// 计算排序
- (void)loadNextSupplier {
    
    NSNumber *idx = _setting.firstObject;
    BJAdSupplier *currentSupplier;
    for (BJAdSupplier *supplier in _supplierM) {
        
        if(![BJAdSdkConfig isSimplifiedChinese]) {
            if ([supplier.tag isEqualToString:SDK_TAG_GG]) {
                currentSupplier = supplier;
                break;
            }
        } else {
            if (supplier.index == idx) {
                currentSupplier = supplier;
                break;
            }
        }
    }

    [self notCPTLoadNextSuppluer:currentSupplier index:idx];
}

/// 执行下个渠道
- (void)notCPTLoadNextSuppluer:(nullable BJAdSupplier *)supplier index:(NSNumber *)idx {
    // 选择渠道执行都失败
    if (_setting.count <= 0) {
        // 抛异常
        if ([_delegate respondsToSelector:@selector(ad_supplierLoadSuppluer:error:)]) {
            [_delegate ad_supplierLoadSuppluer:nil error:[BJAdError errorWithCode:BJAdErrorCode_2006].toNSError];
        }
        return;
    }
    
    @try {
        [_setting removeObjectAtIndex:0];
    } @catch (NSException *exception) {BJ_LEVEL_ERROR_LOG(@"exception: %@", exception);}
    
    if ([_delegate respondsToSelector:@selector(ad_supplierLoadSuppluer:error:)]) {
        [_delegate ad_supplierLoadSuppluer:supplier error:nil];
    }
}

#pragma mark - Private
/// 加载规则
- (void)sortSupplierMByPercent {
    if (_model.rules.count <= 0 || !_model.rules) {
        BJ_LEVEL_ERROR_LOG(@"%@",[BJAdError errorWithCode:BJAdErrorCode_2005].toNSError);
        if ([_delegate respondsToSelector:@selector(ad_supplierLoadSuppluer:error:)]) {
            [_delegate ad_supplierLoadSuppluer:nil error:[BJAdError errorWithCode:BJAdErrorCode_2005].toNSError];
        }
        return;
    }
    [self doPercent];
}

/// 计算权重
- (void)doPercent {

    __block NSInteger percentSum = 0;
    __block CGFloat currentPercentSum = 0;
    NSMutableArray *temp = [_model.rules mutableCopy];
    
    // 对所有percent 求和
    [temp enumerateObjectsUsingBlock:^(BJAdSetting *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        percentSum += obj.percent;
    }];
    
    // 生成 0 - 100 之间随机数(0% - 100%)
    NSInteger result = [self getRandomNumber:0 to:10000];
    
    // 计算各组百分比 并且和随机数比较 当随机数落到该组的概率范围内 则选取该组的顺序
    SWeakSelf(self);
    [temp enumerateObjectsUsingBlock:^(BJAdSetting *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SStrongSelf(self);
        
        CGFloat currentObjPercent = ((CGFloat)obj.percent / (CGFloat)percentSum) * 10000;
        
        currentPercentSum += currentObjPercent;
        if (currentPercentSum > result) {
            // 逆序 是为了后续代码方便
            _setting = [obj.sort mutableCopy];
            _sortTag = obj.tag;

            // 选中策略回调 选中tag
            if ([_delegate respondsToSelector:@selector(ad_supplierManagerLoadSortTag:)]) {
                [_delegate ad_supplierManagerLoadSortTag:_sortTag];
            }
            // 计算tag 中sort 排序
            [strongself loadNextSupplier];
            *stop = YES;
        }
    }];
}

/// 获取随机数
- (NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to {
    return (NSInteger)(from + (arc4random() % (to - from + 1)));
}

- (void)sortSupplierMByIndex {
    if (_supplierM.count > 1) {
        [_supplierM sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            BJAdSupplier *obj11 = obj1;
            BJAdSupplier *obj22 = obj2;
            if (obj11.index > obj22.index) {
                return NSOrderedDescending;
            } else if (obj11.index == obj22.index) {
                return NSOrderedSame;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
}

- (void)dealloc {
    BJ_LEVEL_INFO_LOG(@"Ad SupplierManager dealloc");
    self.model = nil;
}
@end
