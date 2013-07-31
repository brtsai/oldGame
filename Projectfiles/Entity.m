/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "Entity.h"
#import "GameLayer.h"

@implementation Entity
@synthesize hitpoints;
@synthesize playState;
@synthesize type;
@synthesize count;
//This is the method other classes should call to create an instance of Entity
+(id) createEntity
{
	id myEntity = [[self alloc] initWithEntityImage];
//Don't worry about this, this is memory management stuff that will be handled for you automatically    
#ifndef KK_ARC_ENABLED
	[myEntity autorelease];
#endif // KK_ARC_ENABLED
    return myEntity;
}

-(id) initWithEntityImage
{
    
	// Loading the Entity's sprite using a file, is a ship for now but you can change this
	if ((self = [super initWithFile:@"ship.png"]))
	{
        hitpoints = 10;
		//do stuff
	}
    _screenSize = [[CCDirector sharedDirector] winSize];
    [self setCount:0];
    [self setType:@"Entity"];
    playState=0;
	return self;
}

// You can override setPosition, a method inherited from CCSprite, to keep entitiy within screen bounds

/*
-(void) setPosition:(CGPoint)pos
{
	// If the current position is (still) outside the screen no adjustments should be made!
	// This allows entities to move into the screen from outside.
	if ([self isOutsideScreenArea])
	{
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float halfWidth = self.contentSize.width * 0.5f;
		float halfHeight = self.contentSize.height * 0.5f;
		
		// Cap the position so the Ship's sprite stays on the screen
		if (pos.x < halfWidth)
		{
			pos.x = halfWidth;
		}
		else if (pos.x > (screenSize.width - halfWidth))
		{
			pos.x = screenSize.width - halfWidth;
		}
		
		if (pos.y < halfHeight)
		{
			pos.y = halfHeight;
		}
		else if (pos.y > (screenSize.height - halfHeight))
		{
			pos.y = screenSize.height - halfHeight;
		}
	}
	
	[super setPosition:pos];
}

*/ 
 
-(BOOL) isOutsideScreenArea
{
	return (CGRectContainsRect([GameLayer screenRect], [self boundingBox]));
}

//example methods you can add that a normal CCSprite doesn't have
-(void) takeDamage
{
    hitpoints -= 1;
}

-(int) checkHitpoints
{
    return hitpoints;
}

-(void) takeDamage: (int) damageTaken
{
    hitpoints-=damageTaken;
}

-(void) play
{
    switch(playState)
    {
        case -1://remove self from layer
            [self removeSelf];
            break;
        case 0: //extra initialising add in effects n stuff later?
            [self effectsAndMisc];
            break;
        case 1:  //play spawn animation
            [self spawnAnimation];
            break;
        case 2: //do normal actions
            [self action];
            break;
        case 3:
            [self deathAnimation];
            break;
        default: //weird stuff
            if(YES){
            NSString* textToLog;
            textToLog = [NSString stringWithFormat:@" %@ %u", @"Default case reached with state:", playState];
            NSLog(textToLog);
            }
            break;
    }
}
-(void) actionForTouchBegan
{
    
}
-(void) takeDamage:(int)damageTaken fromSource:(NSString *)damageSource
{
    [self takeDamage:damageTaken];
}

-(void) effectsAndMisc
{
    playState=1;
}
-(void) spawnAnimation
{
    playState=2;
}

-(void) deathAnimation
{
    playState=-1;
    [self removeSelf];
}

-(void) action
{
    playState=3;
}

-(void) removeSelf
{
    [super removeFromParentAndCleanup:YES];
}

@end
