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
//    NSInteger pDL; // 左边最低点
//    NSInteger pDR; // 右边最低点
//    NSInteger pH;  // 最高点
    
    CGFloat   avg;
    
    CGFloat   threshold_height;
    CGFloat   threshold_low;
    
    NSInteger tempSteps;
    NSInteger steps;
    
    CGFloat                     wav[100];
    NSInteger                   wavTag;
}

@property(nonatomic, strong)CMMotionManager *motionManager;
@property(nonatomic, strong)LowpassFilter   *lowFilter;

@property(nonatomic, strong)EBStepUpdateHandler internalHandler;

@end

@implementation EBMotionManager

#pragma mark -
CGFloat ave(CGFloat arr[], int n)
{
    double avg=0;

    for(int i=0;i<n;i++)
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
//        steps = steps + tempSteps;
        if (self.internalHandler) {
            self.internalHandler(tempSteps, nil, nil);
        }
    }
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
        
        [NSThread sleepForTimeInterval:.05f];
        
        [self start];
    }
}

- (void)calAvg
{
    int length = sizeof(wav)/sizeof(wav[0]);
    avg = ave(wav, length);
    threshold_height = avg * 1.04;
    threshold_low = avg * 0.985;
    
//    NSLog(@"计算：：： %f, %f, %f", avg, threshold_height, threshold_low);
}

- (void)calWav
{
    NSInteger length = sizeof(wav)/sizeof(wav[0]);
    CGFloat wav_new[100];
    NSMutableArray *arr_new = [NSMutableArray array];
    BOOL isFindHeight = NO;
    BOOL isFindLow = NO;
    NSInteger gap = -1;
    
    // . 找出所有极值
    for (NSInteger i=0; i<length; i++) {
        CGFloat p1 = wav[i];
        CGFloat p2 = wav[i+1];
        CGFloat p3 = wav[i+2];
        CGFloat p4 = wav[i+3];
        CGFloat p5 = wav[i+4];
        
        // 计算波形间隔
        if (gap != -1) {
            gap = gap + 1;
        }
        
        // 找最高点
        if ( ! isFindHeight) {
            if (p1<p2 && p2<p3 && p4<p3 && p5<p4) {
                if (p3>threshold_height) {
                    wav_new[i+2] = p3;
                    
                    if (gap == -1) {
                        [arr_new addObject:@(p3)];
                        gap = 0;
                        isFindHeight = YES;
                        isFindLow = NO;
                    } else if (gap < 6 || gap > 50) {
                        gap = -1;
                    } else {
                        [arr_new addObject:@(p3)];
                        gap = 0;
                        isFindHeight = YES;
                        isFindLow = NO;
                    }
                }
            }
        }
        
        // 找最低点
        if ( ! isFindLow) {
            if (p1>p2 && p2>p3 && p4>p3 && p5>p4) {
                if (p3<threshold_low) {
                    wav_new[i+2] = p3;
                    
                    if (gap == -1) {
                        [arr_new addObject:@(p3)];
                        gap = 0;
                        isFindLow = YES;
                        isFindHeight = NO;
                    } else if (gap < 6 || gap > 50) {
                        gap = -1;
                    } else {
                        [arr_new addObject:@(p3)];
                        gap = 0;
                        isFindLow = YES;
                        isFindHeight = NO;
                    }
                }
            }
        }
        
        if (i+4 == length) {
            break;
        }
    }

//    NSLog(@"got final arr count : %d", arr_new.count );
    
    tempSteps = (arr_new.count/3)>6 ? 0 : arr_new.count/3;
    
    [arr_new removeAllObjects];
    arr_new = nil;    
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
