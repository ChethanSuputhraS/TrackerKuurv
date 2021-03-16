//
//  LeftMenuVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 12/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "LeftMenuVC.h"
#import "LeftMenuCell.h"
#import "LoginVC.h"
#import "HomeVC.h"
#import "HelpVC.h"
#import "Doorbell.h"
#import "AboutUsVC.h"
#import "AccountsVC.h"
#import "URLManager.h"
#import "WebViewVC.h"
@interface LeftMenuVC ()<URLManagerDelegate,FCAlertViewDelegate>
{
}
@end

@implementation LeftMenuVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    arrOptions = [[NSMutableArray alloc] init];
    for (int i = 0; i<6; i++)
    {
        
        NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:@"no" forKey:@"isSelected"];
        if (i==0) {
            [tempDict setValue:@"Home" forKey:@"name"];
            [tempDict setValue:@"active_home_icon.png" forKey:@"image"];
        }
        else if (i==1) {
            [tempDict setValue:@"Account Settings" forKey:@"name"];
            [tempDict setValue:@"settings.png" forKey:@"image"];
        }
        else if (i==2) {
            [tempDict setValue:@"Buy Now" forKey:@"name"];
            [tempDict setValue:@"buy.png" forKey:@"image"];
        }else if (i==3) {
            [tempDict setValue:@"Help" forKey:@"name"];
            [tempDict setValue:@"help_icon.png" forKey:@"image"];
        }else if (i==4) {
            [tempDict setValue:@"About Us" forKey:@"name"];
            [tempDict setValue:@"about.png" forKey:@"image"];
        }else if (i==5) {
            [tempDict setValue:@"Logout" forKey:@"name"];
            [tempDict setValue:@"logout.png" forKey:@"image"];
        }
        
        [arrOptions addObject:tempDict];
    }
    [self setContentViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoorbellPopupSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoorbellPopupSuccess) name:@"DoorbellPopupSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoorbellPopupFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoorbellPopupFailure) name:@"DoorbellPopupFailure" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoorbellPopupNoInternet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoorbellPopupNoInternet) name:@"DoorbellPopupNoInternet" object:nil];
}
#pragma mark - Set Content Frames
-(void)setContentViewFrames
{
    int leftMenuWidth = DEVICE_WIDTH - (50*approaxSize);
    
//    UILabel * lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0,0,leftMenuWidth, 44)];
//    [lblBack setBackgroundColor:global_greenColor];
//    lblBack.hidden = true;
//    [self.view addSubview:lblBack];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0,leftMenuWidth, 160)];
    [viewHeader setBackgroundColor:global_greenColor];
    [self.view addSubview:viewHeader];
    
    UIImageView * imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0,-70, 270, 270)];
    imgLogo.image = [UIImage imageNamed:@"logoIcon.png"];
    imgLogo.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgLogo];
    
    
    UILabel * lblHello = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 50*approaxSize, 30)];
    [lblHello setBackgroundColor:[UIColor clearColor]];
    lblHello.text = @"Hello,";
    lblHello.textAlignment = NSTextAlignmentLeft;
    [lblHello setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblHello setTextColor:global_greyColor];
    [viewHeader addSubview:lblHello];

    UILabel * lblAccName = [[UILabel alloc] initWithFrame:CGRectMake(10+50*approaxSize, 110, 200, 30)];
    [lblAccName setBackgroundColor:[UIColor clearColor]];
    lblAccName.textAlignment = NSTextAlignmentLeft;
    lblAccName.text = [NSString stringWithFormat:@" %@",[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_NAME"]]];
    [lblAccName setFont:[UIFont fontWithName:CGBold size:txtSize]];
    [lblAccName setTextColor:UIColor.whiteColor];
    [viewHeader addSubview:lblAccName];
    
    if ([CURRENT_USER_ID isEqualToString:@"4"])
    {
        lblAccName.text = @"Srivatsa";
    }
    
    UILabel * lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, 135, 240, 25)];
    [lblEmail setBackgroundColor:[UIColor clearColor]];
    lblEmail.text = [NSString stringWithFormat:@"(%@)",CURRENT_USER_EMAIL];
    lblEmail.textAlignment = NSTextAlignmentLeft;
    [lblEmail setFont:[UIFont fontWithName:CGRegularItalic size:txtSize-3]];
    [lblEmail setTextColor:global_greyColor];
    [viewHeader addSubview:lblEmail];
    
    
    tblLeftMenu =[[UITableView alloc]initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170) style:UITableViewStylePlain];
    [tblLeftMenu setBackgroundColor:UIColor.whiteColor];
    tblLeftMenu.showsVerticalScrollIndicator = NO;
    tblLeftMenu.showsHorizontalScrollIndicator=NO;
    tblLeftMenu.scrollEnabled = false;
    [tblLeftMenu setDelegate:self];
    [tblLeftMenu setDataSource:self];
    [tblLeftMenu setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tblLeftMenu];
    
    if (IS_IPHONE_X)
    {
//        lblBack.hidden = false;
        viewHeader.frame = CGRectMake(0,0,leftMenuWidth, 180);
        imgLogo.frame = CGRectMake(0,-50, 270, 270);
        lblHello.frame = CGRectMake(10, 130, 50*approaxSize, 30);
        lblAccName.frame = CGRectMake(10+50*approaxSize, 130, 200, 30);
        lblEmail.frame = CGRectMake(10, 155, 240, 25);
        tblLeftMenu.frame = CGRectMake(0, 180, self.view.frame.size.width, self.view.frame.size.height-222-40);
        
    }
    if (IS_IPHONE_4)
    {
        viewHeader.frame = CGRectMake(0,0,leftMenuWidth, 190);
        tblLeftMenu.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-175);
//        lblHello.frame = CGRectMake(10, 90, 50*approaxSize, 30);
//        lblAccName.frame = CGRectMake(10+50*approaxSize, 90, 200, 30);
//        lblEmail.frame = CGRectMake(10, 115, 240, 25);
    }
}
#pragma mark - Button Click
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
#pragma mark- UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOptions count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[LeftMenuCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblName.text = [NSString stringWithFormat:@"%@",[[arrOptions objectAtIndex:indexPath.row] valueForKey:@"name"]];
    cell.imgIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[arrOptions objectAtIndex:indexPath.row] valueForKey:@"image"]]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        if (homeDashboard)
        {
        }
        else
        {
            homeDashboard =   [[HomeVC alloc] init];
        }
        [homeDashboard callHomeWebServiceForUserLoggedInfo];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"callHomeWebServiceForUserLoggedInfo" object:nil];

        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:homeDashboard];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    }
//    else if (indexPath.row == 1)
//    {
//        LostDeviceVC *demoController = [[LostDeviceVC alloc] init];
//        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
//        NSArray *controllers = [NSArray arrayWithObject:demoController];
//        navigationController.viewControllers = controllers;
//        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
//    }
//    else if (indexPath.row == 2)
//    {
//        NotificationVC *demoController = [[NotificationVC alloc] init];
//        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
//        NSArray *controllers = [NSArray arrayWithObject:demoController];
//        navigationController.viewControllers = controllers;
//        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
//    }
    else if (indexPath.row == 1)
    {
        AccountsVC *demoController = [[AccountsVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if (indexPath.row == 2)
    {
        NSString * strBuyUrl = [NSString stringWithFormat:@"https://www.kuurvtracker.com/buy-now"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strBuyUrl]];
    }
    else if(indexPath.row == 3)
    {
        HelpVC *demoController = [[HelpVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
//        WebViewVC *demoController = [[WebViewVC alloc] init];
//        demoController.btnIndex = 3;
//        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
//        NSArray *controllers = [NSArray arrayWithObject:demoController];
//        navigationController.viewControllers = controllers;
//        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    }
    else if (indexPath.row == 4)
    {
        AboutUsVC *demoController = [[AboutUsVC alloc] init];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if (indexPath.row == 5)
    {
        if (![APP_DELEGATE isNetworkreachable])
        {
            [alertGlobal removeFromSuperview];
           alertGlobal = [[FCAlertView alloc] init];
            alertGlobal.colorScheme = [UIColor blackColor];
            [alertGlobal makeAlertTypeCaution];
            [alertGlobal showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"There is no internet connection. Please connect to internet and then try logging out."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else
        {
            [alertGlobal removeFromSuperview];
            alertGlobal = [[FCAlertView alloc] init];
            alertGlobal.colorScheme = [UIColor blackColor];
            [alertGlobal makeAlertTypeWarning];
            [alertGlobal addButton:@"Yes" withActionBlock:
             ^{
                 [APP_DELEGATE endHudProcess];
                 [APP_DELEGATE startHudProcess:@"Logging out..."];

                 
                 NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
                 [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ID"] forKey:@"user_id"];
                 [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ACCESS_TOKEN"] forKey:@"token"];
                 
                 
                 
                 URLManager *manager = [[URLManager alloc] init];
                 manager.commandName = @"logout";
                 manager.delegate = self;
                 NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/logout";
                 [manager urlCall:strServerUrl withParameters:dict];
                 NSLog(@"sent info for logout is %@",dict);
                 
             }];
            alertGlobal.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
            [alertGlobal showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Are you sure want to Logout?"
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"No" andButtons:nil];
        }

       
    }
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"logout"])
    {
        [APP_DELEGATE endHudProcess];
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSArray * tmpArr = [[BLEManager sharedManager]getLastConnected];
            NSLog(@"last connected arr is %@",[[BLEManager sharedManager]getLastConnected]);
            [[BLEManager sharedManager]stopScan];
            [[[BLEManager sharedManager] foundDevices] removeAllObjects];
            for (int i=0; i<tmpArr.count; i++)
            {
                CBPeripheral * p = [tmpArr objectAtIndex:i];
                [[BLEManager sharedManager]disconnectDevice:p];
            }
            [selectedDeviecDict removeAllObjects];
            [arrayDevice removeAllObjects];
            [arrGlobalDevices removeAllObjects];

            NSString * strDelete = [NSString stringWithFormat:@"delete from UserAccount_Table"];
            [[DataBaseManager dataBaseManager] execute:strDelete];
            
            NSString * strDelete2 = [NSString stringWithFormat:@"delete from Device_Table"];
            [[DataBaseManager dataBaseManager] execute:strDelete2];
            
            NSString * strDelete3 = [NSString stringWithFormat:@"delete from User_Set_Info"];
            [[DataBaseManager dataBaseManager] execute:strDelete3];
//
            [[GIDSignIn sharedInstance] signOut];
            [[GIDSignIn sharedInstance] disconnect];

//            homeDashboard = nil;
            isUserIntialized = YES;
            [homeDashboard LogoutCalled];

            [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isLoggedIn"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CURRENT_USER_NAME"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserDict"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CURRENT_USER_ACCESS_TOKEN"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CURRENT_USER_ID"];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CURRENT_USER_UNIQUEKEY"];
            [[NSUserDefaults standardUserDefaults] setValue:@"Wakey" forKey:@"selectedRingtone"];
            [[NSUserDefaults standardUserDefaults] setValue:@"5" forKey:@"alertDuration"];


            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRememberClicked"] == false)
            {
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CURRENT_USER_EMAIL"];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CURRENT_USER_PASS"];
            }
            [[NSUserDefaults standardUserDefaults]synchronize];

            [APP_DELEGATE movetoLogin];
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
                [alertGlobal removeFromSuperview];
                alertGlobal = [[FCAlertView alloc] init];
                alertGlobal.colorScheme = [UIColor blackColor];
                [alertGlobal makeAlertTypeCaution];
                [alertGlobal showAlertInView:self
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
#pragma mark - FCAlert View Delegate
- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 111)
    {
        [APP_DELEGATE logoutAndClearDB];
    }
}

-(void)DoorbellPopupSuccess
{
    [alertGlobal removeFromSuperview];
    alertGlobal = [[FCAlertView alloc] init];
    alertGlobal.colorScheme = [UIColor blackColor];
    [alertGlobal makeAlertTypeSuccess];
    [alertGlobal showAlertInView:self
                 withTitle:@"KUURV"
              withSubtitle:@"We appreciate your feedback!"
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)DoorbellPopupFailure
{
    [alertGlobal removeFromSuperview];
    alertGlobal = [[FCAlertView alloc] init];
    alertGlobal.colorScheme = [UIColor blackColor];
    [alertGlobal makeAlertTypeCaution];
    [alertGlobal showAlertInView:self
                 withTitle:@"KUURV"
              withSubtitle:@"Please enter valid email id."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)DoorbellPopupNoInternet
{
    [alertGlobal removeFromSuperview];
    alertGlobal = [[FCAlertView alloc] init];
    alertGlobal.colorScheme = [UIColor blackColor];
    [alertGlobal makeAlertTypeCaution];
    [alertGlobal showAlertInView:self
                       withTitle:@"KUURV"
                    withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                 withCustomImage:[UIImage imageNamed:@"logo.png"]
             withDoneButtonTitle:nil
                      andButtons:nil];
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
