//
//  NSString+dateTranser.m
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/17.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "NSString+dateTranser.h"

@implementation NSString (dateTranser)

+ (NSString *)strFromDate:(NSDate *)date
            withFormatter:(NSString *)formatter
{
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    fm.dateFormat = formatter;
    NSString *returnStr = [fm stringFromDate:date];
    fm = nil;
    return returnStr;
}

@end
