//
//  ViewController.m
//  LocationTest
//
//  Created by Mac on 22.08.15.
//  Copyright (c) 2015 CEIT. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>

@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) GMSMarker* marker;
@property (strong, nonatomic) GMSCameraPosition* camera;
@property (weak, nonatomic) IBOutlet GMSMapView* mapView;


@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end


@implementation ViewController

@synthesize locationManager = _locationManager;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.camera = nil;
    [self configureLocationManager];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)configureLocationManager
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)getAddressFromLocation:(CLLocation*)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.addressLabel.text = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        }
    }];
}

- (CLLocationManager*)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView* errorAlertView = [[UIAlertView alloc]initWithTitle:@"Location error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [errorAlertView show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self getAddressFromLocation:newLocation];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];\
    
    CLLocationDistance distanceThreshold = 20.0; // in meters
    if (([self.currentLocation distanceFromLocation:newLocation] > distanceThreshold)||
        (!self.currentLocation))
    {
        self.currentLocation = newLocation;
        [self configureMap];
    }
}

- (void)configureMap
{
//    [self.mapView setAlpha:0.5];
    if (self.locationManager.location) {
        [self.mapView setDelegate:self];
        [self.mapView setMinZoom:1 maxZoom:21];
        [self.mapView setMapType:kGMSTypeTerrain];
        [self configureMarker];
        [self configureCamera];
    }
}

- (void)configureCamera
{
    if (self.camera == nil) {
        self.camera =
        [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
                                    longitude:self.currentLocation.coordinate.longitude
                                         zoom:16];
        [self.mapView setCamera:self.camera];
    }
}

- (void)configureMarker
{
    if (!self.marker) {
        self.marker = [[GMSMarker alloc] init];
    }
    self.marker.position = self.currentLocation.coordinate;
    self.marker.title = @"You are here";
    self.marker.snippet = @"some text";
    self.marker.appearAnimation = kGMSMarkerAnimationPop;
    self.marker.map = self.mapView;
    CGSize imageSize = CGSizeMake(20, 20);
    UIImage* markerImage = [UIImage imageWithImage:[UIImage imageNamed:@"marker"] scaledToSize:imageSize];
    self.marker.icon = markerImage;
//    [GMSMarker markerImageWithColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
