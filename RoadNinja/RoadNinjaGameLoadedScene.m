//
//  RoadNinjaGameLoadedScene.m
//  RoadNinja
//
//  Created by KingsleyZ on 4/6/14.
//  Copyright (c) 2014 JINGGONG ZHENG. All rights reserved.
//

#import "RoadNinjaGameLoadedScene.h"
#import "RoadNinjaGameScene.h"

@implementation RoadNinjaGameLoadedScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        NSString *text = @"Road Ninja";
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = text;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width * 0.5f, self.size.height * 0.5f);
        [self addChild:label];
        
        
        NSString *restartGame = @"Start Game";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryButton.text = restartGame;
        retryButton.fontColor = [SKColor blackColor];
        retryButton.position = CGPointMake(self.size.width * 0.5f, 50);
        retryButton.name = @"start";
        [retryButton setScale:.5];
        
        [self addChild:retryButton];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start"])
    {
        SKTransition *sceneTransition = [SKTransition flipHorizontalWithDuration:0.5];
        
        RoadNinjaGameScene *scene = [RoadNinjaGameScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: sceneTransition];
    }
}

@end
