//
//  LevelOne.m
//  
//
//  Created by Bryan on 7/18/13.
//
//

#import "LevelOne.h"
#import "GenericMenuLayer.h"

@implementation LevelOne

CCLabel* instruction;
CCLabel* metersLeft;

-(void) init
{
    instruction = [CCLabelTTF labelWithString:@"Swipe the screen to run!" fontName:@"arial" fontSize:20.0f];
    instruction.position= ccp(
    [self addChild: instruction z:1];
    
    
    [self scheduleUpdate];
}

-(void) update: (ccTime) dt
{
    
}

@end
