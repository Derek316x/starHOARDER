//
//  Spinor.h
//  dereknetto
//
//  Created by Z on 7/22/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#ifndef SPINOR_H
#define SPINOR_H
#import <Foundation/Foundation.h>

#define kSpinorThresHold 0.0001f
struct mySpinor
{
	float real;
	float complex;
	
	mySpinor(); {}
	mySpinor(float _real, float _complex):real(_real),complex(_complex) {}
	mySpinor(float radians):real(cos(radians/2.0f)),complex(sin(radians/2.0f)) {}
	
	//basic ops
	mySpinor &operator = (const mySpinor &s)
	{
		real = s.real; complex = s.complex;
		return *this;
	}
	
	const mySpinor operator *(const mySpinor &s) const
	{
		return mySpinor(real * s.real - complex * s.complex, real * s.complex + complex * s.real);
	}
	
	float angle()
	{
		return atan2(complex,real)*2;
	}
	
	static mySpinor slerp(const mySpinor &from, const mySpinor &to, const float t)
	{
		float tr,tc;
		float omega, cosom, sinom, scale0, scale1;
		
		//calc cosine
		cosom = from.real * to.real + from.complex * to.complex;
		
		//adjust signs
		if (cosom < 0)
		{
			cosom = -cosom;
			tc = -to.complex;
			tr = -to.real;
		}
		else
		{
			tc = to.complex;
			tr = to.real;
		}
		
		//coefficients
		if ((1 - cosom) > kSpinorThresHold)
		{
			omega = acos(cosom);
			sinom = sinf(omega);
			scale0 = sinf((1-t)*omega) / sinom;
			scale1 = sinf(t*omega) / sinom;
		}
		else
		{
			scale0 = 1 - t;
			scale1 = t;
		}
		
		return mySpinor(scale0 * from.real + scale1 * tr, scale0 * from.complex + scale1 * tc);
	}
};

// spherically interpolates radians
// t must be between 0 and 1 (inclusive)
float Slerp2D(const float fromRadian, const float toRadian, const float t);

#endif /* defined(__dereknetto__Spinor__) */
