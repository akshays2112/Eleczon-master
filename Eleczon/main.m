//
//  main.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/3/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

NSString *gameFontName;
int playerEnergy;
int playerCurrentLevelNumber;
int playerLives;
int doinGameCenter;

int main(int argc, char * argv[])
{
    @autoreleasepool {
        gameFontName = @"Chalkboard SE Bold";
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
