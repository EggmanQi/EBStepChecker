//
//  EBDBManager+Fetch.h
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/15.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBDBManager.h"
#import "StepEntity.h"

@interface EBDBManager (Action)

#pragma mark -
- (StepEntity *)stepEntityByDate:(NSDate *)date;

#pragma mark -
- (void)saveSteps:(int)steps onDate:(NSDate *)date;

@end
