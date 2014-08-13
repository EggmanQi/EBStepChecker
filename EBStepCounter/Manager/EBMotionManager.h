//
//  EBMotionManager.h
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBMotionManager : NSObject

+ (EBMotionManager*)sharedManager;

- (BOOL)isAvailable;
- (BOOL)isActive;

- (void)startWithHandler:(EBStepUpdateHandler)handler;
- (void)pause;
- (void)stop;
- (void)restart;

//- (void)startWithHandler:(EBStepUpdateHandler)handler;

@end
