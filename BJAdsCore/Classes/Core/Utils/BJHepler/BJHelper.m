//
//  BJHelper.m
//  BJAdsCore
//
//  Created by cc on 2022/12/5.
//

#import "BJHelper.h"

@implementation BJHelper

/// 是否同一天
+ (BOOL)isSameDay:(long)time1 withTime2:(long)time2 {
    
    //传入时间毫秒数
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:time1];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:time2];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:pDate2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

/// 路径文件是否存在
+ (BOOL)isPathExistWithPath:(NSString *)path {
    
    if(path.length <= 0 || !path) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

@end
