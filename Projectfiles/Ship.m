//
//  Ship.m
//  
//
//  Created by Bryan on 7/19/13.
//
//

#import "Ship.h"
#import "GameLayer.h"

@implementation Ship
@synthesize damage;
@synthesize hull;
@synthesize attackInterval;
+(id) createShip
{
    id myShip = [[self alloc] init];
    #ifndef KK_ARC_ENABLED
	[myShip autorelease];
    #endif // KK_ARC_ENABLED
    return myShip;
}



-(id) init
{
    if ((self = [super initWithFile:@"ship.png"]))
	{
        
        super.screenSize = [[CCDirector sharedDirector] winSize];
        [self setHull: 1000];
        [self setType: @"Ship"];
        [super setHitpoints:hull];
        [self setAttackInterval:10];
		//do stuff
        [self setDamage:20];
	}
	return self;
}

-(void) upgradeHull
{
    [super setHitpoints:[super hitpoints]+2];
    hull+=2;
}

-(void) upgradeWeapons
{
    damage++;
}

-(void) upgradeAttackSpeed
{
    attackInterval--;
}
-(void) repair
{
    [super setHitpoints:hull];
}

@end
