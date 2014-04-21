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

// The ninja's running speed
static const float NinjaVelocity = 0.05f;

// The cars' speed
static const float CarVelocity = 200.0f;

// Rate of adding a car
static const float CarAddedRate = 0.5f;

// the road border width
static const int LeftRoadBorderWidth = 80;
static const int RightRoadBorderWidth = 240;

// move duration
static const float MoveDuration = 0.3f;

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
    SKLabelNode *_distanceLabel;
    SKSpriteNode *_menuButton;
    SKSpriteNode *_ninja;
    
    CGFloat distanceLabelX;
    CGFloat distanceLabelY;
    CGFloat menuButtonX;
    CGFloat menuButtonY;
    CGFloat backgroundImageX;
    CGFloat backgroundImageY;
    CGFloat ninjaInitialPositionX;
    CGFloat ninjaInitialPositionY;
    
    CGFloat _distance;
    NSTimeInterval _delta;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _lastCarAdded;
    NSTimer *_timer;
    
    SKAction *_moveLeft;
    SKAction *_moveRight;
    
    NSMutableArray *_carXLocations;
    NSInteger carYLocation;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // initialization
        [self initializeVariablesAndLocations:size];
        
        // background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // initialize background
        [self initializingScrollingBackground];
        
        // add nodes
        [self addDistanceLabel];
        [self addMenuButton];
        [self addNinja];
        [self addCars];
        
        // actions
        _moveLeft = [SKAction moveByX:-_ninja.size.width y:0 duration:MoveDuration];
        _moveRight = [SKAction moveByX:_ninja.size.width y:0 duration:MoveDuration];
    }
    
    return self;
}

// initialize variables and locations
- (void)initializeVariablesAndLocations:(CGSize)size
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
    _distance = 0;
    
    _carXLocations = [[NSMutableArray alloc] initWithCapacity:4];
    [_carXLocations addObject:[NSNumber numberWithInt:59]];
    [_carXLocations addObject:[NSNumber numberWithInt:107]];
    [_carXLocations addObject:[NSNumber numberWithInt:156]];
    [_carXLocations addObject:[NSNumber numberWithInt:205]];
    [_carXLocations addObject:[NSNumber numberWithInt:255]];
    carYLocation = self.size.height;
}

// add distance label on the screen
- (void)addDistanceLabel
{
    // add the distance label
    _distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _distanceLabel.fontColor = [SKColor redColor];
    _distanceLabel.text = [NSString stringWithFormat:@"%fm", _distance];
    _distanceLabel.fontSize = 20.0;
    _distanceLabel.position = CGPointMake(distanceLabelX, distanceLabelY);
    _distanceLabel.name = @"distance";
    [self addChild:_distanceLabel];
}

// add menu button on the screen
- (void)addMenuButton
{
    _menuButton = [[SKSpriteNode alloc] initWithImageNamed:@"menu_button"];
    [_menuButton setScale:0.18];
    _menuButton.position = CGPointMake(menuButtonX, menuButtonY);
    _menuButton.name = @"menu";
    [self addChild:_menuButton];
}

// add ninja
- (void)addNinja
{
    _ninja = [[SKSpriteNode alloc] initWithImageNamed:@"ninja"];
    [_ninja setScale:0.7f];
    _ninja.position = CGPointMake(ninjaInitialPositionX, ninjaInitialPositionY);
    _ninja.name = @"ninja";
    [self addChild:_ninja];
}

// add cars
- (void)addCars
{
    NSInteger carNumber = arc4random() % 6 + 1;
    NSString *carName = [NSString stringWithFormat:@"car%d",carNumber];
    SKSpriteNode *car = [SKSpriteNode spriteNodeWithImageNamed:carName];
    car.name = @"car";
    [car setScale:0.6];
    
    // randomly choose a starting location
    int index = arc4random() % 5;
    NSNumber *carXNumber = _carXLocations[index];
    NSInteger carXLocation = [carXNumber integerValue];
    car.position = CGPointMake(carXLocation, carYLocation);
    [self addChild:car];
}

- (void)moveCars
{
    NSArray *nodes = self.children;
    
    for (SKNode *node in nodes)
    {
        if (![node.name isEqual:@"background"] && ![node.name isEqual:@"ninja"] && ![node.name isEqual:@"menu"] && ![node.name isEqual:@"distance"])
        {
            SKSpriteNode *car = (SKSpriteNode *) node;
            CGPoint carVelocity = CGPointMake(0, -CarVelocity);
            CGPoint amountToMove = CGPointMultiply(carVelocity, _delta);
    
            car.position = CGPointAdd(car.position, amountToMove);
            
            // remove car from the screen
            if(car.position.y < 0)
            {
                [car removeFromParent];
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.scene];
    
    /* Called when a touch begins */
    [self menuButtonClickedAt:touchPoint];
    
    // move the ninja
    [self moveNinjaToPoint:touchPoint];
}

// when menu button is clicked
- (void)menuButtonClickedAt:(CGPoint)touchPoint
{
    SKNode *node = [self nodeAtPoint:touchPoint];
    
    // check if the menu_button is clicked
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
    
    if (currentTime - _lastCarAdded > CarAddedRate)
    {
        _lastCarAdded = currentTime;
        [self addCars];
    }
    
    // move the background
    [self moveBackground];
    
    // move the cars
    [self moveCars];
    
    // update distance label
    [self updateDistance];
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

// move the ninja
- (void)moveNinjaToPoint:(CGPoint)point
{
    // move to the right
    if ((point.x > _ninja.position.x) && (_ninja.position.x < RightRoadBorderWidth))
    {
        [_ninja runAction:_moveRight];
    }
    
    // move to the left
    if ((point.x < _ninja.position.x) && (_ninja.position.x > LeftRoadBorderWidth))
    {
        [_ninja runAction:_moveLeft];
    }
}

// calculate distance
- (NSInteger)calculateDistance
{
    _distance = _distance + NinjaVelocity;
    return _distance;
}

// update distance
- (void)updateDistance
{
    [self enumerateChildNodesWithName:@"distance" usingBlock:^(SKNode *node, BOOL *stop)
     {
         SKLabelNode *distanceLabel = (SKLabelNode *) node;
         NSInteger updatedDistance = [self calculateDistance];
         distanceLabel.text = [NSString stringWithFormat:@"%dm", updatedDistance];
     }];
}

@end




















