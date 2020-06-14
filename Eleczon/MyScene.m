//
//  MyScene.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/1/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import "MyScene.h"
#import "Level.h"

@implementation MyScene {
    BOOL alreadyLoading;
    BOOL doneLoading;
    NSMutableArray *progressBarSpriteNodes;
    int currentSlideRight;
    int maxSlideRight;
    NSTimeInterval lastSlide;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self runAction:[SKAction playSoundFileNamed:@"GameStartup.caf" waitForCompletion:NO]];

        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        backgroundNode.position =  CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:backgroundNode];
        alreadyLoading = NO;
        doneLoading = NO;
        progressBarSpriteNodes = [[NSMutableArray alloc] init];
        currentSlideRight = 0;
        lastSlide = 0;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if(!alreadyLoading && !doinGameCenter) {
        alreadyLoading = YES;
        SKSpriteNode *progressBarMask = [SKSpriteNode spriteNodeWithImageNamed:@"ProgressBarMask"];
        SKCropNode *progressBarCropNode = [SKCropNode node];
        SKSpriteNode *progressBar = [SKSpriteNode spriteNodeWithImageNamed:@"ProgressBar"];
        maxSlideRight = progressBar.size.width;
        int numProgressBars = floor(progressBarMask.size.width / progressBar.size.width) + 2;
        for(int i=0;i<numProgressBars;i++) {
            SKSpriteNode *progressBarX = [SKSpriteNode spriteNodeWithImageNamed:@"ProgressBar"];
            [progressBarCropNode addChild:progressBarX];
            progressBarX.position = CGPointMake(((i - 1) * progressBar.size.width) - (progressBarMask.size.width) / 2, 0.0f);
            [progressBarSpriteNodes addObject:progressBarX];
        }
        progressBarCropNode.maskNode = progressBarMask;
        [self addChild:progressBarCropNode];
        progressBarCropNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100 : 60));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [progressBarCropNode setScale:2.0f];
        }
        int levelNumber = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"com.epic3dmud.eleczon.level"];
        int energy = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"com.epic3dmud.eleczon.energy"];
        int lives = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"com.epic3dmud.eleczon.lives"];
        dispatch_async(dispatch_queue_create("com.epic3dmud.eleczon.loading", NULL), ^{
            playerCurrentLevelNumber = (levelNumber > 1 ? levelNumber : 1);
            playerEnergy = energy < 2000 ? 2000 : energy;
            playerLives = lives < 3 ? 3 : lives;
            Level *level = [[Level alloc] initWithSize: self.size];
            level.gameCenter = self.gameCenter;
            doneLoading = YES;
            [self.view presentScene:level transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
        });
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if(!doneLoading  && alreadyLoading) {
        if(currentTime - lastSlide > 0.5) {
            currentSlideRight++;
            if(currentSlideRight >= maxSlideRight) {
                currentSlideRight = 0;
            }
            for(SKSpriteNode *node in progressBarSpriteNodes) {
                if(currentSlideRight == 0) {
                    node.position = CGPointMake(node.position.x - maxSlideRight, node.position.y);
                } else {
                    node.position = CGPointMake(node.position.x + 1, node.position.y);
                }
            }
        }
    }
    if(!doinGameCenter) {
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:gameFontName];
        myLabel.text = @"Tap screen to start!!!";
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            myLabel.fontSize = 50;
        } else {
            myLabel.fontSize = 25;
        }
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 30));
        [self addChild:myLabel];
    }
}

@end
