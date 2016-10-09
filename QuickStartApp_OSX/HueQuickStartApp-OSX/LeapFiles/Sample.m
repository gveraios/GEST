/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/

#import "Sample.h"

NSString* kScreenTapNotification = @"kScreenTapNotification";
NSString* kCircleClockwiseNotification = @"kCircleClockwiseNotification";
NSString* kCircleCounterClockwiseNotification = @"kCircleCounterClockwiseNotification";
NSString* kSwipeLeftNotification = @"kSwipeLeftNotification";
NSString* kSwipeRightNotification = @"kSwipeRightNotification";
NSString* kSwipeUpNotification = @"kSwipeUpNotification";
NSString* kSwipeDownNotification = @"kSwipeDownNotification";
NSString* kSwipeForwardNotification = @"kSwipeForwardNotification";
NSString* kSwipeBackwardNotification = @"kSwipeBackwardNotification";

@implementation Sample
{
    LeapController *controller;
}

- (void)run
{
    controller = [[LeapController alloc] init];
    [controller setPolicyFlags:LEAP_POLICY_BACKGROUND_FRAMES];
    
    [controller addListener:self];
    NSLog(@"running");
}

#pragma mark - SampleListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification
{
    NSLog(@"Connected");
    LeapController *aController = (LeapController *)[notification object];
    [aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

- (void)onDisconnect:(NSNotification *)notification
{
    //Note: not dispatched when running in a debugger.
    NSLog(@"Disconnected");
}

- (void)onExit:(NSNotification *)notification
{
    NSLog(@"Exited");
}

- (void)onFrame:(NSNotification *)notification
{
    LeapController *aController = (LeapController *)[notification object];

    // Get the most recent frame and report some basic information
    LeapFrame *frame = [aController frame:0];

    /*
    NSLog(@"Frame id: %lld, timestamp: %lld, hands: %ld, fingers: %ld, tools: %ld, gestures: %ld",
          [frame id], [frame timestamp], [[frame hands] count],
          [[frame fingers] count], [[frame tools] count], [[frame gestures:nil] count]);
    */
    
    /*
    if ([[frame hands] count] != 0) {
        // Get the first hand
        LeapHand *hand = [[frame hands] objectAtIndex:0];

        // Check if the hand has any fingers
        NSArray *fingers = [hand fingers];
        if ([fingers count] != 0) {
            // Calculate the hand's average finger tip position
            LeapVector *avgPos = [[LeapVector alloc] init];
            for (int i = 0; i < [fingers count]; i++) {
                LeapFinger *finger = [fingers objectAtIndex:i];
                avgPos = [avgPos plus:[finger tipPosition]];
            }
            avgPos = [avgPos divide:[fingers count]];
            NSLog(@"Hand has %ld fingers, average finger tip position %@",
                  [fingers count], avgPos);
        }

        // Get the hand's sphere radius and palm position
        NSLog(@"Hand sphere radius: %f mm, palm position: %@",
              [hand sphereRadius], [hand palmPosition]);

        // Get the hand's normal vector and direction
        const LeapVector *normal = [hand palmNormal];
        const LeapVector *direction = [hand direction];

        // Calculate the hand's pitch, roll, and yaw angles
        NSLog(@"Hand pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
              [direction pitch] * LEAP_RAD_TO_DEG,
              [normal roll] * LEAP_RAD_TO_DEG,
              [direction yaw] * LEAP_RAD_TO_DEG);
    }
    */

    NSArray *gestures = [frame gestures:nil];
    for (int g = 0; g < [gestures count]; g++) {
        LeapGesture *gesture = [gestures objectAtIndex:g];
        switch (gesture.type) {
            case LEAP_GESTURE_TYPE_CIRCLE: {
                LeapCircleGesture *circleGesture = (LeapCircleGesture *)gesture;

                NSString *clockwiseness;
                if ([[[circleGesture pointable] direction] angleTo:[circleGesture normal]] <= LEAP_PI/4) {
                    clockwiseness = @"clockwise";
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCircleClockwiseNotification object:nil];
                } else {
                    clockwiseness = @"counterclockwise";
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCircleCounterClockwiseNotification object:nil];
                }

                // Calculate the angle swept since the last frame
                float sweptAngle = 0;
                if(circleGesture.state != LEAP_GESTURE_STATE_START) {
                    LeapCircleGesture *previousUpdate = (LeapCircleGesture *)[[aController frame:1] gesture:gesture.id];
                    sweptAngle = (circleGesture.progress - previousUpdate.progress) * 2 * LEAP_PI;
                }

                NSLog(@"Circle id: %d, %@, progress: %f, radius %f, angle: %f degrees %@",
                      circleGesture.id, [Sample stringForState:gesture.state],
                      circleGesture.progress, circleGesture.radius,
                      sweptAngle * LEAP_RAD_TO_DEG, clockwiseness);
                break;
            }
            case LEAP_GESTURE_TYPE_SWIPE: {
                LeapSwipeGesture *swipeGesture = (LeapSwipeGesture *)gesture;
                NSLog(@"Swipe id: %d, %@, position: %@, direction: %@, speed: %f",
                      swipeGesture.id, [Sample stringForState:swipeGesture.state],
                      swipeGesture.position, swipeGesture.direction, swipeGesture.speed);
                
                // only send the notification if the state is "started"
                // TODO: use the speed to differentiate between types of swipes (drag/ongoing, fast/one-time)
                if (swipeGesture.state == LEAP_GESTURE_STATE_START) {
                    LeapVector *direction = swipeGesture.direction;
                    float x = direction.x;
                    float y = direction.y;
                    float z = direction.z;
                    
                    NSString *name = nil;
                    
                    if (fabs(x) > fabs(y) && fabs(x) > fabs(z)) {
                        // horizontal (lateral)
                        if (x > 0) {
                            name = kSwipeRightNotification;
                        }
                        else {
                            name = kSwipeLeftNotification;
                        }
                    }
                    else if (fabs(y) > fabs(x) && fabs(y) > fabs(z)) {
                        // vertical
                        if (y > 0) {
                            name = kSwipeUpNotification;
                        }
                        else {
                            name = kSwipeDownNotification;
                        }
                    }
                    else if (fabs(z) > fabs(x) && fabs(z) > fabs(y)) {
                        // horizontal (longitudinal)
                        if (z > 0) {
                            name = kSwipeBackwardNotification;
                        }
                        else {
                            name = kSwipeForwardNotification;
                        }
                    }
                    
                    if (name) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
                    }
                }
                
                break;
            }
            case LEAP_GESTURE_TYPE_KEY_TAP: {
                LeapKeyTapGesture *keyTapGesture = (LeapKeyTapGesture *)gesture;
                NSLog(@"Key Tap id: %d, %@, position: %@, direction: %@",
                      keyTapGesture.id, [Sample stringForState:keyTapGesture.state],
                      keyTapGesture.position, keyTapGesture.direction);
                break;
            }
            case LEAP_GESTURE_TYPE_SCREEN_TAP: {
                LeapScreenTapGesture *screenTapGesture = (LeapScreenTapGesture *)gesture;
                NSLog(@"Screen Tap id: %d, %@, position: %@, direction: %@",
                      screenTapGesture.id, [Sample stringForState:screenTapGesture.state],
                      screenTapGesture.position, screenTapGesture.direction);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kScreenTapNotification object:nil];
                break;
            }
            default:
                NSLog(@"Unknown gesture type");
                break;
        }
    }

    /*
    if (([[frame hands] count] > 0) || [[frame gestures:nil] count] > 0) {
        NSLog(@" ");
    }
    */
}

- (void)onFocusGained:(NSNotification *)notification
{
    NSLog(@"Focus Gained");
}

- (void)onFocusLost:(NSNotification *)notification
{
    NSLog(@"Focus Lost");
}

+ (NSString *)stringForState:(LeapGestureState)state
{
    switch (state) {
        case LEAP_GESTURE_STATE_INVALID:
            return @"STATE_INVALID";
        case LEAP_GESTURE_STATE_START:
            return @"STATE_START";
        case LEAP_GESTURE_STATE_UPDATE:
            return @"STATE_UPDATED";
        case LEAP_GESTURE_STATE_STOP:
            return @"STATE_STOP";
        default:
            return @"STATE_INVALID";
    }
}

@end
