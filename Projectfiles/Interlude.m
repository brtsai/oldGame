//
//  interlude.m
//  
//
//  Created by Bryan on 7/24/13.
//
//

#import "Interlude.h"

@implementation Interlude

int interludeTime, x, y;
bool timeOn,boxOn;
CCLabelTTF* text;
int width, height;
+(id) createInterludeWithTime: (int) time
{
    id myEntity = [[self alloc] initWithTime: time];
    //Don't worry about this, this is memory management stuff that will be handled for you automatically
#ifndef KK_ARC_ENABLED
	[myEntity autorelease];
#endif // KK_ARC_ENABLED
    return myEntity;
}
+(id) createInterludeWithMessage: (NSString*) message
{
    id myEntity = [[self alloc] initWithMessage: message];
    //Don't worry about this, this is memory management stuff that will be handled for you automatically
#ifndef KK_ARC_ENABLED
	[myEntity autorelease];
#endif // KK_ARC_ENABLED
    return myEntity;
}
+(id) createInterludeWithBoxAtX: (int)x y: (int) y withWidth: (int) width andHeight: (int) height
{
    id myEntity = [[self alloc] initWithBoxAtX:x y: y withWidth: width andHeight:height];
    //Don't worry about this, this is memory management stuff that will be handled for you automatically
#ifndef KK_ARC_ENABLED
	[myEntity autorelease];
#endif // KK_ARC_ENABLED
    return myEntity;
}



-(id) initWithBoxAtX: (int) newX y: (int) newY withWidth: (int) newWidth andHeight: (int)newHeight
{
    if ((self = [super init]))
	{
        timeOn=NO;
        boxOn=YES;
        x=newX;
        y=newY;
        width=newWidth;
        height = newHeight;
        [self setType: @"Interlude"];
	}
    return self;
}

-(void) draw
{
    [super draw];
    if(boxOn)
    {
        ccDrawColor4B(50,50,255, 255);
            ccDrawRect(ccp(x,y),ccp(x+width,y+height));
        
    }
    
}
-(id) initWithTime: (int) newTime
{
    if ((self = [super init]))
	{
        boxOn=NO;
        timeOn=YES;
        interludeTime=newTime;
        [self setType: @"Interlude"];
	}
    return self;
}

-(id) initWithMessage: (NSString*) message
{
    if(self = [super init])
    {
        boxOn=NO;
        timeOn=NO;
        [self setType: @"Interlude"];
        text = [CCLabelTTF labelWithString:message fontName:@"arial" fontSize:20.0f];

         CCMenuItemLabel *item = [CCMenuItemLabel itemWithLabel:text target:self selector:@selector(moveOn)];
        CCMenu *theMessage = [CCMenu menuWithItems:item, nil];
        [self addChild: theMessage];
    }
    return self;
}
    
-(void) action
{
    if(timeOn)
    {
        if([super count]<interludeTime)
        {
        [super setCount: [super count]+1];
        }
        else
        {
        [super setPlayState: [super playState]+1];
        }
    }
    else
    {
        
    }
}
-(void) actionForTouchBegan
{
    [super setPlayState: 3];
}
-(void) moveOn
{
    [super setPlayState: [super playState]+1];
}
@end
