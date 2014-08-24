//
//  EBStepManager+backgroundRunning.h
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/17.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBStepManager.h"

@interface EBStepManager (backgroundRunning) <CLLocationManagerDelegate>

- (void)startBGUpdate;
- (void)stopBGUpdate;

@end
