//
//  Help.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/6/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import "Help.h"

@implementation Help {
    SKNode *masterNode;
    CGSize screenSize;
    CGFloat totalCurrentHeight;
    CGFloat leftMarginWidth;
    BOOL touchMoved;
    UITapGestureRecognizer *levelTapRecognizer;
    UITapGestureRecognizer *helpTapRecognizer;
    UIPanGestureRecognizer *helpPanRecognizer;
    UIPanGestureRecognizer *levelPanRecognizer;
}

static const int headerPixels = 50;
static const int paddingBetweenLines = 5;
static const int paddingParagraph = 25;

-(SKSpriteNode *) makeMapIcons: (NSString *) imageName action: (SKAction *) action childNodeImageName: (NSString *) childNodeImageName childNodeAction: (SKAction *) childNodeAction {
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [node setScale:2.0f];
    }
    node.position = CGPointMake(leftMarginWidth + node.size.width / 2.0f, screenSize.height - totalCurrentHeight - headerPixels);
    if(action) {
        [node runAction:[SKAction repeatActionForever: action]];
    }
    [masterNode addChild: node];
    if(childNodeImageName) {
        SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithImageNamed:childNodeImageName];
        childNode.position = CGPointZero;
        [node addChild:childNode];
        if(childNodeAction) {
            [childNode runAction: [SKAction repeatActionForever:childNodeAction]];
        }
    }
    totalCurrentHeight += (1.5f * node.size.height) + paddingBetweenLines;
    return node;
}

-(void) drawMessage: (NSString *) message {
    NSArray *lines = [message componentsSeparatedByString:@"\n"];
    for(NSString *line in lines) {
        SKLabelNode *msglbl = [SKLabelNode labelNodeWithFontNamed:gameFontName];
        msglbl.text = line;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            msglbl.fontSize = 25;
        } else {
            msglbl.fontSize = 12;
        }
        msglbl.position = CGPointMake(leftMarginWidth + msglbl.frame.size.width / 2, screenSize.height - totalCurrentHeight - headerPixels);
        [masterNode addChild:msglbl];
        totalCurrentHeight += msglbl.frame.size.height + paddingBetweenLines;
    }
    totalCurrentHeight += paddingParagraph - paddingBetweenLines;
}

-(void) setupTapRecognizer: (UITapGestureRecognizer *) tapRecognizer panRecognizer: (UIPanGestureRecognizer *) panRecognizer {
    levelTapRecognizer = tapRecognizer;
    [self.view removeGestureRecognizer:tapRecognizer];
    levelPanRecognizer = panRecognizer;
    [self.view removeGestureRecognizer:panRecognizer];
    helpTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:helpTapRecognizer];
    helpPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanned:)];
    [self.view addGestureRecognizer:helpPanRecognizer];
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGFloat y = masterNode.position.y;
    if(totalCurrentHeight > screenSize.height && masterNode.position.y - newPos.y <= totalCurrentHeight - screenSize.height + 50.0f && masterNode.position.y - newPos.y >= 0) {
        y -= newPos.y;
    }
    return CGPointMake(0, y);
}

- (void)panForTranslation:(CGPoint)translation {
    [masterNode setPosition:[self boundLayerPos:translation]];
}

-(void) viewPanned:(UIPanGestureRecognizer *) recognizer {
    [self panForTranslation:[recognizer translationInView:self.view]];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    [self.view presentScene:self.levelScene transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
    [self.view removeGestureRecognizer:helpTapRecognizer];
    [self.view removeGestureRecognizer:helpPanRecognizer];
    [self.view addGestureRecognizer:levelTapRecognizer];
    [self.view addGestureRecognizer:levelPanRecognizer];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        touchMoved = NO;
        
        screenSize = size;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKSpriteNode *backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"Background2"];
        backgroundImageNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:backgroundImageNode];

        masterNode = [[SKNode alloc] init];
        masterNode.position = CGPointZero;
        [self addChild:masterNode];

        leftMarginWidth = 25.0f;
        totalCurrentHeight = 0.0f;
        
        [self makeMapIcons:@"Eleczon" action:nil childNodeImageName:nil childNodeAction:nil];
        [self drawMessage: @"You control the Eleczon!!!\nTilt your way through the maze gaining the\nmaximum energy and lives that you can.  You\ncan also swipe to pan around the whole maze."];
        [self makeMapIcons:@"EnergyIcon" action:nil childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@"The number next to this icon on the top is\nthe amount of energy you have accumulated.\nAt the end of each level when you are victorious\nyour score is posted to the Eleczon game center\nleader board if you are logged into game center.\nAt the level end your energy is also saved so\nwhen you come back you can resume at the\nsame level of energy you quit the game at."];
        [self makeMapIcons:@"LivesIcon" action:nil childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@"This icon is the number of lives you have.\nWhen your energy falls to zero you loose a life.\nThis is saved so when you quit it is restored to\nthe same number of lives."];
        [self makeMapIcons:@"ShieldIcon" action:nil childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@"This icon shows the number of shields you have\npicked up."];
        [self makeMapIcons:@"BulletGreenRight" action:nil childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@"This icon indicates the number of bullets you\nhave left."];
        [self makeMapIcons:@"LevelIcon" action:nil childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@"This is the level number you are on.  For each\nadditional level the maze grows by 1 square\nwide and in height to challenge you.  Your level\nis saved when you quit so you can continue from\nwhere you left off when you come back."];
        [self makeMapIcons:@"Charger" action:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:1.0], [SKAction fadeAlphaTo:1.0 duration:1.0]]] childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@""];
        [self drawMessage:@"The Charger does exact what its called and\nthat is gives you energy bonus of a 100 energy.\nIn addition a random bonus of energy is added\nto the eleczon based on the level number."];
        [self makeMapIcons:@"Discharger" action:[SKAction rotateByAngle:-0.1 duration:0.1] childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@"The Discharger drains 100 energy from the\nEleczon.  In addition to this a random amount\nof energy is drained based on the level number."];
        [self makeMapIcons:@"Gun" action:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:1.0], [SKAction fadeAlphaTo:1.0 duration:1.0]]] childNodeImageName:nil childNodeAction:nil];
        [self drawMessage:@"The gun will shoot bullets after you pick it up\nat 1 bullet per second in the direction you are\ncurrently rolling in.  Upon striking a wall the\nbullet explodes doing nothing and getting\nconsumed.  Upon hitting a Discharger it will\nleech energy from the discharger and give\nit to you dissolving the Discharger and exploding\nin a bang. You have a maximum of 10 bullets."];
        [self makeMapIcons:@"Cloud" action:nil childNodeImageName:@"CloudsLightning" childNodeAction:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:0.2], [SKAction fadeAlphaTo:1.0 duration:0.2]]]];
        [self drawMessage: @"The cloud's lightning bolts charge you up for\n1000 energy plus a bonus amount based on your\nlevel number. The cloud has a cooldown of a\nminute before it can be used to imbue you with\nenergy again."];
        [self makeMapIcons:@"TeleportIn" action:[SKAction rotateByAngle:-0.1 duration:0.1] childNodeImageName:nil childNodeAction:nil];
        [self drawMessage: @"This is the teleport entrance.  The teleport\nentrance is uniquely hooked up to a teleport\nexit in the maze.  You have to use your memory\nto remember which teleport entrance\ncorresponds to which teleport exit.  So beware\nof bumping into this!!!"];
        [self makeMapIcons:@"TeleportOut" action:[SKAction rotateByAngle:0.1 duration:0.1] childNodeImageName:nil childNodeAction:nil];
        [self drawMessage: @"This is the teleport exit.  The teleport exit is\nuniquely hooked up to a teleport entrance.\nYou cannot use the teleport exit to get back\nto the teleport entrance in the maze."];
        [self makeMapIcons:@"Bomb" action:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:0.5], [SKAction fadeAlphaTo:1.0 duration:0.5]]] childNodeImageName:nil childNodeAction:nil];
        [self drawMessage: @"The bomb will reduce your number of lives by 1.\nThis should be avoided at all costs unless you\nare an expert!!!"];
        [self makeMapIcons:@"LevelUp" action:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:0.25], [SKAction fadeAlphaTo:1.0 duration:0.25]]] childNodeImageName:nil childNodeAction:nil];
        [self drawMessage: @"This is the lifesaver!!!  It will increase your\navailable lives by 1."];
        SKSpriteNode *shield = [self makeMapIcons:@"Shield" action:nil childNodeImageName:nil childNodeAction:nil];
        SKEmitterNode *shieldEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"ShieldEffect" ofType:@"sks"]];
        shieldEmitter.position = CGPointZero;
        [shield addChild:shieldEmitter];
        [self drawMessage: @"The shield will protect you from loosing a life to\na bomb.  The shield will only save you from 1\nbomb."];
        NSMutableArray *textures = [[NSMutableArray alloc] init];
        SKTexture *tex1 = [SKTexture textureWithImageNamed:@"Tornado1"];
        [textures addObject:tex1];
        tex1 = [SKTexture textureWithImageNamed:@"Tornado2"];
        [textures addObject:tex1];
        tex1 = [SKTexture textureWithImageNamed:@"Tornado3"];
        [textures addObject:tex1];
        tex1 = [SKTexture textureWithImageNamed:@"Tornado4"];
        [textures addObject:tex1];
        tex1 = [SKTexture textureWithImageNamed:@"Tornado5"];
        [textures addObject:tex1];
        tex1 = [SKTexture textureWithImageNamed:@"Tornado6"];
        [textures addObject:tex1];
        SKSpriteNode *tornado = [SKSpriteNode spriteNodeWithTexture:textures[0]];
        [tornado runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:0.150]]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [tornado setScale:2.0f];
        }
        tornado.position = CGPointMake(leftMarginWidth + tornado.size.width / 2.0f, screenSize.height - totalCurrentHeight - headerPixels);
        totalCurrentHeight += (1.5f * tornado.size.height) + paddingBetweenLines;
        [masterNode addChild:tornado];
        [self drawMessage: @"The repeller will bounce you back with a limited\nforce.  To overcome this ensure your eleczon is\nmoving fast enough before it hits this so it can\nmove through it with decreased speed."];
    }
    return self;
}

@end
