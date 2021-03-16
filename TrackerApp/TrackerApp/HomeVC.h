//
//  HomeVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 12/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapAnnotation.h"
#import "FCAlertView.h"
#import "CustomDeviceVC.h"


@interface HomeVC : UIViewController<UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,FCAlertViewDelegate>
{
    float trackerLatitude;
    float trackerLongitude;
    MKMapView*mapView;
    CLLocationCoordinate2D location;
    MapAnnotation *newAnnotation;
    NSMutableArray*coordinateArray;
    MKPlacemark *destination;
    MKPlacemark *source;
    MKPointAnnotation *annotation1,*annotation2;
    UIView*viewMore,*ViewPicker,*backShadowView;
    UITableView*tblViewMore,*tblMoreDevices;
    NSMutableArray*arrayViewMore;
    UIPickerView *devicePicker;
    UILabel*lblDevice;
    long selectedIndex,autoSelectedIndex;
    NSMutableDictionary * dictCurrentDeviceData;
    UIView *viewDeviceExpandable,*deviceView;
    BOOL isDeviceListOpen;
    NSString * strAddressFromCordinatesForDevice,*strAddressFromCordinatesForCurrentLoc;
    UILabel *lblAddressDisplay;
    NSMutableArray * arrDiscoveredDevices;
    NSString * strLocalID;
    NSString * strServerID;
    BOOL isAlreadyLocated;
    NSTimer * updateTimeTimer;
    UILabel * lblBatteries;
    BOOL isFromDeleteDevice;
}
//-(void)CallmethodfromCustomtochek:(NSMutableDictionary *)dict;
-(void)callHomeWebServiceForUserLoggedInfo;
-(void)SaveAddedDeviceToHome:(NSMutableDictionary *)notify;
-(void)FetchBatteryofDevice:(NSMutableDictionary *)dict;
-(void)LogoutCalled;
-(void)FetchTrackerAlertStatus:(NSMutableDictionary *)notify;
-(void)deleteDevice:(NSMutableDictionary *)notify;
-(void)LocationEnabled;
-(void)DeviceStatustoHome:(NSMutableDictionary *)notify;
-(void)FetchBuzzerVolume:(NSMutableDictionary *)notify;


@end
