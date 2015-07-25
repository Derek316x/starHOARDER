//
//  Gameplay.h
//  dereknetto
//
//  Created by Z on 7/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import <CoreMotion/CoreMotion.h>
//#import <UIKit/UIKit.h>
//#import <iAd/iAd.h>

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate>

@property (strong, nonatomic) NSDate *lastUpdateTime;
@property(nonatomic, retain) UIView  *view;

-(void)didLoadFromCCB;

@end
