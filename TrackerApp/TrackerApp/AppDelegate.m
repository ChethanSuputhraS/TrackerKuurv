//
//  AppDelegate.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 26/03/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeVC.h"
#import "HomeVC.h"
#import "URLManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <objc/runtime.h>
@import Firebase;
@interface AppDelegate ()<URLManagerDelegate,FCAlertViewDelegate>
{

}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //To get current location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLLocationAccuracyBest;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];

    
    [Fabric with:@[[Crashlytics class]]];
    // Use the Firebase library to configure APIs.
    [FIRApp configure];

    //for push notification by sri
    
    isUserIntialized = YES;
    
  
    NSString * tmpStr = [[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_EMAIL"];
    if ([tmpStr isEqualToString:@"benjaminshamoilia@gmail.com"])
    {
        long len = [tmpStr length];
        if (len > 18)
        {
            NSString * newString = [tmpStr substringWithRange:NSMakeRange(0, 18)];
            NSLog(@"rangeeeeeeeeeeeeeeeeeeeeeeeeeeeeee is %@",newString);
            [[NSUserDefaults standardUserDefaults]setValue:newString forKey:@"CURRENT_USER_UNIQUEKEY"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }
//            [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
//    CURRENT_USER_UNIQUEKEY
//    [[NSUserDefaults standardUserDefaults] setValue:@"Vinay@test.com" forKey:@"CURRENT_USER_UNIQUEKEY"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    txtSize = 18;
    
    

//to skip welcome vc when the app is already opened
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTime"] ==  true)
    {
        LoginVC * view1 = [[LoginVC alloc]init];
        UINavigationController * navig = [[UINavigationController alloc]initWithRootViewController:view1];
        self.window = [[UIWindow alloc]init];
        self.window.frame = self.window.bounds;
        self.window.rootViewController = navig;
  
    }
    else
    {
        WelcomeVC * view1 = [[WelcomeVC alloc]init];
        UINavigationController * navig = [[UINavigationController alloc]initWithRootViewController:view1];
        self.window = [[UIWindow alloc]init];
        self.window.frame = self.window.bounds;
        self.window.rootViewController = navig;
        isFirstTime = true;
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isFirstTime"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    globalDeviceToken = @"1234";

 
    
//        CustomDeviceVC * view1 = [[CustomDeviceVC alloc]init];
//        UINavigationController * navig = [[UINavigationController alloc]initWithRootViewController:view1];
//        self.window = [[UIWindow alloc]init];
//        self.window.frame = self.window.bounds;
//        self.window.rootViewController = navig;
//    self.window.rootViewController = navig;

    [self.window makeKeyAndVisible];

    // Override point for customization after application launch.
    
    //FaceBook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    // Add any custom logic here.
    

    
    [GIDSignIn sharedInstance].clientID = @"79795240854-rbtb3ilqq2m4o3qs5orntnofhd3jhj5o.apps.googleusercontent.com";

    [GIDSignIn sharedInstance].delegate = self;

    //Twitter
//    [FIRApp configure];
//        [[Twitter sharedInstance] startWithConsumerKey:@"lw8NlW2GCUDXghXDKDAHvs6we" consumerSecret:@"YAzXWMDodFX7Dt4LjI8g7n0mnsuDu1gn5ycXLq5Q2zYve6JxDa"];
    
    [FIRApp configure];
    [[Twitter sharedInstance] startWithConsumerKey:@"eg2VopEBkPVpbYByG12mc34eU" consumerSecret:@"iLnedbaKCIxLo20ZUn98PCnTCm2jdlvZyE3D5E26cFNXbC2kN0"];
    
    
    if (IS_IPHONE_6plus)
    {
        approaxSize = 1.29;
    }
    else if (IS_IPHONE_6)
    {
        approaxSize = 1.17;
    }
    else
    {
        approaxSize = 1;
    }
    [self updateBackgroundImages];

    [self createDatabase];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *  path = [paths objectAtIndex:0];
    NSLog(@"data base path:%@",[path stringByAppendingPathComponent:@"tracker.sqlite"]);
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"AllDefaultSet"] isEqualToString:@"YES"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"IS_SEPERATION_ALERT"];
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"AllDefaultSet"];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"IS_REPEAT_ALERT"];
        [[NSUserDefaults standardUserDefaults] setValue:@"Wakey" forKey:@"selectedRingtone"];
        [[NSUserDefaults standardUserDefaults] setValue:@"5" forKey:@"alertDuration"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if (intSocialClicked == 0)
    {
        if (@available(iOS 9.0, *)) {
            BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                          openURL:url
                                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                            ];
            // Add any custom logic here.
            return handled;
        } else {
            // Fallback on earlier versions
        }
    }
    else if (intSocialClicked == 1)
    {
        return [[GIDSignIn sharedInstance] handleURL:url];

        /*
        if (@available(iOS 9.0, *))
        {
            return [[GIDSignIn sharedInstance] handleURL:url
                                       sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                              annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        } else {
            // Fallback on earlier versions
        }if (@available(iOS 9.0, *)) {
            return [[GIDSignIn sharedInstance] handleURL:url
                                       sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                              annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        } else {
            // Fallback on earlier versions
        }
         */
    }
    else if(intSocialClicked == 2)
    {
        return [[Twitter sharedInstance] application:application openURL:url options:options];
    }
    
    return true;
    
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if (intSocialClicked == 0)
    {
        BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                   annotation:annotation
                        ];
        // Add any custom logic here.
        return handled;
    }
    else if (intSocialClicked == 1)
    {
        return [[GIDSignIn sharedInstance] handleURL:url];

//        return [[GIDSignIn sharedInstance] handleURL:url
//                                   sourceApplication:sourceApplication
//                                          annotation:annotation];
    }
    return true;
}
/*
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error
{
                    // For client-side use only!
    if (error != nil) {
        if (error.code == kGIDSignInErrorCodeHasNoAuthInKeychain)
        {
            NSLog(@"The user has not signed in before or they have since signed out.");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        return;
    }
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
    NSString *givenName = user.profile.givenName;
    NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    
    NSMutableDictionary * googleDict = [[NSMutableDictionary alloc]init];
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.userID] forKey:@"userId"] ;
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.profile.name] forKey:@"name"] ;                  // For client-side use only!
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.profile.email] forKey:@"email"] ;                  // For client-side use only!

    NSLog(@"Fetched User Information from Gmail Login :email id :%@, full name : %@,user ID : %@",user.profile.email,user.profile.name,user.userID);
    
    if (!error)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getGoogleInfo" object:googleDict];
    }
}
 */
/*
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    
    NSMutableDictionary * googleDict = [[NSMutableDictionary alloc]init];
    
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.userID] forKey:@"userId"] ;                  // For client-side use only!
//    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.profile.name] forKey:@"name"] ;                  // For client-side use only!
//    NSString *givenName = user.profile.givenName;
//    NSString *familyName = user.profile.familyName;
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.profile.email] forKey:@"email"] ;                  // For client-side use only!
    // ...
    NSLog(@"Fetched User Information from Gmail Login :email id :%@, full name : %@,user ID : %@",user.profile.email,user.profile.name,user.userID);
    
    if (!error)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getGoogleInfo" object:googleDict];
    }

}
 */
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}
#pragma mark - Go To Dashboard
-(void)goToHome
{
    sideMenuViewController = [[LeftMenuVC alloc] init];
    container = [MFSideMenuContainerViewController containerWithCenterViewController:[self navigationController] leftMenuViewController:sideMenuViewController rightMenuViewController:nil];
    container.navigationController.navigationBar.hidden = YES;
    self.window.rootViewController = container;
}
- (UINavigationController *)navigationController
{
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[self demoController]];
    nav.navigationBar.hidden = YES;
    return nav;
}
- (HomeVC *)demoController
{
    if (homeDashboard)
    {
    }
    else
    {
        homeDashboard = [[HomeVC alloc] init];
    }
    return homeDashboard;
}
-(void)movetoLogin
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[UIApplication sharedApplication] keyWindow] cache:YES];
    [UIView commitAnimations];
    
    LoginVC * splash = [[LoginVC alloc] init];
    UINavigationController * navControl = [[UINavigationController alloc] initWithRootViewController:splash];
    navControl.navigationBarHidden=YES;
    self.window.rootViewController = navControl;
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
#pragma mark - Error Message
-(void)ShowErrorPopUpWithErrorCode:(NSInteger)errorCode andMessage:(NSString*)errorMessage
{
    UIApplication *app=[UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateBackground)
    {
        return;
    }
    [APP_DELEGATE endHudProcess];
    
    NSString * strErrorMessage;
    if (errorCode == -1004){
        strErrorMessage = @"Could not connect to the server";
    }    else if (errorCode == -1009){
        strErrorMessage = @"No Network Connection";
    }else if (errorCode == -1005){
        strErrorMessage = @"Network Connection Lost";
        //        strErrorMessage = @"";
    }else if (errorCode == -1001){
        strErrorMessage = @"Request Timed Out";
    }else if (errorCode == customErrorCodeForMessage){//custom message
        strErrorMessage = errorMessage;
    }else if (errorCode == -1010){//custom message
        strErrorMessage = errorMessage;
    }
    
    [viewNetworkConnectionPopUp removeFromSuperview];
    [viewNetworkConnectionPopUp setAlpha:0.0];
    
    if (![strErrorMessage isEqualToString:@""])
    {
        viewNetworkConnectionPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, -64, DEVICE_WIDTH, 64)];
        [viewNetworkConnectionPopUp setBackgroundColor:[UIColor clearColor]];
        [self.window addSubview:viewNetworkConnectionPopUp];
        
        UIView * viewTrans = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewNetworkConnectionPopUp.frame.size.width, viewNetworkConnectionPopUp.frame.size.height)];
        [viewTrans setBackgroundColor:[UIColor redColor]];
        [viewTrans setAlpha:0.9];
        [viewNetworkConnectionPopUp addSubview:viewTrans];
        
        UIImageView * imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(50, 24, 16, 16)];
        [imgProfile setImage:[UIImage imageNamed:@"cross.png"]];
        imgProfile.contentMode = UIViewContentModeScaleAspectFit;
        imgProfile.clipsToBounds = YES;
        //[viewNetworkConnectionPopUp addSubview:imgProfile];
        
        UILabel * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, DEVICE_WIDTH-40, 44)];
        [lblMessage setBackgroundColor:[UIColor clearColor]];
        [lblMessage setTextColor:[UIColor whiteColor]];
        [lblMessage setTextAlignment:NSTextAlignmentCenter];
        [lblMessage setNumberOfLines:2];
        [lblMessage setText:[NSString stringWithFormat:@"%@",strErrorMessage]];
        [lblMessage setFont:[UIFont systemFontOfSize:14]];
        [viewNetworkConnectionPopUp addSubview:lblMessage];
        
        [UIView transitionWithView:viewNetworkConnectionPopUp duration:0.3
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [self->viewNetworkConnectionPopUp setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
                        }
                        completion:^(BOOL finished) {
                        }];
    }
    
    [timerNetworkConnectionPopUp invalidate];
    timerNetworkConnectionPopUp = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeNetworkConnectionPopUp:) userInfo:nil repeats:NO];
}
-(void)removeNetworkConnectionPopUp:(NSTimer*)timer
{
    [APP_DELEGATE endHudProcess];
    
    [UIView transitionWithView:viewNetworkConnectionPopUp duration:0.3
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        [self->viewNetworkConnectionPopUp setFrame:CGRectMake(0, -64, DEVICE_WIDTH, 64)];
                    }
                    completion:^(BOOL finished)
     {
         [self->viewNetworkConnectionPopUp removeFromSuperview];
     }];
}

#pragma mark Hud Method
-(void)startHudProcess:(NSString *)text
{
    [HUD removeFromSuperview];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    HUD.labelText = text;
    [self.window addSubview:HUD];
    [HUD show:YES];
}
-(void)endHudProcess
{
    [HUD removeFromSuperview];

    [HUD hide:YES];
}
-(void)updateBackgroundImages
{
    if (IS_IPHONE_4)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone4" forKey:@"globalBackGroundImage"];
    }
    else if (IS_IPHONE_5)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone5" forKey:@"globalBackGroundImage"];
    }
    else if (IS_IPHONE_6)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone6" forKey:@"globalBackGroundImage"];
        
    }
    else if (IS_IPHONE_6plus)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphone6+" forKey:@"globalBackGroundImage"];
        
    }
    else if (IS_IPHONE_X)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"iphonex" forKey:@"globalBackGroundImage"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}
#pragma mark - data Database
-(void)createDatabase
{
    [[DataBaseManager dataBaseManager] Create_UserAccount_Table];
    [[DataBaseManager dataBaseManager] Create_Device_Table];
    [[DataBaseManager dataBaseManager] Create_User_Set_Info];
}

#pragma mark - Global Helper Functions
-(BOOL)validateEmail:(NSString*)email
{
    if( (0 != [email rangeOfString:@"@"].length) &&  (0 != [email rangeOfString:@"."].length) )
    {
        NSMutableCharacterSet *invalidCharSet = [[[NSCharacterSet alphanumericCharacterSet] invertedSet]mutableCopy];
        [invalidCharSet removeCharactersInString:@"_-"];
        
        NSRange range1 = [email rangeOfString:@"@" options:NSCaseInsensitiveSearch];
        
        // If username part contains any character other than "."  "_" "-"
        
        NSString *usernamePart = [email substringToIndex:range1.location];
        NSArray *stringsArray1 = [usernamePart componentsSeparatedByString:@"."];
        for (NSString *string in stringsArray1)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet: invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return FALSE;
        }
        
        NSString *domainPart = [email substringFromIndex:range1.location+1];
        NSArray *stringsArray2 = [domainPart componentsSeparatedByString:@"."];
        
        for (NSString *string in stringsArray2)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:invalidCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return FALSE;
        }
        
        return TRUE;
    }
    else
    {// no '@' or '.' present
        
        return FALSE;
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [playerWhenDisconnect stop];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"])
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
//            [APP_DELEGATE endHudProcess];
//            [APP_DELEGATE startHudProcess:@"Logout...."];
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            
            [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ID"] forKey:@"user_id"];
            [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ACCESS_TOKEN"] forKey:@"token"];
            
            
            URLManager *manager = [[URLManager alloc] init];
            manager.commandName = @"crush";
            manager.delegate = self;
            NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/crash";
            [manager urlCall:strServerUrl withParameters:dict];
            NSLog(@"crush logout info is %@",dict);
        }
        else
        {
        
        }

        
    }
   
    
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    strCurrentDateNTime =  [self checkforValidString:[self getCurrentTime]];
    NSArray * foundDev = [[BLEManager sharedManager] foundDevices];
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
                        NSString * strBle = [[arrayDevice objectAtIndex:indexx]valueForKey:@"ble_address"];
                        NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set updated_time ='%@',latitude = '%f',longitude = '%f',correction_status = '%@' where ble_address = '%@'",strCurrentDateNTime,currentLatitude,currentLongitude,@"0",strBle];
                        [[DataBaseManager dataBaseManager] execute:strUpdate];
                        
                        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",currentLatitude] forKey:[NSString stringWithFormat:@"lat_%@",strBle]];
                        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",currentLongitude] forKey:[NSString stringWithFormat:@"long_%@",strBle]];
                        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:[NSString stringWithFormat:@"status_%@",strBle]];
                        [[NSUserDefaults standardUserDefaults] setValue:strCurrentDateNTime forKey:[NSString stringWithFormat:@"time_%@",strBle]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        NSLog(@" ---------------------------------------------------------->%@",[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"time_%@",strBle]]);
                        [self updateDatatoServer:[arrayDevice objectAtIndex:indexx]];
                        
                    }
                }
                
            }
        }
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)updateDatatoServer:(NSMutableDictionary *)deviceDetail
{
    NSString * strBleAddress = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"ble_address"]];
    NSString * strLat = [NSString stringWithFormat:@"%f", currentLatitude];
    NSString * strLong = [NSString stringWithFormat:@"%f", currentLongitude];
    NSString * strDeviceName = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"device_name"]];
    NSString * strOwnerName = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_name"]];
    NSString * strOwnerEmail = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_email"]];
    NSString * strMobile = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_mobile"]];
//    NSString * strConnectionStatus = @"0";
    NSString * strCurrentTime = [self checkforValidString:[self getCurrentTime]];
    if ([[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"marked_lost"]]isEqualToString:@"NA"])
    {
        [deviceDetail setValue:@"0" forKey:@"marked_lost"];
    }
    
    
    if([[self checkforValidString:[deviceDetail valueForKey:@"is_active"]] isEqualToString:@"1"])
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ID"] forKey:@"user_id"];
            [dict setValue:strBleAddress forKey:@"ble_address"];
            [dict setValue:@"2" forKey:@"device_type"];
            [dict setValue:strLat forKey:@"latitude"];
            [dict setValue:strLong forKey:@"longitude"];
            [dict setValue:[deviceDetail valueForKey:@"tracker_device_alert"] forKey:@"tracker_device_alert"];
            [dict setValue:[deviceDetail valueForKey:@"marked_lost"] forKey:@"marked_lost"];
            [dict setValue:@"1" forKey:@"is_active"];
            [dict setValue:strOwnerName forKey:@"contact_name"];
            [dict setValue:strOwnerEmail forKey:@"contact_email"];
            [dict setValue:strMobile forKey:@"contact_mobile"];
            [dict setValue:strDeviceName forKey:@"device_name"];
            [dict setValue:@"0" forKey:@"correction_status"];
            [dict setValue:[deviceDetail valueForKey:@"server_id"] forKey:@"device_id"];

            URLManager *manager = [[URLManager alloc] init];
            manager.commandName = @"adddevice";
            manager.delegate = self;
            NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/adddevice";
            [manager urlCall:strServerUrl withParameters:dict];
            NSLog(@"sent info for adddevice Appdelegate %@",dict);
            NSLog(@"updated time is %@",[self changeDateFormat:strCurrentTime]);

            
        }
    }
}
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
// This code block is invoked when application is in foreground (active-mode)
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIViewController *vc = self.window.rootViewController;
    
    if (![notification.alertBody containsString:@"has been connected"])
    {
        [alertGlobal removeFromSuperview];
        alertGlobal = [[FCAlertView alloc] init];
        alertGlobal.colorScheme = [UIColor blackColor];
        [alertGlobal makeAlertTypeWarning];
        [alertGlobal showAlertInView:vc
                           withTitle:@"KUURV"
                        withSubtitle:notification.alertBody
                     withCustomImage:[UIImage imageNamed:@"logo.png"]
                 withDoneButtonTitle:nil
                          andButtons:nil];
    }
   

//    UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"KUURV"    message:notification.alertBody
//                                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [notificationAlert show];
}
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:   (UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString   *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)(void))completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       globalDeviceToken = [[[[deviceToken description]
                                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                             stringByReplacingOccurrencesOfString: @">" withString: @""]
                                            stringByReplacingOccurrencesOfString: @" " withString: @""] ;
                       NSLog(@"My device token ============================>>>>>>>>>>>%@",globalDeviceToken);
                   });

    
    
    // Pass device token to auth.
    //    [[FIRAuth auth] setAPNSToken:deviceToken type:FIRAuthAPNSTokenTypeProd];
    // Further handling of the device token if needed by the app.
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //    NSLog(@"Failed to get token, error: %@", error);
}
-(NSString *)getCurrentTime
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    [DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString * currentDateAndTime = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    return currentDateAndTime;
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    NSLog(@"The result is...%@", result);
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"crush"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            
        }
        else
        {
            UIViewController *vc = self.window.rootViewController;
            
            [alertGlobal removeFromSuperview];
            alertGlobal = [[FCAlertView alloc] init];
            alertGlobal.colorScheme = [UIColor blackColor];
            alertGlobal.delegate = self;
            alertGlobal.tag = 111;
            [alertGlobal makeAlertTypeCaution];
            [alertGlobal showAlertInView:vc
                         withTitle:@"KUURV"
                      withSubtitle:@"User logged in from different device,so automatically logging out."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        
        }
    }
}
- (void)onError:(NSError *)error
{
    
    NSLog(@"The error is...%@", error);
    
    
//    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
//    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
//    } else {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
//    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 111)
    {
        [self logoutAndClearDB];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}
/*
- (NSString *)dateValueFromDate:(NSString *)dateStr withGiveDatetoShow:(NSString *)strAttachDate
{
    NSString * globalDateFormat = [NSString stringWithFormat:@"dd-MM-yyyy hh:mm:ss"];
    
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:globalDateFormat];
//    NSTimeZone *gmt = [NSTimeZone localTimeZone];]
    [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

//    [_formatter setTimeZone:gmt];
    NSDate * serverDate =[_formatter dateFromString:dateStr];
    [_formatter setDateFormat:globalDateFormat];
    
    //    NSString * strDateConverted =[_formatter stringFromDate:serverDate];
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *compenents = [calender components:(NSCalendarUnitYear |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay |
                                                         NSCalendarUnitHour |
                                                         NSCalendarUnitMinute |
                                                         NSCalendarUnitSecond) fromDate:serverDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"dd-MM-yyyy hh:mm:ss"]];
    NSString *currnetDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDateComponents *currentDateComponents = [calender components:(NSCalendarUnitYear |
                                                                    NSCalendarUnitMonth |
                                                                    NSCalendarUnitDay |
                                                                    NSCalendarUnitHour |
                                                                    NSCalendarUnitMinute |
                                                                    NSCalendarUnitSecond) fromDate:[dateFormatter dateFromString:currnetDate]];
    if (compenents.year < currentDateComponents.year)
    {
        if (currentDateComponents.year - compenents.year <= 0)
        {
            return [NSString stringWithFormat:@"%@ 0 Years ago",strAttachDate];
            
        }
        NSString * strReturn = [NSString stringWithFormat:@"%li",(currentDateComponents.year - compenents.year)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@ %li Year ago",strAttachDate,(currentDateComponents.year - compenents.year)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@ %li Years ago",strAttachDate,(currentDateComponents.year - compenents.year)];
        }
    }
    else if (compenents.month < currentDateComponents.month)
    {
        if (currentDateComponents.month - compenents.month <= 0)
        {
            return [NSString stringWithFormat:@"%@ 0 Months ago",strAttachDate];
            
        }
        NSString * strReturn = [NSString stringWithFormat:@"%li",(currentDateComponents.month - compenents.month)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@  %li Month ago",strAttachDate,(currentDateComponents.month - compenents.month)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@  %li Months ago",strAttachDate,(currentDateComponents.month - compenents.month)];
        }
    }
    else if (compenents.day < currentDateComponents.day)
    {
        if (currentDateComponents.day - compenents.day <= 0)
        {
            return [NSString stringWithFormat:@"%@ 0 Days ago",strAttachDate];
            
        }
        
        NSString * strReturn = [NSString stringWithFormat:@"%li",(currentDateComponents.day - compenents.day)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@  %li Day ago",strAttachDate,(currentDateComponents.day - compenents.day)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@  %li Days ago",strAttachDate,(currentDateComponents.day - compenents.day)];
        }
    }
    else if (compenents.hour < currentDateComponents.hour)
    {
        if (currentDateComponents.hour - compenents.hour <= 0)
        {
            return [NSString stringWithFormat:@"%@ 0 Hour ago",strAttachDate];

        }
        NSString * strReturn = [NSString stringWithFormat:@"%li",(currentDateComponents.hour - compenents.hour)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@  %li Hour ago",strAttachDate,(currentDateComponents.hour - compenents.hour)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@  %li Hours ago",strAttachDate,(currentDateComponents.hour - compenents.hour)];
        }
    }
    else if(compenents.minute < currentDateComponents.minute)
    {
        if (currentDateComponents.minute - compenents.minute <= 0)
        {
            return [NSString stringWithFormat:@"%@ 0 Minutes ago",strAttachDate];
            
        }
        
        NSString * strReturn = [NSString stringWithFormat:@"%li",(currentDateComponents.minute - compenents.minute)];
        if ([strReturn isEqualToString:@"1"])
        {
            return [NSString stringWithFormat:@"%@  %li Minute ago",strAttachDate,(currentDateComponents.minute - compenents.minute)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@  %li Minutes ago",strAttachDate,(currentDateComponents.minute - compenents.minute)];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%@  0 Minutes ago",strAttachDate];
    }
    return kEmptyString;
}
 */
-(void)logoutAndClearDB
{
    NSArray * tmpArr = [[BLEManager sharedManager]getLastConnected];
    [[BLEManager sharedManager] stopScan];
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
//    homeDashboard = nil;
    isUserIntialized = YES;

     [homeDashboard LogoutCalled];
    
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
    
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] disconnect];


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
-(NSString *)changeDateFormat:(NSString *)dateStr 
{
    NSString * dateString = [APP_DELEGATE checkforValidString:dateStr];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"LLLL dd yyyy 'at' h:mm a"];
    NSString *stringDate = [dateFormatter2 stringFromDate:dateFromString];
    
    return stringDate;
}
-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color
{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
          UILabel *placeholderLabel = object_getIvar(txtField, ivar);
          placeholderLabel.textColor = color;
}
#pragma mark - Map, CLLocation Deletgate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = locations.lastObject;    //new loc
    CLLocation *oldLocation;
    if (locations.count > 1) {
        oldLocation = locations[locations.count - 2];
    }
    if (newLocation != oldLocation)
    {
        currentLatitude = newLocation.coordinate.latitude;
        currentLongitude = newLocation.coordinate.longitude;
        [[NSUserDefaults standardUserDefaults] setDouble:currentLatitude forKey:@"last_latitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:currentLongitude forKey:@"last_longitude"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        currentLocations = newLocation;
        
        if (isLocationGot == NO)
        {
            isLocationGot = YES;
            [homeDashboard LocationEnabled];
        }
    }
}

//-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//
//
////    [locationManager stopUpdatingLocation];
//}

@end
