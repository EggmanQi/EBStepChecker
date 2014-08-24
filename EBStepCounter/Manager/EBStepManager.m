//
//  EBStepManager.m
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBStepManager.h"
#import "EBDBManager+Action.h"
#import "EBStepManager+backgroundRunning.h"
#import "EBM7Manager.h"
#import "EBMotionManager.h"

@interface EBStepManager ()
{
    NSInteger        steps;
}

@property(nonatomic, strong)EBDBManager         *db;
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
        self.db = [EBDBManager sharedManager];
        self.m7 = [EBM7Manager sharedManager];
        self.motion = [EBMotionManager sharedManager];
        
        [self loadSavingData];

        [self startBGUpdate];
    }
    return self;
}



#pragma mark -
- (void)loadSavingData
{
    StepEntity *se = [[EBDBManager sharedManager] stepEntityByDate:[NSDate date]];
    steps = se.steps.integerValue;
}

- (void)saveSteps
{
    [self.db saveSteps:steps
                onDate:[NSDate date]];
}


#pragma mark -
- (void)startStepCounting:(EBStepUpdateHandler)handler
{
    if ([self.m7 isAvailable]) {
        [self.m7 startWithHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
           
            steps = steps + numberOfSteps;
            
            if (handler) {
                handler(steps, timestamp, error);
            }
        }];
    }else {
        [self.motion startWithHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            steps = steps + numberOfSteps;
            
            if (handler) {
                handler(steps, timestamp, error);
            }
        }];
    }
}




@end
