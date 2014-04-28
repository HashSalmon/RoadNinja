//
//  MyScene.m
//  RoadNinja
//
//  Created by KingsleyZ on 4/2/14.
//  Copyright (c) 2014 JINGGONG ZHENG. All rights reserved.
//

#import "RoadNinjaGameScene.h"
#import "RoadNinjaMenuScene.h"
#import "RoadNinjaGameOverScene.h"
#import <AVFoundation/AVFoundation.h>

// assign category for collision detection
static const uint32_t ninjaCategory = 0x1 << 0;
static const uint32_t carCategory = 0x1 << 1;

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
static const int RightRoadBorderWidth = 220;

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

@interface RoadNinjaGameScene()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) SKAction *collisionSound;

@end

@implementation RoadNinjaGameScene
{
    SKLabelNode *_distanceLabel;
    SKSpriteNode *_menuButton;
    SKSpriteNode *_ninja;
    SKSpriteNode *_car;
    
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
    SKAction *_fadeOutNinja;
    SKAction *_fadeInNinja;
    
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
        
        // making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        // initialize sound effect
        //self.collisionSound = [SKAction playSoundFileNamed:@"hit_sound.mp3" waitForCompletion:NO];
        
        // mp3 file url
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"hit_sound" withExtension:@"mp3"];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
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
    
    // add sprite kit physicsbody for collision detection
    _ninja.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_ninja.size.width * 0.5f];
    _ninja.physicsBody.categoryBitMask = ninjaCategory;
    _ninja.physicsBody.dynamic = YES;
    _ninja.physicsBody.contactTestBitMask = carCategory;
    _ninja.physicsBody.collisionBitMask = 0;
    _ninja.physicsBody.usesPreciseCollisionDetection = YES;
    
    // amount to move
    CGFloat moveX = _ninja.size.width + 15.0f;
    
    // actions
    _moveLeft = [SKAction moveByX:-moveX y:0 duration:MoveDuration];
    _moveRight = [SKAction moveByX:moveX y:0 duration:MoveDuration];
    _fadeOutNinja = [SKAction fadeAlphaTo:0.7f duration:0.05f];
    _fadeInNinja = [SKAction fadeInWithDuration:0.05f];
    [self addChild:_ninja];
}

// add cars
- (void)addCars
{
    NSInteger carNumber = arc4random() % 6 + 1;
    NSString *carName = [NSString stringWithFormat:@"car%ld",(long)carNumber];
    _car = [SKSpriteNode spriteNodeWithImageNamed:carName];
    _car.name = @"car";
    [_car setScale:0.6f];
    
    // add collision detection
    _car.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_car.size];
    _car.physicsBody.categoryBitMask = carCategory;
    _car.physicsBody.dynamic = YES;
    _car.physicsBody.contactTestBitMask = ninjaCategory;
    _car.physicsBody.collisionBitMask = 0;
    _car.physicsBody.usesPreciseCollisionDetection = YES;
    
    // randomly choose a starting location
    int index = arc4random() % 5;
    NSNumber *carXNumber = _carXLocations[index];
    NSInteger carXLocation = [carXNumber integerValue];
    _car.position = CGPointMake(carXLocation, carYLocation);
    [self addChild:_car];
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
    if ((point.x > (_ninja.position.x + _ninja.size.width)) && (_ninja.position.x  < RightRoadBorderWidth))
    {
        NSLog(@"Right: %f", _ninja.position.x);
        SKAction *sequenceActions = [SKAction sequence:@[_fadeOutNinja, _moveRight, _fadeInNinja]];

        [_ninja runAction:sequenceActions];
    }
    
    // move to the left
    if ((point.x < _ninja.position.x) && (_ninja.position.x > LeftRoadBorderWidth))
    {
        NSLog(@"Left: %f", _ninja.position.x);
        SKAction *sequenceActions = [SKAction sequence:@[_fadeOutNinja, _moveLeft, _fadeInNinja]];

        [_ninja runAction:sequenceActions];
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
         distanceLabel.text = [NSString stringWithFormat:@"%ldm", (long)updatedDistance];
     }];
}

// collision occured
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"collision detection");
    // ninja body is 0 and car body is 1
    SKPhysicsBody *ninjaBody;
    SKPhysicsBody *carBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        ninjaBody = contact.bodyA;
        carBody = contact.bodyB;
    }
    else
    {
        ninjaBody = contact.bodyB;
        carBody = contact.bodyA;
    }
    
    if ((ninjaBody.categoryBitMask & ninjaCategory) != 0
        && (carBody.categoryBitMask & carCategory) != 0)
    {
        // play collision sound
        [self.audioPlayer play];
    
        // remove ninja and car
        [_ninja removeFromParent];
        [_car removeFromParent];
        
        // change to game over scene
        SKTransition *sceneTransition = [SKTransition fadeWithColor:[UIColor redColor] duration:3.0f];
        SKScene *roadNinjaGameOverScene = [[RoadNinjaGameOverScene alloc] initWithSize:self.size];
        [self.view presentScene:roadNinjaGameOverScene transition:sceneTransition];
    }
}

@end




















