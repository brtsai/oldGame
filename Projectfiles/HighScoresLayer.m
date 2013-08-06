//
//  HighScoresLayer.m
//  
//
//  Created by Bryan on 7/31/13.
//
//

#import "HighScoresLayer.h"
#import "GenericMenuLayer.h"

@implementation HighScoresLayer
CGSize screenSize;

-(id) init
{
    if ((self = [super init]))
    {
        //Adds the back button to the screen.
        screenSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF* leaveLabel = [CCLabelTTF labelWithString:@"Exit" fontName:@"arial" fontSize:45.0f];
        CCMenuItemLabel* backButton = [CCMenuItemLabel itemWithLabel:leaveLabel target:self selector: @selector(toMainMenu)];
        CCMenu* leave = [CCMenu menuWithItems:backButton, nil];
        leave.position = ccp(screenSize.width*3/4,screenSize.height*8/10);
        [self addChild: leave z:1];
        NSString* highScore;
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"]==nil)
        {
            highScore = @"No Highscores";
        }
        else
        {
            highScore = [NSString stringWithFormat:@"%@%u", @"Sector ",[[[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"] intValue]];
        }
        CCLabelTTF* highScoresLabel = [CCLabelTTF labelWithString:highScore fontName:@"arial" fontSize:60.0f];
        highScoresLabel.position = ccp(screenSize.width/2,screenSize.height/2);
        [self addChild: highScoresLabel];
    }
    return self;
}

-(void) toMainMenu
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GenericMenuLayer alloc] init]];
}


@end
