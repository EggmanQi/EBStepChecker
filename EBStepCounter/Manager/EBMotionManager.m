//
//  EBMotionManager.m
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBMotionManager.h"
#import "EBAccelerometerFilter.h"

@interface EBMotionManager ()
{
    NSInteger pDL; // 左边最低点
    NSInteger pDR; // 右边最低点
    NSInteger pH;  // 最高点
    
    CGFloat   avg;
    
    CGFloat   threshold_height;
    CGFloat   threshold_low;
    
    NSInteger steps;
}

@property(nonatomic, strong)CMMotionManager *motionManager;
@property(nonatomic, strong)LowpassFilter   *lowFilter;

@property(nonatomic, strong)NSMutableArray  *wavArray;
@property(nonatomic, strong)NSArray         *deepCopyAvgArray;
@property(nonatomic, strong)NSArray         *deepCopyWavArray;

@end

@implementation EBMotionManager

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
- (void)start
{
    __weak EBMotionManager *weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                             withHandler:^(CMAccelerometerData *accData, NSError *error) {
                                                 accPos accPos;
                                                 accPos.x = accData.acceleration.x;
                                                 accPos.y = accData.acceleration.y;
                                                 accPos.z = accData.acceleration.z;
                                                 
                                                 [weakSelf.lowFilter addAcceleration:accPos];
                                                 
                                                 [weakSelf cal:weakSelf.lowFilter.pos];
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
    
}

- (void)startWithHandler:(EBStepUpdateHandler)handler
{
    [self start];
    
    if (handler) {
        
    }
}

#pragma mark - Cal steps
- (void)cal:(accPos)pos
{
    CGFloat g = sqrtf(pos.x*pos.x + pos.y*pos.y + pos.z*pos.z);
    
    [self.wavArray addObject:@(g)];
    
    if (self.wavArray.count>100) {
        self.deepCopyAvgArray = [[NSArray alloc] initWithArray:self.wavArray copyItems:YES];
        self.deepCopyWavArray = [[NSArray alloc] initWithArray:self.wavArray copyItems:YES];
        
        [self calAvg];
        [self calWav];
        
        [self.wavArray removeAllObjects];
    }
}

- (void)calAvg
{
    //    CGFloat max = [[arvArray valueForKeyPath:@"@max.floatValue"] floatValue];
    //    CGFloat min = [[arvArray valueForKeyPath:@"@min.floatValue"] floatValue];
    avg = [[self.deepCopyAvgArray valueForKeyPath:@"@avg.floatValue"] floatValue];
    threshold_height = avg * 1.04;
    threshold_low = avg * 0.985;
}

- (void)calWav
{
    [self step1_findFirstDownP:0];
    
    NSInteger iH = 999;
    NSInteger iDL = 999;
    NSInteger iDR = 999;
    
    for (NSInteger i=0; i<self.deepCopyWavArray.count; i++) {
        CGFloat p1 = [self.deepCopyWavArray[i] floatValue];
        CGFloat p2 = [self.deepCopyWavArray[i+1] floatValue];
        CGFloat p3 = [self.deepCopyWavArray[i+2] floatValue];
        CGFloat p4 = [self.deepCopyWavArray[i+3] floatValue];
        
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
            steps++;
            
            iH = 999;
            iDL = 999;
            iDR = 999;
        }
        
        if (i+3==self.deepCopyWavArray.count) {
            break;
        }
    }
}

- (void)step1_findFirstDownP:(NSInteger)beginP
{
    pDL = beginP;
    pDR = -1;
    pH  = -1;
    BOOL isEnd = NO;
    
    if (beginP>=self.deepCopyWavArray.count-4) {
        return;
    }
    
    CGFloat pPre = [self.deepCopyWavArray[pDL] floatValue];
    for (NSInteger i=pDL; i<self.deepCopyWavArray.count-2; i++) {
        CGFloat pCurrent = [self.deepCopyWavArray[i] floatValue];
        CGFloat pNext = [self.deepCopyWavArray[i+1] floatValue];
        CGFloat pNext2 = [self.deepCopyWavArray[i+2] floatValue];
        
        // . 波形图为上升趋势
        if (pPre<pCurrent && pCurrent<pNext && pNext<pNext2) {
            if (pPre<threshold_low) {
                pDL = (i-1)<=0 ? 0 : (i-1);
                break;
            }
        }
        
        // . 波形图为 v 型
        if (pPre>pCurrent && pNext>pCurrent && pNext2>pNext) {
            if (pCurrent<threshold_low) {
                pDL = i;
                break;
            }
        }
        
        pPre = pCurrent;
        
        if (i+2 == self.deepCopyWavArray.count-2) {
            isEnd = YES;
            break;
        }
    }
    
    if (!isEnd) {
        [self step2_findHightP];
    }else {
        //        NSLog(@"step 1 结束");
        return;
    }
}

- (void)step2_findHightP
{
    //    NSLog(@"执行 step 2");
    
    BOOL isEnd = NO;
    
    CGFloat pPre = [self.deepCopyWavArray[pDL] floatValue];
    for (NSInteger i=pDL+1; i<self.deepCopyWavArray.count-2; i++) {
        CGFloat pCurrent = [self.deepCopyWavArray[i] floatValue];
        CGFloat pNext = [self.deepCopyWavArray[i+1] floatValue];
        CGFloat pNext2 = [self.deepCopyWavArray[i+2] floatValue];
        
        // . 波形图为 A 形
        if (pPre<pCurrent && pNext<pCurrent && pNext2<pNext) {
            if (pCurrent>threshold_height) {
                pH = i;
                break;
            }
        }
        
        pPre = pCurrent;
        
        if (i+2 == self.deepCopyWavArray.count-2) {
            isEnd = YES;
            break;
        }
    }
    
    if (isEnd) {
        //        NSLog(@"step 2 结束");
        return;
    }
    
    if (pH>0) {
        // 判断时间间隔，不符合则返回到step1
        if (pH-pDL>1 && pH-pDL<=60) {
            [self step3_findSecondDownP];
        }else {
            [self step1_findFirstDownP:pH];
        }
    }else {
        //        NSLog(@"step 2 结束");
        return;
    }
}

- (void)step3_findSecondDownP
{
    //    NSLog(@"执行 step 3");
    
    BOOL isEnd = NO;
    
    CGFloat pPre = [self.deepCopyWavArray[pH] floatValue];
    for (NSInteger i=pH+1; i<self.deepCopyWavArray.count-2; i++) {
        CGFloat pCurrent = [self.deepCopyWavArray[i] floatValue];
        CGFloat pNext = [self.deepCopyWavArray[i+1] floatValue];
        CGFloat pNext2 = [self.deepCopyWavArray[i+2] floatValue];
        
        // . 波形图为 v 型
        if (pPre>pCurrent && pCurrent<pNext && pNext<pNext2) {
            if (pCurrent<threshold_low) {
                pDR = i;
                break;
            }
        }
        
        pPre = pCurrent;
        
        if (i+2 == self.deepCopyWavArray.count-2) {
            isEnd = YES;
            break;
        }
    }
    
    if (isEnd) {
        //        NSLog(@"step 3 结束");
        return;
    }
    
    if (pDR>0) {
        if (pDR-pH>1 && pDR-pH<=60) {
            //            self.steps ++;
            steps ++;
            NSLog(@"有效计步");
        }
    }else {
        //        NSLog(@"step 3 结束");
        return;
    }
    
    [self step1_findFirstDownP:pDR];
}

#pragma mark - Initialization
+ (EBMotionManager*)sharedManager
{
    static EBMotionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EBMotionManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self=[super init]) {
        
    }
    return self;
}

- (CMMotionManager*)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 1/60.0f;
    }
    return _motionManager;
}

- (LowpassFilter*)lowFilter
{
    if (_lowFilter==nil) {
        _lowFilter = [[LowpassFilter alloc] initWithSampleRate:60.0 cutoffFrequency:5.0];
        _lowFilter.adaptive = YES;
    }
    return _lowFilter;
}

- (NSMutableArray*)wavArray
{
    if (!_wavArray) {
        _wavArray = [NSMutableArray array];
    }
    return _wavArray;
}

@end
