//
//  ViewController.m
//  WeatherViewer2
//
//  Created by NSSimpleApps on 09.06.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "ViewController.h"
#import "OWMWeatherAPI.h"
#import "WeatherAnnotationView.h"
#import "WeatherAnnotation.h"
@import MapKit;


@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) BOOL mapViewDidFinishLoading;

@property (strong, nonatomic) OWMWeatherAPI *weatherAPI;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"key"];
    self.weatherAPI.currentTemperatureFormat = OWMTemperatureCelcius;
    
    self.mapViewDidFinishLoading = NO;
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            [self.locationManager requestWhenInUseAuthorization];
        }
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    self.mapViewDidFinishLoading = YES;
    
    CLLocation *location = locations.lastObject;
    
    (self.mapView).region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(10, 10));
    
    [manager stopUpdatingLocation];
    manager.delegate = nil;
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    self.mapViewDidFinishLoading = YES;
    
    NSLog(@"%@", error);
    
    [manager stopUpdatingLocation];
    manager.delegate = nil;
    self.locationManager = nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (!self.mapViewDidFinishLoading) return;
    
    [mapView removeAnnotations:mapView.annotations];
    
    NSArray *grid = [self gridForRegion:mapView.region];
    
    for (NSValue *coordinate in grid) {
        
        [self.weatherAPI currentWeatherByCoordinate:coordinate.MKCoordinateValue
                                         completion:^(NSError *error, NSDictionary *result) {
                                             
                                             WeatherAnnotation *annotation = [[WeatherAnnotation alloc] initWithDictionary:result];
                                             [mapView addAnnotation:annotation];
                                         }];
    }
}

- (NSArray*)gridForRegion:(MKCoordinateRegion)region {
    
    NSMutableArray *array = [NSMutableArray new];
    
    CLLocationCoordinate2D center = region.center;
    
    CLLocationDegrees latitudeDelta = region.span.latitudeDelta;
    CLLocationDegrees longitudeDelta = region.span.longitudeDelta;
    
    CLLocationCoordinate2D bottomLeftCorner;
    bottomLeftCorner.latitude = center.latitude - latitudeDelta / 2;
    bottomLeftCorner.longitude = center.longitude - longitudeDelta / 2;
    
    for (NSInteger lat = 1; lat <= 4; lat++) {
        
        for (NSInteger lon = 1; lon <= 3; lon++) {
            
            [array addObject:[NSValue valueWithMKCoordinate:
                              CLLocationCoordinate2DMake(bottomLeftCorner.latitude + lat*latitudeDelta/5, bottomLeftCorner.longitude + lon*longitudeDelta/4)]];
        }
    }
    return array;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[WeatherAnnotation class]]) {
        
        WeatherAnnotationView *weatherAnnotationView = [[WeatherAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"WeatherAnnotation"];
        weatherAnnotationView.canShowCallout = YES;
        
        return weatherAnnotationView;
    }
    return nil;
}

@end
