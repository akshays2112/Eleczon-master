//
//  GameCenter.h
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/7/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "ViewController.h"

@interface GameCenter : NSObject

extern int doinGameCenter;

@property (nonatomic) BOOL gameCenterEnabled;

-(void)authenticateLocalPlayer: (UIViewController *) mainViewController ;
-(void)reportEnergy: (int) energy;

@end
