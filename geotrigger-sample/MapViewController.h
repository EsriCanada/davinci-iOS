//
//  GTSViewController.h
//  geotrigger-sample
//
//  Created by Ryan Arana on 11/8/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>
#import <ArcGIS/ArcGIS.h>


@interface MapViewController : UIViewController <OpenEarsEventsObserverDelegate, AGSWebMapDelegate>
{
    PocketsphinxController *pocketsphinxController;
    OpenEarsEventsObserver *openEarsEventsObserver;
    FliteController *fliteController;
    Slt *slt;
}

@property (strong, nonatomic) IBOutlet UIButton *notifyButton;
@property (strong, nonatomic) IBOutlet UISwitch *road;
@property (strong, nonatomic) IBOutlet UISwitch *fire;
@property (strong, nonatomic) IBOutlet UISwitch *flood;
@property (strong, nonatomic) IBOutlet UISwitch *rain;
@property (strong, nonatomic) IBOutlet UISwitch *snow;
@property (strong, nonatomic) IBOutlet UISwitch *voice;
@property (strong, nonatomic) IBOutlet UISwitch *user;

@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@end
