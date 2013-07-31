//
//  Pirate.m
//  
//
//  Created by Bryan on 7/23/13.
//
//

#import "Pirate.h"
#import "Ship.h"
#import "GAmelayer.h"
@implementation Pirate
@synthesize damage;
@synthesize attackInterval;
@synthesize bounty;
NSString* text;
bool attacking,attacked,highlight;
CCLabelTTF *textLabel;
Ship* target;
+(id) createPirateWithHealth:(int)health andAttack:(int)attack andAttackInterval:(int)attackInterval andPlayer: (Ship*) player withBounty: (int) bounty
{
    id myPirate = [[self alloc] initWithHealth: health andAttack: attack andAttackInterval:attackInterval andPlayer: player withBounty: bounty];
    
#ifndef KK_ARC_ENABLED
	[myShip autorelease];
#endif // KK_ARC_ENABLED
    return myPirate;
}

+(id) createHighlightedPirateWithHealth:(int)health andAttack:(int)attack andAttackInterval:(int)attackInterval andPlayer: (Ship*) player withBounty: (int) bounty
{
    id myPirate = [[self alloc] initHighlightedWithHealth: health andAttack: attack andAttackInterval:attackInterval andPlayer: player withBounty: bounty];
    
#ifndef KK_ARC_ENABLED
	[myShip autorelease];
#endif // KK_ARC_ENABLED
    return myPirate;
}

-(id) initHighlightedWithHealth: (int) health andAttack: (int) attack andAttackInterval: (int) attackSpeed andPlayer: (Ship*) player withBounty: (int)coins
{
    if ((self = [super initWithFile:@"darkShip.png"]))
	{
        highlight=YES;
        
        glLineWidth(1.0f);
        attacking=NO;
        attacked=NO;
        [super setCount:0];
        super.screenSize = [[CCDirector sharedDirector] winSize];
        [self setAttackInterval:attackSpeed];
        target=player;
        [self setType: @"Pirate"];
        hull = health;
        [super setHitpoints:hull];
        damage = attack;
        bounty = coins;
        text=[NSString stringWithFormat: @" %@ %u", @"HP:",[super hitpoints]];
        textLabel = [CCLabelTTF labelWithString:text fontName:@"arial" fontSize:15.0f];
        [textLabel setPosition:ccp(50,64)];
        [self addChild:textLabel];
	}
	return self;
}


int hull;

-(id) initWithHealth: (int) health andAttack: (int) attack andAttackInterval: (int) attackSpeed andPlayer: (Ship*) player withBounty: (int)coins
{
    if ((self = [super initWithFile:@"darkShip.png"]))
	{
        
        highlight=NO;
        glLineWidth(1.0f);
        attacking=NO;
        attacked=NO;
        [super setCount:0];
        super.screenSize = [[CCDirector sharedDirector] winSize];
        [self setAttackInterval:attackSpeed];
        target=player;
        [self setType: @"Pirate"];
        hull = health;
        [super setHitpoints:hull];
        damage = attack;
        bounty = coins;
        text=[NSString stringWithFormat: @" %@ %u", @"HP:",[super hitpoints]];
        textLabel = [CCLabelTTF labelWithString:text fontName:@"arial" fontSize:15.0f];
        [textLabel setPosition:ccp(50,64)];
        [self addChild:textLabel];
	}
	return self;
}

-(void) repair
{
    [super setHitpoints:hull];
}

-(void) spawnAnimation
{
    if([super count]<82)
    {
        [self setPosition: ccp([self position].x-2,[self position].y)];
        [super setCount: [super count]+1];
    }
         else
         {
             [super setCount: 1];
             [super setPlayState:[super playState]+1];//changes the playState to "action"
         }
}

-(void) action
{
    
    [self updateLabel];


    attacked=NO;
    attacking=NO;
     if([super count]%[target attackInterval] ==0)
     {
         [super takeDamage:[target damage]];
         attacked=YES;
         //NSString* toPrint = [NSString stringWithFormat:@"%@ %u", @"Pirate has:",[self hitpoints]];
         //NSLog(toPrint);
     }
     if([super count]%[self attackInterval]==0)
     {
         attacking=YES;
         //NSLog(@"PirateAttacked");
         [target takeDamage:[self damage]];
         //NSString* toPrint = [NSString stringWithFormat:@"%@ %u", @"Target has:",[target hitpoints]];
         //NSLog(toPrint);
     }
    if([super hitpoints]<1)
    {
        [super setCount:0];
        [super setPlayState:[super playState]+1];//changes the playState to "deathAnimation"
    }
    else{
    [self updateLabel];
    }
    [super setCount: [super count]+1];
}

-(void) draw
{
    [super draw];
    if(attacking)
    {
    ccDrawColor4B(255,0,0, 255);
    ccDrawLine( ccp(15,14), ccp(-(self.position.x-target.position.x)+128-5,24));
    }
    if(attacked)
    {
        ccDrawColor4B(0,255,0, 255);
        ccDrawLine( ccp(5,24), ccp(-(self.position.x-target.position.x)+128-15,14));

    }
    if(highlight)
    {
        ccDrawColor4B(50,50,255, 255);
        ccDrawRect(ccp(0,0),ccp(128, 74));
    }
}

-(void) deathAnimation
{
    
    for(int i=0;i<bounty;i++)
    {
        CCSprite* coin = [CCSprite spriteWithFile:@"spaceCoin.png"];
        [coin setPosition: [self position]];
        [self.parent addChild: coin z:1 tag:9001+i];
    }
    [super setPlayState:-1];
    [self removeSelf];
}

-(void) updateLabel
{
    text=[NSString stringWithFormat: @" %@ %u", @"HP:",[super hitpoints]];

    [textLabel setString:text];
    
    
}

@end
