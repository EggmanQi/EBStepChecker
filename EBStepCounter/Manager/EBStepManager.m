//
//  EBStepManager.m
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBStepManager.h"

#import "EBM7Manager.h"
#import "EBMotionManager.h"

@interface EBStepManager ()
{
    NSInteger        steps;
}

@property(nonatomic, strong)EBM7Manager         *m7;
@property(nonatomic, strong)EBMotionManager     *motion;

@end

@implementation EBStepManager

+ (EBStepManager *)sharedManager
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id) init
{
    if ( (self = [super init]) ) {
        self.m7 = [EBM7Manager sharedManager];
        self.motion = [EBMotionManager sharedManager];
    }
    return self;
}

- (void)startStepCounting:(EBStepUpdateHandler)handler
{
    if ([self.m7 isAvailable]) {
        [self.m7 startWithHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            if (handler) {
                handler(numberOfSteps, timestamp, error);
            }
        }];
    }else {
        [self.motion startWithHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
//            steps = steps + numberOfSteps;
//            printf("%s\n", [[@(steps) stringValue] UTF8String]);
            
            if (handler) {
                handler(numberOfSteps, timestamp, error);
            }
        }];
    }
}



@end
