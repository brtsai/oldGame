//
//  GenericMenuLayer.m
//  Game Template
//
//  Created by Jeremy Rossmann on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericMenuLayer.h"
#import "GameLayer.h"
#import "Ship.h"
#import "HighScoresLayer.h"
@implementation GenericMenuLayer

-(id) init
{
	if ((self = [super init]))
	{
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Start!" fontName:@"arial" fontSize:80.0f];
        
        CCMenuItemLabel *item = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(doSomething)];
        
        CCLabelTTF *tutorialLabel = [CCLabelTTF labelWithString:@"Tutorial!" fontName:@"arial" fontSize:80.0f];
        
        CCMenuItemLabel *tutorialMenuItem = [CCMenuItemLabel itemWithLabel:tutorialLabel target:self selector:@selector(tutorial)];
        
        CCLabelTTF * highScores = [CCLabelTTF labelWithString:@"High Scores" fontName: @"arial" fontSize: 40.0f];
        
        CCMenuItemLabel * highScoresLabel = [CCMenuItemLabel itemWithLabel:highScores target:self selector:@selector(toHighScores)];
                
        CCMenu *menu = [CCMenu menuWithItems:item, tutorialMenuItem, highScoresLabel, nil];
        [menu alignItemsVerticallyWithPadding:5.0f];
        
        
        [self addChild:menu];
        
    }
    
    return self;
    
}

-(void) toHighScores
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[HighScoresLayer alloc] init]];

}

-(void) tutorial
{
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] initAsTutorial]];
}

-(void) doSomething
{
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] initAsEndless]];
}


@end
