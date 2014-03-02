    //
//  GTSViewController.m
//  geotrigger-sample
//
//  Created by Ryan Arana on 11/8/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <OpenEars/LanguageModelGenerator.h>

#import "MapViewController.h"
#import "GTSAppDelegate.h"
#import <GeotriggerSDK/GeotriggerSDK.h>

@interface MapViewController ()

@property (assign, nonatomic) BOOL triggerCreated;
@property (strong, nonatomic) NSMutableOrderedSet *locations;
@property Boolean speechTrigger;
@property Boolean confirm;

@end

@implementation MapViewController

@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;
@synthesize fliteController;
@synthesize slt;

- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.speechTrigger = false;
    self.confirm = false;
    self.locations = [NSMutableOrderedSet new];
    
    [self updateTags:@"rain" withStatus:@"addTags"];
    [self updateTags:@"snow" withStatus:@"addTags"];
    // The didReceiveLocationUpdates block is called every time the manager receive a CLLocation from the CLLocationManager.
    // You can use this block to get access to all location updates from the OS without implementing your own
    // CLLocationManagerDelegate. Here we use it to create a trigger around the first location we receive which will
    // fire on leaving the trigger region. On all subsequent location updates we update the UI to show the latest location
    // we've received.
    [AGSGTGeotriggerManager sharedManager].didReceiveLocationUpdates = ^(NSArray *locations) {
        [self.locations insertObjects:locations atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, locations.count)]];
        CLLocation *location = locations[0];
              // Update our UI
        //self.locationUpdateReceivedLabel.text = [NSString stringWithFormat:@"lat: %3.6f, long: %3.6f", location.coordinate.latitude, location.coordinate.longitude];
        //self.managerReadyLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"managerReadyText"];
    };
    
    // The didUploadLocations block is called every time we send locations to the Geotrigger Service. Here we are just
    // using this information to update our UI.
    [AGSGTGeotriggerManager sharedManager].didUploadLocations = ^(NSUInteger count, NSError *error) {
        if (error == nil) {
            CLLocation *location = self.locations[0];
            //self.locationUpdateSentLabel.text = [NSString stringWithFormat:@"lat: %3.6f, long: %3.6f", location.coordinate.latitude, location.coordinate.longitude];
            //[self.locations removeObjectsInRange:NSMakeRange(self.locations.count-count, count)];
        } else {
            NSLog(@"Location upload error: %@", error.userInfo);
        }
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registerForRemoteNotificationsFailure)
                                                 name:@"registerForRemoteNotificationsFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registerForRemoteNotificationsSuccess)
                                                 name:@"registerForRemoteNotificationsSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushNotificationReceived)
                                                 name:@"pushNotificationReceived" object:nil];
    
    
    //Open ears
    
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"WATCHDOG", @"THUNDER", @"WIND", @"HAIL", @"SLEET", @"RAIN", @"FOG", @"STORM", @"YES", @"NO", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    NSDictionary *languageGeneratorResults = nil;
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
	
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    
    [self.openEarsEventsObserver setDelegate:self];
    
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];

    
    
}

- (IBAction)notifyClicked:(id)sender {
    [[AGSGTApiClient sharedClient] postPath:@"device/notify"
                                 parameters:@{ @"text": @"This came from device/notify", @"url": @"http://pdx.esri.com" }
                                    success:^(id res) {
                                        NSLog(@"device/notify success: %@", res);
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"device/notify failed: %@", error.userInfo);
                                    }];
}

- (void)pushNotificationReceived {
    //self.triggerFiredLabel.text = @"Yes";
}

- (void)registerForRemoteNotificationsFailure {
    //self.registeredForPushNotificationsLabel.text = @"Error";
}

- (void)registerForRemoteNotificationsSuccess {
    //self.registeredForPushNotificationsLabel.text = @"Yes";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    //[self.fliteController say:hypothesis withVoice:self.slt];

    if (self.confirm)
    {
        if([hypothesis isEqualToString:@"YES"])
        {
            [self.fliteController say:@"Thank you, submitting your report" withVoice:self.slt];
            self.confirm = false;
            //send message
        }
        else if ([hypothesis isEqualToString:@"NO"])
        {
            [self.fliteController say:@"Okay, next time don't waste my time" withVoice:self.slt];
            self.confirm = false;
        }
        else
        {
            [self.fliteController say:@"I don't understand. Please say yes or no" withVoice:self.slt];
            
        }
        
        self.speechTrigger = false;
    }
    else if (self.speechTrigger && !([hypothesis isEqualToString:@"YES"] | [hypothesis isEqualToString:@"NO"] | [hypothesis isEqualToString:@"WATCHDOG"] || [[hypothesis componentsSeparatedByString:@" "] count] > 1))
    {
        NSString *begin = @"Do you want to submit a reporting for ";
        NSString *message = [begin stringByAppendingString:hypothesis];
        [self.fliteController say:message withVoice:self.slt];
        self.confirm = true;
        self.speechTrigger = false;
        NSString *lowercase = [hypothesis lowercaseString];
        NSString *userPrefix = @"user-";
        [self submitTrigger:[userPrefix stringByAppendingString:lowercase]];
    }
    else if ([hypothesis isEqualToString:@"WATCHDOG"])
    {
        self.speechTrigger = true;
        [self.fliteController say:@"What would you like to report?" withVoice:self.slt];
        NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    }
}

-(void) submitTrigger:(NSString*)tag
{
    AGSGTTriggerBuilder *builder = [AGSGTTriggerBuilder new];
    //builder.triggerId = @"sampleTrigger";
    builder.tags = @[tag];
    //builder.tags = @[[AGSGTGeotriggerManager sharedManager].deviceDefaultTag];
    builder.direction = @"enter";
    
    [builder setGeoWithLocation:self.locations[0] distance:1000];
    NSString *message;
    if ([@"user-rain" isEqualToString:tag])
        message  = @"User Feedback: Severe rain ahead.";
    else if ([@"user-snow" isEqualToString:tag])
        message  = @"User Feedback: Severe snowfall ahead.";
    else if ([@"user-thunder" isEqualToString:tag])
         message  = @"User Feedback: Storm ahead.";
    else if ([@"user-wind" isEqualToString:tag])
        message  = @"User Feedback: Severe winds ahead.";
    else if ([@"user-hail" isEqualToString:tag])
        message  = @"User Feedback: Severe hail ahead.";
    else if ([@"user-sleet" isEqualToString:tag])
        message  = @"User Feedback: Severe sleet ahead.";
    else if ([@"user-fog" isEqualToString:tag])
        message  = @"User Feedback: Severe fog ahead.";
    else if ([@"user-storm" isEqualToString:tag])
        message  = @"User Feedback: Severe thunderstorm ahead.";
    builder.notificationText = message;
    NSDictionary *params = [builder build];
    [[AGSGTApiClient sharedClient] postPath:@"trigger/create"
         parameters:params
            success:^(id res) {
                NSLog(@"Trigger created: %@", res);
                //self.triggerCreatedLabel.text = @"Yes";
            }
            failure:^(NSError *error) {
                NSLog(@"Trigger create error: %@", error.userInfo);
                //self.triggerCreatedLabel.text = @"Error";
                self.triggerCreated = NO;
            }];

}

- (IBAction)fakeIt:(id)sender {
    
    [self updateTags:@"test" withStatus:@"addTags"];
    
    AGSGTTriggerBuilder *builder = [AGSGTTriggerBuilder new];
    //builder.triggerId = @"sampleTrigger";
    builder.tags = @[@"test"];
    //builder.tags = @[[AGSGTGeotriggerManager sharedManager].deviceDefaultTag];
    builder.direction = @"leave";
    [builder setGeoWithLocation:self.locations[0] distance:10];
    NSString *message = @"Test successful";
    builder.notificationText = message;
    NSDictionary *params = [builder build];
    [[AGSGTApiClient sharedClient] postPath:@"trigger/create"
                                 parameters:params
                                    success:^(id res) {
                                        NSLog(@"Trigger created: %@", res);
                                        //self.triggerCreatedLabel.text = @"Yes";
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Trigger create error: %@", error.userInfo);
                                        //self.triggerCreatedLabel.text = @"Error";
                                        self.triggerCreated = NO;
                                    }];

    
    
}
- (IBAction)testPush:(id)sender {
    NSDictionary *params = @{@"triggerIds": @"test"};
    [[AGSGTApiClient sharedClient] postPath:@"trigger/run"
                                 parameters:params
                                    success:^(id res) {
                                        NSLog(@"Trigger run successful: %@", res);
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Trigger run error: %@", error.userInfo);
                                    }];
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	//NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}

- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (IBAction)onOffRain:(UISwitch*)sender {
    if (sender.on)
    {
        [self updateTags:@"rain" withStatus:@"addTags"];
    }
    else
    {
        [self updateTags:@"rain" withStatus:@"removeTags"];
    }
}

- (IBAction)onOffSnow:(UISwitch*)sender {
    if (sender.on)
    {
        [self updateTags:@"snow" withStatus:@"addTags"];
    }
    else
    {
        [self updateTags:@"snow" withStatus:@"removeTags"];
    }
}

- (IBAction)onOffRoad:(UISwitch*)sender {
    if (sender.on)
    {
        [self updateTags:@"roads" withStatus:@"addTags"];
    }
    else
    {
        [self updateTags:@"roads" withStatus:@"removeTags"];
    }
}

- (IBAction)onOffFire:(UISwitch*)sender {
    if (sender.on)
    {
        [self updateTags:@"fire" withStatus:@"addTags"];
    }
    else
    {
        [self updateTags:@"fire" withStatus:@"removeTags"];
    }
}

- (IBAction)onOffFlood:(UISwitch*)sender {
    if (sender.on)
    {
        [self updateTags:@"flood" withStatus:@"addTags"];
    }
    else
    {
        [self updateTags:@"flood" withStatus:@"removeTags"];
    }
}

- (void) updateTags:(NSString*)tags withStatus:(NSString*)status {
    NSDictionary *params = @{status: tags};
    [[AGSGTApiClient sharedClient] postPath:@"device/update"
                                 parameters:params
                                    success:^(id res) {
                                        NSLog(@"Device updated: %@", res);
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Device update error: %@", error.userInfo);
                                    }];
    
    
    
}
- (IBAction)userSubmission:(UISwitch *)sender {
    
    if (sender.on)
    {
        NSDictionary *params = @{@"addTags": @[@"user-snow",@"user-rain",@"user-thunder",@"user-wind", @"user-hail", @"user-sleet", @"user-fog", @"user-storm"]};
        [[AGSGTApiClient sharedClient] postPath:@"device/update"
                                     parameters:params
                                        success:^(id res) {
                                            NSLog(@"Device updated: %@", res);
                                        }
                                        failure:^(NSError *error) {
                                            NSLog(@"Device update error: %@", error.userInfo);
                                        }];

    }
    else
    {
        NSDictionary *params = @{@"removeTags": @[@"user-snow",@"user-rain",@"user-thunder",@"user-wind", @"user-hail", @"user-sleet", @"user-fog", @"user-storm"]};
        [[AGSGTApiClient sharedClient] postPath:@"device/update"
                                     parameters:params
                                        success:^(id res) {
                                            NSLog(@"Device updated: %@", res);
                                        }
                                        failure:^(NSError *error) {
                                            NSLog(@"Device update error: %@", error.userInfo);
                                        }];
        

        
    }
}

- (IBAction)onOffDuty:(UISwitch*)sender {
    if (sender.on)
    {
        [self.pocketsphinxController resumeRecognition];
    }
    else
    {
        [self.pocketsphinxController suspendRecognition];
    }
}






@end