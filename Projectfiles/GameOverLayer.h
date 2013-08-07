//
//  GameOverLayer.h
//  
//
//  Created by Bryan on 7/19/13.
//
//

#import "CCLayer.h"

@interface GameOverLayer : CCLayer
-(id) initWithSector: (int) sector andDeathMessage: (NSString*) deathMessage;
@end
