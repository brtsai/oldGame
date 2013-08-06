//
//  PirateKing.m
//  
//
//  Created by Bryan on 8/1/13.
//
//

#import "PirateKing.h"
#import "GameLayer.h"
@implementation PirateKing
@synthesize damage;
@synthesize attackInterval;
@synthesize bounty;
NSString* text;
bool attacking,attacked,highlight;
int otherCounter;
CCLabelTTF *textLabel;
Ship* target;
+(id) createPirateKingWithHealth:(int)health andAttack:(int)attack andAttackInterval:(int)attackInterval andPlayer: (Ship*) player withBounty: (int) bounty
{
    id myPirateKing = [[self alloc] initWithHealth: health andAttack: attack andAttackInterval:attackInterval andPlayer: player withBounty: bounty];
    
#ifndef KK_ARC_ENABLED
	[myShip autorelease];
#endif // KK_ARC_ENABLED
    return myPirateKing;
}

+(id) createHighlightedPirateKingWithHealth:(int)health andAttack:(int)attack andAttackInterval:(int)attackInterval andPlayer: (Ship*) player withBounty: (int) bounty
{
    id myPirate = [[self alloc] initHighlightedWithHealth: health andAttack: attack andAttackInterval:attackInterval andPlayer: player withBounty: bounty];
    
#ifndef KK_ARC_ENABLED
	[myShip autorelease];
#endif // KK_ARC_ENABLED
    return myPirate;
}

-(id) initHighlightedWithHealth: (int) health andAttack: (int) attack andAttackInterval: (int) attackSpeed andPlayer: (Ship*) player withBounty: (int)coins
{
    if ((self = [super initWithFile:@"pirateKing.png"]))
	{
        highlight=YES;
        otherCounter=0;
        glLineWidth(1.0f);
        attacking=NO;
        attacked=NO;
        [super setCount:0];
        super.screenSize = [[CCDirector sharedDirector] winSize];
        [self setAttackInterval:attackSpeed];
        target=player;
        [self setType: @"PirateKing"];
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
    if ((self = [super initWithFile:@"pirateKing.png"]))
	{
        otherCounter=0;
        highlight=NO;
        glLineWidth(1.0f);
        attacking=NO;
        attacked=NO;
        [super setCount:0];
        super.screenSize = [[CCDirector sharedDirector] winSize];
        [self setAttackInterval:attackSpeed];
        target=player;
        [self setType: @"PirateKing"];
        hull = health;
        [super setHitpoints:hull];
        damage = attack;
        bounty = coins;
        text=[NSString stringWithFormat: @" %@ %u", @"HP:",[super hitpoints]];
        textLabel = [CCLabelTTF labelWithString:text fontName:@"arial" fontSize:25.0f];
        [textLabel setPosition:ccp(90,180)];
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
    if([super count]%([target attackInterval]*4) ==0)
    {
                [super takeDamage:[target damage]];
        
        if([((GameLayer*) self.parent) superWeaponInUse]==1)
        {
            [super takeDamage:[target damage]];
            [super takeDamage:[target damage]];
        }
        
        attacked=YES;
        //NSString* toPrint = [NSString stringWithFormat:@"%@ %u", @"Pirate has:",[self hitpoints]];
        //NSLog(toPrint);
    }
    if([super count]%([self attackInterval]*4)==0)
    {
        attacking=YES;
        //NSLog(@"PirateAttacked");
        
        if([((GameLayer*) self.parent) superWeaponInUse]==1)
        {
            if([target hitpoints]< [self damage])
            {
                [target repair];
                [((GameLayer*) self.parent)setSuperWeaponInUse: 0];
                otherCounter=0;
            }
        }
        if([((GameLayer*) self.parent)superWeaponInUse]!=3 && [((GameLayer*) self.parent) superWeaponInUse]!=4)
        {
        [target takeDamage:[self damage]];
        }
        else if([((GameLayer*) self.parent) superWeaponInUse]==4)
        {
            NSLog(@"Shot self");
            [super takeDamage:[self damage]];
        }
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
        
        glLineWidth(5);
        ccDrawColor4B(255,0,0, 255);
        if([((GameLayer*) self.parent)superWeaponInUse]!=3 && [((GameLayer*) self.parent) superWeaponInUse]!=4)
        {
        ccDrawLine( ccp(15,50), ccp(-(self.position.x-target.position.x)+128+80,90));
        }
        else if([((GameLayer*) self.parent)superWeaponInUse]==3)
        {
            ccDrawLine( ccp(15,50), ccp(-(self.position.x-target.position.x)+128+100,78));
            glLineWidth(1);
            ccDrawColor4B(0,255,0,255);
            ccDrawLine(ccp(-(self.position.x-target.position.x)+128+68,80),ccp(-(self.position.x-target.position.x)+128+100,78));
            ccDrawLine(ccp(-(self.position.x-target.position.x)+128+112,90),ccp(-(self.position.x-target.position.x)+128+100,78));
            ccDrawLine(ccp(-(self.position.x-target.position.x)+128+104,60),ccp(-(self.position.x-target.position.x)+128+100,78));
            otherCounter++;
        }
        else if([((GameLayer*) self.parent) superWeaponInUse]==4)
        {
            ccDrawLine( ccp(15,50), ccp(-(self.position.x-target.position.x)+128+100,78));
            ccDrawColor4B(0,0,255,255);
            ccDrawLine(ccp(-(self.position.x-target.position.x)+128+100,90),ccp(-(self.position.x-target.position.x)+128+100,66));
            ccDrawColor4B(255,0,255,255);
            ccDrawLine(ccp(-(self.position.x-target.position.x)+128+100,78),ccp(50,120));
            otherCounter++;
        }
    }
    if(attacked)
    {
        glLineWidth(1);
        if([((GameLayer*) self.parent) superWeaponInUse]==1)
        {
            glLineWidth(3);
        }
        ccDrawColor4B(0,255,0, 255);
        ccDrawLine( ccp(50,120), ccp(-(self.position.x-target.position.x)+128+68,80));
        
    }
    if(highlight)
    {
        ccDrawColor4B(50,50,255, 255);
        ccDrawRect(ccp(0,0),ccp(128, 74));
    }
    if([((GameLayer*) self.parent)superWeaponInUse]==3)
    {
        if(otherCounter>4)
        {
            [((GameLayer*) self.parent)setSuperWeaponInUse: 0];
            otherCounter=0;
        }
    }
    if([((GameLayer*) self.parent) superWeaponInUse]==4)
    {
        if(otherCounter>1)
        {
        [((GameLayer*) self.parent)setSuperWeaponInUse: 0];
        otherCounter=0;
        }

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
    
    CCSprite* explosion = [((GameLayer*)self.parent) getExplosion];
    explosion.position = self.position;
    [self.parent addChild:explosion z:1 tag:ExplosionTag];
    
    [super setPlayState:-1];
    [self removeSelf];
}

-(void) updateLabel
{
    text=[NSString stringWithFormat: @" %@ %u", @"HP:",[super hitpoints]];
    [textLabel setString:text];
}

@end
