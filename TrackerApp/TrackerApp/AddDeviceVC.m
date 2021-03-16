//
//  AddDeviceVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 29/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AddDeviceVC.h"
#import "AddDeviceCell.h"
#import "CustomDeviceVC.h"
#import "BLEManager.h"
#import "MNMPullToRefreshManager.h"
#import "QuartzCore/QuartzCore.h"
#import "URLManager.h"
#import <MessageUI/MessageUI.h>

@interface AddDeviceVC ()<MNMPullToRefreshManagerClient,CBCentralManagerDelegate,UIGestureRecognizerDelegate,FCAlertViewDelegate,URLManagerDelegate,MFMailComposeViewControllerDelegate,CBPeripheralDelegate>
{
    MNMPullToRefreshManager * topPullToRefreshManager;
    CBCentralManager*centralManager;
    CBPeripheral * classPeripheral;
    NSMutableDictionary * dictOwner;
    NSString * strBleAddress;
    NSTimer * connectionTimer;
    NSString * strDeviceStatus;
    UIView*instructionsView;
}
@end

@implementation AddDeviceVC

- (void)viewDidLoad
{
    isAddDeviceScreen = YES;
    dictOwner = [[NSMutableDictionary alloc] init];
    [topPullToRefreshManager setPullToRefreshViewVisible:NO];
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:true];
    //    arrDevice = [[NSMutableArray alloc]init];
    arrDevice = [[NSMutableArray alloc]initWithObjects:@"device 1",@"device 2",@"device 3", nil];
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
    isAddingDeviceStirng = @"";
    [APP_DELEGATE endHudProcess];
    NSLog(@"ADD DEVICE VIEW WILL DISAPPEAR");
    
    
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
    //    [viewHeader setBackgroundColor:[UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0]];
    [viewHeader setBackgroundColor:global_greenColor];
    [self.view addSubview:viewHeader];
    
    
    viewHeader.layer.shadowRadius  = 4.5f;
    viewHeader.layer.shadowColor   = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
    viewHeader.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    viewHeader.layer.shadowOpacity = 0.5f;
    viewHeader.layer.masksToBounds = NO;
    
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -4.5f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(viewHeader.bounds, shadowInsets)];
    viewHeader.layer.shadowPath    = shadowPath.CGPath;
    
//    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 44)];
//    lblBack.backgroundColor = [UIColor clearColor];
//    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Add Device"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:txtSize+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgBack = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+11, 14, 22)];
    imgBack.image = [UIImage imageNamed:@"back_icon.png"];
    imgBack.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgBack];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 0, 80, yy)];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];
    
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
        imgRefresh.frame = CGRectMake(DEVICE_WIDTH-30, 40+8, 20, 28);
        [btnBack setFrame:CGRectMake(0, 0, 88, 84)];
        imgBack.frame = CGRectMake(10,40+11, 14, 22);
        viewHeader.frame = CGRectMake(0,0, DEVICE_WIDTH, 84);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
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
    
    yy = yy+44+10;
   
    instructionsView =[[UIView alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    instructionsView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:instructionsView];
    
    UILabel *lblNo1 = [[UILabel alloc]init];
    lblNo1.frame =  CGRectMake(20,0, 35*approaxSize, 35*approaxSize);
    [lblNo1 setBackgroundColor:UIColor.clearColor];
    [lblNo1 setText:@"1)"];
    [lblNo1 setTextAlignment:NSTextAlignmentLeft];
    [lblNo1 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblNo1 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblNo1];

    UILabel * lblInstructuion1 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, 6*approaxSize, DEVICE_WIDTH-45, 25)];
    [lblInstructuion1 setBackgroundColor:[UIColor clearColor]];
    lblInstructuion1.text = [NSString stringWithFormat:@"Please turn Bluetooth ON"];
    lblInstructuion1.numberOfLines = 0;
//    lblInstructuion1.adjustsFontSizeToFitWidth = true;
    [lblInstructuion1 setTextAlignment:NSTextAlignmentLeft];
    [lblInstructuion1 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblInstructuion1 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblInstructuion1];

    long hh = 45+(6*approaxSize);
    UILabel *lblNo2 = [[UILabel alloc]init];
    lblNo2.frame =  CGRectMake(20,hh,35*approaxSize, 35*approaxSize);
    [lblNo2 setBackgroundColor:UIColor.clearColor];
    [lblNo2 setText:@"2)"];
    [lblNo2 setTextAlignment:NSTextAlignmentLeft];
    [lblNo2 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblNo2 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblNo2];
    
    int tmph = 45;
//    if (IS_IPHONE_5)
//    {
//        tmph = 60;
//    }
    UILabel * lblInstructuion2 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+(4.5*approaxSize), DEVICE_WIDTH-45, tmph)];
    [lblInstructuion2 setBackgroundColor:[UIColor clearColor]];
    lblInstructuion2.text = [NSString stringWithFormat:@"Make sure the tracker's battery has enough charge"];
    lblInstructuion2.numberOfLines = 0;
    [lblInstructuion2 setTextAlignment:NSTextAlignmentLeft];
    [lblInstructuion2 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblInstructuion2 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblInstructuion2];
    
    
    hh = hh+tmph+15+(5*approaxSize);
    UILabel *lblNo3 = [[UILabel alloc]init];
    lblNo3.frame =  CGRectMake(20,hh,35*approaxSize, 35*approaxSize);
    [lblNo3 setBackgroundColor:UIColor.clearColor];
    [lblNo3 setText:@"3)"];
    [lblNo3 setTextAlignment:NSTextAlignmentLeft];
    [lblNo3 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblNo3 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblNo3];
    
    tmph = 45;
//    if (IS_IPHONE_5)
//    {
//        tmph = 70;
//    }
    UILabel * lblInstructuion3 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+5.5*approaxSize, DEVICE_WIDTH-45, tmph)];
    [lblInstructuion3 setBackgroundColor:[UIColor clearColor]];
    lblInstructuion3.text = [NSString stringWithFormat:@"Make sure the tracker is within your phone's bluetooth range"];
    lblInstructuion3.numberOfLines = 0;
    [lblInstructuion3 setTextAlignment:NSTextAlignmentLeft];
    [lblInstructuion3 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblInstructuion3 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblInstructuion3];
    
    hh = hh+tmph+15+(5*approaxSize);
    UILabel *lblNo4 = [[UILabel alloc]init];
    lblNo4.frame =  CGRectMake(20,hh,35*approaxSize, 35*approaxSize);
    [lblNo4 setBackgroundColor:UIColor.clearColor];
    [lblNo4 setText:@"4)"];
    [lblNo4 setTextAlignment:NSTextAlignmentLeft];
    [lblNo4 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblNo4 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblNo4];
    
    UILabel * lblInstructuion4 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+6*approaxSize, DEVICE_WIDTH-45, 25)];
    [lblInstructuion4 setBackgroundColor:[UIColor clearColor]];
    lblInstructuion4.text = [NSString stringWithFormat:@"Refresh the app"];
    lblInstructuion4.numberOfLines = 0;
    [lblInstructuion4 setTextAlignment:NSTextAlignmentLeft];
    [lblInstructuion4 setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblInstructuion4 setTextColor:[UIColor grayColor]];
    [instructionsView addSubview:lblInstructuion4];

//    lblInstructuion2 = 2) Make sure that there is sufficient \"%@\" in the battery cell connected to your Tracker Device.@"Charge"
//    lblInstructuion2 = 2)3) Make sure that Tracker Device is within the phone's \"%@\".@"Bluetooth Range"
//    lblInstructuion2 = 4) Refresh and try again.

    if ( [[[BLEManager sharedManager] foundDevices] count] >0)
    {
        tblContent.hidden = false;
        lblScanning.hidden = true;
        lblInstructuions.hidden = true;
        instructionsView.hidden = true;
    }
    else
    {
        tblContent.hidden = true;
        lblScanning.hidden = false;
        lblInstructuions.hidden = false;
        instructionsView.hidden = false;
    }
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

#pragma mark- UITableView Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    AddDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[AddDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblConnect.text = @"Add";
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
            cell.lblConnect.text = @"Add";
            //            cell.lblConnect.textColor = [UIColor colorWithRed:255/255.0f green:73/255.0f blue:64/255.0f alpha:1];
        }
        else
        {
            cell.lblConnect.text = @"Add";
            //            cell.lblConnect.textColor = [UIColor colorWithRed:0/255.0f green:219/255.0f blue:67/255.0f alpha:1];
        }
        cell.lblConnect.textColor = [UIColor blackColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        isAddingDeviceStirng = [NSString stringWithFormat:@"%@",p.identifier];
        if (p.state == CBPeripheralStateConnected)
        {
            [APP_DELEGATE  endHudProcess];
            [APP_DELEGATE startHudProcess:@"Saving Device..."];
            
            [connectionTimer invalidate];
            connectionTimer = nil;
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
            
            strBleAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"ble_address"];
            isConnectedtoAdd = YES;
            classPeripheral = p;
            [[BLEService sharedInstance] SyncUserTextinfowithDevice:CURRENT_USER_UNIQUEKEY with:p withOpcode:@"11"];
            
            //            [APP_DELEGATE startHudProcess:@"Disconnecting..."];
//                        [[BLEManager sharedManager] disconnectDevice:p];
        }
        else if(p.state == CBPeripheralStateConnecting)
        {
            [APP_DELEGATE  endHudProcess];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Something went wrong. Please turn OFF your bluetooth and Turn ON to connect it back."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else
        {
            [APP_DELEGATE  endHudProcess];
            [APP_DELEGATE startHudProcess:@"Saving Device..."];
            
            [connectionTimer invalidate];
            connectionTimer = nil;
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
            strBleAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"ble_address"];
            isConnectedtoAdd = YES;
            classPeripheral = p;
            [[BLEManager sharedManager] connectDevice:p];
        }
    }
    
}
-(void)ConnectionTimeOutMethod
{
    [APP_DELEGATE endHudProcess];

    if (classPeripheral.state == CBPeripheralStateConnected)
    {

    }
    else
    {
        if (classPeripheral == nil)
        {
            return;
        }
        isAddingDeviceStirng = @"";
        [[BLEManager sharedManager] disconnectDevice:classPeripheral];
        [self refreshBtnClick];
          [APP_DELEGATE  endHudProcess];
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
-(void)btnBackClick
{
       isAddDeviceScreen = NO;
    
    isConnectedtoAdd = NO;
    [self removeAllNotifications];
    
    [connectionTimer invalidate];
    connectionTimer = nil;
    [self.navigationController popViewControllerAnimated:true];
}
-(void)refreshBtnClick
{
      [APP_DELEGATE  endHudProcess];
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
        instructionsView.hidden = true;
    }
    else
    {
        tblContent.hidden = true;
        lblScanning.hidden = false;
        lblInstructuions.hidden = false;
        instructionsView.hidden = false;
    }
}
-(void)btnIgnoreClicked
{
    if (classPeripheral)
    {
        [[BLEManager sharedManager]disconnectDevice:classPeripheral];
    }
    [backShadowView removeFromSuperview];
    [viewLostDevice removeFromSuperview];
    [self refreshBtnClick];
    
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
}
//-(void)launchMailAppOnDevice
//{
//    NSString *recipients = [APP_DELEGATE checkforValidString:[dictOwner valueForKey:@"email"]];
//    NSString *body = @"&body=bodyHere";
//
//    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
//    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
//}
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
-(void)removeAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotofiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedNamefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedMobilefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail1fromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail2fromDevice" object:nil];

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
                           self->instructionsView.hidden = true;
                       }
                       else
                       {
                           self->tblContent.hidden = true;
                           self->lblScanning.hidden = false;
                           self->lblInstructuions.hidden = false;
                           self->instructionsView.hidden = false;
                       }
                       [self->tblContent reloadData];
                   });
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
    [connectionTimer invalidate];
    connectionTimer = nil;

    CBPeripheral * tmpPerphrl = [notification object];
    globalPeripheral = tmpPerphrl;
    NSLog(@"Connection Identifier=%@",tmpPerphrl.identifier);
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
//                       [APP_DELEGATE endHudProcess];
                       [self->tblContent reloadData];
                   });
    
    /* FCAlertView *alert = [[FCAlertView alloc] init];
     alert.colorScheme = [UIColor blackColor];
     [alert makeAlertTypeSuccess];
     alert.delegate = self;
     alert.tag = 222;
     [alert showAlertInView:self
     withTitle:@"KUURV"
     withSubtitle:@"Device has been connected successfully."
     withCustomImage:[UIImage imageNamed:@"logo.png"]
     withDoneButtonTitle:nil
     andButtons:nil];*/
    
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [APP_DELEGATE endHudProcess];
                       [self->tblContent reloadData];
                   });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Got the status of device
-(void)AuthenticationCompleted:(NSNotification *)notify
{
    isConnectedtoAdd = NO;
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Connected Device Status===>>>%@",strValue);
    strDeviceStatus = strValue;

    if ([strValue isEqualToString:@"00"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [APP_DELEGATE endHudProcess];

            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            [alert addButton:@"Info" withActionBlock:^{
                [self->connectionTimer invalidate];
                self->connectionTimer = nil;
                self->connectionTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(fetchingDetailTimeout) userInfo:nil repeats:NO];
                [APP_DELEGATE endHudProcess];
                [APP_DELEGATE startHudProcess:@"Fetching details..."];
                [[BLEService sharedInstance] SendCommandWithPeripheral:self->classPeripheral withValue:@"12"];
            }];
            alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
            alert.delegate = self;
            alert.tag = 444;
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"This Tracker device belongs to someone else. Tap on Info to get Owner detail."
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"Cancel" andButtons:nil];
            
        });
        //You are not owner of this device. Tap on get info to get user details.
    }
    else if ([strValue isEqualToString:@"01"])
    {
//        dispatch_async(dispatch_get_main_queue(),
//                       ^{
//                           [APP_DELEGATE endHudProcess];
//                       });
        strCurrentDateNTime =  [self checkforValidString:[self getCurrentTime]];
        NSMutableArray * tmpArr = [[NSMutableArray alloc]init];
        NSString * strQuery = [NSString stringWithFormat:@"select * from Device_Table where user_id ='%@' and ble_address ='%@'",CURRENT_USER_ID,strBleAddress];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArr];
        
        if (tmpArr.count > 0)
        {
            NSString *tmpID  = [[tmpArr objectAtIndex:0] valueForKey:@"id"];
            NSString * strUpdate = [NSString stringWithFormat:@"Update 'Device_Table' set updated_time ='%@',identifier ='%@' where id = '%@'",strCurrentDateNTime,classPeripheral.identifier,tmpID];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            
            NSMutableDictionary * dictHomeInfo = [[NSMutableDictionary alloc] init];
            dictHomeInfo = [[tmpArr objectAtIndex:0]mutableCopy];
            [dictHomeInfo removeObjectForKey:@"identifier"];
            [dictHomeInfo setObject:classPeripheral forKey:@"peripheral"];
            [dictHomeInfo setObject:[NSString stringWithFormat:@"%@",classPeripheral.identifier] forKey:@"identifier"];
            [dictHomeInfo setValue:strCurrentDateNTime forKey:@"updated_time"];
            
            strCurrentDateNTime =  [self checkforValidString:[self getCurrentTime]];
            if (arrayDevice.count > 0)
            {
                NSInteger foundIndexx = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:[dictHomeInfo valueForKey:@"ble_address"]];
                if (foundIndexx != NSNotFound)
                {
                    if (foundIndexx < [arrayDevice count])
                    {
                        [arrayDevice replaceObjectAtIndex:foundIndexx withObject:dictHomeInfo];
                    }
                }
            }
            else
            {
                [arrayDevice addObject:dictHomeInfo];
            }
            [homeDashboard SaveAddedDeviceToHome:dictHomeInfo];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveAddedDeviceToHome" object:dictHomeInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeSuccess];
                alert.delegate = self;
                alert.tag = 222;
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"Device is already added."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[APP_DELEGATE checkforValidString:self->strBleAddress]isEqualToString:@"NA"])
                {
                    [self removeAllNotifications];
                    [APP_DELEGATE endHudProcess];
                    
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:self->strBleAddress forKey:@"bleAddress"];
                    CustomDeviceVC *view1 = [[CustomDeviceVC alloc]init];
                    view1.deviceDetail = dict;
                    view1.classPeripheral = self->classPeripheral;
                    view1.strDeviceStatus = self->strDeviceStatus;
                    [self.navigationController pushViewController:view1 animated:true];
                }
            });
            //Its fresh device. Means go for Setting Image and Name.
        }
        if (classPeripheral)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [APP_DELEGATE endHudProcess];
                           });
            if (![arrGlobalDevices containsObject:classPeripheral])
            {
                [arrGlobalDevices addObject:classPeripheral];
            }
            //You are the owner of device. Carry on.
        }
    }
    else if ([strValue isEqualToString:@"02"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![[APP_DELEGATE checkforValidString:self->strBleAddress]isEqualToString:@"NA"])
            {
                [self removeAllNotifications];
                [APP_DELEGATE endHudProcess];

                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:self->strBleAddress forKey:@"bleAddress"];
                CustomDeviceVC *view1 = [[CustomDeviceVC alloc]init];
                view1.deviceDetail = dict;
                view1.classPeripheral = self->classPeripheral;
                view1.strDeviceStatus = self->strDeviceStatus;
                [self.navigationController pushViewController:view1 animated:true];
            }
        });
        //Its fresh device. Means go for Setting Image and Name.
    }
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
}
-(void)FetchedEmail2fromDevice:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Email 2 Half===>>>%@",strValue);
    NSString * strEmailhalf = [dictOwner valueForKey:@"email"];
    if ([strEmailhalf rangeOfString:@"@"].location != NSNotFound && [strEmailhalf rangeOfString:@".com"].location != NSNotFound)
    {
        
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
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    if([[result valueForKey:@"commandName"] isEqualToString:@"fetchdevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableDictionary * dictData = [[NSMutableDictionary alloc]init];
            dictData = [[result valueForKey:@"result"] valueForKey:@"data"];
            if ([[NSString stringWithFormat:@"%@",[dictData valueForKey:@"user_id"]] isEqualToString:CURRENT_USER_ID])
            {
                if ([[NSString stringWithFormat:@"%@",[dictData valueForKey:@"status"]]isEqualToString:@"1"])
                {
                    [self insertIntoLocalDB:dictData];
                }
                else
                {
                    [self removeAllNotifications];
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:self->strBleAddress forKey:@"bleAddress"];
                    
                    CustomDeviceVC * view1 = [[CustomDeviceVC alloc]init];
                    view1.classPeripheral = classPeripheral;
                    view1.deviceDetail = dict;
                    view1.strDeviceStatus = strDeviceStatus;
                    [APP_DELEGATE endHudProcess];
                    [self.navigationController pushViewController:view1 animated:true];
                }
            }
            else
            {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:self->strBleAddress forKey:@"bleAddress"];
                
                [self removeAllNotifications];
                CustomDeviceVC * view1 = [[CustomDeviceVC alloc]init];
                view1.classPeripheral = classPeripheral;
                view1.deviceDetail = dict;
                view1.strDeviceStatus = strDeviceStatus;
                [APP_DELEGATE endHudProcess];
                [self.navigationController pushViewController:view1 animated:true];
            }
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
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc]init];
                [tmpDict setValue:strBleAddress forKey:@"bleAddress"];
                
                [self removeAllNotifications];
                CustomDeviceVC * view1 = [[CustomDeviceVC alloc]init];
                view1.isDeviceAddedButNoDBInfo = true;
                view1.classPeripheral = classPeripheral;
                view1.deviceDetail = tmpDict;
                view1.strDeviceStatus = strDeviceStatus;
                [APP_DELEGATE endHudProcess];
                [self.navigationController pushViewController:view1 animated:true];
                NSLog(@"call custom device here");
            }
            
        }
    }
}
- (void)onError:(NSError *)error
{
    [APP_DELEGATE endHudProcess];
    
    NSLog(@"The error is...%@", error);
    
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}
-(void)insertIntoLocalDB:(NSMutableDictionary *)dictObtained
{
    NSString * strEmail = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"contact_email"]];
    NSString * strMob = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"contact_mobile"]];
    NSString * strName = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"contact_name"]];
    NSString * strCreated = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"created_at"]];
    NSString * strDeviceImgServer = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_image_path"]];
    NSString * server_id = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"id"]];
    NSString * strActive = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"is_active"]];
    NSString * strLat = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"latitude"]];
    NSString * strLong = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"longitude"]];
    NSString * strMarkLost = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"marked_lost"]];
    NSString * strDeviceAlert = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"tracker_device_alert"]];
    NSString * strUpdatedTime = [APP_DELEGATE checkforValidString:[APP_DELEGATE getCurrentTime]];
    NSString * strDeviceName = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"device_name"]];
    NSString * strLastConnectionStatus = [APP_DELEGATE checkforValidString:[dictObtained valueForKey:@"correction_status"]];
    
    if ([strMarkLost isEqualToString:@"NA"])
    {
        strMarkLost = @"0";
    }
    NSString * requestStr =    [NSString stringWithFormat:@"insert into 'Device_Table'('user_id','ble_address','device_name','latitude','longitude','tracker_device_alert','marked_lost','is_active','contact_name','contact_email','contact_mobile','photo_localURL','identifier','created_time','updated_time','correction_status','server_id', 'photo_serverURL') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'%@','%@','%@',\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,strBleAddress,strDeviceName,strLat,strLong,strDeviceAlert,strMarkLost,strActive,strName,strEmail,strMob,@"NA",classPeripheral.identifier,strCreated,strUpdatedTime,strLastConnectionStatus,server_id,strDeviceImgServer];
//    [[DataBaseManager dataBaseManager] execute:requestStr];
    int strIntId = [[DataBaseManager dataBaseManager]executeSw:requestStr];
    NSMutableDictionary * dictHomeInfo = [[NSMutableDictionary alloc] init];
    dictHomeInfo = [dictObtained mutableCopy];
    [dictHomeInfo setValue:server_id forKey:@"server_id"];
    [dictHomeInfo setValue:strDeviceImgServer forKey:@"photo_serverURL"];
    [dictHomeInfo setObject:classPeripheral forKey:@"peripheral"];
    [dictHomeInfo setObject:[NSString stringWithFormat:@"%@",classPeripheral.identifier] forKey:@"identifier"];
    [dictHomeInfo setValue:@"NA" forKey:@"photo_localURL"];
    [dictHomeInfo setValue:strUpdatedTime forKey:@"updated_at"];
    [dictHomeInfo setValue:strBleAddress forKey:@"ble_address"];
    [dictHomeInfo setValue:[NSString stringWithFormat:@"%d",strIntId] forKey:@"id"];
    [dictHomeInfo removeObjectForKey:@"device_image"];
    [homeDashboard SaveAddedDeviceToHome:dictHomeInfo];
    
    if ([[arrayDevice valueForKey:@"bleAddress"] containsObject:strBleAddress])
    {
        NSInteger foundIndexx = [[arrayDevice valueForKey:@"bleAddress"] indexOfObject:strBleAddress];
        if (foundIndexx != NSNotFound)
        {
            if (foundIndexx < [arrayDevice count])
            {
                [arrayDevice replaceObjectAtIndex:foundIndexx withObject:dictHomeInfo];
            }
        }
    }
    else
    {
        [arrayDevice addObject:dictHomeInfo];
    }
    [homeDashboard SaveAddedDeviceToHome:dictHomeInfo];

//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveAddedDeviceToHome" object:dictHomeInfo];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    alert.delegate = self;
    alert.tag = 222;
    [alert showAlertInView:self
                 withTitle:@"KUURV"
              withSubtitle:@"Device has been added successfully."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
#pragma mark - CentralManager Ble delegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}
#pragma mark - Helper Methods
- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{

}
- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        [APP_DELEGATE endHudProcess];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag == 111)
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE logoutAndClearDB];
    }
    else if(alertView.tag == 444)
    {
        [self refreshBtnClick];
        [APP_DELEGATE endHudProcess];
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
}
-(void)SendLostDeviceDetailtoServer
{
    if ([self isNetworkreachable])
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
                [manager1.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
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

-(void)setUpLostDeviceView
{
    //    [[BLEManager sharedManager] :classPeripheral];disconnectDevice
    
    [APP_DELEGATE endHudProcess];
    
    [[BLEManager sharedManager] disconnectDevice:self->classPeripheral];
    
    if (![[self checkforValidString:[self->dictOwner valueForKey:@"email"]] isEqualToString:@"NA"])
    {
//        [self SendLostDeviceDetailtoServer];
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
    [lblLostDevice setText:@"KUURV"];
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self btnIgnoreClicked];
    bool isSentFailed = false;
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
            [self btnIgnoreClicked];
            if ([self isNetworkreachable]==NO)
            {
                isSentFailed = true;

            }
            
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:^{
        if (isSentFailed == true)
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            alert.delegate = self;
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"There is no internet conncetion. Please try again later to send mail."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
            
        }

    }];
}
-(NSString *)getCurrentTime
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    [DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString * currentDateAndTime = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    return currentDateAndTime;
}
-(BOOL)isNetworkreachable
{
    Reachability *networkReachability = [[Reachability alloc] init];
    NetworkStatus networkStatus = [networkReachability internetConnectionStatus];
    if (networkStatus == NotReachable)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
@end
