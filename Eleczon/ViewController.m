//
//  ViewController.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/1/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import "ViewController.h"
#import "GameCenter.h"
#import "MyScene.h"

@implementation ViewController {
    GameCenter *gc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    doinGameCenter = YES;
    gc = [[GameCenter alloc] init];
    [gc authenticateLocalPlayer: self];
    SKView * skView = (SKView *)self.view;
    MyScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.gameCenter = gc;
    scene.vc = self;
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
