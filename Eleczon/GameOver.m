//
//  GameOver.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/1/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import "GameOver.h"
#import "Level.h"

@implementation GameOver

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self runAction:[SKAction playSoundFileNamed:@"GameOver.caf" waitForCompletion:NO]];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"Background2"];
        backgroundNode.position =  CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:backgroundNode];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:gameFontName];
        
        myLabel.text = @"Game Over!!!";
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            myLabel.fontSize = 50;
        } else {
            myLabel.fontSize = 25;
        }
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:myLabel];
        
        SKLabelNode *tapLabel = [SKLabelNode labelNodeWithFontNamed:gameFontName];
        
        tapLabel.text = @"Tap to start a new game.";
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            tapLabel.fontSize = 30;
        } else {
            tapLabel.fontSize = 15;
        }
        tapLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 25));
        
        [self addChild:tapLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    playerCurrentLevelNumber = 1;
    playerEnergy = 300;
    playerLives = 3;
    Level *level = [[Level alloc] initWithSize: self.size];
    level.gameCenter = self.gameCenter;
    [self.view presentScene:level transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
    //[level setupGestureHandlers];
}

@end
