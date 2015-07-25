//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene {
    
    CCLabelTTF *_totalStarsCollectedLabel;
    CCButton *_startButton;
    
}

-(void) didLoadFromCCB {
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"Total Stars"]){
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Total Stars"];
    }
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"]){
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"HighScore"];
    }
    NSInteger totalStars = [[NSUserDefaults standardUserDefaults] integerForKey:@"Total Stars"];
    _totalStarsCollectedLabel.string = [NSString stringWithFormat:@"%li Stars Collected", (long)totalStars];
    
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playBg:@"gamesounds/theme2.m4a" loop:TRUE];
    
    //play animations
    [[_startButton animationManager] runAnimationsForSequenceNamed:@"start move in"];
}

-(void)play{
    CCLOG(@"play button pressed");
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio stopBg];
    CCScene *gameplayScene = [CCBReader loadAsScene: @"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


@end

