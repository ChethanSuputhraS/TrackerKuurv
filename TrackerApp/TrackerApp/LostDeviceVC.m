//
//  LostDeviceVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 29/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "LostDeviceVC.h"
#import "LostDeviceCell.h"
#import "AddDeviceCell.h"
#import "BLEManager.h"
#import "MNMPullToRefreshManager.h"
#import <MessageUI/MessageUI.h>

@interface LostDeviceVC ()<MNMPullToRefreshManagerClient,MFMailComposeViewControllerDelegate>
{
    MNMPullToRefreshManager * topPullToRefreshManager;
    NSMutableDictionary * dictOwner;
}
@end

@implementation LostDeviceVC

- (void)viewDidLoad
{
    isAddDeviceScreen = YES;
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    dictOwner = [[NSMutableDictionary alloc] init];

    [topPullToRefreshManager setPullToRefreshViewVisible:NO];

    arrDevice = [[NSMutableArray alloc]initWithObjects:@"Tracker 1",@"Tracker 2",@"Tracker 3", nil];
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    if (@available(iOS 10.0, *)) {
        if (centralManager.state == CBCentralManagerStatePoweredOn ||centralManager.state == CBCentralManagerStateUnknown ||centralManager.state == CBManagerStateUnknown || centralManager.state == 5 || centralManager.state == 0)
        {
            
        }
        else
        {
            [self GlobalBLuetoothCheck];
        }
    }
    else
    {
        if (centralManager.state == CBCentralManagerStatePoweredOff)
        {
            [self GlobalBLuetoothCheck];
        }
    }
    
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [self InitialBLE];
    
    [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AuthenticationCompleted:) name:@"AuthenticationCompleted" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedNamefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedNamefromDevice:) name:@"FetchedNamefromDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail1fromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedEmail1fromDevice:) name:@"FetchedEmail1fromDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail2fromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedEmail2fromDevice:) name:@"FetchedEmail2fromDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedMobilefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedMobilefromDevice:) name:@"FetchedMobilefromDevice" object:nil];
    [super viewDidAppear:YES];
    
    [self refreshBtnClick];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotofiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedNamefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedMobilefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail1fromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail2fromDevice" object:nil];
    
    [connectionTimer invalidate];
    connectionTimer = nil;
    
    [super viewDidDisappear:YES];
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
    
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Found Lost Device"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGBold size:txtSize+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, yy)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    
    UIImageView * imgRefresh = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-30, 20+8, 20, 28)];
    [imgRefresh setImage:[UIImage imageNamed:@"reload.png"]];
    [imgRefresh setContentMode:UIViewContentModeScaleAspectFit];
    imgRefresh.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:imgRefresh];
    
    UIButton * btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRefresh setFrame:CGRectMake(DEVICE_WIDTH-80, 0, 80, yy)];
    [btnRefresh addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnRefresh];
    if (IS_IPHONE_X)
    {
        [btnMenu setFrame:CGRectMake(0, 0, 88, 84)];
        imgMenu.frame = CGRectMake(10,40+7, 33, 30);
        viewHeader.frame = CGRectMake(0,0, DEVICE_WIDTH, 84);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        imgRefresh.frame = CGRectMake(DEVICE_WIDTH-30, 40+8, 20, 28);

    }
}
-(void)setContentViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    tblContent =[[UITableView alloc]initWithFrame:CGRectMake(0, yy+8,DEVICE_WIDTH,DEVICE_HEIGHT-yy-8) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:UIColor.clearColor];
    tblContent.showsVerticalScrollIndicator = NO;
    tblContent.showsHorizontalScrollIndicator=NO;
    tblContent.scrollEnabled = true;
    [tblContent setDelegate:self];
    [tblContent setDataSource:self];
    [tblContent setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tblContent];
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblContent withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
   
    yy = yy+30;
    
    lblScanning = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2)-50, yy, 100, 44)];
    [lblScanning setBackgroundColor:[UIColor clearColor]];
    [lblScanning setText:@"Scanning..."];
    [lblScanning setTextAlignment:NSTextAlignmentCenter];
    [lblScanning setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblScanning setTextColor:[UIColor blackColor]];
    [self.view addSubview:lblScanning];
    
    yy = yy+44+25;
    
    lblInstructuions = [[UILabel alloc] initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-20, 44)];
    [lblInstructuions setBackgroundColor:[UIColor clearColor]];
    [lblInstructuions setText:@"Instructions"];
    [lblInstructuions setTextAlignment:NSTextAlignmentLeft];
    [lblInstructuions setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblInstructuions setTextColor:[UIColor grayColor]];
    [self.view addSubview:lblInstructuions];
    
    yy = yy+44;
    
    lblInstructuion1 = [[UILabel alloc] initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-30, 300)];
    [lblInstructuion1 setBackgroundColor:[UIColor clearColor]];
    lblInstructuion1.text = [NSString stringWithFormat:@"1) Please \"%@\" your Phone Bluetooth Connection. \n\n2) Make sure that there is sufficient \"%@\" in the battery cell connected to your Tracker Device. \n\n3) Make sure that Tracker Device is within the phone's \"%@\". \n\n4) Refresh and try again.",@"Turn ON",@"Charge",@"Bluetooth Range"];
    lblInstructuion1.numberOfLines = 0;
    [lblInstructuion1 setTextAlignment:NSTextAlignmentLeft];
    [lblInstructuion1 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblInstructuion1 setTextColor:[UIColor grayColor]];
    [self.view addSubview:lblInstructuion1];
    
    if ( [[[BLEManager sharedManager] foundDevices] count] >0)
    {
        tblContent.hidden = false;
        lblScanning.hidden = true;
        lblInstructuions.hidden = true;
        lblInstructuion1.hidden = true;
    }
    else
    {
        tblContent.hidden = true;
        lblScanning.hidden = false;
        lblInstructuions.hidden = false;
        lblInstructuion1.hidden = false;
    }
}
-(void)GlobalBLuetoothCheck
{
    if (globalAlertPopUP)
    {
        [globalAlertPopUP removeFromParentViewController];
        
    }
    globalAlertPopUP = [UIAlertController alertControllerWithTitle:@"KUURV" message:@"Please Turn ON Bluetooth connection to enjoy all the features of the KUURV app." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [globalAlertPopUP addAction:defaultAction];
    [self presentViewController:globalAlertPopUP animated:true completion:nil];
}
-(void)setUpLostDeviceView
{
    [APP_DELEGATE endHudProcess];
    [[BLEManager sharedManager] disconnectDevice:self->classPeripheral];

    if (![[self checkforValidString:[self->dictOwner valueForKey:@"email"]] isEqualToString:@"NA"])
    {
        [self SendLostDeviceDetailtoServer];
    }
    [backShadowView removeFromSuperview];
    backShadowView = [[UIView alloc] init];
    backShadowView.backgroundColor = [UIColor blackColor];
    backShadowView.alpha = 0.8;
    backShadowView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view addSubview:backShadowView];
    
    [viewLostDevice removeFromSuperview];
    viewLostDevice = [[UIView alloc]initWithFrame:CGRectMake(10,( DEVICE_HEIGHT/2)-165, DEVICE_WIDTH-20, 340)];
    viewLostDevice.backgroundColor = UIColor.whiteColor;
    viewLostDevice.layer.masksToBounds = true;
    viewLostDevice.layer.borderWidth = 1;
    viewLostDevice.layer.borderColor = UIColor.blackColor.CGColor;
    viewLostDevice.layer.cornerRadius = 10;
    [self.view addSubview:viewLostDevice];
    viewLostDevice.hidden = YES;
    
    int yy =10;
    UILabel * lblLostDevice = [[UILabel alloc] initWithFrame:CGRectMake(20, yy, viewLostDevice.frame.size.width-40, 30)];
    [lblLostDevice setBackgroundColor:[UIColor clearColor]];
    [lblLostDevice setText:@"Tracker Device"];
    [lblLostDevice setTextAlignment:NSTextAlignmentCenter];
    [lblLostDevice setFont:[UIFont fontWithName:CGRegular size:txtSize+1.5]];
    [lblLostDevice setTextColor:[UIColor blackColor]];
    [viewLostDevice addSubview:lblLostDevice];
    
    yy = yy+30;
    UILabel * lblInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, viewLostDevice.frame.size.width-20, 70)];
    lblInfo.numberOfLines = 0;
    [lblInfo setBackgroundColor:[UIColor clearColor]];
    [lblInfo setText:@"This device belongs to someone else whose details are as follows"];
    [lblInfo setTextAlignment:NSTextAlignmentLeft];
    [lblInfo setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblInfo setTextColor:[UIColor grayColor]];
    [viewLostDevice addSubview:lblInfo];
    
    yy = yy+70+10;
    
    UILabel * lblOwnerDetails = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, viewLostDevice.frame.size.width-20, 30)];
    [lblOwnerDetails setBackgroundColor:[UIColor clearColor]];
    [lblOwnerDetails setText:@"Owner Details:"];
    [lblOwnerDetails setTextAlignment:NSTextAlignmentLeft];
    [lblOwnerDetails setFont:[UIFont fontWithName:CGBold size:txtSize]];
    [lblOwnerDetails setTextColor:[UIColor blackColor]];
    [viewLostDevice addSubview:lblOwnerDetails];
    
    yy = yy+30;
    
    UILabel * lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, viewLostDevice.frame.size.width-20, 30)];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setText:[APP_DELEGATE checkforValidString:[dictOwner valueForKey:@"name"]]];
    [lblName setTextAlignment:NSTextAlignmentLeft];
    [lblName setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblName setTextColor:[UIColor blackColor]];
    [viewLostDevice addSubview:lblName];
    
    
    yy = yy+30;
    
    UILabel * lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, viewLostDevice.frame.size.width-20, 30)];
    [lblEmail setBackgroundColor:[UIColor clearColor]];
    [lblEmail setText:[APP_DELEGATE checkforValidString:[dictOwner valueForKey:@"email"]]];
    [lblEmail setTextAlignment:NSTextAlignmentLeft];
    [lblEmail setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblEmail setTextColor:[UIColor blackColor]];
    [viewLostDevice addSubview:lblEmail];
    
    yy = yy+30;
    
    UILabel * lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, viewLostDevice.frame.size.width-20, 30)];
    [lblPhone setBackgroundColor:[UIColor clearColor]];
    [lblPhone setText:[APP_DELEGATE checkforValidString:[dictOwner valueForKey:@"mobile"]]];
    [lblPhone setTextAlignment:NSTextAlignmentLeft];
    [lblPhone setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblPhone setTextColor:[UIColor blackColor]];
    [viewLostDevice addSubview:lblPhone];
    
    yy = yy+50;
    
    UIButton*btnContact = [[UIButton alloc]initWithFrame:CGRectMake(10, yy, (viewLostDevice.frame.size.width/2)-20, 50)];
    btnContact.backgroundColor = global_greenColor;
    [btnContact setTitle:@"Contact" forState:UIControlStateNormal];
    btnContact.titleLabel.textColor = UIColor.blackColor;
    btnContact.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnContact.layer.borderColor = UIColor.clearColor.CGColor;
    [btnContact addTarget:self  action:@selector(btnContactClicked) forControlEvents:UIControlEventTouchUpInside];
    btnContact.layer.borderWidth = 1;
    [viewLostDevice addSubview:btnContact];
    
    
    UIButton*btnIgnore = [[UIButton alloc]initWithFrame:CGRectMake((viewLostDevice.frame.size.width/2)+10, yy, (viewLostDevice.frame.size.width/2)-20, 50)];
    btnIgnore.backgroundColor = UIColor.redColor;
    [btnIgnore setTitle:@"Ignore" forState:UIControlStateNormal];
    btnIgnore.titleLabel.textColor = UIColor.blackColor;
    [btnIgnore addTarget:self  action:@selector(btnIgnoreClicked) forControlEvents:UIControlEventTouchUpInside];
    btnIgnore.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnIgnore.layer.borderColor = UIColor.clearColor.CGColor;
    btnIgnore.layer.borderWidth = 1;
    [viewLostDevice addSubview:btnIgnore];
    
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        self->viewLostDevice.hidden = NO;
    } completion:nil];
    
}
#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotofiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotofiyDiscoveredDevices:) name:@"NotofiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"DeviceDidDisConnectNotification" object:nil];
}
-(void)NotofiyDiscoveredDevices:(NSNotification*)notification//Update peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       // UIView usage
                       if ( [[[BLEManager sharedManager] foundDevices] count] >0)
                       {
                           self->tblContent.hidden = false;
                           self->lblScanning.hidden = true;
                           self->lblInstructuions.hidden = true;
                           self->lblInstructuion1.hidden = true;
                       }
                       else
                       {
                           self->tblContent.hidden = true;
                           self->lblScanning.hidden = false;
                           self->lblInstructuions.hidden = false;
                           self->lblInstructuion1.hidden = false;
                       }
                       [self->tblContent reloadData];
                   });
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
    CBPeripheral * tmpPerphrl = [notification object];
    globalPeripheral = tmpPerphrl;
    NSLog(@"Connection Identifier=%@",tmpPerphrl.identifier);


}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
//    [APP_DELEGATE endHudProcess];
    
}
#pragma mark - Got the status of device
-(void)AuthenticationCompleted:(NSNotification *)notify
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self->connectionTimer invalidate];
        isConnectedtoAdd = NO;
        
        
        NSDictionary * tmpDict = [notify object];
        NSString * strValue = [tmpDict valueForKey:@"value"];
        NSLog(@"Connected Device Status===>>>%@",strValue);
        
        if ([strValue isEqualToString:@"00"])
        {
            NSLog(@"authentication 00 is sent");
            [[BLEService sharedInstance] SendCommandWithPeripheral:self->classPeripheral withValue:@"12"];

            
        }
        else if ([strValue isEqualToString:@"01"])
        {
            [APP_DELEGATE endHudProcess];

            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"This Device belongs to You only."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else if ([strValue isEqualToString:@"02"])
        {
            [APP_DELEGATE endHudProcess];

            [[BLEManager sharedManager] disconnectDevice:self->classPeripheral];
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"This Device is a New Device and has not been added with anyone."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
            
        }
        [self->tblContent reloadData];

//    });

}
-(void)FetchedNamefromDevice:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Name===>>>%@",strValue);
    [dictOwner setValue:strValue forKey:@"name"];
}
-(void)FetchedMobilefromDevice:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Mobile===>>>%@",strValue);
    [dictOwner setValue:strValue forKey:@"mobile"];
}
-(void)FetchedEmail1fromDevice:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Email Half===>>>%@",strValue);
    [dictOwner setValue:strValue forKey:@"email"];
    
    if ([strValue rangeOfString:@"@"].location != NSNotFound && [strValue rangeOfString:@".com"].location != NSNotFound)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUpLostDeviceView];
        });
    }
    else
    {
        if (![[APP_DELEGATE checkforValidString:strValue]isEqualToString:@"NA"])
        {
            if (strValue.length < 18)
            {
                [self setUpLostDeviceView];
            }
        }
    }
}
-(void)FetchedEmail2fromDevice:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Email 2 Half===>>>%@",strValue);
    NSString * strEmailhalf = [dictOwner valueForKey:@"email"];
    if ([strEmailhalf rangeOfString:@"@"].location != NSNotFound && [strEmailhalf rangeOfString:@".com"].location != NSNotFound)
    {
        [[BLEManager sharedManager] disconnectDevice:self->classPeripheral];
    }
    else
    {
        if (![[self checkforValidString:strEmailhalf] isEqualToString:@"NA"])
        {
            NSString * strFullEmail = [NSString stringWithFormat:@"%@%@",strEmailhalf,strValue];
            [dictOwner setValue:strFullEmail forKey:@"email"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUpLostDeviceView];
            
        });
        
    }
}
-(void)SyncNameofUsertoDevice
{
    NSLog(@"Wrote user unique value");
    [[BLEService sharedInstance] writeUserUniqueValue:CURRENT_USER_UNIQUEKEY with:classPeripheral];
    
    //    NSString * str = [self hexFromStr:message];
    //    NSData * msgData = [self dataFromHexString:str];
}
-(void)fetchingDetailTimeout
{
    [APP_DELEGATE endHudProcess];
}

#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 55)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *lblmenu=[[UILabel alloc]init];
    lblmenu.text = @"   Tap to Connect Tracker";
    [lblmenu setTextColor:[UIColor grayColor]];
    [lblmenu setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    lblmenu.frame = CGRectMake(0, 0, DEVICE_WIDTH, 45);
    lblmenu.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:lblmenu];
    
    lblmenu.layer.shadowRadius  = 4.5f;
    lblmenu.layer.shadowColor   = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
    lblmenu.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    lblmenu.layer.shadowOpacity = 0.5f;
    lblmenu.layer.masksToBounds = NO;
    
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -4.5f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(lblmenu.bounds, shadowInsets)];
    lblmenu.layer.shadowPath    = shadowPath.CGPath;
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    }
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BLEManager sharedManager] foundDevices] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    AddDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[AddDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblConnect.text = @"Info";
    cell.lblAddress.hidden = NO;
    cell.lblAddress.text = @"NA";
    cell.imgIcon.hidden = NO;
    
    cell.lblDeviceName.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    cell.lblAddress.font = [UIFont fontWithName:CGRegular size:txtSize-1];
    cell.lblConnect.font = [UIFont fontWithName:CGRegular size:txtSize-1];
    //    cell.lblConnect.frame = CGRectMake(DEVICE_WIDTH-40, 0, DEVICE_WIDTH-60, 60);
    
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"peripheral"];
        cell.lblDeviceName.text = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.lblAddress.text = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"ble_address"];
        if (p.state == CBPeripheralStateConnected)
        {
            cell.lblConnect.text = @"Info";
            //            cell.lblConnect.textColor = [UIColor colorWithRed:255/255.0f green:73/255.0f blue:64/255.0f alpha:1];
        }
        else
        {
            cell.lblConnect.text = @"Info";
            //            cell.lblConnect.textColor = [UIColor colorWithRed:0/255.0f green:219/255.0f blue:67/255.0f alpha:1];
        }
        cell.lblConnect.textColor = [UIColor blackColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [connectionTimer invalidate];
    connectionTimer = nil;
    connectionTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    
    [APP_DELEGATE endHudProcess];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            strBleAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"ble_address"];
            isConnectedtoAdd = YES;
            classPeripheral = p;
            [APP_DELEGATE startHudProcess:@"Fetching Info..."];
            [[BLEService sharedInstance] SyncUserTextinfowithDevice:CURRENT_USER_UNIQUEKEY with:p withOpcode:@"11"];

        }
        else
        {
            strBleAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"ble_address"];
            isConnectedtoAdd = YES;
            classPeripheral = p;
            [APP_DELEGATE startHudProcess:@"Fetching Info..."];
            [[BLEManager sharedManager] connectDevice:p];
        }
    }
//    [self setUpLostDeviceView];
}
-(void)ConnectionTimeOutMethod
{
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
        
    }
    else
    {
        if (classPeripheral == nil)
        {
            return;
        }
        [APP_DELEGATE endHudProcess];
        [self refreshBtnClick];
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Something went wrong. Please try again later."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
#pragma mark - All Button Click Events
-(void)btnMenuClicked:(id)sender
{
    isAddDeviceScreen = NO;
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
-(void)btnIgnoreClicked
{
    [backShadowView removeFromSuperview];
    [viewLostDevice removeFromSuperview];
}
-(void)btnContactClicked
{
    NSString * strPhone = @"NA";
    if (![[self checkforValidString:[dictOwner valueForKey:@"mobile"]] isEqualToString:@"NA"])
    {
        strPhone = [dictOwner valueForKey:@"mobile"];
    }
    if (classPeripheral)
    {
        [[BLEManager sharedManager] disconnectDevice:classPeripheral];
    }

    alert2 = [[FCAlertView alloc] init];
    alert2.colorScheme = [UIColor blackColor];
    [alert2 makeAlertTypeWarning];
    [alert2 addButton:@"Call" withActionBlock:
     ^{
         [self->btnCancel removeFromSuperview];
         [self callPhone:@"test"];
         
     }];
    [alert2 addButton:@"Email" withActionBlock:
     ^{
         [self->btnCancel removeFromSuperview];
         [self launchMailAppOnDevice];
         
     }];
    
    
    if (![strPhone isEqualToString:@"NA"])
    {
        [alert2 removeFromSuperview];
        alert2 = [[FCAlertView alloc] init];
        alert2.colorScheme = [UIColor blackColor];
        [alert2 makeAlertTypeWarning];
        alert2.delegate = self;
        [alert2 addButton:@"Call" withActionBlock:
         ^{
             [self->btnCancel removeFromSuperview];
             [self callPhone:strPhone];
             [self btnIgnoreClicked];
         }];
        
        [alert2 addButton:@"Email" withActionBlock:
         ^{
             [self->btnCancel removeFromSuperview];
             [self launchMailAppOnDevice];
         }];
        alert2.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
        [alert2 showAlertInView:self
                      withTitle:@"KUURV"
                   withSubtitle:@"Contact through?"
                withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
            withDoneButtonTitle:@"Email" andButtons:nil];
        alert2.hideDoneButton =true;
        
        viewLostDevice.hidden = YES;
        
        btnCancel = [[UIButton alloc]initWithFrame:CGRectMake((alert2.frame.size.width-70)/2,(alert2.frame.size.height-70),70,70)];
        btnCancel.backgroundColor = UIColor.whiteColor;
        [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [btnCancel setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [btnCancel addTarget:self  action:@selector(btnCancelClicked) forControlEvents:UIControlEventTouchUpInside];
        btnCancel.layer.masksToBounds  = true;
        btnCancel.layer.cornerRadius = 35;
        btnCancel.layer.borderColor = [UIColor redColor].CGColor;
        btnCancel.layer.borderWidth = 1.0;
        [[APP_DELEGATE window] addSubview:btnCancel];
        btnCancel.hidden = true;

    }
    else
    {
        [self launchMailAppOnDevice];
    }
}
-(void)btnCancelClicked
{
    viewLostDevice.hidden = NO;
    [alert2 removeFromSuperview];
    [btnCancel removeFromSuperview];
}
-(void)callPhone:(id)sender
{
    NSString * strCall = [NSString stringWithFormat:@"tel://%@",[dictOwner valueForKey:@"mobile"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strCall]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://8105286869"]];
}
-(void)launchMailAppOnDevice
{
    NSString * strName = [APP_DELEGATE checkforValidString:[dictOwner valueForKey:@"name"]];
    if ([strName isEqualToString:@"NA"])
    {
        strName = @"Hello";
    }
    else
    {
        strName = [NSString stringWithFormat:@"Hello %@", strName];
    }
    NSString * strMsg =  [NSString stringWithFormat:@"%@,\n\n I have found your Tracker device on this location. \n\n https://maps.google.com/maps?q=%f,%f \n\n Please collect it.", strName,currentLatitude,currentLongitude];
    // To address https://maps.google.com/maps?q=23.0225,72.5714
    NSString *recipients = [APP_DELEGATE checkforValidString:[dictOwner valueForKey:@"email"]];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Device found!!!"];
    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:@[recipients]];
    
    if (mc == nil)
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Please set up a Mail account in order to send email."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self btnIgnoreClicked];

    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)refreshBtnClick
{
    NSArray * tmparr = [[BLEManager sharedManager]getLastConnected];
    for (int i=0; i<tmparr.count; i++)
    {
        CBPeripheral * p = [tmparr objectAtIndex:i];
        if (![[arrayDevice valueForKey:@"identifier"] containsObject:[NSString stringWithFormat:@"%@",p.identifier]])
        {
            [[BLEManager sharedManager]disconnectDevice:p];
        }
        
    }
    
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    [tblContent reloadData];
    
    if ( [[[BLEManager sharedManager] foundDevices] count] >0)
    {
        tblContent.hidden = false;
        lblScanning.hidden = true;
        lblInstructuions.hidden = true;
        lblInstructuion1.hidden = true;
    }
    else
    {
        tblContent.hidden = true;
        lblScanning.hidden = false;
        lblInstructuions.hidden = false;
        lblInstructuion1.hidden = false;
    }
}
#pragma mark - MEScrollToTopDelegate Methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [topPullToRefreshManager tableViewScrolled];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y >=360.0f)
    {
    }
    else
        [topPullToRefreshManager tableViewReleased];
}
- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    [self refreshBtnClick];
    [self performSelector:@selector(stoprefresh) withObject:nil afterDelay:1.5];
}
-(void)stoprefresh
{
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
}

-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
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

#pragma mark - Web Service Call
-(void)SendLostDeviceDetailtoServer
{
    if ([APP_DELEGATE isNetworkreachable])
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
                [dict setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:@"latitude"];
                [dict setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:@"longitude"];
                [dict setValue:self->strBleAddress forKey:@"ble_address"];
                [dict setValue:[self->dictOwner valueForKey:@"email"] forKey:@"email"];

                
                [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
                
                AFHTTPRequestOperationManager *manager1 = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://server.url"]];
                //[manager1.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
                NSString *token=[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ACCESS_TOKEN"];
                [manager1.requestSerializer setValue:token forHTTPHeaderField:@"token"];
                [manager1.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];//or content type
                //manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                AFHTTPRequestOperation *op = [manager1 POST:@"http://kuurvtrackerapp.com/mobile/sendnotification" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
                                              {
                                                  NSLog(@"Response=%@",responseObject);
                                                  NSMutableDictionary * dictID = [[NSMutableDictionary alloc] init];
                                                  dictID = [responseObject mutableCopy];
                                                  if ([dictID valueForKey:@"data"] == [NSNull null] || [dictID valueForKey:@"data"] == nil)
                                                  {
                                                      
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
    if (alertView.tag == 222)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag == 111)
    {
        [APP_DELEGATE logoutAndClearDB];
    }
}
- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}
- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
    CGRect frameRect = btnCancel.frame;
    frameRect.origin.y = alertView.alertPopSize-35;
    btnCancel.frame = frameRect;
    btnCancel.hidden = NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
