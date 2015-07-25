//
//  DerekNumber.m
//  dereknetto
//
//  Created by Z on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DerekNumber.h"

@implementation DerekNumber

- (instancetype)initWithRadians:(float)radians {
    
    self = [super init];
    
    if (self) {
        self.real = cos(radians/2.0f);
        self.complex = sin(radians/2.0f);
        self.angle = atan2f(self.real,self.complex)*2;
    }
    return self;
}

@end
