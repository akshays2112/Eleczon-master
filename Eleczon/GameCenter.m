//
//  GameCenter.m
//  Eleczon
//
//  Created by Akshay Srinivasan on 8/7/14.
//  Copyright (c) 2014 Akshay Srinivasan. All rights reserved.
//

#import "GameCenter.h"

@implementation GameCenter

-(void)authenticateLocalPlayer: (UIViewController *) mainViewController {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [mainViewController presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                self.gameCenterEnabled = YES;
            } else{
                self.gameCenterEnabled = NO;
            }
        }
        doinGameCenter = NO;
    };
}

-(void)reportEnergy: (int) energy{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"EleczonLeaderboard"];
    score.value = energy;
    
    [GKScore reportScores:@[score] withCompletionHandler:nil];
}

@end
