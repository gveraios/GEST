# GEST

Inspiration 
Picture this scenario - After a long day at work, you switch into your pajamas, and climb into a warm bed ready to fall asleep. But oh wait - you forgot to turn off the lights, and your stereo system downstairs is still blasting. With GEST, you can easily do these mundane household tasks with a swipe of a hand using our hand gesture sensor home automation system. 


What it does
GEST is a motion controlled hardware attachment that can be taught to control common household devices including the light bulbs, sound system, and more. With a swipe of a hand, our recognition sensor is able to identify the movement and translate it to wanted actions. 

Features of GEST includes the following:
- User can stop/play, rewind, or change the volume of any iTunes music or movie file using hand gestures within local WIFI distance.
- User can control the lighting system in their home using hand gestures including switching on/off the lights, changing the intensity/dimness, and changing the colours of light source. 

How We built it 
Objective C and xCode to make the iOS application
Phillips Hue API for dynamic lighting system
Leap Motion API for hand gesture recognition 
iTunes API with Leap Motion

Challenge We ran into
Bridging the Phillips Hue hardware on a local wifi 
Integrating the Leap-Motion gestures with the lighting system and iTunes 
Tracking the hand gestures with Leap Motion with a high degree of accuracy
Unstable wifi  

Built with 
Objective C, C++, Xcode, OS X, Cocoa UI, Leap Motion, Philiips Hue
