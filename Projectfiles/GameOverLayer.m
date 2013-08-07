//
//  GameOverLayer.m
//  
//
//  Created by Bryan on 7/19/13.
//
//

#import "GameOverLayer.h"
#import "GenericMenuLayer.h"
@implementation GameOverLayer
CGSize screenSize;

-(id) initWithSector: (int) sector andDeathMessage: (NSString*) deathMessage
{
	if ((self = [super init]))
	{
        screenSize = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Return to Start Menu" fontName:@"arial" fontSize:40.0f];
        NSString *playerAt = [NSString stringWithFormat:@"%@ %u", @"You got to sector:", sector];
        CCLabelTTF* endedAt = [CCLabelTTF labelWithString:playerAt fontName: @"arial" fontSize:40.0f];
        endedAt.position=ccp(screenSize.width/2,screenSize.height/2);
        
        [self addChild:endedAt];
        CCMenuItemLabel *item = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(doSomething)];
        
        
        CCMenu *menu = [CCMenu menuWithItems:item, nil];
        menu.position = ccp(screenSize.width/2, screenSize.height*1/4);
        [self addChild:menu];
        
        CCLabelTTF *deathLabel = [CCLabelTTF labelWithString:deathMessage fontName: @"arial" fontSize:40.0f];
        deathLabel.position = ccp(screenSize.width/2,screenSize.height*3/4);
        [self addChild:deathLabel];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"]==nil || [[[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"] intValue]<sector)
        {
            NSNumber *highScore = [NSNumber numberWithInteger:sector];
            [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"highScore"];
            NSLog(@"New High Score");
        }
        
        
    }
    
    return self;
    
}

-(void) doSomething
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GenericMenuLayer alloc] init]];
}
@end
