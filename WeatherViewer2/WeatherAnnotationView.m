//
//  WeatherAnnotationView.m
//  WeatherViewer2
//
//  Created by NSSimpleApps on 09.06.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "WeatherAnnotationView.h"
#import "WeatherAnnotation.h"

@implementation WeatherAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        if ([annotation isKindOfClass:[WeatherAnnotation class]]) {
            
            WeatherAnnotation *weatherAnnotation = annotation;
            
            self.image = [UIImage imageNamed:weatherAnnotation.weatherIcon];
        }
    }
    return self;
}


@end
