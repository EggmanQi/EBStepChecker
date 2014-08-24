//
//  EBStepManager+backgroundRunning.m
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/17.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <objc/runtime.h>
#import "EBStepManager+backgroundRunning.h"

@implementation EBStepManager (backgroundRunning)

- (void)startBGUpdate
{
    [self stopBGUpdate];
    [[self clManager] startUpdatingLocation];
    [[self clManager] startMonitoringSignificantLocationChanges];
}

- (void)stopBGUpdate
{
    [[self clManager] stopUpdatingLocation];
    [[self clManager] stopMonitoringSignificantLocationChanges];
}

#pragma mark -
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"*** 地理位置 更新ing");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"*** 地理位置 Error: %@",[error localizedDescription]);
}

#pragma mark - 
- (CLLocationManager *)clManager
{
    CLLocationManager *lm = (CLLocationManager *)objc_getAssociatedObject(self, @"地理位置管理");
    if (lm==nil) {
        lm = [[CLLocationManager alloc] init];
        lm.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        lm.distanceFilter = 5000;
        lm.activityType = CLActivityTypeFitness;
        lm.delegate = self;
        
        if ([lm respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
            lm.pausesLocationUpdatesAutomatically = NO;
        }
        
        if ([CLLocationManager deferredLocationUpdatesAvailable]) {
            [lm allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)5000 timeout:1000];
        }
        
        objc_setAssociatedObject(self, @"地理位置管理", lm, OBJC_ASSOCIATION_RETAIN);
    }
    
    return lm;
}

@end
