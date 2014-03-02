#import "GTSViewController.h"
#import "GTSAppDelegate.h"


@interface GTSViewController ()

@end

@implementation GTSViewController

@synthesize northArrow = _northArrow;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.map.touchDelegate = self;
    self.map.layerDelegate = self;
    //AGSWebMap* webmap = [[AGSWebMap alloc] initWithItemId:@"b7c16251217d4e8dbbd147ec50ac5875" credential:nil];
    
    //[webmap openIntoMapView:self.map];
    
    AGSTiledMapServiceLayer *tiledLayer =
    [AGSTiledMapServiceLayer
     tiledMapServiceLayerWithURL:[NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"]];
    [self.map addMapLayer:tiledLayer withName:@"Tiled Layer"];
    NSURL* url = [NSURL URLWithString: @"http://apps.esri.ca/ArcGIS/rest/services/EnvironmentCanada/WeatherRADAR/MapServer"];
    AGSDynamicMapServiceLayer* weather = [[AGSDynamicMapServiceLayer alloc] initWithURL:url];
    [self.map addMapLayer:weather withName:@"Weather"];
    
    self.map.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeCompassNavigation;
    self.map.locationDisplay.navigationPointHeightFactor = 0.5;
    
 	[self.map.locationDisplay startDataSource];
    
    //Position the location symbol in the center of the map
    
    
    //Listen to KVO notifications for map gps's autoPanMode property
    [self.map.locationDisplay addObserver:self
                                   forKeyPath:@"autoPanMode"
                                      options:(NSKeyValueObservingOptionNew)
                                      context:NULL];
    
    //Listen to KVO notifications for map rotationAngle property
    [self.map addObserver:self
                   forKeyPath:@"rotationAngle"
                      options:(NSKeyValueObservingOptionNew)
                      context:NULL];
    
    [ self.map.locationDisplay addObserver:self
                                    forKeyPath:@"location"
                                       options:(NSKeyValueObservingOptionNew)
                                       context:NULL];
    
    //Listen to KVO notifications for map scale property
    [self.map addObserver:self
                   forKeyPath:@"mapScale"
                      options:(NSKeyValueObservingOptionNew)
                      context:NULL];
    
	// Do any additional setup after loading the view.
}





- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"location"]) {
        [self.map.locationDisplay removeObserver:self forKeyPath:@"location"];
    }
    else if([keyPath isEqual:@"rotationAngle"]){
        CGAffineTransform transform = CGAffineTransformMakeRotation(-(self.map.rotationAngle*3.14)/180);
        [self.northArrow setTransform:transform];
    }
    
    //if mapscale changed
    else if([keyPath isEqual:@"mapScale"]){
        if(self.map.mapScale < 5000) {
            [self.map zoomToScale:50000 withCenterPoint:nil animated:YES];
            [self.map removeObserver:self forKeyPath:@"mapScale"];
        }
    }
}

- (void) layerDidLoad: (AGSLayer*) layer{
  	NSLog(@"Layer added successfully");
}

- (void) layer : (AGSLayer*) layer didFailToLoadwithError:(NSError*) error {
    NSLog(@"Error: %@",error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end