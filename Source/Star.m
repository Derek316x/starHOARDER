//
//  Star.m
//  dereknetto
//
//  Created by Z on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Star.h"

@implementation Star

-(void) didLoadFromCCB {
    self.physicsBody.collisionType = @"star";
    
}

@end
