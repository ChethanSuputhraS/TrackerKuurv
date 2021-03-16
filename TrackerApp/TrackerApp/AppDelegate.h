//
//  AppDelegate.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 26/03/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <TwitterKit/TwitterKit.h>
#import "LeftMenuVC.h"
#import "MFSideMenu.h"
#import "MBProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "HomeVC.h"
@import GoogleSignIn;
@import Firebase;

#import "LoginVC.h"

NSString * globalDeviceToken,*isAddingDeviceStirng;
int txtSize;
int intSocialClicked, globalCount;
NSInteger approaxSize, updatedRSSI;
LeftMenuVC *sideMenuViewController;
MFSideMenuContainerViewController * container;
bool isFeedbackOpen;
BOOL isCheckforDashScann;
BOOL isConnectedtoAdd;
float currentLatitude;
float currentLongitude;
NSMutableArray * arrGlobalDevices, *arrayDevice;
CBPeripheral * globalPeripheral;
CLLocationManager *locationManager;
AVAudioPlayer *playerWhenDisconnect;
NSString * strCurrentDateNTime;
HomeVC * homeDashboard;
BOOL isAddDeviceScreen;
BOOL isUserIntialized, isUserfromLogin;
NSMutableDictionary * selectedDeviecDict;
FCAlertView * alertGlobal;
BOOL isLocationGot;
BOOL isUserLoggedAndDontEndHudProcess;
UIAlertController * globalAlertPopUP;
CLLocation * lastLocations, * currentLocations;
@interface AppDelegate : UIResponder <UIApplicationDelegate,GIDSignInDelegate,CLLocationManagerDelegate>
{
    MBProgressHUD *HUD;
    UIView * viewNetworkConnectionPopUp;
    NSTimer * timerNetworkConnectionPopUp;
    BOOL isFirstTime;

}
@property (strong, nonatomic) UIWindow *window;


#pragma mark - Helper Methods
-(void)goToHome;
-(void)movetoLogin;
-(void)startHudProcess:(NSString *)text;
-(void)endHudProcess;
-(BOOL)validateEmail:(NSString*)email;
-(BOOL)isNetworkreachable;
-(void)ShowErrorPopUpWithErrorCode:(NSInteger)errorCode andMessage:(NSString*)errorMessage;
-(NSString *)checkforValidString:(NSString *)strRequest;
-(NSString *)changeDateFormat:(NSString *)dateStr ;
-(NSString *)getCurrentTime;
-(void)logoutAndClearDB;
-(void)getPlaceholderText:(UITextField *)txtField  andColor:(UIColor*)color;
@end

