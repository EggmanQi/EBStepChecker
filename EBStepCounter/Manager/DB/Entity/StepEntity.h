//
//  StepEntity.h
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/15.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StepEntity : NSManagedObject

@property (nonatomic, retain) NSString * date;
@property (nonatomic, strong) NSNumber * steps;

@end
