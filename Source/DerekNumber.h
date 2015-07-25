//
//  DerekNumber.h
//  dereknetto
//
//  Created by Z on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DerekNumber : NSNumber

@property (nonatomic, assign) float real;
@property (nonatomic, assign) float complex;
@property (nonatomic, assign) float angle;

- (instancetype)initWithRadians:(float)radians;

@end
