//
//  EBM7Manager.m
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBM7Manager.h"

@interface EBM7Manager ()
{
    BOOL        scActive;
}

@property(nonatomic)CMStepCounter *stepCounter;

@end

@implementation EBM7Manager

#pragma mark - Status
- (BOOL)isAvailable
{
    return [CMStepCounter isStepCountingAvailable];
}

- (BOOL)isActive
{
    return scActive;
}

#pragma mark - Control
- (void)start
{
    scActive = YES;
}

- (void)pause
{
    scActive = NO;
    [self.stepCounter stopStepCountingUpdates];
}

- (void)stop
{
    scActive = NO;
    [self.stepCounter stopStepCountingUpdates];
}

- (void)restart
{
    scActive = YES;
}

- (void)startWithHandler:(EBStepUpdateHandler)handler
{
    scActive = YES;
    
    [self.stepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                             updateOn:1
                                          withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                              if (error) {
                                                  scActive = NO;
                                              }else {
                                                  scActive = YES;
                                              }
                                              if (handler) {
                                                  handler(numberOfSteps, timestamp, error);
                                              }
                                          }];
}

#pragma mark - Initialization
+ (EBM7Manager*)sharedManager
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    if (self=[super init]) {
        scActive = NO;
    }
    return self;
}

- (CMStepCounter*)stepCounter
{
    if (!_stepCounter) {
        _stepCounter = [[CMStepCounter alloc] init];
    }
    return _stepCounter;
}

@end
