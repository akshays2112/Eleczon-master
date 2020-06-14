//
//  Level.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/1/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import "Level.h"
#import "GameOver.h"
#import "Help.h"

@implementation Level {
    NSTimeInterval lastTime;
    CGSize screenSize;
    BOOL victory;
    SKSpriteNode *masterNode;
    int mapTilesTotalWidth;
    int mapTilesTotalHeight;
    BOOL hasGun;
    int numBullets;
    NSTimeInterval lastTimeGunFired;
    SKSpriteNode *player;
    BOOL lastContactWithCloud;
    NSTimeInterval lastTimeContactWithCloud;
    NSMutableDictionary *teleports;
    CGFloat nodeHeight;
    CGFloat nodeWidth;
    BOOL defeat;
    NSMutableArray *oldNodes;
    BOOL updateCalled;
    BOOL gameIsPaused;
    SKSpriteNode *pauseGameButton;
    SKTexture *pauseButtonTexture;
    SKTexture *playButtonTexture;
    Help *helpScene;
    SKSpriteNode *shieldNode;
    NSMutableDictionary *sounds;
    SKLabelNode *energyLabel;
    SKLabelNode *levelLabel;
    SKLabelNode *livesLabel;
    SKLabelNode *shieldsLabel;
    SKLabelNode *bulletsLabel;
    CGFloat headerPixels;
    UIColor *energyTextColor;
    UIColor *energyNegativeTextColor;
    UIColor *livesTextColor;
    UIColor *livesNegativeTextColor;
    UIColor *shieldsTextColor;
    UIColor *shieldsNegativeTextColor;
    UIColor *bulletsTextColor;
    UIColor *levelTextColor;
    CGPoint lastPlayerPosition;
    CGFloat minScale;
    CGFloat maxScale;
    CGFloat currentScale;
    BOOL masterNodeSet;
    BOOL isBeingTeleported;
    CGPoint teleportOutPoint;
    UITapGestureRecognizer *tapRecognizer;
    UIPanGestureRecognizer *panRecognizer;
}

static const uint32_t elczonCategory = 0x1;
static const uint32_t chargerCategory = 0x1 << 1;
static const uint32_t dischargerCategory = 0x1 << 2;
static const uint32_t wallCategory = 0x1 << 3;
static const uint32_t endCategory = 0x1 << 4;
static const uint32_t gunCategory = 0x1 << 5;
static const uint32_t bulletCategory = 0x1 << 6;
static const uint32_t cloudCategory = 0x1 << 7;
static const uint32_t cloudsLightningCategory = 0x1 << 8;
static const uint32_t teleportInCategory = 0x1 << 9;
static const uint32_t teleportOutCategory = 0x1 << 10;
static const uint32_t tornadoCategory = 0x1 << 11;
static const uint32_t bombCategory = 0x1 << 12;
static const uint32_t levelUpCategory = 0x1 << 13;
static const uint32_t shieldCategory = 0x1 << 14;

static const int minMapCharsWide = 18;
static const int minMapCharsHigh = 20;

- (void)setWallNode:(NSString *) imageFileName i:(int)i size:(CGSize)size c:(int)c {
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imageFileName];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [node setScale:2.0f];
    }
    node.position = CGPointMake((c * nodeWidth) + 5 + nodeWidth / 2, mapTilesTotalHeight - (i * nodeHeight) - nodeHeight / 2 - headerPixels);
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size];
    node.physicsBody.categoryBitMask = wallCategory;
    node.physicsBody.dynamic = NO;
    [masterNode addChild: node];
}

- (SKSpriteNode *)addSpriteNode:(NSString *) imageFileName i: (int)i c:(int)c categoryBitMask: (uint32_t) categoryBitMask contactBitMask: (uint32_t) contactBitMask
    collisionBitMask: (uint32_t) collisionBitMask isPlayer: (BOOL) isPlayer isDynamic: (BOOL) isDynamic action: (SKAction *) action
    childNodeImageName: (NSString *) childNodeImageName childNodeAction: (SKAction *) childNodeAction childCategoryBitMask: (uint32_t) childCategoryBitMask {
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imageFileName];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [node setScale:2.0f];
    }
    node.position = CGPointMake((c * nodeWidth) + 5 + nodeWidth / 2, mapTilesTotalHeight - (i * nodeHeight) - nodeHeight / 2 - headerPixels);
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:nodeWidth / 2.0f - 1];
    node.physicsBody.categoryBitMask = categoryBitMask;
    node.physicsBody.contactTestBitMask = contactBitMask;
    node.physicsBody.collisionBitMask = collisionBitMask;
    if(!isPlayer) {
        node.physicsBody.dynamic = isDynamic;
        if(action) {
            [node runAction:[SKAction repeatActionForever:action]];
        }
        if(childNodeImageName) {
            SKSpriteNode *childNode = [SKSpriteNode spriteNodeWithImageNamed:childNodeImageName];
            childNode.position = CGPointMake(0, 0);
            childNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:childNode.size];
            childNode.physicsBody.categoryBitMask = childCategoryBitMask;
            childNode.physicsBody.collisionBitMask = 0;
            childNode.physicsBody.dynamic = NO;
            [childNode runAction: [SKAction repeatActionForever:childNodeAction]];
            [node addChild:childNode];
        }
    }
    [masterNode addChild: node];
    return node;
}

-(SKLabelNode *) createHeaderBarLabel: (int) value atX: (CGFloat) x atY: (CGFloat) y textColor: (UIColor *) textColor {
    SKLabelNode *nodeLabel = [SKLabelNode labelNodeWithFontNamed:gameFontName];
    nodeLabel.fontColor = textColor;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nodeLabel.fontSize = 25;
    } else {
        nodeLabel.fontSize = 12;
    }
    nodeLabel.text = [NSString stringWithFormat:@"%i", value];
    nodeLabel.position = CGPointMake(x + nodeLabel.frame.size.width / 2.0f, y + nodeLabel.frame.size.height / 2.0f);
    [self addChild:nodeLabel];
    return nodeLabel;
}

-(void) updateHeaderBarLabel {
    energyLabel.text = [NSString stringWithFormat:@"%i", playerEnergy];
    livesLabel.text = [NSString stringWithFormat:@"%i", playerLives];
    levelLabel.text = [NSString stringWithFormat:@"%i", playerCurrentLevelNumber];
    shieldsLabel.text = [NSString stringWithFormat:@"%i", self.shieldUp];
    bulletsLabel.text = [NSString stringWithFormat:@"%i", numBullets];
}

-(CGFloat) createHeaderIcon: (NSString *) imageName atX: (CGFloat) x atY: (CGFloat) y {
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [node setScale:2.0f];
    }
    node.position = CGPointMake(x, y + node.size.height / 2.0f);
    [self addChild:node];
    return node.size.width;
}

-(void) doAmountLabelAction: (int) amount initialPosition: (CGPoint) initialPosition textColor: (UIColor *) textColor {
    SKLabelNode *nodeLabel = [SKLabelNode labelNodeWithFontNamed:gameFontName];
    CGFloat y = 0.0f;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nodeLabel.fontSize = 25;
        y = 150.0f;
    } else {
        nodeLabel.fontSize = 12;
        y = 48.0f;
    }
    nodeLabel.fontColor = textColor;
    nodeLabel.text = [NSString stringWithFormat:@"%i", amount];
    nodeLabel.position = initialPosition;
    [masterNode addChild:nodeLabel];
    [nodeLabel runAction:[SKAction fadeAlphaTo:0.0f duration:4]];
    [nodeLabel runAction:[SKAction moveByX:0.0f y:y duration:4] completion:^{ [nodeLabel removeFromParent]; }];
}

-(void) setupScrolling {
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanned:)];
    [self.view addGestureRecognizer:panRecognizer];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

-(void)didMoveToView:(SKView *)view {
    [self setupScrolling];
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGFloat x = masterNode.position.x;
    if(mapTilesTotalWidth > screenSize.width && newPos.x + masterNode.position.x > screenSize.width - mapTilesTotalWidth - 10.0f && newPos.x + masterNode.position.x <= 10.0f) {
        x += newPos.x;
    }
    CGFloat y = masterNode.position.y;
    if(mapTilesTotalHeight + headerPixels > screenSize.height && masterNode.position.y - newPos.y > screenSize.height - mapTilesTotalHeight && masterNode.position.y - newPos.y <= headerPixels + 50.0f) {
        y -= newPos.y;
    }
    return CGPointMake(x, y);
}

- (void)panForTranslation:(CGPoint)translation {
    [masterNode setPosition:[self boundLayerPos:translation]];
}


- (void)viewPanned:(UIPanGestureRecognizer *)recognizer {
    [self panForTranslation:[recognizer translationInView:self.view]];
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    if(victory) {
        Level *level = [[Level alloc] initWithSize: self.size];
        playerEnergy = playerEnergy < 300 ? 300 : playerEnergy;
        playerLives = playerLives < 3 ? 3 : playerLives;
        [level updateHeaderBarLabel];
        [self.view presentScene:level transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
        //[level setupGestureHandlers];
        return;
    }
    CGPoint tapLocation = [recognizer locationInView:self.view];
    tapLocation = [self convertPointFromView:tapLocation];
    SKNode *node = [self nodeAtPoint:tapLocation];
    if ([node.name isEqualToString:@"HelpButton"]) {
        [self runAction:(SKAction *) sounds[@"Ting"]];
        gameIsPaused = YES;
        self.speed = 0.0f;
        self.physicsWorld.speed = 0.0f;
        pauseGameButton.texture = playButtonTexture;
        if(!helpScene) {
            helpScene = [[Help alloc] initWithSize:screenSize];
            helpScene.levelScene = self;
        }
        [self.view presentScene:helpScene transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
        [helpScene setupTapRecognizer:tapRecognizer panRecognizer: panRecognizer];
    } else if([node.name isEqualToString:@"PauseButton"]) {
        [self runAction:(SKAction *) sounds[@"Ting"]];
        if(gameIsPaused == NO) {
            gameIsPaused = YES;
            self.speed = 0.0f;
            self.physicsWorld.speed = 0.0f;
            pauseGameButton.texture = playButtonTexture;
        } else {
            gameIsPaused = NO;
            self.speed = 1.0f;
            self.physicsWorld.speed = 1.0f;
            pauseGameButton.texture = pauseButtonTexture;
        }
    } else if([node.name isEqualToString:@"EnergyLeaderboardButton"]) {
        [self runAction:(SKAction *) sounds[@"Ting"]];
        gameIsPaused = YES;
        self.speed = 0.0f;
        self.physicsWorld.speed = 0.0f;
        pauseGameButton.texture = playButtonTexture;
        GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
        gcViewController.gameCenterDelegate = self;
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = @"EleczonLeaderboard";
        [self.view.window.rootViewController presentViewController:gcViewController animated:YES completion:nil];
    } else if([node.name isEqualToString:@"ReloadMazeButton"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eleczon" message:@"Are you sure you want to reset the maze and get a new maze?" delegate:self
                                              cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
    }
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        isBeingTeleported = NO;
        self.speed = 0;
        self.physicsWorld.speed = 0;
        minScale = 0.5f;
        maxScale = 2.0f;
        currentScale = 1.0f;
        updateCalled = NO;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            headerPixels = 100;
        } else {
            headerPixels = 50;
        }
        playerEnergy = (playerEnergy > 2000 ? playerEnergy : 2000);
        self.physicsWorld.gravity = CGVectorMake(0.0f, -9.8f);
        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        SKSpriteNode *backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"Background2"];
        backgroundImageNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:backgroundImageNode];
        int temptiles = (int)floorf((float)playerCurrentLevelNumber / 15.0f);
        temptiles = temptiles < 16 ? temptiles : 15;
        int numtileswide = minMapCharsWide + temptiles;
        int numtileshigh = minMapCharsHigh + (temptiles * 2) + 1;
        NSMutableArray *maplines = [self createASCIIMapLevel: numtileswide numCharsHigh:numtileshigh];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"WallTopLeft"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [node setScale:2.0f];
        }
        screenSize = size;
        nodeHeight = node.size.height;
        nodeWidth = node.size.width;
        mapTilesTotalWidth = nodeWidth * (((NSString *)maplines[0]).length);
        mapTilesTotalHeight = nodeHeight * maplines.count;
        masterNode = [[SKSpriteNode alloc] init];
        [masterNode setPosition: CGPointMake(0.0f, size.height - mapTilesTotalHeight - 50.0f)];
        [masterNode setSize:CGSizeMake(mapTilesTotalWidth + 10.0f, mapTilesTotalHeight)];
        masterNodeSet = YES;
        [self addChild:masterNode];
        numBullets = 0;
        BOOL foundE = NO;
        teleports = [[NSMutableDictionary alloc] init];
        NSMutableArray *teleportsIn = [[NSMutableArray alloc] init];
        NSMutableArray *teleportsOut = [[NSMutableArray alloc] init];
        for(int i=0;i<maplines.count;i++) {
            if(!foundE) {
                for(int c=0;c<((NSString *)maplines[i]).length;c++){
                    char maplineletter = [((NSString *)maplines[i]) characterAtIndex:c];
                    if(maplineletter == '+') {
                        [self setWallNode:@"WallTopLeft" i:i size:size  c:c];
                    } else if(maplineletter == '-') {
                        [self setWallNode:@"WallTopRight" i:i size:size  c:c];
                    } else if(maplineletter == '&') {
                        [self setWallNode:@"WallTopMiddle" i:i size:size  c:c];
                    } else if(maplineletter == '|') {
                        [self setWallNode:@"WallLeft" i:i size:size  c:c];
                    } else if(maplineletter == ']') {
                        [self setWallNode:@"WallRight" i:i size:size  c:c];
                    } else if(maplineletter == ':') {
                        [self setWallNode:@"WallBottomLeft" i:i size:size  c:c];
                    } else if(maplineletter == ';') {
                        [self setWallNode:@"WallBottomRight" i:i size:size  c:c];
                    } else if(maplineletter == '}') {
                        [self setWallNode:@"WallBottomMiddle" i:i size:size  c:c];
                    } else if(maplineletter == '=') {
                        [self setWallNode:@"WallMiddleMiddle" i:i size:size  c:c];
                    } else if(maplineletter == ')') {
                        [self setWallNode:@"WallMiddleLeftCap" i:i size:size  c:c];
                    } else if(maplineletter == '(') {
                        [self setWallNode:@"WallMiddleRightCap" i:i size:size  c:c];
                    } else if(maplineletter == '$') {
                        [self setWallNode:@"WallBottomRightCap" i:i size:size  c:c];
                    } else if(maplineletter == '%') {
                        [self setWallNode:@"WallBottomLeftCap" i:i size:size  c:c];
                    } else if(maplineletter == 'P') {
                        player = [self addSpriteNode:@"Eleczon" i:i c:c categoryBitMask:elczonCategory contactBitMask: chargerCategory | dischargerCategory |
                            endCategory | gunCategory | cloudCategory | teleportInCategory | tornadoCategory | bombCategory | levelUpCategory | shieldCategory
                            collisionBitMask:wallCategory isPlayer: YES isDynamic: NO action:nil childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0];
                    } else if(maplineletter == 'C') {
                        [self addSpriteNode:@"Charger" i:i c:c categoryBitMask:chargerCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:[SKAction repeatActionForever:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:1.0], [SKAction fadeAlphaTo:1.0 duration:1.0]]]]
                            childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0];
                    } else if(maplineletter == 'D') {
                        [self addSpriteNode:@"Discharger" i:i c:c categoryBitMask:dischargerCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:[SKAction repeatActionForever:[SKAction rotateByAngle:-0.1 duration:0.1]] childNodeImageName:nil childNodeAction:nil
                            childCategoryBitMask:0];
                    } else if(maplineletter == 'E') {
                        SKNode *endnode = [[SKNode alloc] init];
                        endnode.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, mapTilesTotalHeight - (i * nodeHeight) - nodeHeight / 2 - headerPixels) toPoint:CGPointMake(mapTilesTotalWidth, mapTilesTotalHeight - (i * nodeHeight) - nodeHeight / 2 - headerPixels)];
                        endnode.physicsBody.categoryBitMask = endCategory;
                        endnode.physicsBody.collisionBitMask = 0;
                        endnode.physicsBody.dynamic = NO;
                        [masterNode addChild:endnode];
                        foundE = YES;
                    } else if(maplineletter == 'G') {
                        [self addSpriteNode:@"Gun" i:i c:c categoryBitMask:gunCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:1.0], [SKAction fadeAlphaTo:1.0 duration:1.0]]]
                            childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0];
                    } else if(maplineletter == 'L') {
                        [self addSpriteNode:@"Cloud" i:i c:c categoryBitMask:cloudCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO action:nil
                            childNodeImageName:@"CloudsLightning"
                            childNodeAction:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:0.2], [SKAction fadeAlphaTo:1.0 duration:0.2]]]
                            childCategoryBitMask: cloudsLightningCategory];
                    } else if(maplineletter == 'I') {
                        [teleportsIn addObject:[self addSpriteNode:@"TeleportIn" i:i c:c categoryBitMask:teleportInCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:[SKAction rotateByAngle:-0.1 duration:0.1] childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0]];
                    } else if(maplineletter == 'O') {
                        [teleportsOut addObject:[self addSpriteNode:@"TeleportOut" i:i c:c categoryBitMask:teleportOutCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:[SKAction rotateByAngle:0.1 duration:0.1] childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0]];
                    } else if(maplineletter == 'T') {
                        [self addAnimatedSpriteNode: @[@"Tornado1", @"Tornado2", @"Tornado3", @"Tornado4", @"Tornado5", @"Tornado6"] timePerFrame: 0.150 c: c i: i categoryBitMask: tornadoCategory collisionBitMask: 0 isDynamic: NO];
                    } else if(maplineletter == 'B') {
                        [self addSpriteNode:@"Bomb" i:i c:c categoryBitMask:bombCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:0.5], [SKAction fadeAlphaTo:1.0 duration:0.5]]]
                            childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0];
                    } else if(maplineletter == 'U') {
                        [self addSpriteNode:@"LevelUp" i:i c:c categoryBitMask:levelUpCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:[SKAction sequence: @[[SKAction fadeAlphaTo:0.25 duration:0.25], [SKAction fadeAlphaTo:1.0 duration:0.25]]]
                            childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0];
                    } else if(maplineletter == 'S') {
                        SKSpriteNode *shield = [self addSpriteNode:@"Shield" i:i c:c categoryBitMask:shieldCategory contactBitMask:0 collisionBitMask:0 isPlayer:NO isDynamic:NO
                            action:nil childNodeImageName:nil childNodeAction:nil childCategoryBitMask:0];
                        SKEmitterNode *shieldEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"ShieldEffect" ofType:@"sks"]];
                        shieldEmitter.position = CGPointZero;
                        [shield addChild:shieldEmitter];
                    }
                }
            } else {
                NSArray *teleportConnectNumbers = [((NSString *)maplines[i]) componentsSeparatedByString:@","];
                int i=0;
                for(NSString *teleOutIndex in teleportConnectNumbers) {
                    [teleports setObject:teleportsOut[[teleOutIndex integerValue]] forKey:teleportsIn[i]];
                    i++;
                }
            }
        }
        lastTime = 0;
        victory = NO;
        defeat = NO;
        hasGun = NO;
        lastTimeGunFired = 0;
        lastContactWithCloud = NO;
        lastTimeContactWithCloud = 0;
        oldNodes = [[NSMutableArray alloc] init];
        SKSpriteNode *helpButton = [SKSpriteNode spriteNodeWithImageNamed:@"HelpButton"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [helpButton setScale:2.0f];
        }
        helpButton.position = CGPointMake(size.width - 5 - helpButton.size.width / 2, 5 + helpButton.size.height / 2);
        helpButton.name = @"HelpButton";
        helpButton.userInteractionEnabled = NO;
        [self addChild:helpButton];
        gameIsPaused = NO;
        pauseButtonTexture = [SKTexture textureWithImageNamed:@"PauseButton"];
        playButtonTexture = [SKTexture textureWithImageNamed:@"PlayButton"];
        pauseGameButton = [SKSpriteNode spriteNodeWithTexture:pauseButtonTexture];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [pauseGameButton setScale:2.0f];
        }
        pauseGameButton.position = CGPointMake(helpButton.position.x - helpButton.size.width / 2.0f - 30.0f - pauseGameButton.size.width / 2.0f, helpButton.position.y);
        pauseGameButton.name = @"PauseButton";
        pauseGameButton.userInteractionEnabled = NO;
        [self addChild:pauseGameButton];
        SKSpriteNode *energyLeaderboardButton = [SKSpriteNode spriteNodeWithImageNamed:@"EnergyLeaderboardButton"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [energyLeaderboardButton setScale:2.0f];
        }
        energyLeaderboardButton.position = CGPointMake(pauseGameButton.position.x - pauseGameButton.size.width / 2.0f - 30.0f - energyLeaderboardButton.size.width / 2.0f,
            pauseGameButton.position.y);
        energyLeaderboardButton.name = @"EnergyLeaderboardButton";
        energyLeaderboardButton.userInteractionEnabled = NO;
        [self addChild:energyLeaderboardButton];
        SKSpriteNode *reloadMazeButton = [SKSpriteNode spriteNodeWithImageNamed:@"ReloadMazeButton"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [reloadMazeButton setScale:2.0f];
        }
        reloadMazeButton.position = CGPointMake(energyLeaderboardButton.position.x - energyLeaderboardButton.size.width / 2.0f - 30.0f - reloadMazeButton.size.width / 2.0f,
                                                       energyLeaderboardButton.position.y);
        reloadMazeButton.name = @"ReloadMazeButton";
        reloadMazeButton.userInteractionEnabled = NO;
        [self addChild:reloadMazeButton];
        energyTextColor = [SKColor colorWithRed:252.0f/255.0f green:1.0f blue:0.0f alpha:1.0f];
        livesTextColor = [SKColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
        shieldsTextColor = [SKColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
        bulletsTextColor = [SKColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];
        levelTextColor = [SKColor colorWithRed:148.0f/255.0f green:215.0f/255.0f blue:43.0f/255.0f alpha:1.0f];
        energyNegativeTextColor = [SKColor colorWithRed:104.0f/255.0f green:111.0f/255.0f blue:0.0f alpha:1.0f];
        livesNegativeTextColor = [SKColor colorWithRed:78.0f/255.0f green:21.0f/255.0f blue:21.0f/255.0f alpha:1.0f];
        shieldsNegativeTextColor = [SKColor colorWithRed:7.0f/255.0f green:13.0f/255.0f blue:78.0f/255.0f alpha:1.0f];
        CGFloat totalWidth = 40.0f;
        CGFloat headerY = size.height - headerPixels + 20.0f;
        totalWidth += [self createHeaderIcon:@"EnergyIcon" atX:totalWidth atY:headerY];
        energyLabel = [self createHeaderBarLabel:playerEnergy atX:totalWidth + 5.0f atY:headerY - 2.0f textColor:energyTextColor];
        totalWidth += (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 280.0f : 80.0f);
        totalWidth += [self createHeaderIcon:@"LivesIcon" atX:totalWidth atY:headerY];
        livesLabel = [self createHeaderBarLabel:playerLives atX:totalWidth atY:headerY - 2.0f textColor:livesTextColor];
        totalWidth += (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80.0f : 30.0f);
        totalWidth += [self createHeaderIcon:@"ShieldIcon" atX:totalWidth atY:headerY];
        shieldsLabel = [self createHeaderBarLabel:self.shieldUp atX:totalWidth atY:headerY - 2.0f textColor:shieldsTextColor];
        totalWidth += (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80.0f : 30.0f);
        totalWidth += [self createHeaderIcon:@"BulletGreenRight" atX:totalWidth atY:headerY];
        bulletsLabel = [self createHeaderBarLabel:numBullets atX:totalWidth atY:headerY - 2.0f textColor:bulletsTextColor];
        totalWidth += (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80.0f : 30.0f);
        totalWidth += [self createHeaderIcon:@"LevelIcon" atX:totalWidth atY:headerY];
        levelLabel = [self createHeaderBarLabel:playerCurrentLevelNumber atX:totalWidth atY:headerY - 2.0f textColor:levelTextColor];
        [self updateHeaderBarLabel];
        self.shieldUp = 0;
        sounds = [[NSMutableDictionary alloc] init];
        //afconvert -f caff -d LEI16@44100 -c 1 bullet.wav bullet.caf
        [sounds setValue:[SKAction playSoundFileNamed:@"Thunder.caf" waitForCompletion:NO] forKey:@"Cloud"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Charger.caf" waitForCompletion:NO] forKey:@"Charger"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Discharge.caf" waitForCompletion:NO] forKey:@"Discharger"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Shield.caf" waitForCompletion:NO] forKey:@"ShieldedFromBomb"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Bomb.caf" waitForCompletion:NO] forKey:@"Bomb"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Tornado.caf" waitForCompletion:NO] forKey:@"Tornado"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Ting.caf" waitForCompletion:NO] forKey:@"Gun"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Ting.caf" waitForCompletion:NO] forKey:@"Wall"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Ting.caf" waitForCompletion:NO] forKey:@"TeleportIn"];
        [sounds setValue:[SKAction playSoundFileNamed:@"GameStartup.caf" waitForCompletion:NO] forKey:@"Victory"];
        [sounds setValue:[SKAction playSoundFileNamed:@"BulletHit.caf" waitForCompletion:NO] forKey:@"BulletHitWall"];
        [sounds setValue:[SKAction playSoundFileNamed:@"BulletHit.caf" waitForCompletion:NO] forKey:@"BulletHitDischarger"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Bomb.caf" waitForCompletion:NO] forKey:@"BulletHitBomb"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Ting.caf" waitForCompletion:NO] forKey:@"LevelUp"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Shield.caf" waitForCompletion:NO] forKey:@"GotAShield"];
        [sounds setValue:[SKAction playSoundFileNamed:@"Ting.caf" waitForCompletion:NO] forKey:@"ButtonPress"];
        self.speed = 1.0f;
        self.physicsWorld.speed = 1.0f;
    }
    return self;
}

-(void) addAnimatedSpriteNode: (NSArray *) imageNames timePerFrame: (float) timePerFrame c: (int) c i: (int) i categoryBitMask: (uint32_t) categoryBitMask
             collisionBitMask: (uint32_t) collisionBitMask isDynamic: (BOOL) isDynamic {
    NSMutableArray *textures = [[NSMutableArray alloc] init];
    for(NSString *imageName in imageNames) {
        SKTexture *tex1 = [SKTexture textureWithImageNamed:imageName];
        [textures addObject:tex1];
    }
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:textures[0]];
    [node runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:textures timePerFrame:timePerFrame]]];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [node setScale:2.0f];
    }
    node.position = CGPointMake((c * nodeWidth) + 5 + nodeWidth / 2, mapTilesTotalHeight - (i * nodeHeight) - nodeHeight / 2 - headerPixels);
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:nodeWidth / 2.0f];
    node.physicsBody.categoryBitMask = categoryBitMask;
    node.physicsBody.collisionBitMask = collisionBitMask;
    node.physicsBody.dynamic = isDynamic;
    [masterNode addChild:node];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKSpriteNode *node;
    BOOL contactWithCharger = NO;
    BOOL contactWithDischarger = NO;
    BOOL contactWithEnd = NO;
    BOOL contactWithGun = NO;
    BOOL bulletHitWall = NO;
    BOOL bulletHitDischarger = NO;
    BOOL bulletHitBomb = NO;
    BOOL contactWithTeleport = NO;
    BOOL contactWithTornado = NO;
    BOOL contactWithBomb = NO;
    BOOL contactWithLevelUp = NO;
    BOOL contactWithShield = NO;
    SKSpriteNode *discharger;
    SKSpriteNode *bomb;
    if(contact.bodyA.categoryBitMask == chargerCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithCharger = YES;
    } else if(contact.bodyB.categoryBitMask == chargerCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithCharger = YES;
    } else if(contact.bodyA.categoryBitMask == dischargerCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithDischarger = YES;
    } else if(contact.bodyB.categoryBitMask == dischargerCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithDischarger = YES;
    } else if(contact.bodyA.categoryBitMask == endCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithEnd = YES;
    } else if(contact.bodyB.categoryBitMask == endCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithEnd = YES;
    } else if(contact.bodyA.categoryBitMask == gunCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithGun = YES;
    } else if(contact.bodyB.categoryBitMask == gunCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithGun = YES;
    } else if(contact.bodyA.categoryBitMask == teleportInCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithTeleport = YES;
    } else if(contact.bodyB.categoryBitMask == teleportInCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithTeleport = YES;
    } else if(contact.bodyA.categoryBitMask == tornadoCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithTornado = YES;
    } else if(contact.bodyB.categoryBitMask == tornadoCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithTornado = YES;
    } else if(contact.bodyA.categoryBitMask == bombCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithBomb = YES;
    } else if(contact.bodyB.categoryBitMask == bombCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithBomb = YES;
    } else if(contact.bodyA.categoryBitMask == levelUpCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithLevelUp = YES;
    } else if(contact.bodyB.categoryBitMask == levelUpCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithLevelUp = YES;
    } else if(contact.bodyA.categoryBitMask == shieldCategory && contact.bodyB.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        contactWithShield = YES;
    } else if(contact.bodyB.categoryBitMask == shieldCategory && contact.bodyA.categoryBitMask == elczonCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        contactWithShield = YES;
    } else if(contact.bodyA.categoryBitMask == bulletCategory) {
        node = (SKSpriteNode *) contact.bodyA.node;
        if (contact.bodyB.categoryBitMask == wallCategory) {
            bulletHitWall = YES;
        } else if(contact.bodyB.categoryBitMask == dischargerCategory) {
            discharger = (SKSpriteNode *) contact.bodyB.node;
            bulletHitDischarger = YES;
        } else if(contact.bodyB.categoryBitMask == bombCategory) {
            bomb = (SKSpriteNode *) contact.bodyB.node;
            bulletHitBomb = YES;
        }
    } else if(contact.bodyB.categoryBitMask == bulletCategory) {
        node = (SKSpriteNode *) contact.bodyB.node;
        if (contact.bodyA.categoryBitMask == wallCategory) {
            bulletHitWall = YES;
        } else if (contact.bodyA.categoryBitMask == dischargerCategory) {
            discharger = (SKSpriteNode *) contact.bodyA.node;
            bulletHitDischarger = YES;
        } else if(contact.bodyA.categoryBitMask == bombCategory) {
            bomb = (SKSpriteNode *) contact.bodyA.node;
            bulletHitBomb = YES;
        }
    } else if(!lastContactWithCloud && ((contact.bodyA.categoryBitMask == cloudCategory && contact.bodyB.categoryBitMask == elczonCategory) || (contact.bodyB.categoryBitMask == cloudCategory && contact.bodyA.categoryBitMask == elczonCategory))) {
        [self runAction:(SKAction *) sounds[@"Cloud"]];
        int amt = 1000 + ((arc4random() % playerCurrentLevelNumber) * 100);
        playerEnergy += amt;
        [self updateHeaderBarLabel];
        lastContactWithCloud = YES;
        if(contact.bodyA.categoryBitMask == cloudCategory) {
            node = (SKSpriteNode *) contact.bodyA.node;
        } else {
            node = (SKSpriteNode *) contact.bodyB.node;
        }
        [self doAmountLabelAction:amt initialPosition:node.position textColor:energyTextColor];
        SKEmitterNode *chargerEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"ChargerEffect" ofType:@"sks"]];
        chargerEmitter.position = node.position;
        chargerEmitter.numParticlesToEmit = 100;
        [masterNode addChild:chargerEmitter];
    }
    if(contactWithCharger) {
        [self runAction:(SKAction *) sounds[@"Charger"]];
        int amt = 100 + (arc4random() % playerCurrentLevelNumber);
        playerEnergy += amt;
        [self doAmountLabelAction:amt initialPosition:node.position textColor:energyTextColor];
        SKEmitterNode *chargerEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"ChargerEffect" ofType:@"sks"]];
        chargerEmitter.position = node.position;
        chargerEmitter.numParticlesToEmit = 50;
        [masterNode addChild:chargerEmitter];
        [node runAction:[SKAction fadeAlphaTo:0.0f duration:0.5f] completion:^{ [node removeFromParent]; }];
    }
    if(contactWithDischarger) {
        [self runAction:(SKAction *) sounds[@"Discharger"]];
        int amt = 100 + (arc4random() % playerCurrentLevelNumber);
        playerEnergy -= amt;
        [self doAmountLabelAction:-amt initialPosition:node.position textColor:energyNegativeTextColor];
        [self updateHeaderBarLabel];
        SKEmitterNode *chargerEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"DischargerEffect" ofType:@"sks"]];
        chargerEmitter.position = node.position;
        chargerEmitter.numParticlesToEmit = 50;
        [masterNode addChild:chargerEmitter];
        [node runAction:[SKAction fadeAlphaTo:0.0f duration:0.5] completion:^{ [node removeFromParent]; }];
    }
    if(contactWithCharger || contactWithDischarger) {
        [node runAction:[SKAction fadeAlphaTo:0.0f duration:0.5] completion:^{ [node removeFromParent]; }];
        [self updateHeaderBarLabel];
    }
    if(contactWithEnd) {
        [self runAction:(SKAction *) sounds[@"Victory"]];
        SKAction *fade = [SKAction fadeAlphaTo:0.0f duration:0.5];
        [node runAction:fade completion:^{ [node removeFromParent]; }];
        SKLabelNode *victoryLabel = [SKLabelNode labelNodeWithFontNamed:gameFontName];
        victoryLabel.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            victoryLabel.fontSize = 100;
        } else {
            victoryLabel.fontSize = 50;
        }
        victoryLabel.fontColor = [SKColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f];
        victoryLabel.text = @"Victory!!!";
        [victoryLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeAlphaTo:0.5 duration:0.25], [SKAction fadeAlphaTo:1.0 duration:0.25]]]]];
        [self addChild:victoryLabel];
        victory = YES;
        playerCurrentLevelNumber++;
        [[NSUserDefaults standardUserDefaults] setInteger:playerEnergy forKey:@"com.epic3dmud.eleczon.energy"];
        [[NSUserDefaults standardUserDefaults] setInteger:playerLives forKey:@"com.epic3dmud.eleczon.lives"];
        [[NSUserDefaults standardUserDefaults] setInteger:playerCurrentLevelNumber forKey:@"com.epic3dmud.eleczon.level"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(self.gameCenter.gameCenterEnabled) {
            [self.gameCenter reportEnergy:playerEnergy];
        }
    }
    if(contactWithGun) {
        [self runAction:(SKAction *) sounds[@"Gun"]];
        [node removeFromParent];
        hasGun = YES;
        numBullets += 10;
    }
    if(bulletHitWall) {
        [self runAction:(SKAction *) sounds[@"BulletHitWall"]];
        SKEmitterNode *chargerEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BulletHitEffect" ofType:@"sks"]];
        chargerEmitter.position = node.position;
        [masterNode addChild:chargerEmitter];
        [node removeFromParent];
    } else if(bulletHitDischarger) {
        int amt = 100 + (arc4random() % playerCurrentLevelNumber);
        playerEnergy += amt;
        [self doAmountLabelAction:amt initialPosition:node.position textColor:energyTextColor];
        [self runAction:(SKAction *) sounds[@"BulletHitDischarger"]];
        SKEmitterNode *bulletEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BulletHitEffect" ofType:@"sks"]];
        bulletEmitter.position = node.position;
        [masterNode addChild:bulletEmitter];
        [node removeFromParent];
        [discharger runAction:[SKAction fadeAlphaTo:0.0f duration:0.2] completion:^{ [discharger removeFromParent]; }];
        [self updateHeaderBarLabel];
    } else if(bulletHitBomb) {
        [self runAction:(SKAction *) sounds[@"BulletHitBomb"]];
        SKEmitterNode *bulletEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BulletHitEffect" ofType:@"sks"]];
        bulletEmitter.position = node.position;
        [masterNode addChild:bulletEmitter];
        [node removeFromParent];
        [bomb removeFromParent];
    }
    if(contactWithTeleport) {
        for(SKSpriteNode *key in teleports.allKeys) {
            if(truncf(key.position.x) == truncf(node.position.x) && truncf(key.position.y) == truncf(node.position.y)) {
                [self runAction:(SKAction *) sounds[@"TeleportIn"]];
                SKSpriteNode *teleportOut = teleports[key];
                isBeingTeleported = YES;
                teleportOutPoint = teleportOut.position;
                /*
                CGFloat tempzRotation = player.zRotation;
                [player removeFromParent];
                player = [SKSpriteNode spriteNodeWithImageNamed:@"Eleczon"];
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [player setScale:2.0f];
                }
                player.zRotation = tempzRotation;
                player.position = teleportOut.position;
                player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:nodeWidth / 2.0f - 1];
                player.physicsBody.categoryBitMask = elczonCategory;
                player.physicsBody.contactTestBitMask = chargerCategory | dischargerCategory | endCategory | gunCategory | cloudCategory | teleportInCategory |
                    tornadoCategory | bombCategory | levelUpCategory | shieldCategory;
                player.physicsBody.collisionBitMask = wallCategory;
                [masterNode addChild: player];
                 */
                break;
            }
        }
    }
    if(contactWithTornado) {
        [self runAction:(SKAction *) sounds[@"Tornado"]];
        if(player.physicsBody.velocity.dx < 100.0f) {
            [player.physicsBody applyImpulse:CGVectorMake(4.0f * (player.physicsBody.velocity.dx > 0.0f ? -1.0f : 1.0f), 0)];
        }
    }
    if(contactWithBomb && [self nodeNotInOldNodes:node]) {
        if(self.shieldUp > 0) {
            [self runAction:(SKAction *) sounds[@"ShieldedFromBomb"]];
            self.shieldUp--;
            [self doAmountLabelAction:-1 initialPosition:node.position textColor:shieldsNegativeTextColor];
            if(self.shieldUp < 0) {
                self.shieldUp = 0;
            }
            [oldNodes addObject:node];
            [node removeFromParent];
            if(self.shieldUp == 0) {
                [shieldNode removeFromParent];
            }
        } else {
            [self runAction:(SKAction *) sounds[@"Bomb"]];
            playerLives--;
            [self doAmountLabelAction:-1 initialPosition:node.position textColor:livesNegativeTextColor];
            if(playerLives <= 0) {
                [self.view removeGestureRecognizer:panRecognizer];
                [self.view removeGestureRecognizer:tapRecognizer];
                GameOver *scene = [[GameOver alloc] initWithSize: screenSize];
                scene.gameCenter = self.gameCenter;
                [self.view presentScene:scene transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
                defeat = YES;
                return;
            }
            [self updateHeaderBarLabel];
            SKEmitterNode *bombEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"BulletHitEffect" ofType:@"sks"]];
            bombEmitter.position = node.position;
            [oldNodes addObject:node];
            [node removeFromParent];
            [masterNode addChild:bombEmitter];
        }
    }
    if(contactWithLevelUp) {
        [self doAmountLabelAction:-1 initialPosition:node.position textColor:livesTextColor];
        [self runAction:(SKAction *) sounds[@"LevelUp"]];
        SKEmitterNode *chargerEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"LevelUpEffect" ofType:@"sks"]];
        chargerEmitter.position = node.position;
        [masterNode addChild:chargerEmitter];
        [node runAction:[SKAction fadeAlphaTo:0.0f duration:0.2] completion:^{ [node removeFromParent]; }];
        playerLives++;
        [self updateHeaderBarLabel];
    }
    if(contactWithShield) {
        [self doAmountLabelAction:1 initialPosition:node.position textColor:shieldsTextColor];
        [self runAction:(SKAction *) sounds[@"GotAShield"]];
        [node removeFromParent];
        if(self.shieldUp == 0) {
            shieldNode = [SKSpriteNode spriteNodeWithImageNamed:@"Shield"];
            shieldNode.position = CGPointZero;
            [player addChild:shieldNode];
        }
        self.shieldUp++;
    }
}

-(BOOL)nodeNotInOldNodes: (SKSpriteNode *) node {
    for(SKSpriteNode *oldnode in oldNodes) {
        if(node == oldnode) {
            return NO;
        }
    }
    return YES;
}

-(void)didSimulatePhysics {
    if(isBeingTeleported) {
        isBeingTeleported = NO;
        [player setPosition:teleportOutPoint];
    }
}

-(void)update:(NSTimeInterval)currentTime {
    if(gameIsPaused) {
        return;
    }
    if(!updateCalled) {
        updateCalled = YES;
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.1;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
            withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                 self.physicsWorld.gravity = CGVectorMake(accelerometerData.acceleration.x * 2.5f, accelerometerData.acceleration.y * 2.5f);
        }];
    }
    if(!victory && !defeat) {
        if(currentTime - lastTime > 1) {
            playerEnergy -= 1;
            lastTime = currentTime;
            [self updateHeaderBarLabel];
        }
        if(playerEnergy < 0) {
            if(playerLives > 1) {
                playerLives--;
                playerEnergy = 2000;
                [self updateHeaderBarLabel];
            } else {
                [self.view removeGestureRecognizer:panRecognizer];
                [self.view removeGestureRecognizer:tapRecognizer];
                GameOver *scene = [[GameOver alloc] initWithSize: screenSize];
                scene.gameCenter = self.gameCenter;
                [self.view presentScene:scene transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
                defeat = YES;
                return;
            }
        }
        if(hasGun && numBullets > 0) {
            if(currentTime - lastTimeGunFired > 1 && ((player.position.x > 5 + 2 * player.size.width && self.physicsWorld.gravity.dx < 0) ||
               (player.position.x < mapTilesTotalWidth - 2 * player.size.width && self.physicsWorld.gravity.dx > 0))) {
                lastTimeGunFired = currentTime;
                numBullets--;
                NSString *bulletImageName;
                int offsetX = 0;
                CGFloat forceX = 0;
                if(self.physicsWorld.gravity.dx < 0) {
                    bulletImageName = @"BulletGreenLeft";
                    offsetX = player.size.width + 1;
                    forceX = -1000.0f;
                } else {
                    bulletImageName = @"BulletGreenRight";
                    offsetX = player.size.width - 1;
                    forceX = 1000.0f;
                }
                SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:bulletImageName];
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [bullet setScale:2.0f];
                }
                bullet.position = CGPointMake(player.position.x + offsetX, player.position.y + 5);
                bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bullet.size.width, bullet.size.height - 10)];
                bullet.physicsBody.categoryBitMask = bulletCategory;
                bullet.physicsBody.contactTestBitMask = wallCategory | dischargerCategory | bombCategory;
                bullet.physicsBody.collisionBitMask = wallCategory | dischargerCategory;
                bullet.physicsBody.affectedByGravity = NO;
                [masterNode addChild:bullet];
                [bullet.physicsBody applyForce:CGVectorMake(forceX, 0.0f)];
            }
        } else {
            hasGun = NO;
            numBullets = 0;
        }
        if(lastContactWithCloud && currentTime - lastTimeContactWithCloud > 60) {
            if(lastTimeContactWithCloud > 0) {
                lastContactWithCloud = NO;
            }
            lastTimeContactWithCloud = currentTime;
        }
        CGFloat dx = 0;
        CGFloat dy = 0;
        if(masterNode.position.x + player.position.x > screenSize.width / 2 && player.position.x != lastPlayerPosition.x) {
            dx = lastPlayerPosition.x - player.position.x;
            lastPlayerPosition.x = player.position.x;
        }
        if(masterNode.position.x + player.position.x < screenSize.width / 2 && player.position.y != lastPlayerPosition.y) {
            dy = lastPlayerPosition.y - player.position.y;
            lastPlayerPosition.y = player.position.y;
        }
        if(dx!=0 || dy!=0) {
            [self panForTranslation:CGPointMake(dx, -dy)];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        Level *level = [[Level alloc] initWithSize: self.size];
        level.gameCenter = self.gameCenter;
        [self.view presentScene:level transition:[SKTransition doorsOpenHorizontalWithDuration:0.5]];
    }
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(NSMutableArray *) createASCIIMapLevel: (int) numCharsWide numCharsHigh: (int) numCharsHigh {
    int randomTries = MAX(1000 - playerCurrentLevelNumber, 900);
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    int teleportsIn = 0;
    for(int currentCharsHigh = 0; currentCharsHigh < numCharsHigh; currentCharsHigh++) {
        NSMutableString *currentLine = [[NSMutableString alloc] init];
        for(int currentCharsWide = 0; currentCharsWide < numCharsWide; currentCharsWide++) {
            if(currentCharsHigh == 1 && currentCharsWide == 1) {
                [currentLine appendString:@"P"];
            } else if(currentCharsHigh == 0 && currentCharsWide == 0) {
                [currentLine appendString:@"+"];
            } else if(currentCharsHigh == 0 && currentCharsWide == numCharsWide - 1) {
                [currentLine appendString:@"-"];
            } else if(currentCharsHigh == 0) {
                [currentLine appendString:@"&"];
            } else if(currentCharsHigh == numCharsHigh - 1 && currentCharsWide == 0) {
                [currentLine appendString:@":"];
            } else if(currentCharsHigh == numCharsHigh - 1 && currentCharsWide == numCharsWide - 1) {
                [currentLine appendString:@";"];
            } else if(currentCharsHigh == numCharsHigh - 1) {
                [currentLine appendString:@"}"];
            } else if(currentCharsWide == 0) {
                [currentLine appendString:@"|"];
            } else if(currentCharsWide == numCharsWide - 1) {
                [currentLine appendString:@"]"];
            } else if(currentCharsHigh % 2 == 1) {
                int maxTemp = numCharsWide - (currentCharsHigh == 1 ? 3 : 2);
                for(int i=0; i<maxTemp;i++) {
                    int tempTry = arc4random() % randomTries;
                    if(arc4random() % 4 > 0) {
                        [currentLine appendString:@" "];
                    } else if(tempTry > 0 && tempTry < 500) {
                        [currentLine appendString:@"C"];
                    } else if(tempTry >=500 && tempTry < 650) {
                        [currentLine appendString:@"D"];
                    } else if(tempTry >=650 && tempTry < 675) {
                        [currentLine appendString:@"G"];
                    } else if(tempTry >=675 && tempTry < 700) {
                        [currentLine appendString:@"L"];
                    } else if(tempTry >= 700 && tempTry < 725) {
                        [currentLine appendString:@"T"];
                    } else if(tempTry >= 725 && tempTry < 750) {
                        [currentLine appendString:@"B"];
                    } else if(tempTry >= 750 && tempTry < 775) {
                        [currentLine appendString:@"U"];
                    } else if(tempTry >= 775 && tempTry < 800) {
                        [currentLine appendString:@"S"];
                    } else if(tempTry >= 800 && tempTry < 825) {
                        [currentLine appendString:@"I"];
                        teleportsIn++;
                    } else {
                        [currentLine appendString:@" "];
                    }
                    currentCharsWide++;
                }
                currentCharsWide--;
                
            } else if(currentCharsHigh % 2 == 0) {
                int maxholestoroll = (int)floorf((float)playerCurrentLevelNumber / 30.0f);
                if(maxholestoroll > 5) {
                    maxholestoroll = 5;
                }
                int numHolesInFloor = (maxholestoroll > 0 ? arc4random() % maxholestoroll : 0) + 1 + (arc4random() % 2);
                NSMutableArray *holeIndexes = [[NSMutableArray alloc] init];
                while (holeIndexes.count != numHolesInFloor) {
                    [self removeIndexRepeats:holeIndexes];
                    for(int i=0;i<numHolesInFloor;i++) {
                        int temp = arc4random() % (numCharsWide - 2);
                        [holeIndexes addObject:[NSNumber numberWithInteger: (temp == 0 ? 1 : (temp == numCharsWide - 2 ? temp - 1 : temp))]];
                    }
                }
                for(int i=0;i<numCharsWide - 2;i++) {
                    if([self isHoleIndex: i holeIndexes: holeIndexes]) {
                        [currentLine appendString:@" "];
                    } else {
                        [currentLine appendString:@"="];
                    }
                    currentCharsWide++;
                }
                currentCharsWide--;
            }
        }
        currentLine = [NSMutableString stringWithString:[[[[currentLine stringByReplacingOccurrencesOfString:@" = " withString:@" X "]
                        stringByReplacingOccurrencesOfString:@" =" withString:@" ("]
                       stringByReplacingOccurrencesOfString:@"= " withString:@") "] stringByReplacingOccurrencesOfString:@" X " withString:@" = "]];
        [lines addObject:currentLine];
    }
    [(NSMutableString *)lines[lines.count - 1] replaceCharactersInRange:NSMakeRange(((NSMutableString *)lines[lines.count - 1]).length / 2 - 1, 3)
        withString:@") ("];
    [lines addObject:@"E"];
    for(int i=1;i<lines.count - (teleportsIn > 0 ? 3 : 2);i+=2) {
        NSString *line = (NSString *) lines[i];
        for(int c=0;c<line.length;c++) {
            if([line characterAtIndex:c] != ' ' && [line characterAtIndex:c] != 'I' && [(NSString *)lines[i+1] characterAtIndex:c] == ' ') {
                [lines replaceObjectAtIndex:i withObject:[NSMutableString stringWithString:[line stringByReplacingCharactersInRange:NSMakeRange(c, 1) withString:@" "]]];
            } else if([line characterAtIndex:c] == 'I' &&[(NSString *)lines[i+1] characterAtIndex:c] == ' ') {
                [lines replaceObjectAtIndex:i withObject:[NSMutableString stringWithString:[line stringByReplacingCharactersInRange:NSMakeRange(c, 1) withString:@" "]]];
                teleportsIn--;
            }
        }
    }
    if(teleportsIn > 0) {
        NSMutableString *teleportsLine = [[NSMutableString alloc] init];
        NSMutableArray *teleportsOut = [[NSMutableArray alloc] init];
        for(int i=0;i<teleportsIn;i++) {
            BOOL matchedTeleportOut = NO;
            while (!matchedTeleportOut) {
                for(int r=1;!matchedTeleportOut && r<lines.count - 2;r+=2) {
                    NSMutableString *line = (NSMutableString *)lines[r];
                    int tempTry = arc4random() % ((minMapCharsWide + playerCurrentLevelNumber) * (minMapCharsHigh * playerCurrentLevelNumber));
                    if(tempTry >= 0 && tempTry < ((minMapCharsWide + playerCurrentLevelNumber) * (minMapCharsHigh * playerCurrentLevelNumber)) / 10) {
                        for(int c=1;c<line.length - 1;c++) {
                            if([(NSString *)lines[r+1] characterAtIndex:c] != ' ') {
                                char maplineletter = [line characterAtIndex:c];
                                if(maplineletter == ' ') {
                                    tempTry = arc4random() % ((minMapCharsWide + playerCurrentLevelNumber) * (minMapCharsHigh * playerCurrentLevelNumber));
                                    if(tempTry >= 0 && tempTry < ((minMapCharsWide + playerCurrentLevelNumber) * (minMapCharsHigh * playerCurrentLevelNumber)) / 10) {
                                        [lines replaceObjectAtIndex:r withObject:[NSMutableString stringWithString:[line stringByReplacingCharactersInRange:NSMakeRange(c, 1) withString:@"O"]]];
                                        matchedTeleportOut = YES;
                                        [teleportsOut addObject:@[[NSNumber numberWithInt:i], [NSNumber numberWithInt:c], [NSNumber numberWithInt:r]]];
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        NSArray *sortedTeleportsOut = [teleportsOut sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int ac = (int)a[1];
            int bc = (int)b[1];
            int ar = (int)a[2];
            int br = (int)b[2];
            return (ar > br ? -1 : (ar == br ? (ac > bc ? -1 : (ac < bc ? 1 : 0)) : 1));
        }];
        for(int i=0; i<teleportsIn; i++) {
            for(int x=0;x<sortedTeleportsOut.count;x++) {
                if([(NSNumber *)((NSArray *)sortedTeleportsOut[x])[0] intValue] == i) {
                    [teleportsLine appendString:[NSString stringWithFormat:@"%i,", x]];
                    break;
                }
            }
        }
        if(teleportsLine.length > 1) {
            [teleportsLine deleteCharactersInRange:NSMakeRange(teleportsLine.length - 1, 1)];
        }
        [lines addObject:teleportsLine];
    }
    return lines;
}

-(BOOL) isHoleIndex: (int) i holeIndexes: (NSMutableArray *) holeIndexes {
    for(NSNumber *n in holeIndexes) {
        if([n integerValue] == i) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) removeIndexRepeats: (NSMutableArray *) arr {
    NSMutableArray *repeats = [[NSMutableArray alloc] init];
    for(int i=0;i<arr.count;i++) {
        for(int c=0;c<arr.count;c++) {
            if(i != c && [(NSNumber *) arr[i] integerValue] == [(NSNumber *) arr[c] integerValue]) {
                [repeats addObject:[NSNumber numberWithInt:c]];
            }
        }
    }
    for(int i=(int)repeats.count - 1;i>=0;i++) {
        [arr removeObjectAtIndex:[(NSNumber *) repeats[i] integerValue]];
    }
    if(repeats.count > 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
