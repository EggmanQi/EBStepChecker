//
//  ManagerCommon.h
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#ifndef EBStepCounter_ManagerCommon_h
#define EBStepCounter_ManagerCommon_h

typedef void (^EBStepUpdateHandler)(NSInteger numberOfSteps, NSDate *timestamp, NSError *error);

typedef struct{
    float x;
    float y;
    float z;
}accPos;

#endif
