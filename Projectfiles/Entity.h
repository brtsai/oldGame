/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import <Foundation/Foundation.h>
#import "cocos2d.h"

//#import "Component.h"
@class Component;

//By subclassing CCSprite you can add attributes like hitpoints and internal logic 
@interface Entity : CCSprite 
{
    
   
}
 @property int hitpoints;
@property int playState;
 @property NSString* type;
@property int count;
@property CGSize screenSize;
-(void) takeDamage: (int) damageTaken fromSource: (NSString*) damageSource;
+(id) createEntity;
-(id) initWithEntityImage;
-(void) takeDamage;
-(void) takeDamage: (int) damageTaken;
-(int) checkHitpoints;
-(BOOL) isOutsideScreenArea;
-(void) play;
-(void) removeSelf;
-(void) actionForTouchBegan;
@end
