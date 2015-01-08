//
//  EBWeatherViewController.m
//  EBStepCounter
//
//  Created by EggmanQi on 14/8/25.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBWeatherViewController.h"
#import "EBWeatherManager.h"

#define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)

@interface EBWeatherViewController ()

@end

@implementation EBWeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self loadPM];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup
- (void)setupUI
{
    self.descLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
}

#pragma mark -
- (IBAction)onBackAction:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)onReloadAction:(id)sender
{
    [self loadPM];
}

#pragma mark -
- (void)loadPM
{
    [[EBWeatherManager sharedManager] getPMDataInCity:Guangzhou
                                              success:^(NSInteger pm, NSInteger aqi, NSString *desc) {
                                                  self.pmLabel.text = [@(pm) stringValue];
                                                  self.aqiLabel.text = [@(aqi) stringValue];
                                                  self.descLabel.text = desc;
                                              }
                                              failure:^(NSError *error) {
                                                  
                                              }];
}

@end
