//
//  OWMWeatherAPI.h
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKGeometry.h>

typedef NS_OPTIONS(NSInteger, OWMTemperature) {
    
    OWMTemperatureKelvin,
    OWMTemperatureCelcius,
    OWMTemperatureFahrenheit
};

@interface OWMWeatherAPI : NSObject

@property (copy, nonatomic) NSString *apiKey;
@property (copy, nonatomic) NSString *apiVersion;
@property (copy, nonatomic) NSString *lang;

@property (assign, nonatomic) OWMTemperature currentTemperatureFormat;

- (instancetype)initWithAPIKey:(NSString*)apiKey NS_DESIGNATED_INITIALIZER;

- (void)setLangWithPreferedLanguage;

#pragma mark - current weather

- (void)currentWeatherByCityName:(NSString*)name
                      completion:(void(^)(NSError *error, NSDictionary *result))completion;


- (void)currentWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                        completion:(void(^)(NSError *error, NSDictionary *result))completion;

- (void)currentWeatherByCityId:(NSString*)cityId
                    completion:(void(^)(NSError *error, NSDictionary *result))completion;

- (void)currentWeatherAroundCenter:(CLLocationCoordinate2D)center
                             count:(NSInteger)count
                        completion:(void(^)(NSError *error, NSDictionary *result))completion;

#pragma mark - forecast

- (void)forecastWeatherByCityName:(NSString*)name
                       completion:(void(^)(NSError *error, NSDictionary *result))completion;

- (void)forecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                         completion:(void(^)(NSError *error, NSDictionary *result))completion;

- (void)forecastWeatherByCityId:(NSString*)cityId
                     completion:(void(^)(NSError *error, NSDictionary *result))completion;

#pragma mark forcast - n days

- (void)dailyForecastWeatherByCityName:(NSString*)name
                             withCount:(NSInteger)count
                            completion:(void(^)(NSError *error, NSDictionary *result))completion;

- (void)dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                               withCount:(NSInteger)count
                              completion:(void(^)(NSError *error, NSDictionary *result))completion;

- (void)dailyForecastWeatherByCityId:(NSString*)cityId
                           withCount:(NSInteger)count
                          completion:(void(^)(NSError *error, NSDictionary *result))completion;

#pragma mark search

- (void)searchForCityName:(NSString*)name
               completion:(void(^)(NSError *error, NSDictionary *result))completion;

- (void)searchForCityName:(NSString*)name
                withCount:(NSInteger)count
               completion:(void(^)(NSError *error, NSDictionary *result))completion;

@end
