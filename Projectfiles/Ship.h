//
//  Ship.h
//  
//
//  Created by Bryan on 7/19/13.
//
//

#import "Entity.h"

@interface Ship : Entity
@property int hull;
@property int damage;
@property int attackInterval;
+(id) createShip;
-(void) upgradeHull;
-(void) upgradeWeapons;
-(void) upgradeAttackSpeed;
-(void) repair;
@end
