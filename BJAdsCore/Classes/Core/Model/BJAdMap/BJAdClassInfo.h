
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, BJAdEncodingType) {
    BJAdEncodingTypeMask       = 0xFF, ///< mask of type value
    BJAdEncodingTypeUnknown    = 0, ///< unknown
    BJAdEncodingTypeVoid       = 1, ///< void
    BJAdEncodingTypeBool       = 2, ///< bool
    BJAdEncodingTypeInt8       = 3, ///< char / BOOL
    BJAdEncodingTypeUInt8      = 4, ///< unsigned char
    BJAdEncodingTypeInt16      = 5, ///< short
    BJAdEncodingTypeUInt16     = 6, ///< unsigned short
    BJAdEncodingTypeInt32      = 7, ///< int
    BJAdEncodingTypeUInt32     = 8, ///< unsigned int
    BJAdEncodingTypeInt64      = 9, ///< long long
    BJAdEncodingTypeUInt64     = 10, ///< unsigned long long
    BJAdEncodingTypeFloat      = 11, ///< float
    BJAdEncodingTypeDouble     = 12, ///< double
    BJAdEncodingTypeLongDouble = 13, ///< long double
    BJAdEncodingTypeObject     = 14, ///< id
    BJAdEncodingTypeClass      = 15, ///< Class
    BJAdEncodingTypeSEL        = 16, ///< SEL
    BJAdEncodingTypeBlock      = 17, ///< block
    BJAdEncodingTypePointer    = 18, ///< void*
    BJAdEncodingTypeStruct     = 19, ///< struct
    BJAdEncodingTypeUnion      = 20, ///< union
    BJAdEncodingTypeCString    = 21, ///< char*
    BJAdEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    BJAdEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    BJAdEncodingTypeQualifierConst  = 1 << 8,  ///< const
    BJAdEncodingTypeQualifierIn     = 1 << 9,  ///< in
    BJAdEncodingTypeQualifierInout  = 1 << 10, ///< inout
    BJAdEncodingTypeQualifierOut    = 1 << 11, ///< out
    BJAdEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    BJAdEncodingTypeQualifierByref  = 1 << 13, ///< byref
    BJAdEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    BJAdEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    BJAdEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    BJAdEncodingTypePropertyCopy         = 1 << 17, ///< copy
    BJAdEncodingTypePropertyRetain       = 1 << 18, ///< retain
    BJAdEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    BJAdEncodingTypePropertyWeak         = 1 << 20, ///< weak
    BJAdEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    BJAdEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    BJAdEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

BJAdEncodingType BJAdEncodingGetType(const char *typeEncoding);

@interface BJAdClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) BJAdEncodingType type;    ///< Ivar's type

- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 Method information.
 */
@interface BJAdClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type
- (instancetype)initWithMethod:(Method)method;
@end


/**
 Property information.
 */
@interface BJAdClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) BJAdEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

- (instancetype)initWithProperty:(objc_property_t)property;
@end


/**
 Class information for a class.
 */
@interface BJAdClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) BJAdClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, BJAdClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, BJAdClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, BJAdClassPropertyInfo *> *propertyInfos; ///< properties
- (void)setNeedUpdate;

- (BOOL)needUpdate;

+ (nullable instancetype)classInfoWithClass:(Class)cls;

+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
