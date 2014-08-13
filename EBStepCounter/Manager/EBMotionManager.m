//
//  EBMotionManager.m
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBMotionManager.h"
#import "EBAccelerometerFilter.h"

#define NORMAL_FREQUENCY    1/60.0f
#define NORMAL_RATE         60.0f
#define LOW_FREQUENCY       1/10.0f
#define LOW_RATE            10.0f
#define NORMAL_SAMPLE_NUM   100
#define LOW_SAMPLE_NUM      16

@interface EBMotionManager ()
{
    NSInteger pDL; // 左边最低点
    NSInteger pDR; // 右边最低点
    NSInteger pH;  // 最高点
    
    CGFloat   avg;
    
    CGFloat   threshold_height;
    CGFloat   threshold_low;
    
    NSInteger tempSteps;
    NSInteger steps;
    
    CGFloat                 wav[100];
    NSInteger                 wavTag;
}

@property(nonatomic, strong)CMMotionManager *motionManager;
@property(nonatomic, strong)LowpassFilter   *lowFilter;

@property(nonatomic, strong)EBStepUpdateHandler internalHandler;

@end

@implementation EBMotionManager

#pragma mark -
float ave(float arr[], int n)
{
    double avg=0;
    int i=0;
    for(;i<n;i++)
        avg+=(double)arr[i]/(double)(n);
    return avg;
}

#pragma mark - Status
- (BOOL)isAvailable
{
    return [self.motionManager isAccelerometerAvailable];
}

- (BOOL)isActive
{
    return [self.motionManager isAccelerometerActive];
}

#pragma mark - Control
- (void)startWithHandler:(EBStepUpdateHandler)handler
{
    self.internalHandler = handler;
    
    [self start];
}

- (void)start
{
    __weak EBMotionManager *weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                             withHandler:^(CMAccelerometerData *accData, NSError *error) {
                                                 if (!error) {
                                                     [weakSelf prepareCal:accData];
                                                 }else {
                                                     printf("CMMotionManager got error!!!");
                                                 }
                                             }];
}

- (void)pause
{
    [self.motionManager stopAccelerometerUpdates];
}

- (void)stop
{
    [self.motionManager stopAccelerometerUpdates];
}

- (void)restart
{
    [self stop];
    [self start];
}

#pragma mark -
- (void)filtrationSteps
{
    if (tempSteps > 0 && tempSteps < 6) {
        steps = steps + tempSteps;
        if (self.internalHandler) {
            self.internalHandler(steps, nil, nil);
        }
    }
    tempSteps = 0;
}

#pragma mark - Cal steps
- (void)prepareCal:(CMAccelerometerData *)accData
{
    accPos accPos;
    accPos.x = accData.acceleration.x;
    accPos.y = accData.acceleration.y;
    accPos.z = accData.acceleration.z;
    
    [self.lowFilter addAcceleration:accPos];
    
    [self cal:self.lowFilter.pos];
}

- (void)cal:(accPos)pos
{
    CGFloat g = sqrtf(pos.x*pos.x + pos.y*pos.y + pos.z*pos.z);
    
    wav[wavTag] = g;
    wavTag ++;
    if (wavTag == 100) {
        [self stop];
        [self calAvg];
        [self calWav];
        
        wavTag = 0;
        memset(wav, 0x0, 4*100);

        [self filtrationSteps];
        
        [NSThread sleepForTimeInterval:.1f];
        
        [self start];
    }
}

- (void)calAvg
{
    NSInteger length = sizeof(wav)/sizeof(wav[0]);
    avg = ave(wav, length);
    threshold_height = avg * 1.04;
    threshold_low = avg * 0.985;
}

- (void)calWav
{    
    NSInteger iH = 999;
    NSInteger iDL = 999;
    NSInteger iDR = 999;
    NSInteger length = sizeof(wav)/sizeof(wav[0]);
    
    for (NSInteger i=0; i<length; i++) {
        CGFloat p1 = wav[i];
        CGFloat p2 = wav[i+1];
        CGFloat p3 = wav[i+2];
        CGFloat p4 = wav[i+3];
        
        if (p1<p2 && p3<p2 && p4<p3) {  // 最高点
            if (p2>threshold_height) {
                pH = p2;
                iH = i+1;
            }
        }
        
        if (p1>p2 && p3>p2 && p4>p3) {  // 最低点
            if (p2<threshold_low) {
                if (pDL==0) {
                    pDL = p2;
                    iDL = i+1;
                    if (iDL-iH>50 && iDL-iH<5) { // 判断是否在合理区间
                        iDL = 999;
                    }
                }else {
                    pDR = p2;
                    iDR = i+1;
                    if (iDR-iH>50 && iDR-iH<5) {
                        iDR = 999;
                    }
                }
            }
        }
        
        if (iDL<iH && iH<iDR) {
            tempSteps++;
            
            iH = 999;
            iDL = 999;
            iDR = 999;
            
            NSLog(@"步数增加！ %d", tempSteps);
        }
        
        if (i+3 == length) {
            break;
        }
    }
}

#pragma mark - Initialization
+ (EBMotionManager*)sharedManager
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    if (self=[super init]) {
        wavTag = 0;
        tempSteps = 0;
        steps = 0;
    }
    return self;
}

- (CMMotionManager*)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = NORMAL_FREQUENCY;
    }
    return _motionManager;
}

- (LowpassFilter*)lowFilter
{
    if (_lowFilter==nil) {
        _lowFilter = [[LowpassFilter alloc] initWithSampleRate:NORMAL_RATE
                                               cutoffFrequency:LOW_RATE];
        _lowFilter.adaptive = YES;
    }
    return _lowFilter;
}



@end
