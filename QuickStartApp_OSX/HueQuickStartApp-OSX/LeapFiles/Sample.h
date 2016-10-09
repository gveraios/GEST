/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"

extern NSString* kScreenTapNotification;
extern NSString* kCircleClockwiseNotification;
extern NSString* kCircleCounterClockwiseNotification;
extern NSString* kSwipeLeftNotification;
extern NSString* kSwipeRightNotification;
extern NSString* kSwipeUpNotification;
extern NSString* kSwipeDownNotification;
extern NSString* kSwipeForwardNotification;
extern NSString* kSwipeBackwardNotification;

@interface Sample : NSObject<LeapListener>

-(void)run;

@end
