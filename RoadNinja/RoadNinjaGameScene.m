//
//  MyScene.m
//  RoadNinja
//
//  Created by KingsleyZ on 4/2/14.
//  Copyright (c) 2014 JINGGONG ZHENG. All rights reserved.
//

#import "RoadNinjaGameScene.h"
#import "RoadNinjaGameOverScene.h"


@implementation RoadNinjaGameScene
{
    SKLabelNode *distanceLabel;
    SKSpriteNode *menuButton;
    CGFloat distanceLabelX;
    CGFloat distanceLabelY;
    CGFloat menuButtonX;
    CGFloat menuButtonY;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // calculate the label X and Y
        distanceLabelX = 20.0f;
        distanceLabelY = size.height - 25.0f;
        menuButtonX = size.width - 18.0f;
        menuButtonY = size.height - 20.0f;
        
        // background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // add the distance label
        distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        distanceLabel.fontColor = [SKColor grayColor];
        distanceLabel.text = @"0m";
        distanceLabel.fontSize = 20.0;
        distanceLabel.position = CGPointMake(distanceLabelX, distanceLabelY);
        [self addChild:distanceLabel];
        
        // add the menu button
        menuButton = [[SKSpriteNode alloc] initWithImageNamed:@"homeButton"];
        [menuButton setScale:0.18];
        menuButton.position = CGPointMake(menuButtonX, menuButtonY);
        menuButton.name = @"menu";
        [self addChild:menuButton];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    [self menuButtonClickedAt:touches];
    
}

// when menu button is clicked
- (void)menuButtonClickedAt:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"menu"])
    {
        NSLog(@"Menu");
        SKTransition *transitionAnimation = [SKTransition doorsCloseVerticalWithDuration:0.5];
        CGSize gameOverSceneSize = CGSizeMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
        RoadNinjaGameOverScene *gameOverScene = [RoadNinjaGameOverScene sceneWithSize:gameOverSceneSize];
        gameOverScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:gameOverScene transition:transitionAnimation];
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end



















