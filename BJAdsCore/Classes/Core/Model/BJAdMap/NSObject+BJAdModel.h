
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (BJAdModel)

+ (nullable instancetype)ad_modelWithJSON:(id)json;

+ (nullable instancetype)ad_modelWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)ad_dicWithObject:(id)object;
- (NSArray *)ad_arrayWithObject:(id)object;
- (NSDictionary *)ad_dicFromObject:(NSObject *)object;

- (BOOL)ad_modelSetWithJSON:(id)json;

- (BOOL)ad_modelSetWithDictionary:(NSDictionary *)dic;

- (nullable id)ad_modelToJSONObject;

- (nullable NSData *)ad_modelToJSONData;

- (nullable NSString *)ad_modelToJSONString;

- (nullable id)ad_modelCopy;

- (void)ad_modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)ad_modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)ad_modelHash;

- (BOOL)ad_modelIsEqual:(id)model;

- (NSString *)ad_modelDescription;

@end

@interface NSArray (BJAdModel)

+ (nullable NSArray *)ad_modelArrayWithClass:(Class)cls json:(id)json;

@end

@interface NSDictionary (BJAdModel)

+ (nullable NSDictionary *)ad_modelDictionaryWithClass:(Class)cls json:(id)json;
@end

@protocol BJAdModelDelegate <NSObject>
@optional

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
