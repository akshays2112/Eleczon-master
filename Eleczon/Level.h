//
//  Level.h
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/1/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>
#import "GameCenter.h"

@interface Level : SKScene <UIAccelerometerDelegate, SKPhysicsContactDelegate, GKGameCenterControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

extern NSString *gameFontName;
extern int playerEnergy;
extern int playerCurrentLevelNumber;
extern int playerLives;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic) int shieldUp;
@property (nonatomic) GameCenter *gameCenter;


//-(void)setupGestureHandlers;

@end
