//
//  EBViewController.m
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/13.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBViewController.h"
#import "EBStepManager.h"

@interface EBViewController ()

@property(nonatomic, strong)IBOutlet UILabel    *stepsLabel;
@property(nonatomic, strong)IBOutlet UILabel    *timeLabel;

@end

@implementation EBViewController

#pragma mark -
- (void)setupMotion
{
    [[EBStepManager sharedManager] startStepCounting:^(NSInteger numberOfSteps,
                                                       NSDate *timestamp,
                                                       NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }else {
            self.stepsLabel.text = [@(numberOfSteps) stringValue];
        }
    }];
}

- (void)setupDate
{
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    fm.dateStyle = NSDateIntervalFormatterMediumStyle;
    NSString *timeStr = [fm stringFromDate:[NSDate date]];
    self.timeLabel.text = timeStr;
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupMotion];
    [self setupDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
