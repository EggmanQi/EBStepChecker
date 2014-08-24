//
//  EBDBManager+Fetch.m
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/15.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBDBManager+Action.h"
#import "NSString+dateTranser.h"

@implementation EBDBManager (Action)

#pragma mark -
- (StepEntity *)stepEntityByDate:(NSDate *)date
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"StepEntity"];
    
    NSString *dateStr = [NSString strFromDate:date withFormatter:@"yyyyMMdd"];
    NSPredicate *predict = [NSPredicate predicateWithFormat:@" date==%@ ", dateStr];
    [request setPredicate:predict];
    
    NSArray *array = [[self getContext] executeFetchRequest:request error:nil];
    
    //    NSLog(@"＊＊＊ fetchByDate:%@ 查询：%@", searchDayStr, array);
    
    if (array.count==1) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark -
- (void)saveSteps:(int)steps
           onDate:(NSDate *)date
{
    StepEntity *se = [self stepEntityByDate:date];
    if ( ! se) {
        [self addStep:steps
               onDate:date];
    }else {
        [se setValue:@(steps)
                  forKey:@"steps"];
        [self saveContext];
    }
}

#pragma mark -
- (void)addStep:(int)steps
         onDate:(NSDate *)date
{
    StepEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"StepEntity"
                                                       inManagedObjectContext:[self getContext]];
    [entity setValue:@(steps)
              forKey:@"steps"];
    [entity setValue:[NSString strFromDate:date withFormatter:@"yyyyMMdd"]
              forKey:@"date"];
    
    [self saveContext];
}

@end
