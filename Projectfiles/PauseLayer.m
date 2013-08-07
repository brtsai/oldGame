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
#import "GameOverLayer.h"
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
            CCLabelTTF* abandonGame = [CCLabelTTF labelWithString: @"Abandon Mission" fontName:@"arial" fontSize:40.0f];
            CCMenuItemLabel* abandonTheGame = [CCMenuItemLabel itemWithLabel:abandonGame target:self selector:@selector(exitGame)];
            menu = [CCMenu menuWithItems:resumeButton,abandonTheGame, nil];
            [menu alignItemsVerticallyWithPadding:10.0f];
            [self addChild: menu];
        }
    }
    return self;
}

-(void) exitGame
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameOverLayer alloc] initWithSector:pausedGame.eventCycle andDeathMessage:@"Mission Abandoned!"]];
}

-(void) resumeGame
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[pausedGame resume]];
}
@end
