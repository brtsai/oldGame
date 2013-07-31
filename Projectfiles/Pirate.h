//
//  Pirate.h
//  
//
//  Created by Bryan on 7/23/13.
//
//

#import "Entity.h"
#import "Ship.h"

@interface Pirate : Entity

@property int damage;
@property int attackInterval;
+(id) createPirateWithHealth:(int)health andAttack:(int)attack andAttackInterval:(int)attackInterval andPlayer: (Ship*) player withBounty: (int) bounty;
+(id) createHighlightedPirateWithHealth:(int)health andAttack:(int)attack andAttackInterval:(int)attackInterval andPlayer: (Ship*) player withBounty: (int) bounty;
@property int hitpoints;
@property int playState;
@property NSString* type;
@property int count;
@property CGSize screenSize;
@property int bounty;
+(void) takeDamage: (int) damageTaken fromSource: (NSString*) damageSource;
+(id) createEntity;
-(id) initWithEntityImage;
-(void) takeDamage;
-(void) takeDamage: (int) damageTaken;
-(int) checkHitpoints;
-(BOOL) isOutsideScreenArea;
@end
