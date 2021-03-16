//
//  MapAnnotation.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 22/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject<MKAnnotation>
{
    
}
@property (nonatomic, strong) NSString * strTitle;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)title andCoordinate:
(CLLocationCoordinate2D)coordinate2d;


@end
