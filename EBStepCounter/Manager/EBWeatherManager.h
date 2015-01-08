//
//  EBWeatherManager.h
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/25.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Beijing     = 1,
    Chengdu     = 2,
    Guangzhou   = 3,
    Shanghai    = 4,
    Shenyan     = 5,
}EB_City;

typedef void (^getPM25Success)(NSInteger pm, NSInteger aqi, NSString *desc);

@interface EBWeatherManager : NSObject

+ (EBWeatherManager *)sharedManager;

- (void)getPMDataInCity:(EB_City)city
                success:(getPM25Success)success
                failure:(void(^)(NSError *error))failure;
- (void)getWeatherData;

@end
