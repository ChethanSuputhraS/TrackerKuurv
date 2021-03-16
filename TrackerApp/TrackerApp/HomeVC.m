//
//  HomeVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 12/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "HomeVC.h"
#import "ViewMoreCell.h"
#import "PhoneAlertSettingsVC.h"
#import "MapAnnotation.h"
#import "AddDeviceVC.h"
#import "CustomDeviceVC.h"
#import "URLManager.h"
#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"
#import "AsyncImageView.h"
#import "ALBatteryView.h"
@interface HomeVC ()<CBCentralManagerDelegate,URLManagerDelegate>
{
    CBPeripheral * currentPeripheral;
    CBCentralManager*centralManager;
    NSTimer * updateConnectedDeviceTimer;
   
    AsyncImageView * imgDevice;
    UILabel * lblLastseen;
    UIImageView*imgGps;
    UIButton * btnRoute;
    CustomAnnotation *annotationPin ;
    ALBatteryView *batteryView;
    CustomAnnotationView* custannotationView;
    NSTimer * timeoutTimer, * locateTimer, * connectionTimeout,  * batteryCheckTimer;
    UIButton * btnLocate;
    FCAlertView * batteryAlert;
    NSInteger updateCount;
}
@end

@implementation HomeVC

#pragma mark -View  Life Cycle
- (void)viewDidLoad
{
//    CLLocation *locationCord =  [[CLLocation alloc] initWithLatitude:34.050503 longitude:-118.414452];
//
//    NSLog(@"Log Address =%f",[self getAddressFromCordinates:locationCord]);
    isUserIntialized = YES;
    [super viewDidLoad];
    
    [self setNavigationViewFrames];
    [self setContentViewFrames];

}
-(void)methodForViewdidload
{
    [self SetupforDeviceView];
    
    selectedIndex = 0;
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.navigationController setNavigationBarHidden:true];
    
    [self ShowPicker:false andView:tblViewMore];
    
    dictCurrentDeviceData = [[NSMutableDictionary alloc]init];
    arrayViewMore = [[NSMutableArray alloc]initWithObjects:@"Alert Settings",@"Change Name & Image",@"Delete Tracker", nil];
    
    lblAddressDisplay = [[UILabel alloc]init];
    arrGlobalDevices = [[NSMutableArray alloc] init];
    selectedDeviecDict = [[NSMutableDictionary alloc] init];
    arrDiscoveredDevices = [[NSMutableArray alloc]init];
    arrayDevice = [[NSMutableArray alloc]init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from Device_Table where user_id ='%@' group by ble_address",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arrayDevice];
    for (int i =0; i<[arrayDevice count]; i++)
    {
        NSString * strAddress = [NSString stringWithFormat:@"lat_%@",[[arrayDevice objectAtIndex:i] valueForKey:@"ble_address"]];
        if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:strAddress]] isEqualToString:@"NA"])
        {
            NSString * strLat = [[NSUserDefaults standardUserDefaults] valueForKey:strAddress];
            strAddress = [NSString stringWithFormat:@"long_%@",[[arrayDevice objectAtIndex:i] valueForKey:@"ble_address"]];
            if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:strAddress]] isEqualToString:@"NA"])
            {
                NSString * strLong = [[NSUserDefaults standardUserDefaults] valueForKey:strAddress];
                [[arrayDevice objectAtIndex:i] setObject:strLat forKey:@"latitude"];
                [[arrayDevice objectAtIndex:i] setObject:strLong forKey:@"longitude"];
                NSLog(@"LAT=%@   LONG=%@", strLat, strLong);
                strAddress = [NSString stringWithFormat:@"status_%@",[[arrayDevice objectAtIndex:i] valueForKey:@"ble_address"]];
                if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:strAddress]] isEqualToString:@"NA"])
                {
                    [[arrayDevice objectAtIndex:i] setObject:[[NSUserDefaults standardUserDefaults] valueForKey:strAddress] forKey:@"correction_status"];
                }
                strAddress = [NSString stringWithFormat:@"time_%@",[[arrayDevice objectAtIndex:i] valueForKey:@"ble_address"]];
                NSLog(@"straddress is %@",[[NSUserDefaults standardUserDefaults] valueForKey:strAddress]);
                if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:strAddress]] isEqualToString:@"NA"])
                {
                    NSString * strLocalDBDate = [APP_DELEGATE checkforValidString:[[arrayDevice objectAtIndex:i]valueForKey:@"updated_time"]];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                    NSDate *dateFromLocalDB = [dateFormatter dateFromString:strLocalDBDate];
                    
                    NSString * strNSDefaultDate = [APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:strAddress]];
                    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
                    [dateFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *dateFromDefaults = [dateFormatter2 dateFromString:strNSDefaultDate];
                    
                    if ([dateFromLocalDB laterDate:dateFromDefaults])
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:strLocalDBDate forKey:strAddress];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    }
                    [[arrayDevice objectAtIndex:i] setObject:[[NSUserDefaults standardUserDefaults] valueForKey:strAddress] forKey:@"updated_time"];
                    lblLastseen.text = [NSString stringWithFormat:@"Last seen : %@",[APP_DELEGATE changeDateFormat:[[arrayDevice objectAtIndex:i]valueForKey:@"updated_time"]]];
                }
                else
                {
                    [lblLastseen setText: [NSString stringWithFormat:@"Last seen : %@",[APP_DELEGATE changeDateFormat:strCurrentDateNTime]]];
                }
            }
        }
    }
    

    [updateConnectedDeviceTimer invalidate];
    updateConnectedDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(CheckConnectedDevices) userInfo:nil repeats:YES];
    
    [connectionTimeout invalidate];
    connectionTimeout = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timeoutConnection) userInfo:nil repeats:NO];
    
    [timeoutTimer invalidate];
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:13 target:self selector:@selector(timeOutCaller) userInfo:nil repeats:NO];
    
    [batteryCheckTimer invalidate];
    batteryCheckTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(CheckBatteryforConnectedDevice) userInfo:nil repeats:YES];

    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Accessing your Kuurv..."];
    
    [self fetchallDevicesAPI];
}
-(void)viewWillAppear:(BOOL)animated
{
    if (isUserIntialized == YES)
    {
        [self methodForViewdidload];
        isUserIntialized = NO;
    }
        
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SaveAddedDeviceToHome" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SaveAddedDeviceToHome:) name:@"SaveAddedDeviceToHome" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"callHomeWebServiceForUserLoggedInfo" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callHomeWebServiceForUserLoggedInfo:) name:@"callHomeWebServiceForUserLoggedInfo" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchBatteryofDevice" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchBatteryofDevice:) name:@"FetchBatteryofDevice" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchTrackerAlertStatus" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchTrackerAlertStatus:) name:@"FetchTrackerAlertStatus" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteDevice" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDevice:) name:@"deleteDevice" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationEnabled" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationEnabled) name:@"LocationEnabled" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceStatustoHome" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeviceStatustoHome:) name:@"DeviceStatustoHome" object:nil];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (arrayDevice.count >0)
    {
    }
    [self fetchDeviceTableInfo];

}
-(void)viewDidAppear:(BOOL)animated
{
        [self moveLegalLabel];
    if (@available(iOS 10.0, *))
    {
        if (centralManager.state == CBCentralManagerStatePoweredOn ||centralManager.state == CBCentralManagerStateUnknown ||centralManager.state == CBManagerStateUnknown || centralManager.state == 5 || centralManager.state == 0){}
        else if(centralManager.state == CBCentralManagerStateUnknown){}
        else{[self GlobalBLuetoothCheck];}
    }
    else
    {
        if (centralManager.state == CBCentralManagerStatePoweredOff){[self GlobalBLuetoothCheck];}
    }
    NSLog(@"itsCAlled=======");
    [self InitialBLE];
    [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
    [[BLEManager sharedManager] rescan];
}
-(void)moveLegalLabel
{
    if (mapView.subviews.count > 0)
    {
        UIView * legalLink = [mapView.subviews objectAtIndex:1];
        legalLink.frame = CGRectMake(mapView.frame.size.width - legalLink.frame.size.width - 20, mapView.frame.size.height - legalLink.frame.size.height - 60 , legalLink.frame.size.width, legalLink.frame.size.height);
        legalLink.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"callHomeWebServiceForUserLoggedInfo" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchBatteryofDevice" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchTrackerAlertStatus" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteDevice" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationEnabled" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceStatustoHome" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotofiyDiscoveredDevices" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationHome" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationHome" object:nil];
}
-(void)setNavigationViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy)];
    [viewHeader setBackgroundColor:global_greenColor];
    [self.view addSubview:viewHeader];
    
    UIImageView * imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-200)/2,-55, 200, 200)];
    imgLogo.image = [UIImage imageNamed:@"logo.png"];
    imgLogo.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgLogo];

    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, yy)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    UIImageView * imgMore = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-40,20+7, 30, 30)];
    imgMore.image = [UIImage imageNamed:@"view-more.png"];
    imgMore.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMore];
    
    UIButton * btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMore setFrame:CGRectMake(DEVICE_WIDTH-100, 0, 100, yy)];
    [btnMore addTarget:self action:@selector(btnMoreClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnMore.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnMore];
    
    if (IS_IPHONE_X)
    {
        [btnMenu setFrame:CGRectMake(0, 0, 88, 84)];
        imgMenu.frame = CGRectMake(10,40+7, 33, 30);
        imgMore.frame = CGRectMake(DEVICE_WIDTH-40,40+7, 30, 30);
        viewHeader.frame = CGRectMake(0,0, DEVICE_WIDTH, 84);
        imgLogo.frame = CGRectMake((DEVICE_WIDTH-200)/2,-38, 200, 200);
    }
}
-(void)setContentViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH,DEVICE_HEIGHT-yy)];
    [mapView setDelegate:self];
    mapView.showsUserLocation = false;
    mapView.mapType = MKMapTypeStandard;
    [self.view addSubview:mapView];

    NSLog(@"1 CHECK LATITUDE ===========>%f",currentLatitude);
    if (currentLatitude == 0)
    {
        currentLatitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"last_latitude"];
        currentLongitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"last_longitude"];
    }

    if (currentLatitude != 0)
    {
        CLLocation *locationCord =  [[CLLocation alloc] initWithLatitude:currentLatitude longitude:currentLongitude];
        [self getAddressFromCordinates:locationCord];
        
        CLLocationCoordinate2D pinlocation = CLLocationCoordinate2DMake(currentLatitude,currentLatitude);;
        MKPlacemark *mPlacemark = [[MKPlacemark alloc] initWithCoordinate:pinlocation addressDictionary:nil];
        annotationPin = [[CustomAnnotation alloc] initWithPlacemark:mPlacemark];
        annotationPin.title = @"title";
        annotationPin.subtitle1 = @"sub titile" ;
        annotationPin.deviceImg = [UIImage imageNamed:@"logo.png"];;
        annotationPin.isfromAdd = @"NO";
        [mapView addAnnotation:annotationPin];
    }
    btnLocate = [[UIButton alloc]initWithFrame:CGRectMake(15,DEVICE_HEIGHT-80, 60, 60)];
    [btnLocate setTitle:@"Locate" forState:UIControlStateNormal];
    btnLocate.backgroundColor = global_greenColor;
    btnLocate.titleLabel.font = [UIFont fontWithName:CGBold size:txtSize-3];
    [btnLocate setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnLocate addTarget:self action:@selector(btnLocateClicked) forControlEvents:UIControlEventTouchUpInside];
    btnLocate.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f] CGColor];
    btnLocate.layer.shadowOffset = CGSizeMake(0, 6.0f);
    btnLocate.layer.shadowOpacity = 1.0f;
    btnLocate.layer.shadowRadius = 0.0f;
    btnLocate.layer.masksToBounds = NO;
    btnLocate.layer.cornerRadius = 30.0f;
    [self.view addSubview:btnLocate];

    UIButton * btnAddDevice = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70,DEVICE_HEIGHT-80, 60, 60)];
    [btnAddDevice setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    btnAddDevice.backgroundColor = global_greenColor;
    [btnAddDevice addTarget:self action:@selector(addDeviceClicked) forControlEvents:UIControlEventTouchUpInside];
    btnAddDevice.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f] CGColor];
    btnAddDevice.layer.shadowOffset = CGSizeMake(0, 6.0f);
    btnAddDevice.layer.shadowOpacity = 1.0f;
    btnAddDevice.layer.shadowRadius = 0.0f;
    btnAddDevice.layer.masksToBounds = NO;
    btnAddDevice.layer.cornerRadius = 30.0f;
    [self.view addSubview:btnAddDevice];
  
}
-(void)SetupforDeviceView
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    
    [deviceView removeFromSuperview];
    deviceView = [[UIView alloc]initWithFrame:CGRectMake(5,yy+10,DEVICE_WIDTH-60,70)];
    deviceView.layer.masksToBounds = true;
    deviceView.backgroundColor = global_greyColor;
    deviceView.layer.masksToBounds = true;
    deviceView.layer.cornerRadius = 10;
    deviceView.hidden = YES;
    [self.view addSubview:deviceView];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:deviceView.bounds];
    deviceView.layer.masksToBounds = NO;
    deviceView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    deviceView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    deviceView.layer.shadowOpacity = 0.5f;
    deviceView.layer.shadowPath = shadowPath.CGPath;
    
    [imgDevice removeFromSuperview];
    imgDevice = [[AsyncImageView alloc]initWithFrame:CGRectMake(5,15, 50, 50)];
    imgDevice.layer.masksToBounds = true;
    imgDevice.layer.cornerRadius = 25;
    imgDevice.backgroundColor = UIColor.whiteColor;
    imgDevice.contentMode = UIViewContentModeScaleToFill;
    [deviceView addSubview:imgDevice];
    
    [lblDevice removeFromSuperview];
    lblDevice = [[UILabel alloc] initWithFrame:CGRectMake(60,7,deviceView.frame.size.width-107,55)];
    [lblDevice setBackgroundColor:[UIColor clearColor]];
    [lblDevice setText:@" "];
    [lblDevice setTextAlignment:NSTextAlignmentLeft];
    [lblDevice setFont:[UIFont fontWithName:CGBold size:txtSize+2]];
    [lblDevice setTextColor:UIColor.whiteColor];
    lblDevice.numberOfLines = 0;
    [deviceView addSubview:lblDevice];
    
    strCurrentDateNTime =  [APP_DELEGATE checkforValidString:[APP_DELEGATE getCurrentTime]];
    
    [lblLastseen removeFromSuperview];
    lblLastseen = [[UILabel alloc]init];
    lblLastseen.frame = CGRectMake(60,40,deviceView.frame.size.width-75,25);
    [lblLastseen setBackgroundColor:[UIColor clearColor]];
    [lblLastseen setTextAlignment:NSTextAlignmentLeft];
    [lblLastseen setFont:[UIFont fontWithName:CGRegular size:txtSize-6]];
    [lblLastseen setTextColor:UIColor.whiteColor];
    lblLastseen.numberOfLines = 0;
    [deviceView addSubview:lblLastseen];
    
    
    if (arrayDevice.count == 0)
    {
        //        [lblDevice setText:@"No Devices yet"];
    }
    else
    {
        if ([lblDevice.text isEqualToString:@"No Devices yet"])
        {
            [lblDevice.text = [arrayDevice objectAtIndex:0]valueForKey:@"device_name"];
        }
    }
    
    [lblBatteries removeFromSuperview];
    lblBatteries = [[UILabel alloc] init];
    lblBatteries.frame = CGRectMake(deviceView.frame.size.width-38,2,35,30);
    [lblBatteries setTextAlignment:NSTextAlignmentCenter];
    lblBatteries.font = [UIFont systemFontOfSize:txtSize-8];
    [lblBatteries setTextColor:UIColor.whiteColor];
    lblBatteries.text = @"100%";
    lblBatteries.hidden = YES;
    [deviceView addSubview:lblBatteries];

    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        deviceView.frame = CGRectMake(5,yy+10,DEVICE_WIDTH-60,70);
        [batteryView removeFromSuperview];
        batteryView = [[ALBatteryView alloc] initWithFrame:CGRectMake(deviceView.frame.size.width-32,-6,30,30)];

        imgDevice.frame = CGRectMake(5,10, 40, 40);
        imgDevice.layer.cornerRadius = 20;
        [lblDevice setFont:[UIFont fontWithName:CGBold size:txtSize]];
        lblDevice.frame = CGRectMake(48,0,deviceView.frame.size.width-83,50);
        lblLastseen.frame = CGRectMake(20,45,deviceView.frame.size.width-30,25);
        [lblLastseen setFont:[UIFont fontWithName:CGRegular size:txtSize-7]];
        lblBatteries.frame = CGRectMake(deviceView.frame.size.width-65,0,35,15);
    }
    else
    {
        deviceView.frame = CGRectMake(5,yy+10,DEVICE_WIDTH-60,80);
        [batteryView removeFromSuperview];
        batteryView = [[ALBatteryView alloc] initWithFrame:CGRectMake(deviceView.frame.size.width-35,-6,33,33)];
        lblBatteries.frame = CGRectMake(deviceView.frame.size.width-64,-2,32,22);
        lblBatteries.font = [UIFont systemFontOfSize:txtSize-7];
        lblLastseen.frame = CGRectMake(60,55,deviceView.frame.size.width-63,25);

    }
    [deviceView addSubview:batteryView];
    [batteryView setBatteryLevelWithAnimation:NO forValue:0 inPercent:YES];
    
    
    UIImageView*imgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(deviceView.frame.size.width-25,(70-2)/2+2,15,9)];
    imgArrow.image = [UIImage imageNamed:@"downArrow.png"];
    imgArrow.backgroundColor = UIColor.clearColor;
    imgArrow.hidden = false;
    imgArrow.userInteractionEnabled = true;
    [deviceView addSubview:imgArrow];
    
    UIButton * btnDevicePicker = [[UIButton alloc]initWithFrame:CGRectMake(5,0,deviceView.frame.size.width,70)];
    btnDevicePicker.backgroundColor = UIColor.clearColor;
    [btnDevicePicker addTarget:self action:@selector(btnDevicePickerClicked) forControlEvents:UIControlEventTouchUpInside];
    [deviceView addSubview:btnDevicePicker];
    
    [viewDeviceExpandable removeFromSuperview];
    viewDeviceExpandable = [[UIView alloc]init];
    viewDeviceExpandable.backgroundColor = UIColor.clearColor;
    viewDeviceExpandable.hidden = true;
    viewDeviceExpandable.frame = CGRectMake(5,deviceView.frame.origin.y+70,DEVICE_WIDTH-60,0);
    [self.view addSubview:viewDeviceExpandable];
    
    [tblMoreDevices removeFromSuperview];
    tblMoreDevices =[[UITableView alloc]initWithFrame:CGRectMake(0,0,viewDeviceExpandable.frame.size.width,220) style:UITableViewStylePlain];
    [tblMoreDevices setBackgroundColor:[UIColor clearColor]];
    tblMoreDevices.showsVerticalScrollIndicator = NO;
    tblMoreDevices.showsHorizontalScrollIndicator=NO;
    [tblMoreDevices setDelegate:self];
    [tblMoreDevices setDataSource:self];
    [tblMoreDevices setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [viewDeviceExpandable addSubview:tblMoreDevices];
    
    [imgGps removeFromSuperview];
    imgGps = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-50,yy+0+20,40,40)];
    imgGps.image = [UIImage imageNamed:@"gpsIcon"];
    imgGps.backgroundColor = UIColor.clearColor;
    imgGps.userInteractionEnabled = true;
    imgGps.layer.cornerRadius = 20;
    imgGps.layer.masksToBounds = YES;
    [self.view addSubview:imgGps];
    
    [btnRoute removeFromSuperview];
    btnRoute = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-50,yy+8,50,70)];
    btnRoute.backgroundColor = UIColor.clearColor;
    [btnRoute addTarget:self action:@selector(btnRouteClicked) forControlEvents:UIControlEventTouchUpInside];
    btnRoute.layer.cornerRadius = 22.0f;
    [self.view addSubview:btnRoute];

}
-(void)moreOptionClicked
{
    [viewMore removeFromSuperview];
    viewMore = [[UIView alloc]initWithFrame:CGRectMake(0,DEVICE_HEIGHT, DEVICE_WIDTH-0, 195)];
    viewMore.backgroundColor = [UIColor colorWithRed:232.0/255.0f green:232.0/255.0f  blue:232.0/255.0f  alpha:1];
//    viewMore.alpha = 0.7;
    viewMore.layer.masksToBounds = YES;
//    viewMore.layer.cornerRadius = 10;
    [self.view addSubview:viewMore];
    
    [tblViewMore removeFromSuperview];
    tblViewMore =[[UITableView alloc]initWithFrame:CGRectMake(10,DEVICE_HEIGHT,DEVICE_WIDTH-20,viewMore.frame.size.height ) style:UITableViewStylePlain];
    [tblViewMore setBackgroundColor:[UIColor clearColor]];
    tblViewMore.showsVerticalScrollIndicator = NO;
    tblViewMore.showsHorizontalScrollIndicator=NO;
    tblViewMore.scrollEnabled = false;
    [tblViewMore setDelegate:self];
    [tblViewMore setDataSource:self];
    [tblViewMore setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tblViewMore.layer.masksToBounds = YES;
    tblViewMore.layer.cornerRadius = 10;
    [self.view addSubview:tblViewMore];
    
    [self ShowPicker:YES andView:tblViewMore];
}
-(void)SaveAddedDeviceToHome:(NSMutableDictionary *)notify
{
    NSMutableDictionary * dict = notify;
    if ([arrayDevice count]>0)
    {
        if (![[arrayDevice valueForKey:@"ble_address"] containsObject:[dict valueForKey:@"ble_address"]])
        {
            [arrayDevice addObject:dict];
        }
    }
    else
    {
        arrayDevice = [[NSMutableArray alloc] init];
        [arrayDevice addObject:dict];
    }
    CBPeripheral * pd = [dict objectForKey:@"peripheral"];
    if (pd)
    {
        NSLog(@"---------->>>>from Save Added device to Home");

        [[BLEService sharedInstance] SendCommandWithPeripheral:pd withValue:@"13"];
        [[BLEService sharedInstance] SendCommandWithPeripheral:pd withValue:@"15"];

    }
    [self fetchDeviceTableInfo];
}
-(void)callHomeWebServiceForUserLoggedInfo
{
    [self fetchallDevicesAPI];
}


#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblMoreDevices)
    {
        return arrayDevice.count;
    }
    else
    {
        return arrayViewMore.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblMoreDevices)
    {
        return 55;
    }
    else
    {
        return 65;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    ViewMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[ViewMoreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    if (tableView == tblMoreDevices)
    {
        cell.lblName.hidden = true;
        cell.swtchh.hidden = true;
        cell.imgDevice.image = [UIImage imageNamed:@"logoDisplay.png"];;
        
        if (arrayDevice.count > 0)
        {
            cell.lblMoreDevices.text  = [[arrayDevice objectAtIndex:indexPath.row]valueForKey:@"device_name"];
            if (![[APP_DELEGATE checkforValidString:[[arrayDevice objectAtIndex:indexPath.row] valueForKey:@"photo_localURL"]] isEqualToString:@"NA"])
            {
                NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"TrackerDeviceName/%@",[[arrayDevice objectAtIndex:indexPath.row] valueForKey:@"photo_localURL"]]];
                NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                UIImage * mainImage = [UIImage imageWithData:pngData];
                UIImage * image = [self scaleMyImage:mainImage];
                cell.imgDevice.image = image;
            }
            else if(![[APP_DELEGATE checkforValidString:[[arrayDevice objectAtIndex:indexPath.row] valueForKey:@"photo_serverURL"]] isEqualToString:@"NA"])
            {
                NSURL * tmpURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrayDevice objectAtIndex:indexPath.row] valueForKey:@"photo_serverURL"]]];
                cell.imgDevice.imageURL = tmpURL;
            }
        }
    }
    else
    {
        cell.lblback.hidden = true;
        cell.lblMoreDevices.hidden = true;
        cell.lblName.layer.masksToBounds = YES;
        cell.lblName.layer.cornerRadius = 10;

        cell.lblName.frame =  CGRectMake(0,4,tblViewMore.frame.size.width-0,57);
        cell.lblName.text = [arrayViewMore objectAtIndex:indexPath.row];
        [cell.lblName setTextColor:UIColor.blackColor];
        [cell.lblName setFont:[UIFont fontWithName:CGRegular size:txtSize]];
        if ([[arrayViewMore objectAtIndex:indexPath.row] isEqualToString:@"Delete Tracker"])
        {
            [cell.lblName setTextColor:UIColor.redColor];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblMoreDevices)
    {
        [self hideDeviceView];
        [backShadowView removeFromSuperview];
        [self ShowPicker:NO andView:ViewPicker];

        strLocalID = [[arrayDevice objectAtIndex:indexPath.row]valueForKey:@"id"];
        strServerID = [[arrayDevice objectAtIndex:indexPath.row]valueForKey:@"server_id"];
        selectedDeviecDict  = [arrayDevice objectAtIndex:indexPath.row];
        selectedIndex = indexPath.row;
        [self SetupforCurrentDevice];
    }
    else
    {
        [self ShowPicker:false andView:tblViewMore];
        if (indexPath.row == 0)
        {
            PhoneAlertSettingsVC *view1 = [[PhoneAlertSettingsVC alloc]init];
            view1.phoneAlertDict = selectedDeviecDict;
            view1.arrayIndex = selectedIndex;
            [self.navigationController pushViewController:view1 animated:true];
        }
     
        else if (indexPath.row == 1)
        {
            if (arrayDevice.count == 0)
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"There is no device found."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                CustomDeviceVC *view1 = [[CustomDeviceVC alloc]init];
                view1.deviceDetail = selectedDeviecDict;
                view1.sentIndex = selectedIndex;
                view1.isfromHome = true;
                [self.navigationController pushViewController:view1 animated:true];
            }
        }
        else if (indexPath.row == 2)
        {
            if (arrayDevice.count == 0)
            {
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"There is no device to delete."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                if ([APP_DELEGATE isNetworkreachable])
                {
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeWarning];
                    [alert addButton:@"Yes" withActionBlock:
                     ^{

                         [APP_DELEGATE endHudProcess];
                         [APP_DELEGATE startHudProcess:@"Removing Tracker..."];
                         CBPeripheral * sp = [selectedDeviecDict valueForKey:@"peripheral"];
                         if (sp.state == CBPeripheralStateConnected)
                         {
                             [[BLEService sharedInstance] SendCommandWithPeripheral:sp withValue:@"14"];
                              [[BLEService sharedInstance] SyncUserTextinfowithDevice:CURRENT_USER_UNIQUEKEY with:sp withOpcode:@"9"];
                         }
                             [selectedDeviecDict removeObjectForKey:@"peripheral"];
                             [selectedDeviecDict setValue:@"NA" forKey:@"identifier"];
                             if (arrayDevice.count > self->selectedIndex)
                             {
                                 [[arrayDevice objectAtIndex:self->selectedIndex] setObject:@"2" forKey:@"is_active"];
                             }
                            
                             [self->mapView removeAnnotation:self->annotationPin];
                             NSString * strDelete = [NSString stringWithFormat:@"Delete from Device_Table where ble_address = '%@'",[selectedDeviecDict valueForKey:@"ble_address"]];
                             [[DataBaseManager dataBaseManager]execute:strDelete];
                             if (arrayDevice.count != 0)
                             {
                                 for (int i = 0; i<arrayDevice.count; i++)
                                 {
                                     if ([[[arrayDevice objectAtIndex:i]valueForKey:@"ble_address"]isEqualToString:[selectedDeviecDict valueForKey:@"ble_address"]])
                                     {
                                         [arrayDevice removeObjectAtIndex:i];
                                     }
                                 }
                             }
                             [self DeleteDeviceAPICall:[selectedDeviecDict valueForKey:@"server_id"] withBleAddress:[selectedDeviecDict valueForKey:@"ble_address"]];
                             
                             self->currentPeripheral = nil;
                             self->selectedIndex = 0;
                             [self fetchDeviceTableInfo];
                     }];
                    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
                    [alert showAlertInView:self
                                 withTitle:@"KUURV"
                              withSubtitle:@"Are you sure want to Delete this device?"
                           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
                       withDoneButtonTitle:@"No" andButtons:nil];
                }
                else
                {
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    alert.colorScheme = [UIColor blackColor];
                    [alert makeAlertTypeCaution];
                    [alert showAlertInView:self
                                 withTitle:@"KUURV"
                              withSubtitle:@"Please check your internet connection and try again."
                           withCustomImage:[UIImage imageNamed:@"logo.png"]
                       withDoneButtonTitle:nil
                                andButtons:nil];
                }
            }
        }
    }
}

#pragma mark - Webservice Call & its Delegate
-(void)fetchallDevicesAPI
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        [dict setValue:@"20" forKey:@"limit"];
        [dict setValue:@"0" forKey:@"offset"];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"devicelist";
        manager.delegate = self;
        NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/devicelist";
        [manager urlCall:strServerUrl withParameters:dict];
        NSLog(@"sent info for devicelist info is %@",dict);
    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"There is no internet connection. Please connect to internet and try again."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }

}
-(void)DeleteDeviceAPICall:(NSString *)strServerId withBleAddress:(NSString *)strBleaddress
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        isFromDeleteDevice = true;

        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:strServerId forKey:@"device_id"];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        [dict setValue:strBleaddress forKey:@"ble_address"];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"deleteDevice";
        manager.delegate = self;
        NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/deletedevice";
        [manager urlCall:strServerUrl withParameters:dict];
        NSLog(@"sent info for devicelist info is %@",dict);
    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"There is no internet connection. Please connect to internet and try again."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    /*
    if ([APP_DELEGATE isNetworkreachable])
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
                [dict setValue:strServerId forKey:@"device_id"];
                [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
                [dict setValue:strBleaddress forKey:@"ble_address"];

                AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
                NSString *token=[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ACCESS_TOKEN"];
                [manager1.requestSerializer setValue:token forHTTPHeaderField:@"token"];
                [manager1.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
                //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                AFHTTPRequestOperation *op = [manager1 POST:@"http://kuurvtrackerapp.com/mobile/deletedevice" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
                                              {
                                                  
                                              }
                                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        [APP_DELEGATE endHudProcess];
                                                        if (error)
                                                        {
                                                        }
                                                    }];
                [op start];
            }
            // Perform async operation
            // Call your method/function here
            // Example:
            dispatch_sync(dispatch_get_main_queue(), ^{
                //Method call finish here
            });
        });
    }
     */
}
-(void)timeOutCaller
{
    if (timeoutTimer)
    {
        [APP_DELEGATE endHudProcess];
    }
}
-(void)CheckBluetoothStatus
{
    if (centralManager.state == CBCentralManagerStatePoweredOff ||centralManager.state == 4)
    {
        [APP_DELEGATE endHudProcess];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Please turn Bluetooth ON"
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    
}
- (void)onResult:(NSDictionary *)result
{
    [self CheckBluetoothStatus];
    [timeoutTimer invalidate];

//
    NSLog(@"The result is...%@", result);
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    if([[result valueForKey:@"commandName"] isEqualToString:@"devicelist"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableArray * arrServer = [[NSMutableArray alloc]init];
            arrServer = [[result valueForKey:@"result"] valueForKey:@"data"];
            if ([arrServer count]>0)
            {
                for (int i = 0; i< arrServer.count; i++)
                {
                    [self UpdateDeviceinLocalDatabase:[arrServer objectAtIndex:i]];
                    NSMutableArray * tmpArr = [[NSMutableArray alloc]init];
                    NSString * strQuery = [NSString stringWithFormat:@"select * from User_Set_Info"];
                    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArr];
                    NSString * strName = [[arrServer objectAtIndex:i] valueForKey:@"contact_name"];
                    NSString * strEmail = [[arrServer objectAtIndex:i] valueForKey:@"contact_email"];
                    NSString * strMob = [APP_DELEGATE checkforValidString:[[arrServer objectAtIndex:i] valueForKey:@"contact_mobile"]];
                    if (tmpArr.count > 0)
                    {
                        NSString * strQry = [NSString stringWithFormat:@"Update User_Set_Info set user_id ='%@', name = '%@', email = '%@', mobile = '%@'",CURRENT_USER_ID,strName,strEmail,strMob];
                        if ([strMob isEqualToString:@"NA"])
                        {
                            strQry = [NSString stringWithFormat:@"Update User_Set_Info set user_id ='%@', name = '%@', email = '%@'",CURRENT_USER_ID,strName,strEmail];
                        }
                        [[DataBaseManager dataBaseManager] execute:strQry];
                    }
                    else
                    {
                        NSString * strDelete = [NSString stringWithFormat:@"delete from User_Set_Info"];
                        [[DataBaseManager dataBaseManager] execute:strDelete];
                        NSString * requestStr =[NSString stringWithFormat:@"insert into 'User_Set_Info'('user_id','name','email','mobile') values(\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,strName,strEmail,strMob];
                        [[DataBaseManager dataBaseManager] execute:requestStr];
                    }
                }
                for (int i=0; i<arrayDevice.count; i++)
                {
                    if (![[arrServer valueForKey:@"ble_address"] containsObject:[[arrayDevice objectAtIndex:i] valueForKey:@"ble_address"]])
                    {
                        NSString * strDelete = [NSString stringWithFormat:@"Delete from Device_Table where ble_address = '%@'",[[arrayDevice objectAtIndex:i] valueForKey:@"ble_address"]];
                        [[DataBaseManager dataBaseManager]execute:strDelete];
                        [[arrayDevice objectAtIndex:i]setObject:@"2" forKey:@"is_active"];
                    }
                }
            }
            else
            {
                [APP_DELEGATE endHudProcess];

                arrayDevice = [[NSMutableArray alloc] init];
                NSString * strDelete = [NSString stringWithFormat:@"delete from Device_Table"];
                [[DataBaseManager dataBaseManager] execute:strDelete];
            }
            [self fetchDeviceTableInfo];
        }
        else
        {
            if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [alertGlobal removeFromSuperview];
                alertGlobal = [[FCAlertView alloc] init];
                alertGlobal.colorScheme = [UIColor blackColor];
                alertGlobal.delegate = self;
                alertGlobal.tag = 111;
                [alertGlobal makeAlertTypeCaution];
                [alertGlobal showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"User logged in from different device,so automatically logging out."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:[[result valueForKey:@"result"]valueForKey:@"message"]
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"deleteDevice"])
    {
         [APP_DELEGATE endHudProcess];
        isFromDeleteDevice = false;
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSLog(@"deleted device frm web");
            
            FCAlertView *alert = [[FCAlertView alloc] init];
                                        alert.colorScheme = [UIColor blackColor];
                                        [alert makeAlertTypeSuccess];
                                        [alert showAlertInView:self
                                                     withTitle:@"KUURV"
                                                  withSubtitle:@"Deleted Successfully"
                                               withCustomImage:[UIImage imageNamed:@"logo.png"]
                                           withDoneButtonTitle:nil
                                                    andButtons:nil];
        }
        else
        {
            if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [alertGlobal removeFromSuperview];
                alertGlobal = [[FCAlertView alloc] init];
                alertGlobal.colorScheme = [UIColor blackColor];
                alertGlobal.delegate = self;
                alertGlobal.tag = 111;
                [alertGlobal makeAlertTypeCaution];
                [alertGlobal showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"User logged in from different device,so automatically logging out."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:[[result valueForKey:@"result"]valueForKey:@"message"]
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
           
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"markaslost"])
    {
         [APP_DELEGATE endHudProcess];
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSString * strMsg;
            if ([[selectedDeviecDict valueForKey:@"marked_lost"]isEqualToString:@"1"] || [[selectedDeviecDict valueForKey:@"marked_lost"]isEqualToString:@"YES"])
            {
                [selectedDeviecDict setValue:@"0" forKey:@"marked_lost"];
                strMsg = @"Device has been successfully removed from marked as lost.";
            }
            else
            {
                [selectedDeviecDict setValue:@"1" forKey:@"marked_lost"];
                strMsg = @"Device has been successfully marked as lost.";
            }
            for (int i = 0; i<arrayDevice.count; i++)
            {
                if ([[[arrayDevice objectAtIndex:i]valueForKey:@"ble_address"]isEqualToString:[selectedDeviecDict valueForKey:@"ble_address"]])
                {
                    [[arrayDevice objectAtIndex:i]setValue:[selectedDeviecDict valueForKey:@"marked_lost"] forKey:@"marked_lost"];
                }
            }
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:strMsg
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else
        {
            if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [alertGlobal removeFromSuperview];
                alertGlobal = [[FCAlertView alloc] init];
                alertGlobal.colorScheme = [UIColor blackColor];
                alertGlobal.delegate = self;
                alertGlobal.tag = 111;
                [alertGlobal makeAlertTypeCaution];
                [alertGlobal showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"User logged in from different device,so automatically logging out."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:[[result valueForKey:@"result"]valueForKey:@"message"]
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
           
        }
    }
}
- (void)onError:(NSError *)error
{
    if (isFromDeleteDevice == true)
    {
        [APP_DELEGATE endHudProcess];
        isFromDeleteDevice = false;
    }
    [self CheckBluetoothStatus];
    [timeoutTimer invalidate];
//    [APP_DELEGATE endHudProcess];
    NSLog(@"The error is...%@", error);
    NSInteger ancode = [error code];
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}

#pragma mark - Button Click Evnets
-(void)btnMenuClicked:(id)sender
{
    [self ShowPicker:false andView:tblViewMore];
    [self hideDeviceView];
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}
-(void)btnMoreClicked:(id)sender
{
    [self hideDeviceView];
    [self moreOptionClicked];
}
-(void)addDeviceClicked
{
    [self hideDeviceView];
    [self ShowPicker:false andView:tblViewMore];
    AddDeviceVC *view1 = [[AddDeviceVC alloc]init];
    [self.navigationController pushViewController:view1 animated:true];
}
-(void)btnDevicePickerClicked
{
    if (arrayDevice.count == 0)
    {
        viewDeviceExpandable.frame = CGRectMake(5,deviceView.frame.origin.y+72.5,DEVICE_WIDTH-80,0);
    }
    else
    {
        if (isDeviceListOpen == false)
        {
            isDeviceListOpen = true;
            [UIView transitionWithView:viewDeviceExpandable duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{self->viewDeviceExpandable.hidden = false;}completion:NULL];
        }
        else
        {
            isDeviceListOpen = false;
            [self hideDeviceView];
        }
        int yy = 82.5;
        if (DEVICE_WIDTH == 320)
        {
            yy = 72.5;
        }
        
        viewDeviceExpandable.frame = CGRectMake(5,deviceView.frame.origin.y+yy,DEVICE_WIDTH-80,55 * (arrayDevice.count));
    }
}
-(void)btnRouteClicked
{
    double destLat = [[selectedDeviecDict valueForKey:@"latitude"] doubleValue];
    double destLong = [[selectedDeviecDict valueForKey:@"longitude"] doubleValue];

    NSString *originString = [NSString stringWithFormat:@"%f,%f",currentLatitude, currentLongitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destLat, destLong];


    NSString * strMapDirection = [NSString stringWithFormat:@"https://www.google.com/maps/dir/?api=1&origin=%@&destination=%@",originString,destinationString];
    if ([originString isEqualToString:destinationString])
    {
        strMapDirection = [NSString stringWithFormat:@"https://maps.google.com/maps?q=%f,%f",destLat,destLong];
    }
    NSLog(@"Route ori=%@   dest=%@",originString,destinationString);
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strMapDirection]];
    } else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strMapDirection]];
    }
}
-(void)btnLocateClicked
{
    if (centralManager.state == CBCentralManagerStatePoweredOff ||centralManager.state == 4)
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Please turn Bluetooth ON and then try locating your device."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else if (arrayDevice.count == 0)
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Add device to locate it."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
        CBPeripheral * sp = [selectedDeviecDict valueForKey:@"peripheral"];
        if (sp.state == CBPeripheralStateConnected)
        {
            if (isAlreadyLocated)
            {
                [btnLocate setTitle:@"Locate" forState:UIControlStateNormal];
                isAlreadyLocated = false;
                [[BLEService sharedInstance] SendCommandWithPeripheral:sp withValue:@"14"];
            }
            else
            {
                [locateTimer invalidate];
                locateTimer = nil;
                locateTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(LocateBtntitleChange) userInfo:nil repeats:NO];
                [btnLocate setTitle:@"Stop" forState:UIControlStateNormal];
                isAlreadyLocated = true;
                [[BLEService sharedInstance] SendCommandWithPeripheral:sp withValue:@"7"];
            }
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Tracker is disconnected. Please connect in order to locate."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
}
-(void)LocateBtntitleChange
{
    [locateTimer invalidate];
    locateTimer = nil;
    if (isAlreadyLocated)
    {
        isAlreadyLocated = false;
        [btnLocate setTitle:@"Locate" forState:UIControlStateNormal];
    }
}
//-(void)setDeviceTrackerStaus:(BOOL)isOn
//{
//    NSInteger valuInt = 0;
//    if (isOn)
//    {
//        valuInt = 1;
//    }
//    NSData * valueData = [[NSData alloc] initWithBytes:&valuInt length:1];
//    
//    NSInteger opInt = 8;
//    NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
//    
//    NSInteger lengths = 1;
//    NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
//    
//    NSMutableData * finalData = [opCodeData mutableCopy];
//    [finalData appendData:lengthData];
//    [finalData appendData:valueData];
//    [[BLEService sharedInstance] SendCommandNSData:finalData withPeripheral:currentPeripheral];
//    NSLog(@"final data=%@",finalData);
//
//}

#pragma mark - Database Methods
-(void)UpdateDeviceinLocalDatabase:(NSMutableDictionary *)dictObtained
{
    NSString * strBle = [[APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"ble_address"]] lowercaseString];
    strBle = [strBle stringByReplacingOccurrencesOfString:@":" withString:@""];
    strBle = [strBle stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString * dateString = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"updated_at"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone systemTimeZone];   //Asia/Kolkata (GMT+5:30) offset 19800

    [dateFormatter setTimeZone:gmt];

    NSDate *dateFromString = [dateFormatter dateFromString:dateString];   //2019-11-26 07:31:55


    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSString *stringDate = [APP_DELEGATE checkforValidString:[dateFormatter2 stringFromDate:dateFromString]];
    
    NSString * strEmail = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"contact_email"]];
    NSString * strMob = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"contact_mobile"]];
    NSString * strName = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"contact_name"]];
    NSString * strCreated = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"created_at"]];
    NSString * strDeviceID = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"id"]];
    NSString * strActive = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"is_active"]];
    NSString * strLat = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"latitude"]];
    NSString * strLong = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"longitude"]];
    NSString * strMarkLost = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"marked_lost"]];
    NSString * strUpdatedTime = [APP_DELEGATE checkforValidString:stringDate];
    NSString * strUserID = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"user_id"]];
    NSString * strDeviceName = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_name"]];
    NSString * strLastConnectionStatus = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"correction_status"]];
    NSString * strServerUrl = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_image_path"]];
//    NSString * strTrackerAlert = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"tracker_device_alert"]];

    if ([strMarkLost isEqualToString:@"NA"])
    {
        strMarkLost = @"0";
    }
    [dictObtained setValue:strCreated forKey:@"created_time"];
    [dictObtained setValue:strUpdatedTime forKey:@"updated_time"];
    [dictObtained setValue:strServerUrl forKey:@"photo_serverURL"];
//    [dictObtained setValue:strTrackerAlert forKey:@"tracker_device_alert"];

    if ([[arrayDevice valueForKey:@"ble_address"] containsObject:strBle])
    {
        NSInteger foundIndexx = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:strBle];
        if (foundIndexx != NSNotFound)
        {
            if (foundIndexx < [arrayDevice count])
            {
                NSString * dateString = [APP_DELEGATE checkforValidString:[[arrayDevice objectAtIndex:foundIndexx]valueForKey:@"updated_time"]];
                [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
                NSDate *  localDate = [dateFormatter dateFromString:dateString];
//                if (localDate > dateString)
                if ([localDate laterDate:dateFromString])
                {
                    stringDate = dateString;
                }
                [[arrayDevice objectAtIndex:foundIndexx] setObject:strDeviceName forKey:@"device_name"];
                [[arrayDevice objectAtIndex:foundIndexx] setObject:strServerUrl forKey:@"photo_serverURL"];
                [[arrayDevice objectAtIndex:foundIndexx] setObject:[APP_DELEGATE checkforValidString:stringDate] forKey:@"updated_time"];
                [[arrayDevice objectAtIndex:foundIndexx] setObject:strLat forKey:@"latitude"];
                [[arrayDevice objectAtIndex:foundIndexx] setObject:strLong forKey:@"longitude"];
                [[arrayDevice objectAtIndex:foundIndexx] setValue:strDeviceID forKey:@"server_id"];
                [[arrayDevice objectAtIndex:foundIndexx] setObject:strActive forKey:@"is_active"];
                [[arrayDevice objectAtIndex:foundIndexx] setObject:strMarkLost forKey:@"marked_lost"];
                [[arrayDevice objectAtIndex:foundIndexx] setObject:strLastConnectionStatus forKey:@"correction_status"];
            }
        }
        NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set user_id ='%@',device_name = '%@',latitude = '%@',longitude = '%@',marked_lost = '%@',is_active = '%@',contact_name = '%@',contact_email = '%@',contact_mobile = '%@',photo_localURL = '%@',photo_serverURL = '%@',identifier = '%@',created_time = '%@',updated_time = '%@',correction_status = '%@', server_id ='%@' where ble_address = '%@'",strUserID,strDeviceName,strLat,strLong,strMarkLost,strActive,strName,strEmail,strMob,@"NA",strServerUrl,@"NA",strCreated,stringDate,strLastConnectionStatus,strDeviceID,strBle];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
    }
    else
    {
        [dictObtained setValue:@"NA" forKey:@"photo_localURL"];
        [dictObtained setValue:@"NA" forKey:@"identifier"];
        
        NSString * strDel = [NSString stringWithFormat:@"delete from Device_Table where ble_address ='%@'",strBle];
        [[DataBaseManager dataBaseManager] execute:strDel];
        NSString * requestStr = [NSString stringWithFormat:@"insert into 'Device_Table'('user_id','ble_address','device_name','latitude','longitude','tracker_device_alert','marked_lost','is_active','contact_name','contact_email','contact_mobile','photo_localURL','photo_serverURL','identifier','created_time','updated_time','correction_status','server_id') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'%@','%@','%@',\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,strBle,strDeviceName,strLat,strLong,@"1",@"0",@"1",strName,strEmail,strMob,@"NA",strServerUrl,@"NA",strCreated,strUpdatedTime,strLastConnectionStatus,strDeviceID];
      int localIntId =  [[DataBaseManager dataBaseManager] executeSw:requestStr];
        NSString * strLocalId = [NSString stringWithFormat:@"%d",localIntId];
        [dictObtained setObject:strDeviceID forKey:@"server_id"];
        [dictObtained setObject:strLocalId forKey:@"id"];

        if ([arrayDevice count]==0)
        {
            arrayDevice = [[NSMutableArray alloc] init];
            [arrayDevice addObject:dictObtained];
        }
        else
        {
            [arrayDevice addObject:dictObtained];
        }
    }
}
#pragma mark - Device View Setup
-(void)fetchDeviceTableInfo
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (arrayDevice.count == 0)
                       {
                           if (isUserLoggedAndDontEndHudProcess == false)
                           {
                               [APP_DELEGATE endHudProcess];
                           }
                           //        [lblDevice setText:@"No Devices yet"];
                           self->deviceView.hidden = YES;
                           self->imgGps.hidden = YES;
                           self->btnRoute.hidden = YES;
                           [self->mapView removeAnnotation:self->annotationPin];
                           
                           selectedDeviecDict = [[NSMutableDictionary alloc] init];
                           
                           CLLocation *locationCord =  [[CLLocation alloc] initWithLatitude:currentLatitude longitude:currentLongitude];
                           MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
                           ([locationCord coordinate], 1000, 1000);
                           [self->mapView setRegion:region animated:YES];
                           
                           CLLocationCoordinate2D currentLoc = CLLocationCoordinate2DMake(currentLatitude,currentLongitude);
                           [self->mapView removeAnnotation:self->annotation1];
                           self->annotation1 = [[MKPointAnnotation alloc] init];
                           self->annotation1.coordinate = currentLoc;
                           self->annotation1.title = @"Your current Location";
                           [self->mapView addAnnotation:self->annotation1];
                       }
                       else
                       {
//                           [APP_DELEGATE endHudProcess];
                           
                           self->deviceView.hidden = NO;
                           self->imgGps.hidden = NO;
                           self->btnRoute.hidden = NO;
                           [self->mapView removeAnnotation:self->annotation1];
                           
                           if (self->selectedIndex < arrayDevice.count)
                           {
                               self->strLocalID = [[arrayDevice objectAtIndex:self->selectedIndex]valueForKey:@"id"];
                               self->strServerID = [[arrayDevice objectAtIndex:self->selectedIndex]valueForKey:@"server_id"];
                               self->deviceView.hidden = NO;
                               self->imgGps.hidden = NO;
                               self->btnRoute.hidden = NO;
                               
                               selectedDeviecDict = [[NSMutableDictionary alloc]init];
                               selectedDeviecDict = [arrayDevice objectAtIndex:self->selectedIndex];
                               [self SetupforCurrentDevice];
                           }
                       }
                       [self->tblMoreDevices reloadData];
                       if(arrayDevice.count == 0)
                       {
                           [self->mapView removeAnnotation:self->annotationPin];
                           CLLocationCoordinate2D currentLoc = CLLocationCoordinate2DMake(currentLatitude,currentLongitude);
                           [self->mapView removeAnnotation:self->annotation1];
                           self->annotation1 = [[MKPointAnnotation alloc] init];
                           self->annotation1.coordinate = currentLoc;
                           self->annotation1.title = @"Your current Location";
                           [self->mapView addAnnotation:self->annotation1];
                       }

                   });
}
-(void)SetupforCurrentDevice
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (![[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"updated_time"]] isEqualToString:@"NA"])
                       {
                           self->lblLastseen.text = [NSString stringWithFormat:@"Last seen : %@",[APP_DELEGATE changeDateFormat:[selectedDeviecDict valueForKey:@"updated_time"]]];
                       }
                   });
    lblDevice.text = [selectedDeviecDict valueForKey:@"device_name"];
    imgDevice.layer.borderWidth = 1;
    
    double dlat = currentLatitude;
    double dlong = currentLongitude;
    if (![[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"latitude"]] isEqualToString:@"NA"])
    {
        if ([[selectedDeviecDict valueForKey:@"latitude"] doubleValue] != 0)
        {
            dlat = [[selectedDeviecDict valueForKey:@"latitude"] doubleValue];
            dlong = [[selectedDeviecDict valueForKey:@"longitude"] doubleValue];
        }
    }
    [self SetDeviceAnnotationwithLat:dlat longitudes:dlong];
    [self setDevicePhotowithUrl];
    
    if ([[selectedDeviecDict valueForKey:@"identifier"]isEqualToString:[NSString stringWithFormat:@"%@",globalPeripheral.identifier]])
    {
        currentPeripheral = globalPeripheral;
    }
    else
    {
        NSInteger foundIndex = [arrGlobalDevices indexOfObject:[selectedDeviecDict valueForKey:@"peripheral"]];
        if (foundIndex != NSNotFound)
        {
            if (foundIndex < [arrGlobalDevices count])
            {
                CBPeripheral * p = [arrGlobalDevices objectAtIndex:foundIndex];
                if(p.state == CBPeripheralStateConnected)
                {
                    [selectedDeviecDict setObject:@"1" forKey:@"correction_status"];
                    self->imgDevice.layer.borderColor = [UIColor greenColor].CGColor;
                    self->lblLastseen.hidden = true;
                    batteryView.hidden = NO;
                }
                else
                {
                    [[BLEManager sharedManager] connectDevice:p];
                }
            }
        }
    }
    CBPeripheral * sp = [selectedDeviecDict valueForKey:@"peripheral"];
    if (sp.state == CBPeripheralStateConnected)
    {
        imgDevice.layer.borderColor = [UIColor greenColor].CGColor;
        batteryView.hidden = NO;
        lblLastseen.hidden = true;
        lblBatteries.hidden = NO;

        NSLog(@"---------->>>>from setupforCurrentdevice");

        [[BLEService sharedInstance] SendCommandWithPeripheral:sp withValue:@"13"];
        [[BLEService sharedInstance] SendCommandWithPeripheral:sp withValue:@"15"];

        lblDevice.frame = CGRectMake(60,12,deviceView.frame.size.width-107,55);
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            lblDevice.frame = CGRectMake(60,5,deviceView.frame.size.width-107,55);
        }
    }
    else
    {
        lblLastseen.hidden = false;
        imgDevice.layer.borderColor = [UIColor redColor].CGColor;
        batteryView.hidden = YES;
        lblBatteries.hidden = YES;
        lblDevice.frame = CGRectMake(60,7,deviceView.frame.size.width-107,55);
        if (IS_IPHONE_4 || IS_IPHONE_5)
        {
            lblDevice.frame = CGRectMake(60,0,deviceView.frame.size.width-107,55);
        }
    }
}
-(void)setDevicePhotowithUrl
{
    imgDevice.image = [UIImage imageNamed:@"logoDisplay"];

    if (![[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"photo_localURL"]] isEqualToString:@"NA"])
    {
        NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"TrackerDeviceName/%@",[selectedDeviecDict valueForKey:@"photo_localURL"]]];
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage * mainImage = [UIImage imageWithData:pngData];
        UIImage * image = [self scaleMyImage:mainImage];
        imgDevice.image = image;
        annotationPin.img = @"NA";
    }
    else if(![[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"photo_serverURL"]] isEqualToString:@"NA"])
    {
        NSURL * tmpURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[selectedDeviecDict valueForKey:@"photo_serverURL"]]];
        imgDevice.imageURL = tmpURL;
        annotationPin.deviceImg = imgDevice.image;
        annotationPin.img = [selectedDeviecDict valueForKey:@"photo_serverURL"];
        if (![APP_DELEGATE isNetworkreachable])
        {
        }
    }
    else
    {
        imgDevice.image = [UIImage imageNamed:@"logoDisplay.png"];
        annotationPin.deviceImg = imgDevice.image;
    }

}
-(void)timeoutConnection
{
    [APP_DELEGATE endHudProcess];
    [connectionTimeout invalidate];
    connectionTimeout = nil;
}
#pragma mark - Map Methods
-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        MKPinAnnotationView *pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: @"pin"];
        pin.image = [UIImage imageNamed:@"UserPin.png"];
        return nil;
    }
    else if ([annotation isKindOfClass:[CustomAnnotation class]])
    {
        static NSString * const identifier = @"CustomAnnotation";
        custannotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        if (custannotationView)
        {
            custannotationView.annotation = annotation;
        }
        else
        {
            custannotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        custannotationView.canShowCallout = NO;
        custannotationView.image = [UIImage imageNamed:@"mappin_green_icon.png"];
        custannotationView.title = [selectedDeviecDict valueForKey:@"device_name"];
        custannotationView.deviceImg = [UIImage imageNamed:@"logoDisplay.png"];;
        if (![[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"photo_localURL"]] isEqualToString:@"NA"])
        {
            NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"TrackerDeviceName/%@",[selectedDeviecDict valueForKey:@"photo_localURL"]]];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            UIImage * mainImage = [UIImage imageWithData:pngData];
            UIImage * image = [self scaleMyImage:mainImage];
            custannotationView.deviceImg = image;
            custannotationView.img = @"NA";
        }
        else if(![[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"photo_serverURL"]] isEqualToString:@"NA"])
        {
            NSURL * tmpURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[selectedDeviecDict valueForKey:@"photo_serverURL"]]];
            imgDevice.imageURL = tmpURL;
            custannotationView.deviceImg = imgDevice.image;
            custannotationView.img = [selectedDeviecDict valueForKey:@"photo_serverURL"];
        }
        else
        {
            custannotationView.deviceImg = [UIImage imageNamed:@"logoDisplay.png"];;
        }
        if ([[selectedDeviecDict valueForKey:@"device_name"] isEqualToString:@"KP device"])
        {
            custannotationView.deviceImg = [UIImage imageNamed:@"face.jpg"];;
        }
        return custannotationView;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor colorWithRed:0.0/255.0 green:171.0/255.0 blue:253.0/255.0 alpha:1.0];
    renderer.lineWidth = 10.0;
    return  renderer;
}
// When a map annotation point is added, zoom to it (1500 range)
-(void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    if([views count]>0)
    {
        MKAnnotationView *annotationView = [views objectAtIndex:0];
        if (annotationView)
        {
            id <MKAnnotation> mp = [annotationView annotation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
            ([mp coordinate], 1000, 1000);
            if (region.center.latitude > -89 && region.center.latitude < 89 && region.center.longitude > -179 && region.center.longitude < 179 )
            {
                [mv setRegion:region animated:YES];
                [mv selectAnnotation:mp animated:YES];
            }
        }
    }
}
-(double)getAddressFromCordinates:(CLLocation *)cordinates
{
    if (selectedDeviecDict)
    {
        NSString * strAddress = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Address%@",[selectedDeviecDict valueForKey:@"ble_address"]]];
        if (![[self checkforValidString:strAddress] isEqualToString:@"NA"])
        {
            self->strAddressFromCordinatesForDevice = strAddress;
            [self->custannotationView setAddress:strAddress];
            [self->custannotationView reloadInputViews];
        }
    }
    CLLocation *locationCord =  cordinates;
//    NSLog(@"coooorrrrddddd arrrreeeeeee  %@",cordinates);
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:locationCord completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks)
        {
            if (cordinates.coordinate.latitude != 0)
            {
                NSString * strAddress;
                if ([[placemark name] length]<=37)
                {
                    strAddress = [NSString stringWithFormat:@"Near %@\n%@, %@ %@",[placemark name],[placemark subAdministrativeArea],[placemark administrativeArea],[placemark postalCode]];
                }
                else
                {
                    strAddress = [NSString stringWithFormat:@"Near %@ %@, %@ %@",[placemark name],[placemark subAdministrativeArea],[placemark administrativeArea],[placemark postalCode]];
                }

                NSLog(@"Found Address=%lu & text=%@",(unsigned long)[placemark name].length,strAddress);
                self->strAddressFromCordinatesForDevice = strAddress;
                [self->custannotationView setAddress:strAddress];
                
                if (selectedDeviecDict)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:strAddress  forKey:[NSString stringWithFormat:@"Address%@",[selectedDeviecDict valueForKey:@"ble_address"]]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                [self->custannotationView reloadInputViews];
            }
        }
        if (error != nil)
        {
            if (selectedDeviecDict)
            {
                NSString * strAddress = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Address%@",[selectedDeviecDict valueForKey:@"ble_address"]]];
                if (![[self checkforValidString:strAddress] isEqualToString:@"NA"])
                {
                    self->strAddressFromCordinatesForDevice = strAddress;
                    [self->custannotationView setAddress:strAddress];
                    [self->custannotationView reloadInputViews];
                }
            }
        }
    }];
    return 0;
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *selectedAnnotation = view.annotation; // This will give the annotation.
    if([selectedAnnotation.title  isEqual: @"My current Location"] || [selectedAnnotation.title  isEqual: @"My Location"] || [selectedAnnotation.title  isEqual: @"India"])
    {
//        [custannotationView setAddress:strAddressFromCordinatesForDevice];
    }
    else
    {
//        [custannotationView setAddress:strAddressFromCordinatesForDevice];
        CBPeripheral * p = [selectedDeviecDict objectForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            CLLocation *locationCord =  [[CLLocation alloc] initWithLatitude:currentLatitude longitude:currentLongitude];
            [self getAddressFromCordinates:locationCord];
            
            [selectedDeviecDict setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:@"latitude"];
            [selectedDeviecDict setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:@"longitude"];
        }
        
        if ([[arrayDevice valueForKey:@"ble_address"] containsObject:[selectedDeviecDict valueForKey:@"ble_address"]])
        {
            NSInteger  indexx = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:[selectedDeviecDict valueForKey:@"ble_address"]];
            {
                if (indexx != NSNotFound)
                {
                    if (indexx < [arrayDevice count])
                    {
                        CBPeripheral * p = [[arrayDevice objectAtIndex:indexx] valueForKey:@"peripheral"];
                        if (p.state == CBPeripheralStateConnected)
                        {
                            [[arrayDevice objectAtIndex:indexx]setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:@"latitude"];
                            [[arrayDevice objectAtIndex:indexx]setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:@"longitude"];
                        }
                    }
                }
            }
        }
    }
}
-(void)LocationEnabled
{
    NSLog(@"2 CHECK LATITUDE ===========>%f",currentLatitude);
//    CLLocation *locationCord =  [[CLLocation alloc] initWithLatitude:currentLatitude longitude:currentLongitude];
//    [self getAddressFromCordinates:locationCord];
}
#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotofiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotificationHome" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotificationHome" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotofiyDiscoveredDevices:) name:@"NotofiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotificationHome:) name:@"DeviceDidConnectNotificationHome" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotificationHome:) name:@"DeviceDidDisConnectNotificationHome" object:nil];
}

-(void)NotofiyDiscoveredDevices:(NSNotification*)notification//Update peripheral
{

}
-(void)DeviceDidConnectNotificationHome:(NSNotification*)notification//Connect periperal
{
    

}

-(void)DeviceDidDisConnectNotificationHome:(NSNotification*)notification//Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       CBPeripheral * sp = [selectedDeviecDict objectForKey:@"peripheral"];
                       if (sp)
                       {
                           if (sp.state == CBPeripheralStateConnected)
                           {
                               self->imgDevice.layer.borderColor = [UIColor greenColor].CGColor;
                               self->deviceView.hidden = NO;
                               self->lblLastseen.hidden = true;
                               self->lblDevice.frame = CGRectMake(60,12,self->deviceView.frame.size.width-107,55);
                               if (IS_IPHONE_4 || IS_IPHONE_5)
                               {
                                   self->lblDevice.frame = CGRectMake(60,5,self->deviceView.frame.size.width-107,55);
                               }
                           }
                           else
                           {
                               strCurrentDateNTime =  [APP_DELEGATE checkforValidString:[APP_DELEGATE getCurrentTime]];
                               [selectedDeviecDict setValue:strCurrentDateNTime forKey:@"updated_time"];
                               self->lblLastseen.text = [NSString stringWithFormat:@"Last seen : %@",[APP_DELEGATE changeDateFormat:[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"updated_time"]]]];
                               self->lblLastseen.hidden = false;
                               self->imgDevice.layer.borderColor = [UIColor redColor].CGColor;
                               self->batteryView.hidden = YES;
                               self->lblBatteries.hidden = YES;
                               self->lblDevice.frame = CGRectMake(60,7,self->deviceView.frame.size.width-107,55);
                               if (IS_IPHONE_4 || IS_IPHONE_5)
                               {
                                   self->lblDevice.frame = CGRectMake(60,0,self->deviceView.frame.size.width-107,55);
                               }
                               double dlat = currentLatitude;
                               double dlong = currentLongitude;
                               [self SetDeviceAnnotationwithLat:dlat longitudes:dlong];
                           }
                       }
                   });
}
-(void)GlobalBLuetoothCheck
{
    if (globalAlertPopUP)
    {
        [globalAlertPopUP removeFromParentViewController];
        
    }
    globalAlertPopUP = [UIAlertController alertControllerWithTitle:@"KUURV" message:@"Please turn Bluetooth ON to access all of the features." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [globalAlertPopUP addAction:defaultAction];
    [self presentViewController:globalAlertPopUP animated:true completion:nil];
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
}
-(void)FetchTrackerAlertStatus:(NSMutableDictionary *)notify
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       NSMutableDictionary * dictInfo = notify;
                       if(![[APP_DELEGATE checkforValidString:[dictInfo valueForKey:@"identifier"]] isEqualToString:@"NA"])
                       {
                           NSInteger foundIndex = [[arrayDevice valueForKey:@"identifier"] indexOfObject:[dictInfo valueForKey:@"identifier"]];
                           if (foundIndex != NSNotFound)
                           {
                               if (foundIndex < [arrayDevice count])
                               {
                                   [[arrayDevice objectAtIndex:foundIndex] setValue:[dictInfo valueForKey:@"values"] forKey:@"tracker_device_alert"];
                               }
                           }
                           if ([[selectedDeviecDict valueForKey:@"identifier"] isEqualToString:[dictInfo valueForKey:@"identifier"]])
                           {
                               [selectedDeviecDict setValue:[dictInfo valueForKey:@"values"] forKey:@"tracker_device_alert"];
                           }
                       }
                       else
                       {
                           CBPeripheral * tmpPeri = [dictInfo valueForKey:@"peripheral"];
                           if (tmpPeri != nil)
                           {
                               NSInteger foundIndex = [[arrayDevice valueForKey:@"peripheral"] indexOfObject:[dictInfo valueForKey:@"peripheral"]];
                               if (foundIndex != NSNotFound)
                               {
                                   if (foundIndex < [arrayDevice count])
                                   {
                                       [[arrayDevice objectAtIndex:foundIndex] setValue:[dictInfo valueForKey:@"values"] forKey:@"tracker_device_alert"];
                                   }
                               }
                               CBPeripheral * currentP = [selectedDeviecDict valueForKey:@"peripheral"];
                               if (currentP == tmpPeri)
                               {
                                   [selectedDeviecDict setValue:[dictInfo valueForKey:@"values"] forKey:@"tracker_device_alert"];
                               }
                           }
                       }
                       NSLog(@"Here is Updated data for Tracker Alert=%@", dictInfo);
                   });
}
-(void)FetchBatteryofDevice:(NSMutableDictionary *)dict
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       
                       NSMutableDictionary * dictInfo = dict;
                       if(![[APP_DELEGATE checkforValidString:[dictInfo valueForKey:@"identifier"]] isEqualToString:@"NA"])
                       {
                           NSInteger foundIndex = [[arrayDevice valueForKey:@"identifier"] indexOfObject:[dictInfo valueForKey:@"identifier"]];
                           if (foundIndex != NSNotFound)
                           {
                               if (foundIndex < [arrayDevice count])
                               {
                                   [[arrayDevice objectAtIndex:foundIndex] setValue:[dictInfo valueForKey:@"battery"] forKey:@"battery"];
                                   if ([[dictInfo valueForKey:@"battery"] doubleValue] < 40)
                                   {
                                       NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate new] timeIntervalSince1970]];
                                       double current = [timestamp doubleValue];
                                       NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:current] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults]doubleForKey:@"current_time"]]];
                                       
                                       [[NSUserDefaults standardUserDefaults] setDouble:current forKey:@"current_time"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       NSLog(@"difference: %f", difference);

                                       if (difference >= 3600)
                                       {
                                           [self showBatteryLowPopup:[arrayDevice objectAtIndex:foundIndex]];
                                       }
                                   }

                               }
                           }
                           if ([[selectedDeviecDict valueForKey:@"identifier"] isEqualToString:[dictInfo valueForKey:@"identifier"]])
                           {
                               self->batteryView.hidden = NO;
                               [self->batteryView setBatteryLevelWithAnimation:NO forValue:[[dictInfo valueForKey:@"battery"] floatValue] inPercent:YES];
                               self->lblBatteries.hidden = NO;
                               self->lblBatteries.text = [NSString stringWithFormat:@"%.0f%%",[[dictInfo valueForKey:@"battery"] floatValue]];
                               self->lblDevice.frame = CGRectMake(60,12,self->deviceView.frame.size.width-107,55);
                               if (IS_IPHONE_4 || IS_IPHONE_5)
                               {
                                   self->lblDevice.frame = CGRectMake(60,5,self->deviceView.frame.size.width-107,55);
                               }
                           }
                       }
                       else
                       {
                           CBPeripheral * tmpPeri = [dictInfo valueForKey:@"peripheral"];
                           if (tmpPeri != nil)
                           {
                               NSInteger foundIndex = [[arrayDevice valueForKey:@"peripheral"] indexOfObject:[dictInfo valueForKey:@"peripheral"]];
                               if (foundIndex != NSNotFound)
                               {
                                   if (foundIndex < [arrayDevice count])
                                   {
                                       [[arrayDevice objectAtIndex:foundIndex] setValue:[dictInfo valueForKey:@"battery"] forKey:@"battery"];
                                       if ([[dictInfo valueForKey:@"battery"] doubleValue] < 40)
                                       {
                                           NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate new] timeIntervalSince1970]];
                                           double current = [timestamp doubleValue];
                                           NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:current] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults]doubleForKey:@"current_time"]]];
                                           
                                           [[NSUserDefaults standardUserDefaults] setDouble:current forKey:@"current_time"];
                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                           NSLog(@"difference: %f", difference);
                                           
                                           if (difference >= 3600)
                                           {
                                               [self showBatteryLowPopup:[arrayDevice objectAtIndex:foundIndex]];
                                           }
                                       }
                                   }
                               }
                               CBPeripheral * currentP = [selectedDeviecDict valueForKey:@"peripheral"];
                               if (currentP == tmpPeri)
                               {
                                   self->batteryView.hidden = NO;
                                   [self->batteryView setBatteryLevelWithAnimation:NO forValue:[[dictInfo valueForKey:@"battery"] floatValue] inPercent:YES];
                                   self->lblBatteries.hidden = NO;
                                   self->lblBatteries.text = [NSString stringWithFormat:@"%.0f%%",[[dictInfo valueForKey:@"battery"] floatValue]];
                                   self->lblDevice.frame = CGRectMake(60,12,self->deviceView.frame.size.width-107,55);
                                   if (IS_IPHONE_4 || IS_IPHONE_5)
                                   {
                                       self->lblDevice.frame = CGRectMake(60,5,self->deviceView.frame.size.width-107,55);
                                   }
                               }
                           }
                       }
                   });
}
-(void)FetchBuzzerVolume:(NSMutableDictionary *)notify
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       NSMutableDictionary * dictInfo = notify;
                       if(![[APP_DELEGATE checkforValidString:[dictInfo valueForKey:@"identifier"]] isEqualToString:@"NA"])
                       {
                           NSInteger foundIndex = [[arrayDevice valueForKey:@"identifier"] indexOfObject:[dictInfo valueForKey:@"identifier"]];
                           if (foundIndex != NSNotFound)
                           {
                               if (foundIndex < [arrayDevice count])
                               {
                                   [[arrayDevice objectAtIndex:foundIndex] setValue:[dictInfo valueForKey:@"values"] forKey:@"volume"];
                               }
                           }
                           if ([[selectedDeviecDict valueForKey:@"identifier"] isEqualToString:[dictInfo valueForKey:@"identifier"]])
                           {
                               [selectedDeviecDict setValue:[dictInfo valueForKey:@"values"] forKey:@"volume"];
                           }
                       }
                       else
                       {
                           CBPeripheral * tmpPeri = [dictInfo valueForKey:@"peripheral"];
                           if (tmpPeri != nil)
                           {
                               NSInteger foundIndex = [[arrayDevice valueForKey:@"peripheral"] indexOfObject:[dictInfo valueForKey:@"peripheral"]];
                               if (foundIndex != NSNotFound)
                               {
                                   if (foundIndex < [arrayDevice count])
                                   {
                                       [[arrayDevice objectAtIndex:foundIndex] setValue:[dictInfo valueForKey:@"values"] forKey:@"volume"];
                                   }
                               }
                               CBPeripheral * currentP = [selectedDeviecDict valueForKey:@"peripheral"];
                               if (currentP == tmpPeri)
                               {
                                   [selectedDeviecDict setValue:[dictInfo valueForKey:@"values"] forKey:@"volume"];
                               }
                           }
                       }
                       NSLog(@"Here is Updated data for Tracker Alert=%@", dictInfo);
                   });
}

-(void)showBatteryLowPopup:(NSMutableDictionary *)dict
{
    NSString * strMsg = [NSString stringWithFormat:@"%@'s battery is low.",[dict valueForKey:@"device_name"]];
    
    [batteryAlert  removeFromSuperview];
    batteryAlert = [[FCAlertView alloc] init];
    batteryAlert.colorScheme = [UIColor blackColor];
    [batteryAlert makeAlertTypeDanger];
    [batteryAlert showAlertInView:self
                 withTitle:@"KUURV"
              withSubtitle:strMsg
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];

}
-(void)deleteDevice:(NSMutableDictionary *)notify
{
    
}
-(void)DeviceStatustoHome:(NSMutableDictionary *)notify
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"] == NO)
                       {
                           return;
                       }
                       if (self->connectionTimeout)
                       {
                           [APP_DELEGATE endHudProcess];
                       }
                       NSMutableDictionary * dict = notify;
                       CBPeripheral * livePeripheral = [dict objectForKey:@"peripheral"];
                       BOOL isCurrentDeviceConneteced = NO;
                       if ([[selectedDeviecDict valueForKey:@"identifier"] isEqualToString:[NSString stringWithFormat:@"%@",livePeripheral.identifier]])
                       {
                           isCurrentDeviceConneteced = YES;
                           self->currentPeripheral = livePeripheral;
                           globalPeripheral = self->currentPeripheral;
                       }
                       else if ([selectedDeviecDict objectForKey:@"peripheral"])
                       {
                           CBPeripheral * selectPeri = [selectedDeviecDict objectForKey:@"peripheral"];
                           if (selectPeri == livePeripheral)
                           {
                               isCurrentDeviceConneteced = YES;
                               self->currentPeripheral = livePeripheral;
                               globalPeripheral = self->currentPeripheral;
                           }
                       }
                       if (isCurrentDeviceConneteced)
                       {
                           [selectedDeviecDict setObject:globalPeripheral forKey:@"peripheral"];
                           [self SetDeviceAnnotationwithLat:currentLatitude longitudes:currentLongitude];
                           self->lblLastseen.text = [NSString stringWithFormat:@"Last seen : %@",[APP_DELEGATE changeDateFormat:[selectedDeviecDict valueForKey:@"updated_time"]]];
                           if (livePeripheral.state == CBPeripheralStateConnected)
                           {
                               self->imgDevice.layer.borderColor = [UIColor greenColor].CGColor;
                               self->lblLastseen.hidden = true;
                           }
                           else
                           {
                               self->imgDevice.layer.borderColor = [UIColor redColor].CGColor;
                               self->lblLastseen.hidden = false;
                           }
                           if (![arrGlobalDevices containsObject:livePeripheral])
                           {
                               [arrGlobalDevices addObject:livePeripheral];
                           }
                       }
                       CBPeripheral * pd = self->currentPeripheral;
                       if (pd)
                       {
                           NSLog(@"---------->>>>from Device StatusHome");
                           [[BLEService sharedInstance] SendCommandWithPeripheral:pd withValue:@"13"];
                           [[BLEService sharedInstance] SendCommandWithPeripheral:pd withValue:@"15"];
                       }
                   });
}
-(void)SetDeviceAnnotationwithLat:(double)dlat longitudes:(double)dlong
{
    CLLocationCoordinate2D pinlocation = CLLocationCoordinate2DMake(dlat,dlong);;
    MKPlacemark *mPlacemark = [[MKPlacemark alloc] initWithCoordinate:pinlocation addressDictionary:nil];
    [self->mapView removeAnnotation:self->annotationPin];
    self->annotationPin = [[CustomAnnotation alloc] initWithPlacemark:mPlacemark];
    self->annotationPin.title = [selectedDeviecDict valueForKey:@"device_name"];
    self->annotationPin.subtitle1 = @"sub titile" ;
    self->annotationPin.deviceImg = [UIImage imageNamed:@"logo.png"];;
    self->annotationPin.isfromAdd = @"NO";
    [self->mapView addAnnotation:self->annotationPin];
    
    CLLocation *locationCord = [[CLLocation alloc] initWithLatitude:dlat longitude:dlong];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
    ([locationCord coordinate], 1000, 1000);
    [mapView setRegion:region animated:YES];

    if (dlat != 0)
    {
        CLLocation *locationCord =  [[CLLocation alloc] initWithLatitude:dlat longitude:dlong];
        [self getAddressFromCordinates:locationCord];
        
        [selectedDeviecDict setValue:[NSString stringWithFormat:@"%f",dlat] forKey:@"latitude"];
        [selectedDeviecDict setValue:[NSString stringWithFormat:@"%f",dlong] forKey:@"longitude"];
    }
}
-(void)CheckConnectedDevices
{
    if (centralManager.state == CBCentralManagerStatePoweredOff ||centralManager.state == 4)
    {
        if (lblLastseen.hidden == true)
        {
            lblLastseen.hidden = false;
            imgDevice.layer.borderColor = [UIColor redColor].CGColor;
            batteryView.hidden = YES;
            lblBatteries.hidden = YES;

            lblDevice.frame = CGRectMake(60,7,deviceView.frame.size.width-107,55);
            if (IS_IPHONE_4 || IS_IPHONE_5)
            {
                lblDevice.frame = CGRectMake(60,0,deviceView.frame.size.width-107,55);
            }
            strCurrentDateNTime =  [APP_DELEGATE checkforValidString:[APP_DELEGATE getCurrentTime]];
            [lblLastseen setText: [NSString stringWithFormat:@"Last seen : %@",[APP_DELEGATE changeDateFormat:strCurrentDateNTime]]];

            [selectedDeviecDict setValue:strCurrentDateNTime forKey:@"updated_time"];
            [selectedDeviecDict setValue:@"0" forKey:@"correction_status"];
            [selectedDeviecDict setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:@"latitude"];
            [selectedDeviecDict setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:@"longitude"];

            NSArray * foundDev = [[BLEManager sharedManager] foundDevices];
            NSLog(@"last connected arr is %@",foundDev);
            for(int i = 0;i<foundDev.count;i++)
            {
                if ([[arrayDevice valueForKey:@"ble_address"] containsObject:[[foundDev objectAtIndex:i]valueForKey:@"ble_address"]])
                {
                    NSInteger  indexx = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:[[foundDev objectAtIndex:i]valueForKey:@"ble_address"]];
                    {
                        if (indexx != NSNotFound)
                        {
                            if (indexx < [arrayDevice count])
                            {
                                [[arrayDevice objectAtIndex:indexx]setValue:strCurrentDateNTime forKey:@"updated_time"];
                                [[arrayDevice objectAtIndex:indexx]setValue:@"0" forKey:@"correction_status"];
                                [[arrayDevice objectAtIndex:indexx]setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:@"latitude"];
                                [[arrayDevice objectAtIndex:indexx]setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:@"longitude"];
                            }
                        }
                    }
                }
            }
        }
    }
    NSMutableArray * arrCnt = [[NSMutableArray alloc] init];
    arrCnt = [[BLEManager sharedManager] foundDevices];
    for (int i=0; i<[arrCnt count]; i++)
    {
        CBPeripheral * tmpPerphrl = [[arrCnt objectAtIndex:i] objectForKey:@"peripheral"];
        if ([[arrayDevice valueForKey:@"ble_address"] containsObject:[[arrCnt objectAtIndex:i] valueForKey:@"ble_address"]])
        {
            NSInteger idxAddress = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:[[arrCnt objectAtIndex:i] valueForKey:@"ble_address"]];
            if (idxAddress != NSNotFound)
            {
                if (idxAddress < [arrayDevice count])
                {
                    [[arrayDevice objectAtIndex:idxAddress]setObject:tmpPerphrl forKey:@"peripheral"];
                    [[arrayDevice objectAtIndex:idxAddress]setValue:[NSString stringWithFormat:@"%@",tmpPerphrl.identifier] forKey:@"identifier"];
                    if ([[selectedDeviecDict valueForKey:@"ble_address"]isEqualToString:[[arrayDevice objectAtIndex:idxAddress] valueForKey:@"ble_address"]])
                    {
                        [selectedDeviecDict setObject:tmpPerphrl forKey:@"peripheral"];
                        [selectedDeviecDict setValue:[NSString stringWithFormat:@"%@",tmpPerphrl.identifier] forKey:@"identifier"];
                    }
                    if (tmpPerphrl.state == CBPeripheralStateConnected)
                    {
                    }
                    else
                    {
                        [[BLEManager sharedManager] connectDevice:tmpPerphrl];
                    }
                }
            }
        }
    }
}
-(void)CheckBatteryforConnectedDevice
{
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        // Example:
      
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            //Method call finish here
//        });
//    });
    BOOL isNewlocation = NO;
          NSString * strLat = [NSString stringWithFormat:@"%f", currentLocations.coordinate.latitude];
          NSString * strLong = [NSString stringWithFormat:@"%f", currentLocations.coordinate.longitude];
          NSString * strCurrentTime = [self checkforValidString:[self getCurrentTime]];
          NSString * strConnectionStatus = @"1";

          if (currentLocations != lastLocations)
          {
              isNewlocation = YES;
              lastLocations = currentLocations;
              if (arrayDevice.count>0)
              {
                  CBPeripheral * p = [selectedDeviecDict objectForKey:@"peripheral"];
                  if (p.state == CBPeripheralStateConnected)
                  {
                      [selectedDeviecDict setObject:strLat forKey:@"latitude"];
                      [selectedDeviecDict setObject:strLong forKey:@"longitude"];
                      [self SetDeviceAnnotationwithLat:currentLocations.coordinate.latitude longitudes:currentLocations.coordinate.longitude];

                      NSString * strBleAddress = [self checkforValidString:[selectedDeviecDict valueForKey:@"ble_address"]];

                      [[NSUserDefaults standardUserDefaults] setValue:strLat forKey:[NSString stringWithFormat:@"lat_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] setValue:strLong forKey:[NSString stringWithFormat:@"long_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] setValue:strConnectionStatus forKey:[NSString stringWithFormat:@"status_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] setValue:strCurrentTime forKey:[NSString stringWithFormat:@"time_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] synchronize];

                  }
              }
          }
          for (int i=0; i<[arrayDevice count]; i++)
          {
              CBPeripheral * p = [[arrayDevice objectAtIndex:i] objectForKey:@"peripheral"];
              NSString * strBleAddress = [[arrayDevice objectAtIndex:i] objectForKey:@"ble_address"];
              if (p.state == CBPeripheralStateConnected)
              {
                  [[BLEService sharedInstance] SendCommandWithPeripheral:p withValue:@"13"];
                  if (isNewlocation)
                  {
                      [[arrayDevice objectAtIndex:i] setObject:strLat forKey:@"latitude"];
                      [[arrayDevice objectAtIndex:i] setObject:strLong forKey:@"longitude"];
                      [[NSUserDefaults standardUserDefaults] setValue:strLat forKey:[NSString stringWithFormat:@"lat_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] setValue:strLong forKey:[NSString stringWithFormat:@"long_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] setValue:strConnectionStatus forKey:[NSString stringWithFormat:@"status_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] setValue:strCurrentTime forKey:[NSString stringWithFormat:@"time_%@",strBleAddress]];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                  }
              }
          }
    
    [self performSelector:@selector(UpdateConnectedDeviceLocation) withObject:nil afterDelay:60];
}
-(void)UpdateConnectedDeviceLocation
{
    updateCount = 0;
    if (updateCount < [arrayDevice count])
    {
        [self SendLocationDetailtoserver:[arrayDevice objectAtIndex:updateCount]];
    }
}
-(void)SendLocationDetailtoserver:(NSMutableDictionary *)tmpDict
{
    updateCount = updateCount + 1;

    CBPeripheral * p = [tmpDict objectForKey:@"peripheral"];
    if (p.state == CBPeripheralStateConnected)
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                {
                    NSString * strBleAddress = [tmpDict valueForKey:@"ble_address"];
                    NSString * strCurrentTime = [self checkforValidString:[self getCurrentTime]];
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:@"latitude"];
                    [dict setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:@"longitude"];
                    [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
                    [dict setValue:[tmpDict valueForKey:@"ble_address"] forKey:@"ble_address"];
                    [dict setValue:@"2" forKey:@"device_type"];
                    [dict setValue:[tmpDict valueForKey:@"tracker_device_alert"] forKey:@"tracker_device_alert"];
                    [dict setValue:[tmpDict valueForKey:@"marked_lost"] forKey:@"marked_lost"];
                    [dict setValue:@"1" forKey:@"is_active"];
                    [dict setValue:[tmpDict valueForKey:@"contact_name"] forKey:@"contact_name"];
                    [dict setValue:[tmpDict valueForKey:@"contact_email"] forKey:@"contact_email"];
                    [dict setValue:[tmpDict valueForKey:@"contact_mobile"] forKey:@"contact_mobile"];
                    [dict setValue:[tmpDict valueForKey:@"device_name"] forKey:@"device_name"];
                    [dict setValue:@"1" forKey:@"correction_status"];
                    [dict setValue:[tmpDict valueForKey:@"server_id"] forKey:@"device_id"];
                    [dict setValue:[tmpDict valueForKey:@"server_id"] forKey:@"device_id"];
                    if ([[self checkforValidString:[tmpDict valueForKey:@"marked_lost"]]isEqualToString:@"NA"])
                    {
                        [dict setValue:@"0" forKey:@"marked_lost"];
                    }
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:[NSString stringWithFormat:@"lat_%@",strBleAddress]];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:[NSString stringWithFormat:@"long_%@",strBleAddress]];
                    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:[NSString stringWithFormat:@"status_%@",strBleAddress]];
                    [[NSUserDefaults standardUserDefaults] setValue:strCurrentTime forKey:[NSString stringWithFormat:@"time_%@",strBleAddress]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                    //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
                    NSString *token=[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ACCESS_TOKEN"];
                    [manager1.requestSerializer setValue:token forHTTPHeaderField:@"token"];
                    [manager1.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];//or content type
                    //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    AFHTTPRequestOperation *op = [manager1 POST:@"http://kuurvtrackerapp.com/mobile/adddevice" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                  {
                                                      NSLog(@"Response=%@",responseObject);
                                                      NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                                                      dictID = [responseObject mutableCopy];
                                                      if ([dictID valueForKey:@"data"] == [NSNull null] || [dictID valueForKey:@"data"] == nil)
                                                      {
                                                          if (self->updateCount < [arrayDevice count])
                                                          {
                                                              [self SendLocationDetailtoserver:[arrayDevice objectAtIndex:self->updateCount]];
                                                          }
                                                      }
                                                  }
                                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            if (error)
                                                            {
                                                            }
                                                        }];
                    [op start];
                }
                // Perform async operation
                // Call your method/function here
                // Example:
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //Method call finish here
                });
            });
        }
    }
}
#pragma mark - UI touch event
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self ShowPicker:false andView:tblViewMore];
    [self hideDeviceView];
}
-(UIImage *)scaleMyImage:(UIImage *)newImg
{
    UIGraphicsBeginImageContext(CGSizeMake(newImg.size.width/2,newImg.size.height/2));
    [newImg drawInRect: CGRectMake(0, 0, newImg.size.width/2, newImg.size.height/2)];
    UIImage        *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return smallImage;
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        animations:^{
                            
                            if (myView == self->tblViewMore)
                            {
                                self->tblViewMore.frame = CGRectMake(10,DEVICE_HEIGHT-195, DEVICE_WIDTH-20, 195);
                                self->viewMore.frame = CGRectMake(0,DEVICE_HEIGHT-195, DEVICE_WIDTH-0, 195);
                            }
                            else if (myView == self->ViewPicker)
                            {
                                self->ViewPicker.frame = CGRectMake(20,(DEVICE_HEIGHT/2)-125, DEVICE_WIDTH-20, 350);
                            }
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            [self->tblViewMore removeFromSuperview];
                            [self->viewMore removeFromSuperview];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
-(void)hideDeviceView
{
    isDeviceListOpen = false;
    [UIView transitionWithView:viewDeviceExpandable
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self->viewDeviceExpandable.hidden = true;
                    }
                    completion:NULL];
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 111)
    {
        [APP_DELEGATE logoutAndClearDB];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}
-(void)LogoutCalled
{
    [updateConnectedDeviceTimer invalidate];
    updateConnectedDeviceTimer = nil;
    
    [batteryCheckTimer invalidate];
    batteryCheckTimer = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@"(null)"])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return strValid;
}
-(NSString *)getCurrentTime
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    [DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString * currentDateAndTime = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    return currentDateAndTime;
}
@end

  /*Extra Code
   
   //Code to make mark as lost from Didslecterowatindexpath
   else if (indexPath.row == 1)
   {
   if (arrayDevice.count == 0)
   {
   FCAlertView *alert = [[FCAlertView alloc] init];
   alert.colorScheme = [UIColor blackColor];
   [alert makeAlertTypeCaution];
   [alert showAlertInView:self
   withTitle:@"KUURV"
   withSubtitle:@"Choose device to mark it as lost."
   withCustomImage:[UIImage imageNamed:@"logo.png"]
   withDoneButtonTitle:nil
   andButtons:nil];
   }
   else
   {
   NSString * strMsg;
   NSString * strLost;
   if ([[selectedDeviecDict valueForKey:@"marked_lost"]isEqualToString:@"1"] || [[selectedDeviecDict valueForKey:@"marked_lost"]isEqualToString:@"YES"])
   {
   strMsg = @"Are you sure that you want to remove this device from marked as lost?";
   strLost = @"0";
   }
   else
   {
   strMsg = @"Are you sure that you want to mark this device as lost?";
   strLost = @"1";
   }
   FCAlertView *alert = [[FCAlertView alloc] init];
   alert.colorScheme = [UIColor blackColor];
   [alert makeAlertTypeWarning];
   [alert addButton:@"Yes" withActionBlock:
   ^{
   if ([APP_DELEGATE isNetworkreachable])
   {
   [APP_DELEGATE endHudProcess];
   [APP_DELEGATE startHudProcess:@"Updating Device info...."];
   NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
   [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
   [dict setValue:[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"server_id"]] forKey:@"device_id"];
   [dict setValue:strLost forKey:@"marked_lost"];
   
   
   URLManager *manager = [[URLManager alloc] init];
   manager.commandName = @"markaslost";
   manager.delegate = self;
   NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/markaslost";
   [manager urlCall:strServerUrl withParameters:dict];
   NSLog(@"sent info for marked as lost is %@",dict);
   }
   else
   {
   FCAlertView *alert = [[FCAlertView alloc] init];
   alert.colorScheme = [UIColor blackColor];
   [alert makeAlertTypeCaution];
   [alert showAlertInView:self
   withTitle:@@"KUURV"
   withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
   withCustomImage:[UIImage imageNamed:@"logo.png"]
   withDoneButtonTitle:nil
   andButtons:nil];
   }
   }];
   alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
   [alert showAlertInView:self
   withTitle:@"KUURV"
   withSubtitle:strMsg
   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
   withDoneButtonTitle:@"No" andButtons:nil];
   }
   }
   Near 336D, Vijay Nagar Road, Mahadeshwara Layout
   */
    
