//
//  MyScene.m
//  RoadNinja
//
//  Created by KingsleyZ on 4/2/14.
//  Copyright (c) 2014 JINGGONG ZHENG. All rights reserved.
//

#import "RoadNinjaGameScene.h"
#import "RoadNinjaMenuScene.h"

// The background moving speed
static const float BackgroundVelocity = 150.0f;

// vector addition
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

// vector multiplication
static inline CGPoint CGPointMultiply(const CGPoint a, const CGFloat scalar)
{
    return CGPointMake(a.x * scalar, a.y * scalar);
}

@implementation RoadNinjaGameScene
{
    SKLabelNode *distanceLabel;
    SKSpriteNode *menuButton;
    SKSpriteNode *_ninja;
    CGFloat distanceLabelX;
    CGFloat distanceLabelY;
    CGFloat menuButtonX;
    CGFloat menuButtonY;
    CGFloat backgroundImageX;
    CGFloat backgroundImageY;
    CGFloat ninjaInitialPositionX;
    CGFloat ninjaInitialPositionY;
    NSTimeInterval _delta;
    NSTimeInterval _lastUpdateTime;

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
        backgroundImageX = 0.0f;
        backgroundImageY = 25.0f;
        ninjaInitialPositionX = self.size.width * 0.5f;
        ninjaInitialPositionY = self.size.height * 0.2f;
        
        // background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // initialize background
        [self initializingScrollingBackground];
        
        // add the distance label
        distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        distanceLabel.fontColor = [SKColor redColor];
        distanceLabel.text = @"0m";
        distanceLabel.fontSize = 20.0;
        distanceLabel.position = CGPointMake(distanceLabelX, distanceLabelY);
        [self addChild:distanceLabel];
        
        // add the menu button
        menuButton = [[SKSpriteNode alloc] initWithImageNamed:@"menu_button"];
        [menuButton setScale:0.18];
        menuButton.position = CGPointMake(menuButtonX, menuButtonY);
        menuButton.name = @"menu";
        [self addChild:menuButton];
        
        // add the ninja
        _ninja = [[SKSpriteNode alloc] initWithImageNamed:@"ninja"];
        _ninja.position = CGPointMake(ninjaInitialPositionX, ninjaInitialPositionY);
        _ninja.name = @"ninja";
        [self addChild:_ninja];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
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
        SKTransition *transitionAnimation = [SKTransition doorsCloseVerticalWithDuration:0.5];
        //CGSize gameOverSceneSize = CGSizeMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
        RoadNinjaMenuScene *gameMenuScene = [RoadNinjaMenuScene sceneWithSize:self.size];
        gameMenuScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:gameMenuScene transition:transitionAnimation];
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
    if (_lastUpdateTime)
    {
        _delta = currentTime - _lastUpdateTime;
    }
    else
    {
        _delta = 0;
    }
    
    _lastUpdateTime = currentTime;
    
    [self moveBackground];
}

// initialize the scrolling background
- (void)initializingScrollingBackground
{
    for (int i = 0; i < 2; i++)
    {
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"road_bg"];
        background.size = CGSizeMake(self.size.width, self.size.height);
        background.position = CGPointMake(backgroundImageX, i * background.size.height);
        background.anchorPoint = CGPointZero;
        background.name = @"background";
        [self addChild:background];
    }
}

// move the background
- (void)moveBackground
{
    [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop)
    {
        SKSpriteNode *background = (SKSpriteNode *) node;
        CGPoint backgroundVelocity = CGPointMake(0, -BackgroundVelocity);
        CGPoint amountToMove = CGPointMultiply(backgroundVelocity, _delta);
        background.position = CGPointAdd(background.position, amountToMove);
        
        if (background.position.y <= -background.size.height)
        {
            background.position = CGPointMake(background.position.x, background.position.y + background.size.height * 2);
        }
    }];
}

@end




















