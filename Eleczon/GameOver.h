//
//  GameOver.h
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/1/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameCenter.h"

@interface GameOver : SKScene

@property (nonatomic) GameCenter *gameCenter;

-(id)initWithSize:(CGSize)size;

@end
