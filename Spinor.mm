//
//  Spinor.cpp
//  dereknetto
//
//  Created by Z on 7/22/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Spinor.h"

float Slerp2D(const float fromRadian, const float toRadian, const float t)
{
	mySpinor from(fromRadian);
	mySpinor to(toRadian);
	mySpinor s = mySpinor::slerp(from, to, t);
	return s.angle();
}

