//
//  EBStepManager.h
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBStepManager : NSObject

+ (EBStepManager *)sharedManager;

- (void)startStepCounting:(EBStepUpdateHandler)handler;
- (void)stopStepCounting;
- (void)saveSteps;

@end
