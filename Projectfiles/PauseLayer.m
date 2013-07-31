//
//  PauseLayer.m
//  
//
//  Created by Bryan on 7/31/13.
//
//

#import "PauseLayer.h"
#import "GameLayer.h"
#import "GenericMenuLayer.h"
@implementation PauseLayer
CCMenu* menu;
GameLayer* pausedGame;

-(id) initWithGame: (GameLayer*) theGame
{
    if(self = [super init])
    {
        if(theGame==nil)
        {
            [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GenericMenuLayer alloc] init]];
        }
        else
        {
            pausedGame = theGame;
            CCLabelTTF* resume = [CCLabelTTF labelWithString:@"Resume" fontName:@"arial" fontSize:80.0f];
            CCMenuItemLabel* resumeButton = [CCMenuItemLabel itemWithLabel:resume target:self selector:@selector(resumeGame)];
            menu = [CCMenu menuWithItems:resumeButton,nil];
            [self addChild: menu];
        }
    }
    return self;
}



-(void) resumeGame
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[pausedGame resume]];
}
@end
