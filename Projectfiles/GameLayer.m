/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 
 
 
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

#import "GameLayer.h"
#import "Entity.h"
#import "GenericMenuLayer.h"
#import "Ship.h"
#import "Pirate.h"
#import "PirateKing.h"
#import "Planet.h"
#import "Interlude.h"
#import "GameOverLayer.h"
#import "PauseLayer.h"
#import "SpacePort.h"
@implementation GameLayer
bool shake_once;
static CGRect screenRect;
NSString* healthToDisplay;
NSString* attackPowerToDisplay;
static GameLayer* instanceOfGameLayer;
CGSize screenSize;
Ship* ship;
CCMenu* upgradesMenu;
CCMenu* superWeaponsMenu;
CCLabelTTF* superWeaponsMenuTitle;
CCMenu* pauseButton;
CCAnimation *taunting;
//These labels will be used to check if touch input is working
//**COMMENT THIS OUT WHEN YOU START WORK ON YOUR OWN GAME
//CCLabelTTF* verifyTouchStart;
//CCLabelTTF* verifyTouchAvailable;
//CCLabelTTF* verifyTouchEnd;
CCLabelTTF* health;
CCLabelTTF* attackPower;
CCSprite* background;
CCSprite* playerCreditsSprite;
CCSprite* sprite;
CCLabelTTF* playerCreditsLabel;
CCLabelTTF* currentSuperWeaponIndicator;
int currentPlayerCredits;
int currentSuperWeapon;
//**
int backgroundCount;
bool moving;
Entity* currentEvent;
NSDictionary* gameEvents;
int eventNumber;
int eventCycle;
int enemyCount;
int gameState;
int repairChanceEqualizer;
@synthesize superWeaponInUse;
//this allows other classes in your project to query the GameLayer for the screenRect
+(CGRect) screenRect
{
	return screenRect;
}

//If another class wants to get a reference to this layer, they can by calling this method
+(GameLayer*) sharedGameLayer
{
	NSAssert(instanceOfGameLayer != nil, @"GameLayer instance not yet initialized!");
	return instanceOfGameLayer;
}

-(id) initAsTutorial
{
    if ((self = [self init])){
        //Adds the back button to the screen.
        CCLabelTTF* leaveLabel = [CCLabelTTF labelWithString:@"Exit" fontName:@"arial" fontSize:45.0f];
        CCMenuItemLabel* backButton = [CCMenuItemLabel itemWithLabel:leaveLabel target:self selector: @selector(toMainMenu)];
        CCMenu* leave = [CCMenu menuWithItems:backButton, nil];
        leave.position = ccp(screenSize.width*3/4,screenSize.height*8/10);
        [self addChild: leave z:1];
        gameState=2;
    }
    
    return self;
}

-(id) initAsEndless
{
    if ((self = [self init])){
        //Adds the pause button to the screen.
        CCLabelTTF* pauseLabel = [CCLabelTTF labelWithString:@"Pause" fontName: @"arial" fontSize:40.0f];
        CCMenuItemLabel* pauseButtonMenuItem = [CCMenuItemLabel itemWithLabel: pauseLabel target: self selector: @selector(toPauseScreen)];
        pauseButton = [CCMenu menuWithItems: pauseButtonMenuItem,nil];
        pauseButton.position = ccp(screenSize.width/6, screenSize.height/3);
        [self addChild: pauseButton z:2];
    }
    
    return self;
}

-(id) resume
{
    [self scheduleUpdate];
    [self reloadMenus];
    [self reloadSprites];
    return self;
}
-(void) reloadSprites
{
    NSMutableArray* arrayE = [[NSMutableArray alloc] init];
    while([self getChildByTag:ExplosionTag]!=nil)
    {
        NSLog(@"Explosion found");
        CCSprite* explosion = (CCSprite*)[self getChildByTag:ExplosionTag];
        [arrayE addObject:explosion];
        [self removeChildByTag:ExplosionTag];
    }
    NSLog([NSString stringWithFormat:@"%@%u",@"Elements in Array: ",[arrayE count]]);
    [self removeExplosions];
    while([arrayE count]>0)
    {
        NSLog(@"Explosion Reloaded");
        CCSprite* spriteE = (CCSprite*)[arrayE objectAtIndex: [arrayE count]-1];
        [spriteE runAction:taunt];
        
        [self addChild:spriteE z:1 tag: ExplosionTag];
        
        [arrayE removeObjectAtIndex: [arrayE count]-1];
    }
}


-(void) reloadMenus
{
    
    //Reloads the pause button
    [self removeChild: pauseButton cleanup:YES];
    CCLabelTTF* pauseLabel = [CCLabelTTF labelWithString:@"Pause" fontName: @"arial" fontSize:40.0f];
    CCMenuItemLabel* pauseButtonMenuItem = [CCMenuItemLabel itemWithLabel: pauseLabel target: self selector: @selector(toPauseScreen)];
    pauseButton = [CCMenu menuWithItems: pauseButtonMenuItem,nil];
    pauseButton.position = ccp(screenSize.width/6, screenSize.height/3);
    [self addChild: pauseButton z:2];
    
    
    //Reloads the upgrades menu
    
    CCLabelTTF* repairShipLabel = [CCLabelTTF labelWithString:@"Repair: 5 Credits" fontName: @"arial" fontSize: 25.0f];
    CCLabelTTF* upgradeAttackLabel = [CCLabelTTF labelWithString:@"Add Attack: 5 Credits" fontName: @"arial" fontSize: 25.0f];
    CCLabelTTF* upgradeHullLabel = [CCLabelTTF labelWithString:@"Add Hull: 2 Credits" fontName: @"arial" fontSize: 25.0f];
    CCLabelTTF* upgradeAttackSpeedLabel = [CCLabelTTF labelWithString:@"Fire Faster: 20 Credits" fontName: @"arial" fontSize: 25.0f];
    CCMenuItemLabel *repairShipMenuItem = [CCMenuItemLabel itemWithLabel:repairShipLabel target:self selector:@selector(repairPlayerShip)];
    
    
    repairShipMenuItem.tag=1;// sets the repairshipmenuitem tag as 1 to use it to retreive the item from CCMenu
    CCMenuItemLabel *upgradeHullMenuItem = [CCMenuItemLabel itemWithLabel:upgradeHullLabel target:self selector:@selector(upgradePlayerHull)];
    [repairShipMenuItem setVisible:[[self getChildByTag:UpgradesMenuTag] getChildByTag: 1].visible];
    
    
    upgradeHullMenuItem.tag=2; //sets the upgradehullmenuitem tag to 2 to use as reference for retrieval
    CCMenuItemLabel *upgradeAttackMenuItem = [CCMenuItemLabel itemWithLabel:upgradeAttackLabel target:self selector:@selector(upgradePlayerAttack)];
    [upgradeHullMenuItem setVisible:[[self getChildByTag:UpgradesMenuTag] getChildByTag: 2].visible];
    
    
    upgradeAttackMenuItem.tag=3; //Sets the upgradeAttackMenuItem tag to 3 to use as reference for retrieval
    CCMenuItemLabel *upgradeAttackSpeedMenuItem = [CCMenuItemLabel itemWithLabel:upgradeAttackSpeedLabel target:self selector:@selector(upgradePlayerAttackSpeed)];
    [upgradeAttackMenuItem setVisible:[[self getChildByTag:UpgradesMenuTag] getChildByTag: 3].visible];
    
    
    upgradeAttackSpeedMenuItem.tag=4; //sets the attackspeedmenuitem tag to 4 as a reference for retrieval
    [upgradeAttackSpeedMenuItem setVisible:[[self getChildByTag:UpgradesMenuTag] getChildByTag: 4].visible];
    
    
    upgradesMenu = [CCMenu menuWithItems:repairShipMenuItem, upgradeHullMenuItem, upgradeAttackMenuItem, upgradeAttackSpeedMenuItem, nil];
    
    [upgradesMenu alignItemsVertically];
    [upgradesMenu setPosition:ccp(screenSize.width*3/4-8,screenSize.height/2-10)];
    [self removeChildByTag:UpgradesMenuTag];
    [self addChild: upgradesMenu z:1 tag: UpgradesMenuTag];

    
    //[[self getChildByTag:UpgradesMenuTag] setVisible: NO];
    
    
    
    CCLabelTTF* megaLaserLabel = [CCLabelTTF labelWithString:@"Mega Laser" fontName: @"arial" fontSize: 25.0f];
    CCLabelTTF* emergencyRepairLabel = [CCLabelTTF labelWithString: @"Emergency Repair" fontName: @"arial" fontSize:25.0f];
    CCLabelTTF* pointDefenseLabel = [CCLabelTTF labelWithString: @"Point Defenses" fontName: @"arial" fontSize:25.0f];
    CCLabelTTF* reflectorLabel = [CCLabelTTF labelWithString: @"Reflector Shields" fontName: @"arial" fontSize: 25.0f];
    CCMenuItemLabel *megaLaserMenuItem = [CCMenuItemLabel itemWithLabel: megaLaserLabel target:self selector: @selector(chooseMegaLaser)];
    megaLaserMenuItem.tag=1;
    CCMenuItemLabel *emergencyRepairMenuItem = [CCMenuItemLabel itemWithLabel: emergencyRepairLabel target: self selector: @selector(chooseEmergencyRepair)];
    emergencyRepairMenuItem.tag=2;
    CCMenuItemLabel * pointDefenseMenuItem = [CCMenuItemLabel itemWithLabel: pointDefenseLabel target: self selector: @selector(choosePointDefense)];
    pointDefenseMenuItem.tag=3;
    CCMenuItemLabel* reflectorMenuItem = [CCMenuItemLabel itemWithLabel: reflectorLabel target: self selector: @selector(chooseReflector)];
    reflectorMenuItem.tag=4;
    superWeaponsMenu= [CCMenu menuWithItems: megaLaserMenuItem, emergencyRepairMenuItem, pointDefenseMenuItem, reflectorMenuItem,nil];
    [superWeaponsMenu alignItemsVertically];
    [superWeaponsMenu setPosition: ccp(screenSize.width*3/4-8,screenSize.height/2-10)];
    /*
    [megaLaserMenuItem setVisible: [[self getChildByTag: SuperWeaponsMenuTag] getChildByTag:1].visible];
    [emergencyRepairMenuItem setVisible: [[self getChildByTag: SuperWeaponsMenuTag] getChildByTag:2].visible];
    [pointDefenseMenuItem setVisible: [[self getChildByTag: SuperWeaponsMenuTag] getChildByTag:3].visible];
    [reflectorMenuItem setVisible: [[self getChildByTag: SuperWeaponsMenuTag] getChildByTag:4].visible];
     */
    [superWeaponsMenu setVisible: [self getChildByTag:SuperWeaponsMenuTag].visible];
    [self removeChildByTag: SuperWeaponsMenuTag];
    [self addChild: superWeaponsMenu z:1 tag:SuperWeaponsMenuTag];

    
    
}


-(void) chooseMegaLaser
{
    [(SpacePort*)[self getChildByTag: CurrentEntityTag] die];
    currentSuperWeapon=1;
    [self putAwaySuperWeaponsMenu];
    
}

-(void) choosePointDefense
{
    [(SpacePort*) [self getChildByTag: CurrentEntityTag] die];
    currentSuperWeapon=3;
    [self putAwaySuperWeaponsMenu];

}

-(void) chooseEmergencyRepair
{
    [(SpacePort*) [self getChildByTag: CurrentEntityTag] die];

    currentSuperWeapon=2;
    [self putAwaySuperWeaponsMenu];

}

-(void) chooseReflector
{
    [(SpacePort*) [self getChildByTag: CurrentEntityTag] die];

    currentSuperWeapon=4;
    [self putAwaySuperWeaponsMenu];

}

-(void) usePowerUp
{
    superWeaponInUse = currentSuperWeapon;
    currentSuperWeapon=0;
    if(superWeaponInUse==2)
    {
        [ship repair];
        superWeaponInUse=0;
    }
}

-(id) init
{
	if ((self = [super init]))
	{
        currentSuperWeapon=1;
        repairChanceEqualizer=0;
        currentEvent=nil;
        gameState=1;
		instanceOfGameLayer = self;
        backgroundCount=0;
        moving=YES;
        //get the rectangle that describes the edges of the screen
        screenSize = [[CCDirector sharedDirector] winSize];
		screenRect = CGRectMake(0, 0, screenSize.width, screenSize.height);
		shake_once = NO;
        self.accelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
        
        currentSuperWeaponIndicator = [CCLabelTTF labelWithString:@"No Adv. Tech" fontName:@"arial" fontSize:25.0f];
        currentSuperWeaponIndicator.position = ccp(screenSize.width*2/3, screenSize.height*83/100);
        [self addChild: currentSuperWeaponIndicator z:1 tag:CurrentSuperWeaponIndicatorTag];
        //Loads the background image.
        background = [CCSprite spriteWithFile:@"StarBackground.png"];
        [background setAnchorPoint:ccp(0,0)];
        [background setPosition:ccp(0,0)];
        [self addChild:background z:0 tag:StarBackgroundTag];
        
        //Loads the credits sprite image
        playerCreditsSprite = [CCSprite spriteWithFile:@"spaceCoin.png"];
        [playerCreditsSprite setPosition:ccp(screenSize.width/8,screenSize.height*8/10)];
        [self addChild:playerCreditsSprite z:1 tag:PlayerCreditsSpriteTag];
        
        //Loads the credits indicator
        currentPlayerCredits = 0;
        NSString* currentPlayerCreditsString = [NSString stringWithFormat:@"%u",currentPlayerCredits];
        playerCreditsLabel = [CCLabelTTF labelWithString:currentPlayerCreditsString fontName:@"arial" fontSize:20.0f];
        playerCreditsLabel.position=ccp(screenSize.width*15/64, screenSize.height*8/10);
        [self addChild: playerCreditsLabel z:1 tag:PlayerCreditsTag];
        
        //Loads the upgrades menu
        CCLabelTTF* repairShipLabel = [CCLabelTTF labelWithString:@"Repair: 5 Credits" fontName: @"arial" fontSize: 25.0f];
        CCLabelTTF* upgradeAttackLabel = [CCLabelTTF labelWithString:@"Add Attack: 5 Credits" fontName: @"arial" fontSize: 25.0f];
        CCLabelTTF* upgradeHullLabel = [CCLabelTTF labelWithString:@"Add Hull: 2 Credits" fontName: @"arial" fontSize: 25.0f];
        CCLabelTTF* upgradeAttackSpeedLabel = [CCLabelTTF labelWithString:@"Fire Faster: 20 Credits" fontName: @"arial" fontSize: 25.0f];
        CCMenuItemLabel *repairShipMenuItem = [CCMenuItemLabel itemWithLabel:repairShipLabel target:self selector:@selector(repairPlayerShip)];
        repairShipMenuItem.tag=1;// sets the repairshipmenuitem tag as 1 to use it to retreive the item from CCMenu
        CCMenuItemLabel *upgradeHullMenuItem = [CCMenuItemLabel itemWithLabel:upgradeHullLabel target:self selector:@selector(upgradePlayerHull)];
        upgradeHullMenuItem.tag=2; //sets the upgradehullmenuitem tag to 2 to use as reference for retrieval
        CCMenuItemLabel *upgradeAttackMenuItem = [CCMenuItemLabel itemWithLabel:upgradeAttackLabel target:self selector:@selector(upgradePlayerAttack)];
        upgradeAttackMenuItem.tag=3; //Sets the upgradeAttackMenuItem tag to 3 to use as reference for retrieval
        CCMenuItemLabel *upgradeAttackSpeedMenuItem = [CCMenuItemLabel itemWithLabel:upgradeAttackSpeedLabel target:self selector:@selector(upgradePlayerAttackSpeed)];
        upgradeAttackSpeedMenuItem.tag=4; //sets the attackspeedmenuitem tag to 4 as a reference for retrieval
        upgradesMenu = [CCMenu menuWithItems:repairShipMenuItem, upgradeHullMenuItem, upgradeAttackMenuItem, upgradeAttackSpeedMenuItem, nil];
        [upgradesMenu alignItemsVertically];
        [upgradesMenu setPosition:ccp(screenSize.width*3/4-8,screenSize.height/2-10)];
        [self addChild: upgradesMenu z:1 tag: UpgradesMenuTag];
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 1] setVisible:NO];
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 2] setVisible:NO];
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 3] setVisible:NO];
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 4] setVisible:NO];
        [[self getChildByTag:UpgradesMenuTag] setVisible: NO];
        //Loads the Super Weapons Menu
        CCLabelTTF* megaLaserLabel = [CCLabelTTF labelWithString:@"Mega Laser" fontName: @"arial" fontSize: 25.0f];
        CCLabelTTF* emergencyRepairLabel = [CCLabelTTF labelWithString: @"Emergency Repair" fontName: @"arial" fontSize:25.0f];
        CCLabelTTF* pointDefenseLabel = [CCLabelTTF labelWithString: @"Point Defenses" fontName: @"arial" fontSize:25.0f];
        CCLabelTTF* reflectorLabel = [CCLabelTTF labelWithString: @"Reflector Shields" fontName: @"arial" fontSize: 25.0f];
        CCMenuItemLabel *megaLaserMenuItem = [CCMenuItemLabel itemWithLabel: megaLaserLabel target:self selector: @selector(chooseMegaLaser)];
        megaLaserMenuItem.tag=1;
        CCMenuItemLabel *emergencyRepairMenuItem = [CCMenuItemLabel itemWithLabel: emergencyRepairLabel target: self selector: @selector(chooseEmergencyRepair)];
        emergencyRepairMenuItem.tag=2;
        CCMenuItemLabel * pointDefenseMenuItem = [CCMenuItemLabel itemWithLabel: pointDefenseLabel target: self selector: @selector(choosePointDefense)];
        pointDefenseMenuItem.tag=3;
        CCMenuItemLabel* reflectorMenuItem = [CCMenuItemLabel itemWithLabel: reflectorLabel target: self selector: @selector(chooseReflector)];
        reflectorMenuItem.tag=4;
        superWeaponsMenu= [CCMenu menuWithItems: megaLaserMenuItem, emergencyRepairMenuItem, pointDefenseMenuItem, reflectorMenuItem,nil];
        [superWeaponsMenu alignItemsVertically];
        [superWeaponsMenu setPosition: ccp(screenSize.width*3/4-8,screenSize.height/2-10)];
        [self addChild: superWeaponsMenu z:1 tag:SuperWeaponsMenuTag];
        
        superWeaponsMenuTitle = [CCLabelTTF labelWithString:@"Advanced Tech" fontName: @"arial" fontSize: 30.0f];
        
        [superWeaponsMenuTitle setPosition: ccp(screenSize.width*3/4-8, screenSize.height*3/4)];
        [self addChild: superWeaponsMenuTitle z:1 tag: SuperWeaponsMenuTitleTag];
        [[self getChildByTag: SuperWeaponsMenuTitleTag] setVisible:NO];
        /*
        [[[self getChildByTag:SuperWeaponsMenuTag] getChildByTag: 1] setVisible: NO];
        [[[self getChildByTag:SuperWeaponsMenuTag] getChildByTag: 2] setVisible: NO];

        [[[self getChildByTag:SuperWeaponsMenuTag] getChildByTag: 3] setVisible: NO];

        [[[self getChildByTag:SuperWeaponsMenuTag] getChildByTag: 4] setVisible: NO];
        */
        
        [[self getChildByTag: SuperWeaponsMenuTag] setVisible:NO];
        
        //This puts a ship on screen so you know you've switched to this layer and everything is loading right
        //**COMMENT THIS OUT WHEN YOU START WORK ON YOUR OWN GAME
        /*
         Entity* testEntity = [Entity createEntity];
         [testEntity setPosition: ccp(screenSize.width/5, screenSize.height/2)];
         [self addChild:testEntity z:1 tag:1];
         */
        
        //Loads the Player Ship
        ship = [Ship createShip];
        [ship setPosition: ccp(screenSize.width/5, screenSize.height/2)];
        [self addChild:ship z:1 tag:1];
        //Loads the Heal Indicator
        healthToDisplay = [NSString stringWithFormat: @" %@ %u %@ %u", @"Hull Remaining:", [ship hitpoints], @"/", [ship hull]];
        health = [CCLabelTTF labelWithString:healthToDisplay fontName:@"arial" fontSize:(20.0f)];
        health.position=ccp(screenSize.width/4,screenSize.height*9/10);
        [self addChild: health z:1 tag: PlayerHealthTag];
        //Loads the attack indicator
        attackPowerToDisplay = [NSString stringWithFormat: @" %@ %u %@ %u", @"Attack Power:", [ship damage], @" per ", [ship attackInterval]];
        attackPower= [CCLabelTTF labelWithString:attackPowerToDisplay fontName: @"arial" fontSize:(20.0f)];
        attackPower.position=ccp(screenSize.width*3/4,screenSize.height*9/10);
        [self addChild: attackPower z:1 tag:PlayerAttackTag];
        
        //Loads in events
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Events" ofType:@"plist"];
        gameEvents = [NSDictionary dictionaryWithContentsOfFile:path];
        eventNumber=1;
        eventCycle =0;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"explosion.plist"];
        
        //Load in the spritesheet, if retina Kobold2D will automatically use bearframes-hd.png
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"explosion.png"];
        
        [self addChild:spriteSheet];
        
        //Define the frames based on the plist - note that for this to work, the original files must be in the format bear1, bear2, bear3 etc...
        
        //When it comes time to get art for your own original game, makegameswith.us will give you spritesheets that follow this convention, <spritename>1 <spritename>2 <spritename>3 etc...
        
        tauntingFrames = [NSMutableArray array];
        
        for(int i = 1; i <= 11; ++i)
        {
            [tauntingFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"explosion%d.png", i]]];
        }
        
        //Initialize the bear with the first frame you loaded from your spritesheet, bear1
        
        
        //Create an animation from the set of frames you created earlier
        
        taunting = [CCAnimation animationWithFrames: tauntingFrames delay:0.05f];
        
        [[CCAnimationCache sharedAnimationCache] addAnimation:taunting name:@"explosion"];
        //Create an action with the animation that can then be assigned to a sprite
        
        taunt = [CCSequence actions: [CCAnimate actionWithAnimation:taunting restoreOriginalFrame:NO], nil];
        
        //tell the bear to run the taunting action
        
        /*
        sprite = [CCSprite spriteWithSpriteFrameName:@"explosion1.png"];
        
        sprite.anchorPoint = CGPointZero;
        sprite.position = CGPointMake(0,0);
        
        [sprite runAction:taunt];
        
        [self addChild:sprite z:1];
         */
        /*
         for (id key in getRoot) {
         NSLog(@"key: %@, value: %@ \n", key, [getRoot objectForKey:key]);
         }
         */
        /*
         currentEvent =[Pirate createPirateWithHealth:3 andAttack:1 andAttackInterval:50 andPlayer:ship withBounty: 3];
         [currentEvent setPosition:ccp(screenSize.width,screenSize.height/2)];
         [self addChild: currentEvent z:1 tag:CurrentEntityTag];
         */
        /*
         currentEvent = [Planet createPlanet];
         [currentEvent setPosition:ccp(screenSize.width,screenSize.height/2)];
         [self addChild: currentEvent z:0 tag:CurrentEntityTag];
         */
        /*
         CCSprite* coin = [CCSprite spriteWithFile:@"coins.png"];
         [coin setPosition:ccp(screenSize.width*4/5, screenSize.height/2)];
         [self addChild:coin z:1 tag:9001];
         */
        //**
        
        //We've provided this code so you can check to see if touch input is working.
        //**COMMENT THIS OUT WHEN YOU START WORK ON YOUR OWN GAME
        /*
         verifyTouchStart = [CCLabelTTF labelWithString:@"Touch Started" fontName:@"arial" fontSize:20.0f];
         verifyTouchAvailable = [CCLabelTTF labelWithString:@"No Taps" fontName:@"arial" fontSize:20.0f];
         verifyTouchEnd = [CCLabelTTF labelWithString:@"Touch Ended" fontName:@"arial" fontSize:20.0f];
         
         verifyTouchStart.position = ccp(100,100);
         verifyTouchAvailable.position = ccp(250,300);
         verifyTouchEnd.position = ccp(400,100);
         
         
         verifyTouchStart.visible = false;
         verifyTouchEnd.visible = false;
         
         
         [self addChild: verifyTouchStart z:1 tag: TouchStartedLabelTag];
         [self addChild: verifyTouchAvailable z:1 tag: TouchAvailableLabelTag];
         [self addChild: verifyTouchEnd z:1 tag: TouchEndedLabelTag];
         
         */
        
        //This will schedule a call to the update method every frame
        [self scheduleUpdate];

        //this line initializes the instanceOfGameLayer variable such that it can be accessed by the sharedGameLayer method
        
        


    }
    
	return self;
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
        float THRESHOLD = 2;
    NSLog(@"Meter");
    if (acceleration.x > THRESHOLD || acceleration.x < -THRESHOLD ||
        acceleration.y > THRESHOLD || acceleration.y < -THRESHOLD ||
        acceleration.z > THRESHOLD || acceleration.z < -THRESHOLD) {
        
        if (!shake_once) {
            shake_once = YES;
            NSLog(@"Tremors");
        }
        
    }
    else {
        shake_once = NO;
    NSLog(@"Nothing");
    }
    
}


-(void) update: (ccTime) dt
{
    [self updatePlayerHealthIndicator];
    [self updatePlayerAttackIndicator];
    [self updatePlayerCoinIndicator];
    [self updateCurrentSuperWeaponIndicator];
    KKInput *input = [KKInput sharedInput];
    [self moveBackground];
    //This will be true during the frame a new finger touches the screen
    if(input.anyTouchBeganThisFrame)
    {
        if(currentEvent!=nil)
        {
            [currentEvent actionForTouchBegan];
        }
        //This lets you see if the touch was registered
        //**COMMENT THIS OUT WHEN YOU START WORK ON YOUR OWN GAME
        //[self getChildByTag:TouchStartedLabelTag].visible = true;
    }
    
    //This will be true as long as there is at least one finger touching the screen
    if(input.touchesAvailable)
    {
        //This lets you see where you are touching
        //**COMMENT THIS OUT WHEN YOU START WORK ON YOUR OWN GAME
        CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
        [self pickUpCoinsAt:pos];
        //[((CCLabelTTF*)[self getChildByTag:TouchAvailableLabelTag]) setString:[NSString stringWithFormat:@"You are tapping at %@", NSStringFromCGPoint(pos) ]];
        //**
    }
    
    //This will be true during the frame a finger that was once touching the screen stops touching the screen
    if(input.anyTouchEndedThisFrame)
    {
        //This lets you see if the end of the touch was registered
        //**COMMENT THIS OUT WHEN YOU START WORK ON YOUR OWN GAME
        //[self getChildByTag:TouchEndedLabelTag].visible = true;
    }
    
    if([ship hitpoints] <1)
    {
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameOverLayer alloc] initWithSector:eventCycle]];
    }
    
    if(currentEvent!=nil)
    {
        if([[currentEvent type] isEqualToString:@"Pirate"]) 
        {
            [(Pirate*)currentEvent play];
        }
        else if([[currentEvent type] isEqualToString:@"Planet"])
        {
            [(Planet*)currentEvent play];
        }
        else if([[currentEvent type] isEqualToString:@"Interlude"])
        {
            [(Interlude*)currentEvent play];
        }
        else if([[currentEvent type] isEqualToString:@"PirateKing"])
        {
            [(PirateKing*) currentEvent play];
        }
        else if([[currentEvent type] isEqualToString:@"SpacePort"])
        {
            [(SpacePort*) currentEvent play];
        }
        if(currentEvent.playState==-1)
        {
            currentEvent=nil;
        }
    }
    else [self loadTheNextEvent];
    
}

-(void) loadTheNextEvent
{
    
    if(gameState==2)
    {
        NSLog(@"Loading Tutorial");
        [self loadTutorial];
    }
    else if(gameState==1)[self loadNextIncrementalEvent];
}

-(void) loadTutorial
{
    switch(eventNumber)
    {
        case 1:
        {
            currentEvent = [Interlude createInterludeWithMessage:@""];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"Welcome to the tutorial! Tap to continue.";
            CCLabelTTF* screenText = [CCLabelTTF labelWithString :textToBeShown dimensions: CGSizeMake(400,100) alignment: UITextAlignmentCenter fontName:@"arial" fontSize:20.0f];
            screenText.position = ccp(screenSize.width/2,screenSize.height/5);
            [self addChild: screenText z:1 tag:TextOnScreenTag];
            break;
        }
        case 2:
        {
            currentEvent = [Interlude createInterludeWithBoxAtX:ship.position.x-54 y:ship.position.y-32 withWidth:128 andHeight:64];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"Your ship automatically attacks enemies.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        case 3:
        {
            currentEvent =[Pirate createHighlightedPirateWithHealth:50 andAttack:1 andAttackInterval:10 andPlayer:ship withBounty: 3];
            [currentEvent setPosition:ccp(screenSize.width+64,screenSize.height/2)];

            NSString* textToBeShown = @"Enemies get stronger as time goes by.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        }
        case 4:
        {
            currentEvent = [Interlude createInterludeWithBoxAtX:screenSize.width-(ship.position.x+26) y:ship.position.y-22 withWidth:45 andHeight:45];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"Enemies drop space swagg. Trade swagg for upgrades at planets.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        case 5:
        {
            currentEvent = [Planet createPlanet];
            [currentEvent setPosition:ccp(screenSize.width,screenSize.height/2)];
            [self addChild: currentEvent z:0 tag:CurrentEntityTag];
            NSString* textToBeShown = @"";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        case 6:
        {
            currentEvent = [Interlude createInterludeWithMessage: @""];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"You don't stay long at planets. Tap to continue.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        case 7:
        {
            currentEvent = [Interlude createInterludeWithMessage: @""];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"Later on, planets will have a lower chance of carrying upgrades.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        case 8:
        {
            currentEvent = [Interlude createInterludeWithBoxAtX:screenSize.width/4-105 y:screenSize.height*9/10-10 withWidth:215 andHeight:24];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"This shows your HP.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        case 9:
        {
            currentEvent = [Interlude createInterludeWithBoxAtX:screenSize.width*3/4-105 y:screenSize.height*9/10-10 withWidth:215 andHeight:24];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"This shows how strong and fast your attacks are.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        case 10:
        {
            currentEvent = [Interlude createInterludeWithMessage: @""];
            [self addChild: currentEvent z:1 tag: CurrentEntityTag];
            NSString* textToBeShown = @"Thanks for going through the tutorial! Tap the screen to exit.";
            [(CCLabelTTF*)[self getChildByTag: TextOnScreenTag] setString: textToBeShown];
            break;
        }
        default:
            [self removeChildByTag:TextOnScreenTag];
            [self toMainMenu];
            break;
    }
    eventNumber++;
}
/*
-(void) loadTutorial
{
    //NSLog([NSString stringWithFormat:@"%@%u", @"EventNumber = ",eventNumber]);
    switch (eventNumber) {
        case 1:
            currentEvent = [Interlude createInterludeWithMessage:@" Welcome to the Tutorial!"];
            [currentEvent setPosition: ccp(screenSize.width*1/7,0)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 2:
            currentEvent = [Interlude createInterludeWithMessage:@"<==That is your ship!"];
            [currentEvent setPosition: ccp(screenSize.width*1/7,0)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 3:
            currentEvent = [Interlude createInterludeWithMessage:@"You can't directly control the ship :("];
            [currentEvent setPosition: ccp(screenSize.width*1/7,0)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 4:
            currentEvent = [Interlude createInterludeWithMessage:@"But the ship will automatically fight enemies."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 5:
            currentEvent = [Interlude createInterludeWithMessage:@"Here comes an enemy! ==>"];
            [currentEvent setPosition: ccp(screenSize.width*1/7,0)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 6:
            currentEvent =[Pirate createPirateWithHealth:10 andAttack:1 andAttackInterval:50 andPlayer:ship withBounty: 3];
            [currentEvent setPosition:ccp(screenSize.width+64,screenSize.height/2)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 7:   
            currentEvent = [Interlude createInterludeWithMessage:@"Enemies drop loot"];
            [currentEvent setPosition: ccp(screenSize.width*1/7,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 8:
            currentEvent = [Interlude createInterludeWithMessage:@"Tap or drag your finger over the loot to collect it"];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 9:
            currentEvent = [Interlude createInterludeWithMessage:@"Over time these enemies will get stronger."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 10:
            currentEvent = [Interlude createInterludeWithMessage:@"But you can upgrade your ship at planets."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 11:
            currentEvent = [Interlude createInterludeWithMessage:@"You won't stay too long at planets though."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 12:
            currentEvent = [Interlude createInterludeWithMessage:@"So shop quickly!"];
            [currentEvent setPosition: ccp(screenSize.width*1/7,0)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 13:
            currentEvent = [Interlude createInterludeWithMessage:@"Planet ahead! ==>"];
            [currentEvent setPosition: ccp(screenSize.width*1/7,0)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 14:
            currentEvent = [Planet createPlanet];
            [currentEvent setPosition:ccp(screenSize.width,screenSize.height/2)];
            [self addChild: currentEvent z:0 tag:CurrentEntityTag];
            break;
        case 15:
            currentEvent = [Interlude createInterludeWithMessage:@"Planets won't always have everything though."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 16:
            currentEvent = [Interlude createInterludeWithMessage:@"And some may not even be inhabited!"];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 17:
            currentEvent = [Interlude createInterludeWithMessage:@"So whether you spend or save is up to you."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 18:
            currentEvent = [Interlude createInterludeWithMessage:@"Next Segment: Upgrades and Stats"];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 19:
            currentEvent = [Interlude createInterludeWithMessage:@"You may notice the indicators up above."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 20:
            currentEvent = [Interlude createInterludeWithMessage:@"The one on the left shows your hull"];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 21:
            currentEvent = [Interlude createInterludeWithMessage:@"The number to the left of the / is your remaining hull."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 22:
            currentEvent = [Interlude createInterludeWithMessage:@"The number to the right of the / is your maximum hull."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 23:
            currentEvent = [Interlude createInterludeWithMessage:@"You can repair your remaining hull at planets."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 24:
            break;
        case 25:
            currentEvent = [Interlude createInterludeWithMessage:@"Next is the attack power indicator."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 26:
            currentEvent = [Interlude createInterludeWithMessage:@"It shows how much damage your ship does per attack."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 27:
            currentEvent = [Interlude createInterludeWithMessage:@"The last number on the right shows your attack speed."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 28:
            currentEvent = [Interlude createInterludeWithMessage:@"That's how many frames between the ship's attacks."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 29:
            currentEvent = [Interlude createInterludeWithMessage:@"It can't be upgraded below 1 though :("];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 30:
            currentEvent = [Interlude createInterludeWithMessage:@"That would mean attack infinite times per frame."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 31:
            currentEvent = [Interlude createInterludeWithMessage:@"Infinite attacks per frame would destroy space-time."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 32:
            currentEvent = [Interlude createInterludeWithMessage:@"That would be bad."];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        case 33:
            currentEvent = [Interlude createInterludeWithMessage:@"Thanks for going through the tutorial!"];
            [currentEvent setPosition: ccp(0,-screenSize.height*1/4)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            break;
        default:
            [self toMainMenu];
            break;
    }

    
    eventNumber++;
}
 */
-(void) loadNextIncrementalEvent
{
    NSLog(@"Loading Next IncrementalEvent");
    NSLog([NSString stringWithFormat:@"%@%u", @"Event: ", eventNumber]);
    if(eventNumber == 1 || eventNumber == 3 || eventNumber == 5)
    {
        
        //[self removeExplosions];
        int attackInterval=10;
        if(eventCycle<15*9)
        {
            attackInterval-=eventCycle/15;
        }
        else{
            attackInterval=1;
        }
        //NSLog([ NSString stringWithFormat:@"%@%u",@"AttackInterval: ",attackInterval]);
        if(eventCycle%10==0)
        {
            currentEvent = [PirateKing createPirateKingWithHealth:3*(100+eventCycle*20) andAttack:15+(eventCycle*5/3)+ [ship hull]/20 andAttackInterval:attackInterval andPlayer:ship withBounty:12];
            [currentEvent setPosition:ccp(screenSize.width+64,screenSize.height/2)];
            [self addChild: currentEvent z:1 tag:CurrentEntityTag];
            eventNumber=8;
            superWeaponInUse=currentSuperWeapon;
        }
        else{
        currentEvent =[Pirate createPirateWithHealth:100+eventCycle*15 andAttack:15+(eventCycle*5/3) andAttackInterval:attackInterval andPlayer:ship withBounty: 3];
        [currentEvent setPosition:ccp(screenSize.width+64,screenSize.height/2)];
        [self addChild: currentEvent z:1 tag:CurrentEntityTag];
        }
    }
    else if(eventNumber %2 ==0)
    {
        if(eventCycle>25)
        {
            if(arc4random()%50<5)
            {
            if(eventNumber==6)eventNumber=4;
            }
        }
        currentEvent = [Interlude createInterludeWithTime:90];
    }
    else if(eventNumber ==7)
    {
        
        currentEvent = [Planet createPlanet];
        [currentEvent setPosition:ccp(screenSize.width,screenSize.height/2)];
        [self addChild: currentEvent z:0 tag:CurrentEntityTag];
        if(eventCycle==9)
        {
            eventNumber=8;
        }
    }
    else if(eventNumber==9)
    {
        currentSuperWeapon=0;
        superWeaponInUse=0;
        NSLog(@"Loading Port");
        currentEvent = [SpacePort createSpacePort];
        [currentEvent setPosition:ccp(screenSize.width,screenSize.height/2)];
        [self addChild: currentEvent z:0 tag:CurrentEntityTag];

    }
    eventNumber++;
    NSLog([NSString stringWithFormat:@"%@%u", @"Event: ", eventNumber]);
    if(eventNumber>7 && eventNumber!=9)
    {
        eventNumber=1;
        eventCycle++;
    }
}

-(void) loadNextEvent
{
    NSString* eventToBeLoaded =[NSString stringWithFormat: @"%@%u", @"Event", eventNumber];
    NSDictionary* eventToLoad = (NSDictionary*)[gameEvents objectForKey:eventToBeLoaded];
    //NSString* message = [NSString stringWithFormat: @" %@ %@", @"Loading Type: ", [eventToLoad objectForKey:@"Type"]];
    //NSLog(message);
    /*
    for (id key in gameEvents) {
        NSLog(@"key: %@, value: %@ \n", key, [gameEvents objectForKey:key]);
    }
     */
    if([[eventToLoad objectForKey:@"Type"] isEqualToString:@"Pirate"])
    {
        NSLog(@"Loading Pirate");
        int spawnHealth = [[eventToLoad objectForKey:@"Health"]intValue ];
        int spawnAttack = [[eventToLoad objectForKey: @"Attack"] intValue];
        int spawnAttackInterval = [[eventToLoad objectForKey: @"AttackInterval"] intValue];
        int spawnBounty = [[eventToLoad objectForKey:@"Bounty"] intValue];
        currentEvent =[Pirate createPirateWithHealth:spawnHealth andAttack:spawnAttack andAttackInterval:spawnAttackInterval andPlayer:ship withBounty: spawnBounty];
        [currentEvent setPosition:ccp(screenSize.width+64,screenSize.height/2)];
        [self addChild: currentEvent z:1 tag:CurrentEntityTag];
    }
    else if([[eventToLoad objectForKey:@"Type"] isEqualToString:@"Planet"])
            {
                currentEvent = [Planet createPlanet];
                [currentEvent setPosition:ccp(screenSize.width,screenSize.height/2)];
                [self addChild: currentEvent z:0 tag:CurrentEntityTag];
            }
    else if([[eventToLoad objectForKey:@"Type"] isEqualToString:@"Interlude"])
    {
        int spawnTime = [[eventToLoad objectForKey:@"Time"]intValue];
        currentEvent = [Interlude createInterludeWithTime:spawnTime];
        [self addChild: currentEvent z:0 tag:CurrentEntityTag];
    }
    eventNumber++;
    if(eventNumber>7)
    {
        eventNumber=1;
    }
}

-(void) pickUpCoinsAt: (CGPoint) pos
{
    NSMutableArray* coins = [[NSMutableArray alloc] init];
    CCArray* arr = [self children];
    for(CCLabelTTF* obj in arr)
    {
        if([obj isKindOfClass:[CCSprite class]])
        {
            if(((CCSprite*) obj).tag>9000)
            {
                [coins addObject: obj];
            }
        }

    }
    for(CCSprite* sprite in coins)
    {
        if(CGRectContainsPoint(sprite.boundingBox, pos))
        {
            [self removeChildByTag:sprite.tag];
            [self addCoinToPlayer];
        }
    }
    
}

-(void) addCoinToPlayer
{
    currentPlayerCredits++;
}

-(void) updatePlayerCoinIndicator
{
    NSString* currentPlayerCreditsString = [NSString stringWithFormat:@"%u",currentPlayerCredits];
    [(CCLabelTTF*)[self getChildByTag:PlayerCreditsTag] setString:currentPlayerCreditsString];
}

-(void) updatePlayerHealthIndicator
{
    healthToDisplay = [NSString stringWithFormat: @" %@ %u %@ %u", @"Hull:", [ship hitpoints], @"/", [ship hull]];
    [(CCLabelTTF*)[self getChildByTag:PlayerHealthTag] setString:healthToDisplay];
    
    
}
-(void) updatePlayerAttackIndicator
{
    attackPowerToDisplay = [NSString stringWithFormat: @" %@ %u %@ %u", @"Attack Power:", [ship damage], @" per ", [ship attackInterval]];
    [(CCLabelTTF*)[self getChildByTag:PlayerAttackTag] setString:attackPowerToDisplay];
    
    
}
-(void) moveBackground
{
    if(moving)
    {
        if(backgroundCount<568)
        {
            backgroundCount++;
            if(eventCycle<51)
            {
                backgroundCount+=eventCycle/10;
            }
            else{
                backgroundCount+=6;
            }
            [((CCSprite*)[self getChildByTag:StarBackgroundTag]) setPosition:ccp(-backgroundCount,0)];
        }
        else
        {
            backgroundCount=0;
        }
    }
}

-(void) dealloc
{
	instanceOfGameLayer = nil;
	
#ifndef KK_ARC_ENABLED
	// don't forget to call "super dealloc"
	[super dealloc];
#endif // KK_ARC_ENABLED
}

-(void) toPauseScreen
{
    NSLog(@"Pausing");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[PauseLayer alloc] initWithGame: self]];
}

-(void) bringUpUpgradesMenu
{
    //tag 1 = repairShip
    //tag 2 = upgradeHull
    //tag 3 = upgradeAttack
    //tag 4 = upgradeAttackSpeed
    if(gameState==1)[self bringUpUpgradesMenuEndlessMode];
    else if(gameState==2)[self bringUpUpgradesMenuTutorialMode];
        [[self getChildByTag:UpgradesMenuTag] setVisible: YES];
    
}

-(void) bringUpUpgradesMenuTutorialMode
{
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 1] setVisible:YES];
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 3] setVisible:YES];
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 2] setVisible:YES];
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 4] setVisible:YES];
}

-(void) bringUpUpgradesMenuEndlessMode
{
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 1] setVisible:NO];
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 2] setVisible:NO];
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 3] setVisible:NO];
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 4] setVisible:NO];
    int x=arc4random()%40;
    if(eventCycle<25)x-=(25-eventCycle);
    x-=10*repairChanceEqualizer;
    if(eventCycle>100)
    {
        x+=5;
            if(eventCycle>300)
            {
                x+=5;
            }
    }
    
    if(x<25)
    {
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 1] setVisible:YES];
        repairChanceEqualizer=0;
    }
    else
    {
        repairChanceEqualizer++;
    }
    x=arc4random()%50;
    if(eventCycle<25)x-=(26-eventCycle);
    if(x<25)
    {
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 3] setVisible:YES];
    }
    x=arc4random()%75;
    if(eventCycle<25)x-=(51-eventCycle*2);
    if(x<50)
    {
        [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 2] setVisible:YES];
    }
    if(ship.attackInterval>1)
    {
        x=arc4random()%400;
        if(eventCycle<50)x-=(51-eventCycle*2);
        if(x<50)
        {
            [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 4] setVisible:YES];
        }
    }
}

-(void) putAwayUpgradesMenu
{
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 1] setVisible:NO];
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 2] setVisible:NO];
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 3] setVisible:NO];
    [[[self getChildByTag:UpgradesMenuTag] getChildByTag: 4] setVisible:NO];
    [[self getChildByTag:UpgradesMenuTag] setVisible: NO];
}

-(void) upgradePlayerHull
{
    if(currentPlayerCredits>1)
    {
        currentPlayerCredits-=2;
        [ship upgradeHull];
    }
}

-(void) upgradePlayerAttack
{
    if(currentPlayerCredits>4)
    {
        currentPlayerCredits-=5;
        [ship upgradeWeapons];
    }
}

-(void) upgradePlayerAttackSpeed
{
    if(currentPlayerCredits>19)
    {
        if([ship attackInterval]>1)
        {
        currentPlayerCredits-=20;
        [ship upgradeAttackSpeed];
        }
    }
}

-(void) updateCurrentSuperWeaponIndicator
{
    NSString* stringToUse;
    switch(currentSuperWeapon)
    {
        case 1: stringToUse = @"Tech: Pew Pew Lazorz";
            break;
        case 2: stringToUse = @"Tech: Emer. Repair";
            break;
        case 3: stringToUse = @"Tech: Pwnt. Defense";
            break;
        case 4: stringToUse = @"Tech: Rflcptr Shields";
            break;
        default: stringToUse = @"No Adv. Tech";
            break;
    }
    
    [((CCLabelTTF*)[self getChildByTag: CurrentSuperWeaponIndicatorTag]) setString:stringToUse];
}

-(void) bringUpSuperWeaponsMenu
{
    [[self getChildByTag: SuperWeaponsMenuTag] setVisible:YES];
    
    [[self getChildByTag: SuperWeaponsMenuTitleTag] setVisible:YES];
}

-(void) putAwaySuperWeaponsMenu
{
    [[self getChildByTag: SuperWeaponsMenuTag] setVisible: NO];
    
    [[self getChildByTag: SuperWeaponsMenuTitleTag] setVisible:NO];
}

-(void) repairPlayerShip
{
    if(currentPlayerCredits>4)
    {
        
        if([ship hitpoints]<[ship hull])
        {
        currentPlayerCredits-=5;
        [ship repair];
        }
    }
}

-(void) toMainMenu
{
    eventCycle =0;
    eventNumber =0;
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GenericMenuLayer alloc] init]];
}

-(CCSprite*) getExplosion
{
    sprite = [CCSprite spriteWithSpriteFrameName:@"explosion1.png"];
    taunt = [CCSequence actions: [CCAnimate actionWithAnimation:taunting restoreOriginalFrame:NO], [CCCallFuncND actionWithTarget:sprite selector:@selector(removeFromParentAndCleanup:) data:(void*)NO], nil];
    [sprite runAction:taunt];
    
    return sprite;
    
}



-(void) removeExplosions
{
    while([self getChildByTag:ExplosionTag]!=nil)
    {
        [self removeChildByTag:ExplosionTag];
    }
}
@end
