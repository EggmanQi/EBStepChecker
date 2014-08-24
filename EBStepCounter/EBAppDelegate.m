//
//  EBAppDelegate.m
//  EBStepCounter
//
//  Created by EggmanQi on 14-3-23.
//  Copyright (c) 2014年 EggBrain Studio. All rights reserved.
//

#import "EBAppDelegate.h"
#import "EBViewController.h"
#import "EBStepManager.h"

@implementation EBAppDelegate

#pragma mark - Prepare
- (void)prepareForApp
{

}

#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self prepareForApp];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    EBViewController *vc = [[EBViewController alloc] init];
    self.window.rootViewController = vc;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[EBStepManager sharedManager] saveSteps];
    [[EBDBManager sharedManager] saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EBStepManager sharedManager] saveSteps];
    [[EBDBManager sharedManager] saveContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"是否持续更新ui"
                                                        object:nil
                                                      userInfo:@{@"should UI Active": @(NO)}];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EBStepManager sharedManager] saveSteps];
    [[EBDBManager sharedManager] saveContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"是否持续更新ui"
                                                        object:nil
                                                      userInfo:@{@"should UI Active": @(YES)}];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[EBStepManager sharedManager] saveSteps];
    [[EBDBManager sharedManager] saveContext];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EBStepManager sharedManager] saveSteps];
    [[EBDBManager sharedManager] saveContext];
}

@end
