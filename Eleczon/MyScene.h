//
//  MyScene.h
//  Eleczon
//

//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ViewController.h"
#import "GameCenter.h"

@interface MyScene : SKScene

extern NSString *gameFontName;

@property (nonatomic) GameCenter *gameCenter;
@property (strong, nonatomic) ViewController *vc;

@end
