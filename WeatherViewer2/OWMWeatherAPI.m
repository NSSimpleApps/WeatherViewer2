//
//  OWMWeatherAPI.m
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import "OWMWeatherAPI.h"
#import "AFURLResponseSerialization.h"
#import "AFHTTPSessionManager.h"

@interface OWMWeatherAPI ()

@property (nonatomic, strong) AFHTTPSessionManager *client;

@property (copy, nonatomic) NSString *baseURL;

@end

@implementation OWMWeatherAPI

- (instancetype)init {
    
    return [self initWithAPIKey:@""];
}

- (instancetype)initWithAPIKey:(NSString *)apiKey {
    
    self = [super init];
    
    if (self) {
        
        self.baseURL = @"http://api.openweathermap.org/data/";
        self.apiKey  = apiKey;
        self.apiVersion = @"2.5";
        self.currentTemperatureFormat = OWMTemperatureCelcius;
        
        self.client = [[AFHTTPSessionManager alloc] init];
        self.client.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        self.client.responseSerializer.acceptableContentTypes  = [NSSet setWithObjects:@"application/json",
                                                                  @"text/json", nil];
        
        self.apiKey = @"63f90ae5889c24671a5dc80efa827738";
    }
    return self;
}

#pragma mark - private parts

+ (NSNumber*)tempToCelcius:(NSNumber*)tempKelvin {
    
    return @(tempKelvin.floatValue - 273.15);
}

+ (NSNumber*)tempToFahrenheit:(NSNumber*)tempKelvin {
    
    return @((tempKelvin.floatValue * 9/5) - 459.67);
}

- (NSNumber*)convertTemp:(NSNumber*)temp {
    
    if (self.currentTemperatureFormat == OWMTemperatureCelcius) {
        
        return [OWMWeatherAPI tempToCelcius:temp];
    } else if (self.currentTemperatureFormat == OWMTemperatureFahrenheit) {
        
        return [OWMWeatherAPI tempToFahrenheit:temp];
    } else {
        return temp;
    }
}

- (NSDate*)convertToDate:(NSNumber*)num {
    
    return [NSDate dateWithTimeIntervalSince1970:num.integerValue];
}

// Recursivly change temperatures in result data
- (NSDictionary*)convertResult:(NSDictionary*)res {
    
    NSMutableDictionary *dic = [res mutableCopy];
    
    NSMutableDictionary *main = [dic[@"main"] mutableCopy];
    
    if (main) {
        
        main[@"temp"] = [self convertTemp:main[@"temp"]];
        main[@"temp_min"] = [self convertTemp:main[@"temp_min"]];
        main[@"temp_max"] = [self convertTemp:main[@"temp_max"]];
        
        dic[@"main"] = [main copy];
    }
    
    NSMutableDictionary *temp = [dic[@"temp"] mutableCopy];
    
    if (temp) {
        
        temp[@"day"] = [self convertTemp:temp[@"day"]];
        temp[@"eve"] = [self convertTemp:temp[@"eve"]];
        temp[@"max"] = [self convertTemp:temp[@"max"]];
        temp[@"min"] = [self convertTemp:temp[@"min"]];
        temp[@"morn"] = [self convertTemp:temp[@"morn"]];
        temp[@"night"] = [self convertTemp:temp[@"night"]];        
        
        dic[@"temp"] = [temp copy];
    }
    NSMutableDictionary *sys = [dic[@"sys"] mutableCopy];
    
    if (sys) {
        
        sys[@"sunrise"] = [self convertToDate: sys[@"sunrise"]];
        sys[@"sunset"] = [self convertToDate: sys[@"sunset"]];
        
        dic[@"sys"] = [sys copy];
    }
    NSMutableArray *list = [dic[@"list"] mutableCopy];
    
    if (list) {
        
        for (NSUInteger i = 0; i < list.count; i++) {
            
            list[i] = [self convertResult:list[i]];
        }
        dic[@"list"] = [list copy];
    }
    dic[@"dt"] = [self convertToDate:dic[@"dt"]];

    return [dic copy];
}

// Calls the web api, and converts the result. Then it calls the callback on the caller-queue

- (void)callMethod:(NSString*)method completion:(void(^)(NSError *error, NSDictionary *result))completion {
    
    NSString *langString;
    
    if (self.lang && self.lang.length > 0) {
        
        langString = [NSString stringWithFormat:@"&lang=%@", self.lang];
    } else {
        
        langString = @"";
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&APPID=%@%@",
                           self.baseURL, self.apiVersion, method, self.apiKey, langString];
    
    
    [self.client GET:urlString
          parameters:@{ @"cachePolicy" : @"NSURLRequestUseProtocolCachePolicy" }
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 NSDictionary *res = [self convertResult:responseObject];
                 if (completion) {
                     
                     completion(nil, res);
                 }
                 
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 
                 if (completion) {
                     
                     completion(error, nil);
                 }
             }];
}

#pragma mark - public api

- (void)setLangWithPreferedLanguage {
    
    NSString *lang = [NSLocale preferredLanguages].firstObject;
    
    // look up, lang and convert it to the format that openweathermap.org accepts.
    NSDictionary *langCodes = @{
                                @"sv" : @"se",
                                @"es" : @"sp",
                                @"en-GB": @"en",
                                @"uk" : @"ua",
                                @"pt-PT" : @"pt",
                                @"zh-Hans" : @"zh_cn",
                                @"zh-Hant" : @"zh_tw",                                
                                };
    
    NSString *l = langCodes[lang];
    
    if (l) {
        lang = l;
    }
    self.lang = lang;
}

#pragma mark current weather

- (void)currentWeatherByCityName:(NSString *)name completion:(void(^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/weather?q=%@", name];
    
    [self callMethod:method completion:completion];
}

- (void)currentWeatherByCoordinate:(CLLocationCoordinate2D)coordinate completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/weather?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method completion:completion];
}

- (void)currentWeatherByCityId:(NSString *)cityId completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/weather?id=%@", cityId];
    [self callMethod:method completion:completion];
}

- (void)currentWeatherAroundCenter:(CLLocationCoordinate2D)center
                             count:(NSInteger)count
                    completion:(void(^)(NSError *error, NSDictionary *result))completion {
    
    NSString *method = [NSString stringWithFormat:@"/find?lat=%.1f,&lon=%.1f&cnt=%ld", center.latitude, center.longitude, (long)count];
    
    [self callMethod:method completion:completion];
}

#pragma mark forecast

- (void)forecastWeatherByCityName:(NSString *)name completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/forecast?q=%@", name];
    [self callMethod:method completion:completion];
}

- (void)forecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/forecast?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method completion:completion];
}

- (void)forecastWeatherByCityId:(NSString *)cityId completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/forecast?id=%@", cityId];
    [self callMethod:method completion:completion];
}

#pragma mark forecast - n days

- (void)dailyForecastWeatherByCityName:(NSString *)name withCount:(NSInteger)count completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?q=%@&cnt=%ld", name, (long)count];
    [self callMethod:method completion:completion];
}

- (void)dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate withCount:(NSInteger)count completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?lat=%f&lon=%f&cnt=%ld",
                        coordinate.latitude, coordinate.longitude, (long)count];
    [self callMethod:method completion:completion];
}

- (void)dailyForecastWeatherByCityId:(NSString *)cityId withCount:(NSInteger)count completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?id=%@&cnt=%ld", cityId, (long)count];
    [self callMethod:method completion:completion];
}

#pragma mark searching

- (void)searchForCityName:(NSString *)name completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/find?q=%@&units=metric", name];
    
    [self callMethod:method completion:completion];
}

- (void)searchForCityName:(NSString *)name withCount:(NSInteger)count completion:(void (^)(NSError *, NSDictionary *))completion {
    
    NSString *method = [NSString stringWithFormat:@"/find?q=%@&units=metric&cnt=%ld", name, (long)count];
    
    [self callMethod:method completion:completion];
}

@end
