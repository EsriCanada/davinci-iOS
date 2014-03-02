//
//  GTSViewController.h
//  geotrigger-sample
//
//  Created by Ryan Arana on 11/8/13.
//  Copyright (c) 2013 ESRI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface GTSViewController : UIViewController <AGSMapViewTouchDelegate, AGSMapViewLayerDelegate>
    
     @property (strong, nonatomic) IBOutlet AGSMapView *map;
    @property (strong, nonatomic) IBOutlet UIView *northArrow;

@end

