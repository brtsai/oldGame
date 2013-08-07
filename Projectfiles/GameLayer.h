/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Entity.h"


//This assigns an integer value to an arbitrarily long list, where each has a value 1 greater than the last. So here TouchAvailableLabelTag = 3 and TouchEndedLabelTag = 4
typedef enum
{
	TouchStartedLabelTag = 2,
	TouchAvailableLabelTag,
	TouchEndedLabelTag,
	StarBackgroundTag,
    CurrentEntityTag,
    PlayerHealthTag,
    PlayerCreditsTag,
    PlayerCreditsSpriteTag,
    PlayerAttackTag,
    UpgradesMenuTag,
    TextOnScreenTag,
    ExplosionTag,
    SuperWeaponsMenuTag,
    SuperWeaponsMenuTitleTag,
    CurrentSuperWeaponIndicatorTag
} LabelTags;

@interface GameLayer : CCLayer 
{
    CCSprite* Background;
    CCSequence *taunt;
    NSMutableArray *tauntingFrames;
}
+(CGRect) screenRect;
+(GameLayer*) sharedGameLayer;
-(CCSprite*) getExplosion;
-(void) removeExplosions;
-(void) bringUpUpgradesMenu;
-(void) putAwayUpgradesMenu;
-(id) initAsTutorial;
-(id) initAsEndless;
-(id) resume;
-(void) putAwaySuperWeaponsMenu;
-(void) bringUpSuperWeaponsMenu;
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@property int superWeaponInUse;
@property int gameState;
@property int eventCycle;
@end
