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
//        [self calWav];
        [self calWav_New];
        
        wavTag = 0;
        memset(wav, 0x0, 4*100);

        [self filtrationSteps];
        
        [NSThread sleepForTimeInterval:.1f];
        
        [self start];
    }
}

- (void)calAvg
{
    int length = sizeof(wav)/sizeof(wav[0]);
    avg = ave(wav, length);
    threshold_height = avg * 1.03;
    threshold_low = avg * 0.99;
    
//    NSLog(@"计算：：： %f, %f, %f", avg, threshold_height, threshold_low);
}

- (void)calWav_New
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
    
    return;
    
    // . 判断极值是否符合正弦函数
    for (NSInteger i=0; i<length; i++) {
        
    }
    
}

- (void)calWav
{
    tempSteps = 0;
    
    NSInteger iHL = 999;
    NSInteger iD  = 999;
    NSInteger iHR = 999;
    
    NSInteger iDL = 999;
    NSInteger iH  = 999;
    NSInteger iDR = 999;
    
    NSInteger length = sizeof(wav)/sizeof(wav[0]);
    
    BOOL      isHeightFirst = NO;
    
    for (NSInteger i=0; i<length; i++) {
        CGFloat p1 = wav[i];
        CGFloat p2 = wav[i+1];
        CGFloat p3 = wav[i+2];
        CGFloat p4 = wav[i+3];
        
        if (p1<p2 && p3<p2 && p4<p3) {  // 最高点
            if (p2>threshold_height) {
//                NSLog(@"get 最高");
                iH = i+1;
            }
        }
        
        if (p1>p2 && p3>p2 && p4>p3) {  // 最低点
            if (p2<threshold_low) {
                if (iH == 999) {
                    iDL = p2;
                }else {
                    if (iDL-iH<60 && iDL-iH>10) {
                        iDL = p2;
                    }else {
                        iDR = p2;
                        if (iDR-iH>60) {
                            iH = 999;
                            iDL = 999;
                            iDR = 999;
                        }
                    }
                }
//                if (pDL==0) {
//                    pDL = p2;
//                    iDL = i+1;
//                    if (iDL-iH>60 && iDL-iH<5) { // 判断是否在合理区间
//                        NSLog(@"get 最低-左");
//                        iDL = 999;
//                    }
//                }else {
//                    pDR = p2;
//                    iDR = i+1;
//                    if (iDR-iH>60 && iDR-iH<5) {
//                        NSLog(@"get 最低-右");
//                        iDR = 999;
//                    }
//                }
            }
        }
        
        if (iDL<iH && iH<iDR) {
            tempSteps = tempSteps + 1;
            
            iH = 999;
            iDL = 999;
            iDR = 999;
            
//            NSLog(@"步数增加！ %d", tempSteps);
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
