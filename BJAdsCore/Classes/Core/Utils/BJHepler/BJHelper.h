//
//  BJHelper.h
//  BJAdsCore
//
//  Created by cc on 2022/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJHelper : NSObject

/*
 比较两个时间是否同一天
 */
+ (BOOL)isSameDay:(long)time1 withTime2:(long)time2;

/*
 判断文件路径是否存在
 path:路径
 */
+ (BOOL)isPathExistWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
