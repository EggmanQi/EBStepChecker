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

@end

@implementation EBViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
