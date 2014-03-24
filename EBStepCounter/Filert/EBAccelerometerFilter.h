//
//  EBAccelerometerFilter.h
//  StepCounterDemo
//
//  Created by EggmanQi on 14-1-29.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagerCommon.h"

@class LowpassFilter;
@class HighpassFilter;
@interface EBAccelerometerFilter : NSObject
{
	BOOL adaptive;
	CGFloat x, y, z;
}

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat z;

@property (nonatomic, getter=isAdaptive) BOOL adaptive;
@property (unsafe_unretained, nonatomic, readonly) NSString *name;

// Add a UIAcceleration to the filter.
- (void)addAcceleration:(accPos)accel;

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;
- (void)countStep;

@end

#pragma mark - 低通滤波
@interface LowpassFilter : EBAccelerometerFilter
{
	double filterConstant;
	CGFloat lastX, lastY, lastZ;
}
@property(nonatomic)accPos  pos;
@property(nonatomic, assign)NSInteger *lowStep;

//- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

@end

#pragma mark - 高通滤波
@interface HighpassFilter : EBAccelerometerFilter
{
	double filterConstant;
	CGFloat lastX, lastY, lastZ;
}
@property(nonatomic)accPos  pos;
@property(nonatomic, strong)NSMutableArray *posArray;
@property(nonatomic, assign)CGFloat diffMax;
@property(nonatomic, assign)CGFloat diffMin;
@property(nonatomic, assign)NSInteger *highStep;

//- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

@end
