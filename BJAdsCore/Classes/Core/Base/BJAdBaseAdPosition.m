//
//  BJAdBaseAdPosition.m
//

#import "BJAdBaseAdPosition.h"

@interface BJAdBaseAdPosition ()

@property (nonatomic, strong) BJAdSupplier *supplier;
@end

@implementation BJAdBaseAdPosition

- (instancetype)initWithSupplier:(BJAdSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _supplier = supplier;
        self.banner_y = -999;
    }
    return self;
}
- (void)loadAd {
    if (!_supplier) {
        return;
    }
    [self supplierStateLoad];
}
- (void)supplierStateLoad {}
- (void)showAd {}
- (void)deallocAdapter {}



@end
