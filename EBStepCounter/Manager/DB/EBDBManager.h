//
//  EBDBManager.h
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/15.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EBDBManager : NSObject

+ (EBDBManager *)sharedManager;
- (NSManagedObjectContext*)getContext;
- (void)saveContext;

@end
