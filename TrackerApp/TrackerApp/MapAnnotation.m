//
//  MapAnnotation.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 22/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation
-(id) initWithTitle:(NSString *)title andCoordinate:(CLLocationCoordinate2D)coordinate2d
{
    self.strTitle = title;
    self.coordinate = coordinate2d;
    return self;
}

@end
