//
//  Avatar.m
//  dereknetto
//
//  Created by Z on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Avatar.h"

@implementation Avatar

-(void) didLoadFromCCB {
    self.physicsBody.collisionType = @"avatar";
}

@end
