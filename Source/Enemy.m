//
//  Enemy.m
//  dereknetto
//
//  Created by Z on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy

-(void) didLoadFromCCB {
    self.physicsBody.collisionType = @"enemy";
}

@end
