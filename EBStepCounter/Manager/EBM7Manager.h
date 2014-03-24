//
//  EBM7Manager.h
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerCommon.h"

@interface EBM7Manager : NSObject

+ (EBM7Manager*)sharedManager;

- (BOOL)isAvailable;
- (BOOL)isActive;

- (void)start;
- (void)pause;
- (void)stop;
- (void)restart;

- (void)startWithHandler:(EBStepUpdateHandler)handler;

@end
