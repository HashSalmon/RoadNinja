//
//  RoadNinjaMenuScene.m
//  RoadNinja
//
//  Created by KingsleyZ on 4/6/14.
//  Copyright (c) 2014 JINGGONG ZHENG. All rights reserved.
//

#import "RoadNinjaMenuScene.h"
#import "RoadNinjaGameScene.h"

@implementation RoadNinjaMenuScene
{
    CGFloat resumeButtonX;
    CGFloat resumeButtonY;
    CGFloat restartButtonX;
    CGFloat restartButtonY;
    CGFloat exitButtonX;
    CGFloat exitButtonY;
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // calculate buttons location
        resumeButtonX = size.width * 0.5f;
        resumeButtonY = size.height * 0.7f;
        restartButtonX = resumeButtonX;
        restartButtonY = resumeButtonY - 100.0f;
        exitButtonX = resumeButtonX;
        exitButtonY = restartButtonY - 100.0f;
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // resume button
        SKLabelNode *resumeButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        resumeButton.text = @"Resume";
        resumeButton.fontColor = [SKColor redColor];
        resumeButton.position = CGPointMake(resumeButtonX, resumeButtonY);
        resumeButton.name = @"resumeButton";
        [self addChild:resumeButton];
        
        // restart button
        SKLabelNode *restartButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        restartButton.text = @"Restart";
        restartButton.fontColor = [SKColor redColor];
        restartButton.position = CGPointMake(restartButtonX, restartButtonY);
        restartButton.name = @"restartButton";
        [self addChild:restartButton];
        
        // exit button
        SKLabelNode *exitButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        exitButton.text = @"Exit";
        exitButton.fontColor = [SKColor redColor];
        exitButton.position = CGPointMake(exitButtonX, exitButtonY);
        exitButton.name = @"exitButton";
        [self addChild:exitButton];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // resume button is touched
    [self resumeButtonTouched:touches];
    
    // restart button is touched
    [self restartButtonTouched:touches];
    
    // exit button is touched
    [self exitButtonTouched:touches];
}

- (void)resumeButtonTouched:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:touchPoint];
    
    if ([touchNode.name isEqualToString:@"resumeButton"])
    {
        SKTransition *transitionAnimation = [SKTransition doorsOpenVerticalWithDuration:0.5];
        //CGSize gameOverSceneSize = CGSizeMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
        RoadNinjaGameScene *gameScene = [RoadNinjaGameScene sceneWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:gameScene transition:transitionAnimation];
    }
}

- (void)restartButtonTouched:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:touchPoint];
    
    if ([touchNode.name isEqualToString:@"restartButton"])
    {
        NSLog(@"Restart");
    }
}

// exit game
- (void)exitButtonTouched:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:touchPoint];
    
    if ([touchNode.name isEqualToString:@"exitButton"])
    {
        exit(0);
    }
}

@end












