//
//  interlude.h
//  
//
//  Created by Bryan on 7/24/13.
//
//

#import "Entity.h"

@interface Interlude : Entity
+(id) createInterludeWithTime: (int) time;
+(id) createInterludeWithMessage: (NSString*) message;
+(id) createInterludeWithBoxAtX: (int)x y: (int) y withWidth: (int) width andHeight: (int) height;
@end
