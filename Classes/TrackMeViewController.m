//
//  TrackMeViewController.m
//  TrackMe
//
//  Created by Steve Baker on 2/15/10.
//  Copyright Beepscore LLC 2010. All rights reserved.
//

#import "TrackMeViewController.h"
#import "PointOfInterest.h"

@implementation TrackMeViewController

#pragma mark -
#pragma mark properties
@synthesize myMapView;
@synthesize locationManager;
@synthesize desiredAccuracyDictionary;
@synthesize pinColorDictionary;


// define preferences keys
NSString * const DesiredAccuracyPrefKey = @"DesiredAccuracyPrefKey";
NSString * const DistanceFilterValuePrefKey = @"DistanceFilterValuePrefKey";
NSString * const PinColorPrefKey = @"PinColorPrefKey";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


// load preferences from Settings.  Ref Dudney sec 9.5-9.6
- (void) loadPrefs {
    
    // Create dictionary of strings and integers, based on constants.
    // Ref http://stackoverflow.com/questions/925991/objective-c-nsstring-to-enum
    
    desiredAccuracyKeyArray = [[NSArray alloc] initWithObjects:
                               @"kCLLocationAccuracyBest",
                               @"kCLLocationAccuracyNearestTenMeters", 
                               @"kCLLocationAccuracyHundredMeters", 
                               @"kCLLocationAccuracyKilometer", 
                               @"kCLLocationAccuracyThreeKilometers", 
                               nil];
    desiredAccuracyObjectArray = [[NSArray alloc] initWithObjects:
                                  [NSNumber numberWithDouble:kCLLocationAccuracyBest],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyNearestTenMeters],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyHundredMeters],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyKilometer],
                                  [NSNumber numberWithDouble:kCLLocationAccuracyThreeKilometers],
                                  nil];
    desiredAccuracyDictionary = [[NSDictionary alloc] 
                                 initWithObjects:desiredAccuracyObjectArray forKeys:desiredAccuracyKeyArray];
    
    [desiredAccuracyKeyArray release];
    [desiredAccuracyObjectArray release];

    
    pinColorKeyArray = [[NSArray alloc] initWithObjects:
                        @"MKPinAnnotationColorRed",
                        @"MKPinAnnotationColorGreen", 
                        @"MKPinAnnotationColorPurple", 
                        nil];
    pinColorObjectArray = [[NSArray alloc] initWithObjects:
                           [NSNumber numberWithInt:MKPinAnnotationColorRed],
                           [NSNumber numberWithInt:MKPinAnnotationColorGreen],
                           [NSNumber numberWithInt:MKPinAnnotationColorPurple],
                           nil];
    pinColorDictionary = [[NSDictionary alloc] initWithObjects:pinColorObjectArray forKeys:pinColorKeyArray];
    
    [pinColorKeyArray release];
    [pinColorObjectArray release];


    // set app defaults
    desiredAccuracyMeters = kCLLocationAccuracyNearestTenMeters;    
    distanceFilterValueMeters = 10.0;    
    myPinColor = MKPinAnnotationColorPurple;

    // read user prefs
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationAccuracy userDesiredAccuracy = 
    [[desiredAccuracyDictionary objectForKey:[defaults stringForKey:DesiredAccuracyPrefKey]] doubleValue];     
    if (0 != userDesiredAccuracy) {
        desiredAccuracyMeters = userDesiredAccuracy;
    }
    
    CLLocationDistance userDistanceFilterValue = [defaults floatForKey:DistanceFilterValuePrefKey];
    if (0 != userDistanceFilterValue) {
        distanceFilterValueMeters = userDistanceFilterValue;
    }
    
    myPinColor = [[pinColorDictionary objectForKey:[defaults stringForKey:PinColorPrefKey]] intValue];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPrefs];
    
    // TODO: If not moving, stop updating location to save power
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = desiredAccuracyMeters;
    
    // notify us only if distance changes by more than distanceFilter
    self.locationManager.distanceFilter = distanceFilterValueMeters;
    
    NSLog(@"desiredAccuracy = %5.1f meters, distanceFilter = %5.1f meters",
          self.locationManager.desiredAccuracy, self.locationManager.distanceFilter);
    
    [self.locationManager startUpdatingLocation];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait == interfaceOrientation)
            || (UIInterfaceOrientationLandscapeLeft == interfaceOrientation)
            || (UIInterfaceOrientationLandscapeRight == interfaceOrientation));
}


#pragma mark Memory management
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // Stop updating location to reduce power consumption and save battery 
    [self.locationManager stopUpdatingLocation];
}


// Ref http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmNibObjects.html
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
    // Release any retained outlets
    // set properties to nil, which also releases them
    self.myMapView = nil;
    self.locationManager = nil;
    [desiredAccuracyDictionary release], desiredAccuracyDictionary = nil;    
    [pinColorDictionary release], pinColorDictionary = nil;
    
    [super viewDidUnload];
}


- (void)dealloc {
    [myMapView release], myMapView = nil;
    [locationManager release], locationManager = nil;
    [desiredAccuracyDictionary release], desiredAccuracyDictionary = nil;    
    [pinColorDictionary release], pinColorDictionary = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark MKMapViewDelegate methods
// Ref Dudney sec 25.3
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKPinAnnotationView *annotationView = nil;
    
    if(annotation != mapView.userLocation)
    {
        // Attempt to get an unused annotationView.  Returns nil if one isn't available.
        // Ref http://developer.apple.com/iphone/library/documentation/MapKit/Reference/MKMapView_Class/MKMapView/MKMapView.html#//apple_ref/occ/instm/MKMapView/dequeueReusableAnnotationViewWithIdentifier:
        annotationView = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:@"myIdentifier"];
        
        // if dequeue didn't return an annotationView, allocate a new one
        if (nil == annotationView) {
            // NSLog(@"dequeue didn't return an annotationView, allocing a new one");
            annotationView = [[[MKPinAnnotationView alloc] 
                               initWithAnnotation:annotation
                               reuseIdentifier:@"myIdentifier"]
                              autorelease];
        } else {
            NSLog(@"dequeueReusableAnnotationViewWithIdentifier returned an annotationView");
        }    
        [annotationView setPinColor:myPinColor];
        [annotationView setCanShowCallout:YES];
        [annotationView setAnimatesDrop:YES];
    } else {
        [mapView.userLocation setTitle:@"I am here"];
    }
    return annotationView;
}


- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"lat: %f, long: %f, latDelta: %f, longDelta: %f",
          aMapView.region.center.latitude, aMapView.region.center.longitude, 
          aMapView.region.span.latitudeDelta, aMapView.region.span.longitudeDelta);
}


#pragma mark Location methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    // Ref Dudney Ch25 pg 470, 466, 451.  Can recenter map as on pg 451, but don't need to?  
    // In IB, checking mapView showsUserLocation will initially center map for us.
    
    // Set region based on old and new location
    CLLocationCoordinate2D theCenter = newLocation.coordinate;    
    CLLocationDegrees theLatitudeDelta;
    CLLocationDegrees theLongitudeDelta;    
    MKCoordinateSpan theSpan;
    
    // isSameLocation returns YES if newLocation coordinates equal the oldLocation coordinates.
    // This may happen on the second update
    BOOL isSameLocation = ((newLocation.coordinate.latitude == oldLocation.coordinate.latitude)
                           && (newLocation.coordinate.longitude == oldLocation.coordinate.longitude));
    
    // if this is the first update, oldLocation is nil
    if ((nil == oldLocation) || isSameLocation) {
        theLatitudeDelta = 0.02;
        theLongitudeDelta = 0.02;
    } else {
        theLatitudeDelta = fmin(45.0, 4.0 * fabs(newLocation.coordinate.latitude - oldLocation.coordinate.latitude));
        theLongitudeDelta = fmin(45.0, 4.0 * fabs(newLocation.coordinate.longitude - oldLocation.coordinate.longitude));
    }
    theSpan = MKCoordinateSpanMake(theLatitudeDelta, theLongitudeDelta);
    
    NSLog(@"lat: %f, long: %f, latDelta: %f, longDelta: %f",
          theCenter.latitude, theCenter.longitude, theSpan.latitudeDelta, theSpan.longitudeDelta);
    MKCoordinateRegion theRegion = MKCoordinateRegionMake(theCenter, theSpan);    
    [self.myMapView setRegion:theRegion animated:YES];
    
    PointOfInterest *newPointOfInterest = [[PointOfInterest alloc] init];
    
    // annotation title
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];                
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];                
    newPointOfInterest.title = [dateFormatter stringFromDate:newLocation.timestamp];
    [dateFormatter release];
    
    newPointOfInterest.coordinate = newLocation.coordinate;
    
    [self.myMapView addAnnotation:newPointOfInterest];
    [newPointOfInterest release], newPointOfInterest = nil;
}

@end

