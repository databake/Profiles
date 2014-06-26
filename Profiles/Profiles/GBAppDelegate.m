//
//  GBAppDelegate.m
//  Profiles
//
//  Created by Graham Barker on 25/06/2014.
//  Copyright (c) 2014 Donson. All rights reserved.
//

#import "GBAppDelegate.h"
#import "GBCoreData.h"

@implementation GBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    return YES;
}

@end
