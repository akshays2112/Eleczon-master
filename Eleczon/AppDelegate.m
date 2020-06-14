//
//  AppDelegate.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/3/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import "AppDelegate.h"



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setInteger:playerEnergy forKey:@"com.epic3dmud.eleczon.energy"];
    [[NSUserDefaults standardUserDefaults] setInteger:playerLives forKey:@"com.epic3dmud.eleczon.lives"];
    [[NSUserDefaults standardUserDefaults] setInteger:playerCurrentLevelNumber forKey:@"com.epic3dmud.eleczon.level"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    /*
     [[[NSString alloc] initWithFormat:@"%i,%i,%i", (self.currentLevelNumber + 1 > maxLevels ? self.currentLevelNumber : ++self.currentLevelNumber), self.energy, self.lives] writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"eleczonPlayer.data"] atomically:NO encoding:NSUTF8StringEncoding error:nil];*/
}

@end
