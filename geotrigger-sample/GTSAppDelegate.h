//
//  GTSAppDelegate.h
//  geotrigger-sample
//
//  Created by Ryan Arana on 11/8/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GTSAppDelegate : UIResponder 

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *managerReadyText;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end
