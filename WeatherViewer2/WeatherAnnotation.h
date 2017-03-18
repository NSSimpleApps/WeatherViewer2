//
//  WeatherAnnotation.h
//  WeatherViewer2
//
//  Created by NSSimpleApps on 09.06.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface WeatherAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithDictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (copy, nonatomic) NSString *weatherIcon;

@end
