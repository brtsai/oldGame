//
//  Planet.m
//  
//
//  Created by Bryan on 7/24/13.
//
//

#import "Planet.h"
#import "GameLayer.h"
@implementation Planet
NSString* text;
CCLabelTTF* textLabel;
+(id) createPlanet
{
    id myEntity = [[self alloc] init];
    //Don't worry about this, this is memory management stuff that will be handled for you automatically
#ifndef KK_ARC_ENABLED
	[myEntity autorelease];
#endif // KK_ARC_ENABLED
    return myEntity;
}

-(id) init
{
    if ((self = [super initWithFile:@"planet.png"]))
	{
        [self setType: @"Planet"];
        text=@"";
        textLabel = [CCLabelTTF labelWithString:text fontName:@"arial" fontSize:20.0f];
        [textLabel setPosition:ccp(75,-20)];
        [self addChild:textLabel];
	}
    return self;
}
-(void) effectsAndMisc
{
    [super setPlayState:1];
    [self updateLabel];
}
-(void) spawnAnimation
{
    if([super count]<150)
    {
        [self setPosition: ccp([self position].x-2,[self position].y)];
        [super setCount: [super count]+1];
    }
    else
    {
        [super setCount: 0];
        [super setPlayState:[super playState]+1];//changes the playState to "action"
        [((GameLayer*) self.parent) bringUpUpgradesMenu];
    }
}

-(void) action
{
    [super setCount: [super count]+1];
    [self updateLabel];
    if([super count]>300)
    {
        [super setCount: 0];
        [((GameLayer*) self.parent) putAwayUpgradesMenu];
        [super setPlayState: [super playState]+1];
        [self updateLabel];
    }
}

-(void) updateLabel
{
    if([super playState]==1) text=@"Entering Orbit";
    else if([super playState]==2)
    {
        NSString* newText = [NSString stringWithFormat:@" %@ %u", @"Leaving Orbit in: ", 300-[super count]];
        text=newText;
    }
    else if([super playState]==3) text=@"Leaving System";
    
    [textLabel setString:text];
    
    
}

-(void) deathAnimation
{
    if([super count]<150)
    {
        [self setPosition: ccp([self position].x-2,[self position].y)];
        [super setCount: [super count]+1];
    }
    else
    {
        super.playState=-1;
        [self removeSelf];
    }
}
@end
