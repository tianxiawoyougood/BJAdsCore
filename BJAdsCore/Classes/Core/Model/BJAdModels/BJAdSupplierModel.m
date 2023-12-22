//
//  BJAdSupplierModel.m
//  

#import "BJAdSupplierModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJAdSupplierModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"suppliers" : [BJAdSupplier class],
             @"rules" : [BJAdSetting class]
    };
}
@end

@implementation BJAdSetting
@end

@implementation BJAdSupplier
@end

NS_ASSUME_NONNULL_END
