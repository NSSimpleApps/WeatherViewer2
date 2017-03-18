//
//  WeatherAnnotation.m
//  WeatherViewer2
//
//  Created by NSSimpleApps on 09.06.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "WeatherAnnotation.h"

@implementation WeatherAnnotation

- (instancetype)init {
    
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    
    if (self) {
        
        self.weatherIcon = [dictionary[@"weather"] firstObject][@"icon"];
        self.title = dictionary[@"name"];
        self.subtitle = [NSString stringWithFormat:@"%.1f C", [dictionary[@"main"][@"temp"] floatValue]];
        
        _coordinate.latitude = [dictionary[@"coord"][@"lat"] doubleValue];
        _coordinate.longitude = [dictionary[@"coord"][@"lon"] doubleValue];
    }
    return self;
}

@end
