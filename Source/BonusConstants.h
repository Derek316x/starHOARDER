//
//  BonusConstants.h
//  dereknetto
//
//  Created by Z on 7/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#ifndef dereknetto_BonusConstants_h
#define dereknetto_BonusConstants_h

#define ARC4RANDOM_MAX      0x100000000

static CGFloat const GAME_SPEED = 2.f;

static CGFloat const speedMultiplier = 1200;
static float const defaultTime = 8; //start time and max time of clock

static CGFloat const starLife = 0.5;
static CGFloat const enemyLife = 3;

static int const MAX_ENEMIES = 5;
static int const MAX_STARS =10;

static float const Y_offset =11; //used in tilt calibration

const float deadZone = .2f; // used to prevent jittering in accelerometer updates

const float kSpinorThresHold = 0.0001f; //used in slerp2D method



#endif
