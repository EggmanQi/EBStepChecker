//
//  NSString+dateTranser.h
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/17.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (dateTranser)

+ (NSString *)strFromDate:(NSDate *)date
            withFormatter:(NSString *)formatter;

@end
