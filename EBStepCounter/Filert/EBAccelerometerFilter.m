//
//  EBAccelerometerFilter.m
//  StepCounterDemo
//
//  Created by EggmanQi on 14-1-29.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBAccelerometerFilter.h"

@implementation EBAccelerometerFilter
@synthesize x, y, z, adaptive;

- (void)addAcceleration:(accPos)accel
{
	x = accel.x;
	y = accel.y;
	z = accel.z;
}

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq{return self;}
- (void)countStep{}

@end

#pragma mark -

#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0

// . 求方差
double Norm(double x, double y, double z)
{
	return sqrt(x * x + y * y + z * z);
}

// . 取中间值
double Clamp(double v, double min, double max)
{
	if(v > max)
		return max;
	else if(v < min)
		return min;
	else
		return v;
}


#pragma mark - 低通滤波

// See http://en.wikipedia.org/wiki/Low-pass_filter for details low pass filtering
@implementation LowpassFilter

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	if(self = [super init])
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = dt / (dt + RC);
	}
	return self;
}

- (void)addAcceleration:(accPos )accel
{
	double alpha = filterConstant;
	
    // 是否自适应
	if(adaptive)
	{
		double d = Clamp(fabs(Norm(x, y, z) - Norm(accel.x, accel.y, accel.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = (1.0 - d) * filterConstant / kAccelerometerNoiseAttenuation + d * filterConstant;
	}
	
	x = accel.x * alpha + x * (1.0 - alpha);
	y = accel.y * alpha + y * (1.0 - alpha);
	z = accel.z * alpha + z * (1.0 - alpha);
    
    _pos.x = x;
    _pos.y = y;
    _pos.z = z;
}

- (NSString *)name
{
	return adaptive ? @"Adaptive Lowpass Filter" : @"Lowpass Filter";
}

- (void)countStep
{}

@end


#pragma mark - 高通滤波

// See http://en.wikipedia.org/wiki/High-pass_filter for details on high pass filtering
@implementation HighpassFilter

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	if (self = [super init])
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = RC / (dt + RC);
        
        _posArray = [NSMutableArray array];
        _diffMax = -999;
        _diffMin = -999;
        _highStep = 0;
	}
	return self;
}

- (void)addAcceleration:(accPos )accel
{
	double alpha = filterConstant;
	
	if (adaptive)
	{
		double d = Clamp(fabs(Norm(x, y, z) - Norm(accel.x, accel.y, accel.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = d * filterConstant / kAccelerometerNoiseAttenuation + (1.0 - d) * filterConstant;
	}
	
	x = alpha * (x + accel.x - lastX);
	y = alpha * (y + accel.y - lastY);
	z = alpha * (z + accel.z - lastZ);
	
	lastX = accel.x;
	lastY = accel.y;
	lastZ = accel.z;
    
    _pos.x = lastX;
    _pos.y = lastY;
    _pos.z = lastZ;
    
    [self countStep];
}

- (NSString *)name
{
	return adaptive ? @"Adaptive Highpass Filter" : @"Highpass Filter";
}

- (void)countStep
{
    
}

@end