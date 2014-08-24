//
//  EBViewController.m
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/13.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import <pop/POP.h>
#import <objc/runtime.h>
#import "EBViewController.h"
#import "EBStepManager.h"
#import "NSString+dateTranser.h"

@interface EBViewController () <POPAnimationDelegate>

@property(nonatomic, strong)IBOutlet UILabel    *stepsLabel;
@property(nonatomic, strong)IBOutlet UILabel    *timeLabel;

@end

@implementation EBViewController

#pragma mark -
- (IBAction)onSaveAction:(id)sender
{
    [[EBStepManager sharedManager] saveSteps];
}

#pragma mark -
- (void)handleUIRunningNotification:(NSNotification *)notification
{
    NSNumber *shouldUIActive = [notification.userInfo objectForKey:@"should UI Active"];
    if (shouldUIActive.boolValue) {
        //  TODO: 要停止ui动画
    }
}

#pragma mark -
- (void)pop_animationDidStart:(POPAnimation *)anim
{
//    NSLog(@"pop animation start");
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
//    NSLog(@"pop animation stop");
    
//    [self.stepsLabel pop_removeAllAnimations];
}

#pragma mark - 
- (void)shakeStep
{
    POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
    
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    
    basicAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.5, 1.5)];
    basicAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    
    basicAnimation.name=@"AnyAnimationNameYouWant";
    basicAnimation.delegate=self;
    basicAnimation.springBounciness = 14;
    basicAnimation.springSpeed = 13;
    
    [self.stepsLabel pop_addAnimation:basicAnimation
                               forKey:@"a_1"];
    [basicAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
//            NSLog(@"block finish");
        }
    }];
}

#pragma mark -
- (void)setupFont
{
    self.stepsLabel.font = [UIFont fontWithName:@"MFYueHei_Noncommercial-Regular"
                                           size:70];
    self.timeLabel.font = [UIFont fontWithName:@"MFYueHei_Noncommercial-Regular"
                                          size:20];
}

- (void)setupMotion
{
    [[EBStepManager sharedManager] startStepCounting:^(NSInteger numberOfSteps,
                                                       NSDate *timestamp,
                                                       NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }else {
            self.stepsLabel.text = [@(numberOfSteps) stringValue];
            [self shakeStep];
        }
    }];
}

- (void)setupDate
{
    
    self.timeLabel.text = [NSString strFromDate:[NSDate date]
                                  withFormatter:@"yyyy年MM月dd日\n EEEE\n hh:mm:ss"];
}

- (void)setupTimer
{
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(setupDate)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)setupNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIRunningNotification:)
                                                 name:@"是否持续更新ui"
                                               object:nil];
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFont];
    [self setupMotion];
    [self setupDate];
    [self setupTimer];
    [self setupNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
- (NSDateFormatter *)timeDateFormat
{
    NSDateFormatter *fm = (NSDateFormatter *)objc_getAssociatedObject(self, @"time date format");
    if ( ! fm) {
        fm = [[NSDateFormatter alloc] init];
        fm.dateFormat = @"yyyy年MM月dd日\n EEEE\n hh:mm:ss";
        objc_setAssociatedObject(self, @"time date format", fm, OBJC_ASSOCIATION_RETAIN);
    }
    return fm;
}

@end
