//
//  Help.h
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/6/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Level.h"

@interface Help : SKScene

extern NSString *gameFontName;

@property (strong, nonatomic) Level *levelScene;

-(void) setupTapRecognizer: (UITapGestureRecognizer *) tapRecognizer panRecognizer: (UIPanGestureRecognizer *) panRecognizer;

@end
