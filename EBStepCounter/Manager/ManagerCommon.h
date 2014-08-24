//
//  ManagerCommon.h
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#ifndef EBStepCounter_ManagerCommon_h
#define EBStepCounter_ManagerCommon_h

#define TEST_MODE       1

typedef void (^EBStepUpdateHandler)(NSInteger numberOfSteps, NSDate *timestamp, NSError *error);

typedef struct{
    float x;
    float y;
    float z;
}accPos;

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
    static dispatch_once_t pred = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = block(); \
    }); \
    return _sharedObject; \

#endif
