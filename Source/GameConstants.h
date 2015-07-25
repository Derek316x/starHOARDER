//
//  GameConstants.h
//  dereknetto
//
//  Created by Z on 7/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#ifndef dereknetto_GameConstants_h
#define dereknetto_GameConstants_h

#define ARC4RANDOM_MAX      0x100000000

static CGFloat const GAME_SPEED = 2.f;

CGFloat speedMultiplier = 1500;

static float const defaultTime = 8; //start time and max time of clock

static CGFloat const starLife = 1;
static CGFloat const enemyLife = 5;

CGFloat enemySpeed = 100;

int MAX_ENEMIES = 1;

static int const MAX_STARS =1;

static float const Y_offset =11; //used in tilt calibration 11 is best

const float deadZone = .2f; // used to prevent jittering in accelerometer updates

const float kSpinorThresHold = 0.0001f; //used in slerp2D method

#endif