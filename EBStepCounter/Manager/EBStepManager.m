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
@property(nonatomic, strong)NSTimer             *timer;
@property(nonatomic, strong)EBStepUpdateHandler handler;

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
        self.motion = [EBMotionManager sharedManager];
        self.m7 = [EBM7Manager sharedManager];
        
        if ( ! [self.m7 isAvailable]) {
            [self startBGUpdate];
        }
        
        [self loadSavingData];
        
        [self startDayTimer];
    }
    return self;
}

#pragma mark -
- (void)startDayTimer
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
                                  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                        fromDate:[NSDate date]];
    
    [comps setHour:23]; //+24表示获取下一天的date，-24表示获取前一天的date；
    [comps setMinute:59];
    [comps setSecond:59];
    NSDate *future = [calendar dateFromComponents:comps];
    
    NSTimeInterval ti = [future timeIntervalSinceNow];
    // . find 夸日时间
    _timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                              target:self
                                            selector:@selector(handleNextDay)
                                            userInfo:nil
                                             repeats:NO];
}

- (void)handleNextDay
{
    [self stopStepCounting];
    [self saveOldDay];
    [self performSelector:@selector(creatNewDay)
               withObject:nil
               afterDelay:5];
}

- (void)saveOldDay
{
    [self saveSteps];
}

- (void)creatNewDay
{
    steps = 0;
    [self saveSteps];
    [self startDayTimer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"重新计步" object:nil];
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
    _handler = handler;
    
    if ([self.m7 isAvailable]) {
        [self.m7 startWithHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
           
            steps = steps + numberOfSteps;
            
            if (_handler) {
                _handler(steps, timestamp, error);
            }
        }];
    }else {
        [self.motion startWithHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            steps = steps + numberOfSteps;
            
            if (_handler) {
                _handler(steps, timestamp, error);
            }
        }];
    }
}

- (void)stopStepCounting
{
    if ([self.m7 isAvailable]) {
        [self.m7 stop];
    }else {
        [self.motion stop];
    }
}



@end
