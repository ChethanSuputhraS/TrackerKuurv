//
//  LoginVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 26/03/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "LoginVC.h"
#import "HomeVC.h"
#import "ForgotVC.h"
#import "WebViewVC.h"
#import <AuthenticationServices/AuthenticationServices.h>
@interface LoginVC ()<URLManagerDelegate,FCAlertViewDelegate, UIGestureRecognizerDelegate,ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@end

@implementation LoginVC

- (void)viewDidLoad
{
    setCurrentIdentifier = @"setCurrentIdentifier";
    isUserfromLogin = YES;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"])
    {
        isUserLoggedAndDontEndHudProcess = false;
        isUserfromLogin = NO;
        [APP_DELEGATE goToHome];
        return;
    }
    [[APP_DELEGATE window] setBackgroundColor:global_greenColor];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.navigationController setNavigationBarHidden:true];
    
     socialDict = [[NSMutableDictionary alloc]init];

    [self setContentViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // google
    [GIDSignIn sharedInstance].delegate = self;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGoogleInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGoogleInfo:) name:@"getGoogleInfo" object:nil];
    
    if (@available(iOS 13.0, *)) {
              [self observeAppleSignInState];
//              [self setupUI];
          }
}
/*
- (void)setupUI {

    // Sign In With Apple


//    if (@available(iOS 13.0, *)) {
//    // Sign In With Apple Button
//    ASAuthorizationAppleIDButton *appleIDButton = [ASAuthorizationAppleIDButton new];
//
//    appleIDButton.frame =  CGRectMake(.0, .0, CGRectGetWidth(self.view.frame) - 40.0, 100.0);
//    CGPoint origin = CGPointMake(20.0, CGRectGetMidY(self.view.frame));
//    CGRect frame = appleIDButton.frame;
//    frame.origin = origin;
//    appleIDButton.frame = frame;
//    appleIDButton.cornerRadius = CGRectGetHeight(appleIDButton.frame) * 0.25;
////    [self.view addSubview:appleIDButton];
//    [appleIDButton addTarget:self action:@selector(handleAuthrization:) forControlEvents:UIControlEventTouchUpInside];
//    }
//
//    NSMutableString *mStr = [NSMutableString string];
//    [mStr appendString:@"Sign In With Apple \n"];
//    appleIDLoginInfoTextView.text = [mStr copy];
}
 */
//apple Signin delegates
 - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)){

    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", controller);
    NSLog(@"%@", authorization);

    NSLog(@"authorization.credential：%@", authorization.credential);

    NSMutableString *mStr = [NSMutableString string];
//    mStr = [appleIDLoginInfoTextView.text mutableCopy];

    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *user = appleIDCredential.user;
        [[NSUserDefaults standardUserDefaults] setValue:user forKey:setCurrentIdentifier];
        [mStr appendString:user?:@""];
        
//        NSString *familyName = appleIDCredential.fullName.familyName;
//        [mStr appendString:familyName?:@""];
        NSString *givenName = appleIDCredential.fullName.givenName;
        NSLog(@"obtained name is %@",givenName);
        NSString *email = appleIDCredential.email;
        [mStr appendString:email?:@""];
        NSLog(@"obtained email id  is %@",email);
        [mStr appendString:@"\n"];
        NSLog(@"obtained unique id  is %@",appleIDCredential.user);
//        appleIDLoginInfoTextView.text = mStr;
                
        if (![[APP_DELEGATE checkforValidString:appleIDCredential.user]isEqualToString:@"NA"])
        {
            intSocialClicked = 3;

            if ([[APP_DELEGATE checkforValidString:email]isEqualToString:@"NA"])
            {
                email = @"";
                givenName = @"";
            }
            [socialDict setValue:[APP_DELEGATE checkforValidString:email] forKey:@"email"];
                       [socialDict setValue:[APP_DELEGATE checkforValidString:givenName] forKey:@"name"];
                       [socialDict setValue:@"apple" forKey:@"social_type"];
                       [socialDict setValue:@"YES" forKey:@"isfromsocial"];
                       [socialDict setValue:[APP_DELEGATE checkforValidString:appleIDCredential.user] forKey:@"social_id"];
            
            if ([APP_DELEGATE isNetworkreachable])
            {
                [self loginViaEmailWebService];
            }
            else
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"We are not able to fetch your email from here, Please try with different login method."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        ASPasswordCredential *passwordCredential = authorization.credential;
        NSString *user = passwordCredential.user;
        NSString *password = passwordCredential.password;
        [mStr appendString:user?:@""];
        [mStr appendString:password?:@""];
        [mStr appendString:@"\n"];
        NSLog(@"mStr：%@", mStr);
//        appleIDLoginInfoTextView.text = mStr;
    } else {
         mStr = [@"check" mutableCopy];
//        appleIDLoginInfoTextView.text = mStr;
    }
}


- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0))
{
    FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"We are not able to fetch your email from here, Please try with different login method."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];

    NSLog(@"%s", __FUNCTION__);
    NSLog(@"error ：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"ASAuthorizationErrorCanceled";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"ASAuthorizationErrorFailed";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"ASAuthorizationErrorInvalidResponse";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"ASAuthorizationErrorNotHandled";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"ASAuthorizationErrorUnknown";
            break;
    }

//    NSMutableString *mStr = [appleIDLoginInfoTextView.text mutableCopy];
//    [mStr appendString:errorMsg];
//    [mStr appendString:@"\n"];
//    appleIDLoginInfoTextView.text = [mStr copy];

    if (errorMsg) {
        return;
    }

    if (error.localizedDescription) {
//        NSMutableString *mStr = [appleIDLoginInfoTextView.text mutableCopy];
//        [mStr appendString:error.localizedDescription];
//        [mStr appendString:@"\n"];
//        appleIDLoginInfoTextView.text = [mStr copy];
    }
    NSLog(@"controller requests：%@", controller.authorizationRequests);
    /*
     ((ASAuthorizationAppleIDRequest *)(controller.authorizationRequests[0])).requestedScopes
     <__NSArrayI 0x2821e2520>(
     full_name,
     email
     )
     */
}

//! Tells the delegate from which window it should present content to the user.
 - (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){

    NSLog(@"window：%s", __FUNCTION__);
    return self.view.window;
}

//- (void)dealloc {
//
//    if (@available(iOS 13.0, *)) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
//    }
//}

- (void)btnAppleClicked
{
    if (@available(iOS 13.0, *)) {
        // A mechanism for generating requests to authenticate users based on their Apple ID.
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];

        // Creates a new Apple ID authorization request.
        ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
        // The contact information to be requested from the user during authentication.
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

        // A controller that manages authorization requests created by a provider.
        ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];

        // A delegate that the authorization controller informs about the success or failure of an authorization attempt.
        controller.delegate = self;

        // A delegate that provides a display context in which the system can present an authorization interface to the user.
        controller.presentationContextProvider = self;

        // starts the authorization flows named during controller initialization.
        [controller performRequests];
    }
}
- (void)observeAppleSignInState {
    if (@available(iOS 13.0, *)) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}

- (void)handleSignInWithAppleStateChanged:(id)noti {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", noti);
}
-(void)viewWillAppear:(BOOL)animated
{
    if (globalAlertPopUP)
    {
        [globalAlertPopUP removeFromParentViewController];
        
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRememberClicked"] == true)
    {
        if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_EMAIL"]]isEqualToString:@"NA"])
        {
            txtEmailLogin.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_EMAIL"];
        }
        else
        {
            txtEmailLogin.text = @"";
            txtEmailLogin.placeholder = @"Email";
        }
        if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_PASS"]]isEqualToString:@"NA"])
        {
            txtPasswordLogin.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_PASS"];
        }
        else
        {
            txtPasswordLogin.text = @"";
            txtPasswordLogin.placeholder = @"Password";
        }
        isRememberClicked = true;
        imgRemember.image = [UIImage imageNamed:@"checkboxSelected.png"];
    }
}
-(void)setContentViewFrames
{
    int hh = 20;
    if (IS_IPHONE_X)
    {
        hh = 40;
    }
    
    UIImageView *imgback = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    imgback.backgroundColor = UIColor.clearColor;
    imgback.image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults]valueForKey:@"globalBackGroundImage"]];
    [self.view addSubview:imgback];
    
    //   login view
    loginView = [[UIView alloc]initWithFrame:CGRectMake(0, hh, DEVICE_WIDTH, DEVICE_HEIGHT-hh)];
    loginView.backgroundColor = UIColor.clearColor;
    loginView.hidden = false;
    [self.view addSubview:loginView];
    
    UITapGestureRecognizer * tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tapGest.delegate = self;
    [loginView addGestureRecognizer:tapGest];
    
    int yy = 0;
    UILabel *lblLogin = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/2)-60, yy, 120, 44)];
    lblLogin.backgroundColor = UIColor.clearColor;
    lblLogin.text = @"Log in";
    lblLogin.layer.masksToBounds = true;
    lblLogin.textColor = UIColor.whiteColor;
    lblLogin.textAlignment = NSTextAlignmentCenter;
    lblLogin.font = [UIFont fontWithName:CGBold size:txtSize+5];
    [loginView addSubview:lblLogin];
    
    if (IS_IPHONE_4)
    {
        hh = hh-40;
    }
    else if (IS_IPHONE_5 )
    {
        hh = hh-20;
    }
    else if (IS_IPHONE_6 )
    {
        hh = hh+20;
    }
    else if (IS_IPHONE_6plus)
    {
        hh = hh+30;
    }
    else if (IS_IPHONE_X)
    {
        hh = hh-hh+20;
    }
    UIView * loginViewComp = [[UIView alloc]init];
    loginViewComp.backgroundColor = UIColor.clearColor;
    loginViewComp.frame = CGRectMake(0, hh, DEVICE_WIDTH, DEVICE_HEIGHT-hh);
    [loginView addSubview:loginViewComp];
    
    yy = yy+44+30;
    txtEmailLogin = [[UIFloatLabelTextField alloc]init];
    txtEmailLogin.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtEmailLogin.textAlignment = NSTextAlignmentLeft;
    txtEmailLogin.backgroundColor = UIColor.clearColor;
    //    [txtEmailLogin setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtEmailLogin.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmailLogin.floatLabelPassiveColor = global_greyColor;
    txtEmailLogin.floatLabelActiveColor = global_greyColor;
    txtEmailLogin.placeholder = @"Email";
    txtEmailLogin.delegate = self;
    txtEmailLogin.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmailLogin.textColor = global_greyColor;
    txtEmailLogin.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtEmailLogin.keyboardType = UIKeyboardTypeEmailAddress;
    txtEmailLogin.returnKeyType = UIReturnKeyNext;
    [loginViewComp addSubview:txtEmailLogin];
    [APP_DELEGATE getPlaceholderText:txtEmailLogin andColor:global_greyColor];
    
    lblEmailLoginLine = [[UILabel alloc]init];
    lblEmailLoginLine.backgroundColor = global_greyColor;
    lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtEmailLogin addSubview:lblEmailLoginLine];
    
    lblEmailErrorMsgLogin = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblEmailErrorMsgLogin.backgroundColor = UIColor.clearColor;
    lblEmailErrorMsgLogin.text = @"Please enter your Email";
    lblEmailErrorMsgLogin.textColor = UIColor.redColor;
    lblEmailErrorMsgLogin.textAlignment = NSTextAlignmentLeft;
    lblEmailErrorMsgLogin.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblEmailErrorMsgLogin.hidden = true;
    [loginViewComp addSubview:lblEmailErrorMsgLogin];
    
    if (IS_IPHONE_X)
    {
        yy = yy+10;
    }
    yy = yy+40+20;
    txtPasswordLogin = [[UIFloatLabelTextField alloc]init];
    txtPasswordLogin.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtPasswordLogin.textAlignment = NSTextAlignmentLeft;
    txtPasswordLogin.backgroundColor = UIColor.clearColor;
    //    [txtPasswordLogin setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtPasswordLogin.autocorrectionType = UITextAutocorrectionTypeNo;
    txtPasswordLogin.floatLabelPassiveColor = global_greyColor;
    txtPasswordLogin.floatLabelActiveColor = global_greyColor;
    txtPasswordLogin.placeholder = @"Password";
    txtPasswordLogin.delegate = self;
    txtPasswordLogin.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPasswordLogin.textColor = global_greyColor;
    txtPasswordLogin.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtPasswordLogin.returnKeyType = UIReturnKeyDone;
    [loginViewComp addSubview:txtPasswordLogin];
    txtPasswordLogin.secureTextEntry = true;
    [APP_DELEGATE getPlaceholderText:txtPasswordLogin andColor:global_greyColor];

    btnShowPassLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPassLogin.frame = CGRectMake(loginViewComp.frame.size.width-60, yy, 40, 40);
    btnShowPassLogin.backgroundColor = [UIColor clearColor];
    btnShowPassLogin.tag = 0;
    [btnShowPassLogin addTarget:self action:@selector(showPassclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPassLogin setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
    [loginViewComp addSubview:btnShowPassLogin];
    
    lblPasswordLoginLine = [[UILabel alloc]init];
    lblPasswordLoginLine.backgroundColor = global_greyColor;
    lblPasswordLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtPasswordLogin addSubview:lblPasswordLoginLine];
    
    lblPasswordErrorMsgLogin = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblPasswordErrorMsgLogin.backgroundColor = UIColor.clearColor;
    lblPasswordErrorMsgLogin.text = @"Please enter your Password";
    lblPasswordErrorMsgLogin.textColor = UIColor.redColor;
    lblPasswordErrorMsgLogin.textAlignment = NSTextAlignmentLeft;
    lblPasswordErrorMsgLogin.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblPasswordErrorMsgLogin.hidden = true;
    [loginViewComp addSubview:lblPasswordErrorMsgLogin];
    
    if (IS_IPHONE_X)
    {
        yy = yy+10;
    }
    yy = yy+40+5;
    
    imgRemember = [[UIImageView alloc]initWithFrame:CGRectMake(20,yy+12, 20, 20)];
    imgRemember.image = [UIImage imageNamed:@"checkboxUnselected.png"];
    imgRemember.backgroundColor = UIColor.clearColor;
    [loginViewComp addSubview:imgRemember];
    
    UILabel * lblRemember = [[UILabel alloc] initWithFrame:CGRectMake(45, yy, DEVICE_WIDTH-40, 44)];
    [lblRemember setBackgroundColor:[UIColor clearColor]];
    [lblRemember setText:@"Remember Me?"];
    [lblRemember setTextAlignment:NSTextAlignmentLeft];
    [lblRemember setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblRemember setTextColor:UIColor.whiteColor];
    [loginViewComp addSubview:lblRemember];
    
    UIButton*btnRemember = [[UIButton alloc]initWithFrame:CGRectMake(10, yy, 180, 50)];
    btnRemember.backgroundColor = UIColor.clearColor;
    [btnRemember addTarget:self action:@selector(btnRememberClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginViewComp addSubview:btnRemember];
    
    if (IS_IPHONE_X)
    {
        yy = yy+10;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+50;
    }
    else
    {
        yy = yy+40+10;
    }
    UIButton*btnLogin = [[UIButton alloc]initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-40, 50)];
    btnLogin.backgroundColor = global_greyColor;
    [btnLogin setTitle:@"Log in" forState:UIControlStateNormal];
    btnLogin.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnLogin.layer.masksToBounds = true;
    btnLogin.layer.cornerRadius = 25;
    [btnLogin addTarget:self action:@selector(btnLoginClick) forControlEvents:UIControlEventTouchUpInside];
    [btnLogin setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [loginViewComp addSubview:btnLogin];
    
    if (IS_IPHONE_X)
    {
        yy = yy+20;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+50+5;//
    }
    else
    {
        yy = yy+50+20;
    }
    UIButton*btnForgotPassword = [[UIButton alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/2)-100, yy, 200, 30)];
    btnForgotPassword.backgroundColor = UIColor.clearColor;
    [btnForgotPassword setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [btnForgotPassword setTitleColor:UIColor.whiteColor forState:UIControlStateNormal] ;
    btnForgotPassword.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
    [btnForgotPassword addTarget:self action:@selector(forgotPasswordClick) forControlEvents:UIControlEventTouchUpInside];
    [loginViewComp addSubview:btnForgotPassword];
    
    if (IS_IPHONE_X)
    {
        yy = yy+10;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+30+10;
    }
    else
    {
        yy = yy+30+25;
    }
    
    UILabel *lblSocial = [[UILabel alloc]initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-40, 30)];
    lblSocial.backgroundColor = UIColor.clearColor;
    lblSocial.text = @"Login With Social";
    lblSocial.layer.masksToBounds = true;
    lblSocial.textColor = UIColor.whiteColor;
    lblSocial.textAlignment = NSTextAlignmentCenter;
    lblSocial.font = [UIFont fontWithName:CGRegular size:txtSize];
    [loginViewComp addSubview:lblSocial];
    
    if (IS_IPHONE_X)
    {
        yy = yy+10;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+30;
    }
    else
    {
        yy = yy+40;
    }
    
    int zz = 0;
    if (@available(iOS 13.0, *))
    {
        zz = (DEVICE_WIDTH/2)-85-30;
    }
    else
    {
        zz = (DEVICE_WIDTH/2)-85;
    }

    UIButton* btnFb = [[UIButton alloc]init];
    btnFb.backgroundColor = UIColor.clearColor;
    btnFb.frame = CGRectMake(zz, yy, 44, 44);
    btnFb.layer.masksToBounds = true;
    btnFb.layer.borderWidth = 1;
    btnFb.layer.borderColor = UIColor.whiteColor.CGColor;
    btnFb.layer.cornerRadius = 22;
    [btnFb addTarget:self action:@selector(btnFbClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnFb setBackgroundImage:[UIImage imageNamed:@"fb.png"] forState:UIControlStateNormal];
    [loginViewComp addSubview:btnFb];
    

//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2)-85, yy, 44, 44)];
//    loginButton.center = btnFb.center;
//    loginButton.layer.cornerRadius = 22;
//    loginButton.layer.masksToBounds = true;
//    loginButton.layer.borderWidth = 1;
//    loginButton.readPermissions =  @[@"email"];
//    loginButton.imageView.image = [UIImage imageNamed:@"fb.png"];
////            loginButton.hidden = true;
//    [loginViewComp addSubview:loginButton];
    
    zz = zz+50+10;

    UIButton *btnGoogle = [[UIButton alloc]init];
    btnGoogle.backgroundColor = UIColor.clearColor;
    btnGoogle.frame = CGRectMake(zz, yy, 44, 44);
    btnGoogle.layer.borderWidth = 1;
    btnGoogle.layer.borderColor = UIColor.whiteColor.CGColor;
    btnGoogle.layer.cornerRadius = 22;
    [btnGoogle addTarget:self action:@selector(btnGoogleClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnGoogle setBackgroundImage:[UIImage imageNamed:@"google.png"] forState:UIControlStateNormal];
    [loginViewComp addSubview:btnGoogle];
    
    zz = zz+50+10;
    UIButton *btnTwitter = [[UIButton alloc]init];
    btnTwitter.backgroundColor = UIColor.clearColor;
    btnTwitter.frame = CGRectMake(zz, yy, 44, 44);
    btnTwitter.layer.borderWidth = 1;
    btnTwitter.layer.borderColor = UIColor.whiteColor.CGColor;
    btnTwitter.layer.cornerRadius = 22;
    [btnTwitter addTarget:self action:@selector(btnTwitterClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnTwitter setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
    [loginViewComp addSubview:btnTwitter];
    
    zz = zz+50+10;
     if (@available(iOS 13.0, *))
     {
         UIButton *btnApple = [[UIButton alloc]init];
            btnApple.backgroundColor = UIColor.clearColor;
            btnApple.frame = CGRectMake(zz, yy, 44, 44);
            btnApple.layer.borderWidth = 1;
            btnApple.layer.borderColor = UIColor.whiteColor.CGColor;
            btnApple.layer.cornerRadius = 22;
            [btnApple addTarget:self action:@selector(btnAppleClicked) forControlEvents:UIControlEventTouchUpInside];
            [btnApple setImage:[UIImage imageNamed:@"apple.png"] forState:UIControlStateNormal];
         btnApple.subviews.firstObject.contentMode = UIViewContentModeScaleAspectFit;
            [loginViewComp addSubview:btnApple];
         
     }
   
    
    
    if (IS_IPHONE_X)
    {
        yy = yy+20;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+50+10;
    }
    else if (IS_IPHONE_5)
    {
        yy = yy+50+15;

    }
    else
    {
        yy = yy+50+30;
    }
    
    
    UIButton*btnMoveToSignUp = [[UIButton alloc]initWithFrame:CGRectMake(70, yy, DEVICE_WIDTH-140, 50)];
    btnMoveToSignUp.backgroundColor = UIColor.clearColor;
    [btnMoveToSignUp setTitle:@"Sign up" forState:UIControlStateNormal];
    btnMoveToSignUp.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnMoveToSignUp.layer.masksToBounds = true;
    btnMoveToSignUp.layer.cornerRadius = 25;
    btnMoveToSignUp.layer.borderColor = UIColor.whiteColor.CGColor;
    btnMoveToSignUp.layer.borderWidth = 1;
    [btnMoveToSignUp addTarget:self action:@selector(btnCreateNewClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnMoveToSignUp setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [loginViewComp addSubview:btnMoveToSignUp];
    
    
    // signUp frames
    hh = 20;
    if (IS_IPHONE_X)
    {
        hh = 40;
    }
    if (IS_IPHONE_4)
    {
        hh = 10;
    }
    signUpView = [[UIView alloc]initWithFrame:CGRectMake(0, hh, DEVICE_WIDTH, DEVICE_HEIGHT)];
    signUpView.backgroundColor = UIColor.clearColor;
    signUpView.hidden = YES;
    [self.view addSubview:signUpView];
    
    UITapGestureRecognizer * tapGest1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tapGest1.delegate = self;
    [signUpView addGestureRecognizer:tapGest1];
    
    
    yy = 0;
    UILabel *lblSignUp = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/2)-60, yy, 120, 44)];
    lblSignUp.backgroundColor = UIColor.clearColor;
    lblSignUp.text = @"Sign up";
    lblSignUp.layer.masksToBounds = true;
    lblSignUp.textColor = UIColor.whiteColor;
    lblSignUp.textAlignment = NSTextAlignmentCenter;
    lblSignUp.font = [UIFont fontWithName:CGBold size:txtSize+5];
    [signUpView addSubview:lblSignUp];
    
    if (IS_IPHONE_5 )
    {
        hh = hh-20;
    }
    else if (IS_IPHONE_6 )
    {
        hh = hh+20;
    }
    else if (IS_IPHONE_6plus)
    {
        hh = hh+30;
    }
    else if (IS_IPHONE_X)
    {
        hh = hh-hh+20;
    }
    UIView * signUpViewComp = [[UIView alloc]init];
    signUpViewComp.backgroundColor = UIColor.clearColor;
    signUpViewComp.frame = CGRectMake(0, hh, DEVICE_WIDTH, DEVICE_HEIGHT-hh);
    [signUpView addSubview:signUpViewComp];
    
    if (IS_IPHONE_X)
    {
        yy = yy +10;
    }
    yy = yy+44+20;
    txtName = [[UIFloatLabelTextField alloc]init];
    txtName.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtName.textAlignment = NSTextAlignmentLeft;
    txtName.backgroundColor = UIColor.clearColor;
    //    [txtName setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtName.floatLabelPassiveColor = global_greyColor;
    txtName.floatLabelActiveColor = global_greyColor;
    txtName.placeholder = @"Name";
    txtName.delegate = self;
    txtName.textColor = global_greyColor;
    txtName.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtName.keyboardType = UIKeyboardTypeEmailAddress;
    txtName.returnKeyType = UIReturnKeyNext;
    [signUpViewComp addSubview:txtName];
    [APP_DELEGATE getPlaceholderText:txtName andColor:global_greyColor];

    lblNameErrorMsg = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblNameErrorMsg.backgroundColor = UIColor.clearColor;
    lblNameErrorMsg.text = @"Please enter your Name";
    lblNameErrorMsg.textColor = UIColor.redColor;
    lblNameErrorMsg.textAlignment = NSTextAlignmentLeft;
    lblNameErrorMsg.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblNameErrorMsg.hidden = true;
    [signUpViewComp addSubview:lblNameErrorMsg];
    
    lblNameLine = [[UILabel alloc]init];
    lblNameLine.backgroundColor = global_greyColor;
    lblNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtName addSubview:lblNameLine];
    if (IS_IPHONE_X)
    {
        yy = yy +10;
    }
    yy = yy+40+20;
    txtEmailSignUp = [[UIFloatLabelTextField alloc]init];
    txtEmailSignUp.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtEmailSignUp.textAlignment = NSTextAlignmentLeft;
    txtEmailSignUp.backgroundColor = UIColor.clearColor;
    //    [txtEmailSignUp setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtEmailSignUp.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmailSignUp.floatLabelPassiveColor = global_greyColor;
    txtEmailSignUp.floatLabelActiveColor = global_greyColor;
    txtEmailSignUp.placeholder = @"Email";
    txtEmailSignUp.delegate = self;
    txtEmailSignUp.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmailSignUp.textColor = global_greyColor;
    txtEmailSignUp.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtEmailSignUp.keyboardType = UIKeyboardTypeEmailAddress;
    txtEmailSignUp.returnKeyType = UIReturnKeyNext;
    [signUpViewComp addSubview:txtEmailSignUp];
    [APP_DELEGATE getPlaceholderText:txtEmailSignUp andColor:global_greyColor];

    lblEmailErrorMsgSignUp = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblEmailErrorMsgSignUp.backgroundColor = UIColor.clearColor;
    lblEmailErrorMsgSignUp.text = @"Please enter your Email";
    lblEmailErrorMsgSignUp.textColor = UIColor.redColor;
    lblEmailErrorMsgSignUp.textAlignment = NSTextAlignmentLeft;
    lblEmailErrorMsgSignUp.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblEmailErrorMsgSignUp.hidden = true;
    [signUpViewComp addSubview:lblEmailErrorMsgSignUp];
    
    lblEmailSignUpLine = [[UILabel alloc]init];
    lblEmailSignUpLine.backgroundColor = global_greyColor;
    lblEmailSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtEmailSignUp addSubview:lblEmailSignUpLine];
    if (IS_IPHONE_X)
    {
        yy = yy +10;
    }
    yy = yy+40+20;
    txtPasswordSignUp = [[UIFloatLabelTextField alloc]init];
    txtPasswordSignUp.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtPasswordSignUp.textAlignment = NSTextAlignmentLeft;
    txtPasswordSignUp.backgroundColor = UIColor.clearColor;
    //    [txtPasswordSignUp setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtPasswordSignUp.autocorrectionType = UITextAutocorrectionTypeNo;
    txtPasswordSignUp.floatLabelPassiveColor = global_greyColor;
    txtPasswordSignUp.floatLabelActiveColor = global_greyColor;
    txtPasswordSignUp.placeholder = @"Password";
    txtPasswordSignUp.delegate = self;
    txtPasswordSignUp.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtPasswordSignUp.textColor = global_greyColor;
    txtPasswordSignUp.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtPasswordSignUp.keyboardType = UIKeyboardTypeEmailAddress;
    txtPasswordSignUp.returnKeyType = UIReturnKeyNext;
    txtPasswordSignUp.secureTextEntry = true;
    [signUpViewComp addSubview:txtPasswordSignUp];
    [APP_DELEGATE getPlaceholderText:txtPasswordSignUp andColor:global_greyColor];

    btnShowPassSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowPassSignUp.frame = CGRectMake(signUpViewComp.frame.size.width-60, yy, 40, 40);
    btnShowPassSignUp.backgroundColor = [UIColor clearColor];
    btnShowPassSignUp.tag = 1;
    [btnShowPassSignUp addTarget:self action:@selector(showPassclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowPassSignUp setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
    [signUpViewComp addSubview:btnShowPassSignUp];
    
    lblPasswordErrorMsgSigUp = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblPasswordErrorMsgSigUp.backgroundColor = UIColor.clearColor;
    lblPasswordErrorMsgSigUp.text = @"Please enter your Password";
    lblPasswordErrorMsgSigUp.textColor = UIColor.redColor;
    lblPasswordErrorMsgSigUp.textAlignment = NSTextAlignmentLeft;
    lblPasswordErrorMsgSigUp.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblPasswordErrorMsgSigUp.hidden = true;
    [signUpViewComp addSubview:lblPasswordErrorMsgSigUp];
    
    lblPasswordSignUpLine = [[UILabel alloc]init];
    lblPasswordSignUpLine.backgroundColor = global_greyColor;
    lblPasswordSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtPasswordSignUp addSubview:lblPasswordSignUpLine];
    if (IS_IPHONE_X)
    {
        yy = yy +10;
    }
    yy = yy+40+20;
    txtConfirmPassword = [[UIFloatLabelTextField alloc]init];
    txtConfirmPassword.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtConfirmPassword.textAlignment = NSTextAlignmentLeft;
    txtConfirmPassword.backgroundColor = UIColor.clearColor;
    txtConfirmPassword.secureTextEntry = true;
    //    [txtConfirmPassword setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtConfirmPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    txtConfirmPassword.floatLabelPassiveColor = global_greyColor;
    txtConfirmPassword.floatLabelActiveColor = global_greyColor;
    txtConfirmPassword.placeholder = @"Confirm Password";
    txtConfirmPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtConfirmPassword.delegate = self;
    txtConfirmPassword.textColor = global_greyColor;
    txtConfirmPassword.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtConfirmPassword.keyboardType = UIKeyboardTypeEmailAddress;
    txtConfirmPassword.returnKeyType = UIReturnKeyDone;
    [signUpViewComp addSubview:txtConfirmPassword];
    [APP_DELEGATE getPlaceholderText:txtConfirmPassword andColor:global_greyColor];

    btnShowConfirmPassSignup = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowConfirmPassSignup.frame = CGRectMake(signUpViewComp.frame.size.width-60, yy, 40, 40);
    btnShowConfirmPassSignup.backgroundColor = [UIColor clearColor];
    btnShowConfirmPassSignup.tag = 2;
    [btnShowConfirmPassSignup addTarget:self action:@selector(showPassclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowConfirmPassSignup setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
    [signUpViewComp addSubview:btnShowConfirmPassSignup];
    
    lblConfirmPasswordErrorMsgSignUp = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblConfirmPasswordErrorMsgSignUp.backgroundColor = UIColor.clearColor;
    lblConfirmPasswordErrorMsgSignUp.text = @"Password & Confirm Password should match";
    lblConfirmPasswordErrorMsgSignUp.textColor = UIColor.redColor;
    lblConfirmPasswordErrorMsgSignUp.textAlignment = NSTextAlignmentLeft;
    lblConfirmPasswordErrorMsgSignUp.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblConfirmPasswordErrorMsgSignUp.hidden = true;
    [signUpViewComp addSubview:lblConfirmPasswordErrorMsgSignUp];
    
    lblConfirmPasswordLine = [[UILabel alloc]init];
    lblConfirmPasswordLine.backgroundColor = global_greyColor;
    lblConfirmPasswordLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtConfirmPassword addSubview:lblConfirmPasswordLine];
    
    if (IS_IPHONE_X)
    {
        yy = yy +10;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+35;
    }
    else
    {
        yy = yy+40+10;
    }
    
    imgTerms = [[UIImageView alloc]initWithFrame:CGRectMake(20,yy+12, 20, 20)];
    imgTerms.image = [UIImage imageNamed:@"checkboxUnselected.png"];
    imgTerms.backgroundColor = UIColor.clearColor;
    [signUpViewComp addSubview:imgTerms];
    
    UILabel * lblTerms = [[UILabel alloc] initWithFrame:CGRectMake(45, yy, DEVICE_WIDTH-40, 44)];
    [lblTerms setBackgroundColor:[UIColor clearColor]];
    [lblTerms setText:@" I accept all terms and conditions"];
    [lblTerms setTextAlignment:NSTextAlignmentLeft];
    [lblTerms setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblTerms setTextColor:global_greyColor];
    [signUpViewComp addSubview:lblTerms];
    
    //    if (IS_IPHONE_X)
    //    {
    //        lblTerms.frame = CGRectMake(10, yy, DEVICE_WIDTH-40, 44);
    //    }
    
    UIButton*btnTermsAndCondWebView = [[UIButton alloc]initWithFrame:CGRectMake(120, yy, 40*5, 44)];
    btnTermsAndCondWebView.backgroundColor = UIColor.clearColor;
    [btnTermsAndCondWebView addTarget:self action:@selector(btnTermsAndCondWebViewClicked) forControlEvents:UIControlEventTouchUpInside];
    [signUpViewComp addSubview:btnTermsAndCondWebView];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: lblTerms.attributedText];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColor.whiteColor
                 range:NSMakeRange(13, 21)];
    [lblTerms setAttributedText: text];
    
    UIButton*btnTermsAndCond = [[UIButton alloc]initWithFrame:CGRectMake(0, yy, 60, 50)];
    btnTermsAndCond.backgroundColor = UIColor.clearColor;
    [btnTermsAndCond addTarget:self action:@selector(btnTermsClicked) forControlEvents:UIControlEventTouchUpInside];
    [signUpViewComp addSubview:btnTermsAndCond];
    
    if (IS_IPHONE_X)
    {
        yy = yy +10;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+44;
    }
    else
    {
        yy = yy+44+40;
    }
    UIButton*btnRegister = [[UIButton alloc]initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-40, 50)];
    btnRegister.backgroundColor = global_greyColor;
    [btnRegister setTitle:@"Register" forState:UIControlStateNormal];
    btnRegister.titleLabel.textColor = UIColor.blackColor;
    btnRegister.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnRegister.layer.masksToBounds = true;
    btnRegister.layer.cornerRadius =  25;
    [btnRegister addTarget:self action:@selector(btnRegisterClicked) forControlEvents:UIControlEventTouchUpInside];
    [signUpViewComp addSubview:btnRegister];
    
    if (IS_IPHONE_X)
    {
        yy = yy +10;
    }
    if (IS_IPHONE_4)
    {
        yy = yy+50;
    }
    else
    {
        yy = yy+50+20;
    }
    
    
    UIButton*btnAlreadyHave = [[UIButton alloc]initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-10, 50)];
    btnAlreadyHave.backgroundColor = UIColor.clearColor;
    [btnAlreadyHave setTitle:@"Already have an Account? Login" forState:UIControlStateNormal];
    btnAlreadyHave.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize];
    [btnAlreadyHave addTarget:self action:@selector(btnAlreadyHave) forControlEvents:UIControlEventTouchUpInside];
    [signUpViewComp addSubview:btnAlreadyHave];
    
    NSMutableAttributedString *attrStr2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Already have an Account? Log in"]];
    [attrStr2 addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(25, 5)];
    [attrStr2 addAttribute:NSForegroundColorAttributeName value:global_greyColor range:NSMakeRange(0, 25)];
    [btnAlreadyHave setAttributedTitle:attrStr2 forState:UIControlStateNormal];
    
}

#pragma mark - All Button Events
-(void)btnCreateNewClicked
{
    txtName.text = @"";
    txtName.placeholder = @"Name";
    lblNameErrorMsg.hidden = true;
    lblNameLine.backgroundColor = global_greyColor;

    txtEmailSignUp.text = @"";
    txtEmailSignUp.placeholder = @"Email";
    lblEmailErrorMsgSignUp.hidden = true;
    lblEmailSignUpLine.backgroundColor = global_greyColor;

    txtPasswordSignUp.text = @"";
    txtPasswordSignUp.placeholder = @"Password";
    lblPasswordErrorMsgSigUp.hidden = true;
    lblPasswordSignUpLine.backgroundColor = global_greyColor;

    txtConfirmPassword.text = @"";
    txtConfirmPassword.placeholder = @"Confirm Password";
    lblConfirmPasswordErrorMsgSignUp.hidden = true;
    lblConfirmPasswordLine.backgroundColor = global_greyColor;

    isShowPassword1 = NO;
    isShowPassword2 = NO;

    [btnShowPassSignUp setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
    [btnShowConfirmPassSignup setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];

    imgTerms.image = [UIImage imageNamed:@"checkboxUnselected.png"];
    isTermsClicked = false;

    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^(void){
        self->loginView.hidden = true;
        self->signUpView.hidden = false;
    } completion:nil];
    
}
-(void)btnAlreadyHave
{
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^(void){
        self->loginView.hidden = false;
        self->signUpView.hidden = true;
    } completion:nil];
}
-(void)showPassclick:(id)sender
{
    if ([sender tag] == 0)
    {
        if (isShowPassword0)
        {
            isShowPassword0 = NO;
            [btnShowPassLogin setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            txtPasswordLogin.secureTextEntry = YES;
        }
        else
        {
            isShowPassword0 = YES;
            [btnShowPassLogin setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
            txtPasswordLogin.secureTextEntry = NO;
        }
    }
    else if ([sender tag] == 1)
    {
        if (isShowPassword1)
        {
            isShowPassword1 = NO;
            [btnShowPassSignUp setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            txtPasswordSignUp.secureTextEntry = YES;
        }
        else
        {
            isShowPassword1 = YES;
            [btnShowPassSignUp setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
            txtPasswordSignUp.secureTextEntry = NO;
        }
    }
    else if ([sender tag] == 2)
    {
        if (isShowPassword2)
        {
            isShowPassword2 = NO;
            [btnShowConfirmPassSignup setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            txtConfirmPassword.secureTextEntry = YES;
        }
        else
        {
            isShowPassword2 = YES;
            [btnShowConfirmPassSignup setImage:[UIImage imageNamed:@"visible.png"] forState:UIControlStateNormal];
            txtConfirmPassword.secureTextEntry = NO;
            
        }
    }
}
-(void)btnFbClicked
{
    intSocialClicked = 0;
    
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login
     logInWithPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             
             FCAlertView *alert = [[FCAlertView alloc] init];
             alert.colorScheme = [UIColor blackColor];
             [alert makeAlertTypeCaution];
             [alert showAlertInView:self
                          withTitle:@"KUURV"
                       withSubtitle:@"We are not able to fetch your email from here, Please try with different login method."
                    withCustomImage:[UIImage imageNamed:@"logo.png"]
                withDoneButtonTitle:nil
                         andButtons:nil];
             
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email"}]
              startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                  
                  if (!error) {
                      NSLog(@"fetched user from fb is :%@ ", result);
                      [self->socialDict setValue:[APP_DELEGATE checkforValidString:[result valueForKey:@"email"]] forKey:@"email"];
                      [self->socialDict setValue:[APP_DELEGATE checkforValidString:[result valueForKey:@"name"]] forKey:@"name"];
                      [self->socialDict setValue:@"fb" forKey:@"social_type"];
                      [self->socialDict setValue:@"YES" forKey:@"isfromsocial"];
                      [self->socialDict setValue:[APP_DELEGATE checkforValidString:[result valueForKey:@"id"]] forKey:@"social_id"];
                      
                      
                      if (![[APP_DELEGATE checkforValidString:[self->socialDict valueForKey:@"email"]]isEqualToString:@"NA"])
                      {
                          if ([APP_DELEGATE isNetworkreachable])
                          {
                              [self loginViaEmailWebService];
                          }
                          else
                          {
                              FCAlertView *alert = [[FCAlertView alloc] init];
                              alert.colorScheme = [UIColor blackColor];
                              [alert makeAlertTypeCaution];
                              [alert showAlertInView:self
                                           withTitle:@"KUURV"
                                        withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                                     withCustomImage:[UIImage imageNamed:@"logo.png"]
                                 withDoneButtonTitle:nil
                                          andButtons:nil];
                          }
                      }
                      else
                      {
                          FCAlertView *alert = [[FCAlertView alloc] init];
                          alert.colorScheme = [UIColor blackColor];
                          [alert makeAlertTypeCaution];
                          [alert showAlertInView:self
                                       withTitle:@"KUURV"
                                    withSubtitle:@"We are not able to fetch your email from here, Please try with different login method."
                                 withCustomImage:[UIImage imageNamed:@"logo.png"]
                             withDoneButtonTitle:nil
                                      andButtons:nil];
                      }
                  }
              }];
         }
     }
     ];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
       
    }
   
   
}
-(void)btnGoogleClicked
{
    [GIDSignIn sharedInstance].presentingViewController = self;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGoogleInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGoogleInfo:) name:@"getGoogleInfo" object:nil];

    intSocialClicked = 1;
    [GIDSignIn sharedInstance].delegate = self;
    [[GIDSignIn sharedInstance] signIn];
}
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
//    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
//    NSString *givenName = user.profile.givenName;
//    NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    
    NSMutableDictionary * googleDict = [[NSMutableDictionary alloc]init];
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.userID] forKey:@"userId"] ;
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.profile.name] forKey:@"name"] ;                  // For client-side use only!
    [googleDict setValue:[APP_DELEGATE checkforValidString:user.profile.email] forKey:@"email"] ;                  // For client-side use only!
    
    NSLog(@"Fetched User Information from Gmail Login :email id :%@, full name : %@,user ID : %@",user.profile.email,user.profile.name,user.userID);
    
    if (!error)
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"getGoogleInfo" object:googleDict];
        [self getGoogleInfo:googleDict];
    }
}
//-(void)getGoogleInfo:(NSNotification *)notify
-(void)getGoogleInfo:(NSMutableDictionary *)dataDict
{
    NSMutableDictionary * dict = dataDict;
    NSLog(@"received google dict is %@",dict);
   
    [self->socialDict setValue:[APP_DELEGATE checkforValidString:[dict valueForKey:@"email"]] forKey:@"email"];
    [self->socialDict setValue:[APP_DELEGATE checkforValidString:[dict valueForKey:@"name"]] forKey:@"name"];
    [self->socialDict setValue:@"google" forKey:@"social_type"];
    [self->socialDict setValue:@"YES" forKey:@"isfromsocial"];
    [self->socialDict setValue:[APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%@",[dict valueForKey:@"userId"]]] forKey:@"social_id"];
    
    if (![[APP_DELEGATE checkforValidString:[self->socialDict valueForKey:@"email"]]isEqualToString:@"NA"])
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self loginViaEmailWebService];
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"We are not able to fetch your email from here, Please try with different login method."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
-(void)btnTwitterClicked
{
    intSocialClicked = 2;
    
    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
//                          NSLog(@"Twitter login name is %@", [session userName]);
//                          NSLog(@"Twitter login userID is %@", [session userID]);
             
             TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
             NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                              URL:@"https://api.twitter.com/1.1/account/verify_credentials.json"
                                                       parameters:@{@"include_email": @"true", @"skip_status": @"true"}
                                                            error:nil];
             
             [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
          
                 //        NSLog(@"twitter dict is %@",dictionary);
                 NSLog(@"twitter email id is %@",[APP_DELEGATE checkforValidString:[dictionary valueForKey:@"email"]]);
                 NSLog(@"twitter name is %@",[APP_DELEGATE checkforValidString:[dictionary valueForKey:@"name"]]);
                 NSLog(@"twitter id is %@",[APP_DELEGATE checkforValidString:[dictionary valueForKey:@"id_str"]]);

                 [self->socialDict setValue:[APP_DELEGATE checkforValidString:[dictionary valueForKey:@"email"]] forKey:@"email"];
                 [self->socialDict setValue:[APP_DELEGATE checkforValidString:[dictionary valueForKey:@"name"]] forKey:@"name"];
                 [self->socialDict setValue:@"twitter" forKey:@"social_type"];
                 [self->socialDict setValue:@"YES" forKey:@"isfromsocial"];
                 [self->socialDict setValue:[APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id_str"]]] forKey:@"social_id"];

                 if (![[APP_DELEGATE checkforValidString:[self->socialDict valueForKey:@"email"]]isEqualToString:@"NA"])
                 {
                     if ([APP_DELEGATE isNetworkreachable])
                     {
                         [self loginViaEmailWebService];
                     }
                     else
                     {
                         FCAlertView *alert = [[FCAlertView alloc] init];
                         alert.colorScheme = [UIColor blackColor];
                         [alert makeAlertTypeCaution];
                         [alert showAlertInView:self
                                      withTitle:@"KUURV"
                                   withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                                withCustomImage:[UIImage imageNamed:@"logo.png"]
                            withDoneButtonTitle:nil
                                     andButtons:nil];
                     }
                 }
                 else
                 {
                     FCAlertView *alert = [[FCAlertView alloc] init];
                     alert.colorScheme = [UIColor blackColor];
                     [alert makeAlertTypeCaution];
                     [alert showAlertInView:self
                                  withTitle:@"KUURV"
                               withSubtitle:@"We are not able to fetch your email from here, Please try with different login method."
                            withCustomImage:[UIImage imageNamed:@"logo.png"]
                        withDoneButtonTitle:nil
                                 andButtons:nil];
                 }

             }];
           
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }
     }];
}
-(void)forgotPasswordClick
{
    ForgotVC*view1 = [[ForgotVC alloc]init];
    [self.navigationController pushViewController:view1 animated:true];
}
-(void)btnLoginClick
{
    [self.view endEditing:true];
    
    if([txtEmailLogin.text isEqualToString:@""])
    {
        lblEmailErrorMsgLogin.hidden = false;
        lblEmailErrorMsgLogin.text = @"Please enter your Email";
        lblEmailLoginLine.backgroundColor = UIColor.redColor;
    }
    else  if(![APP_DELEGATE validateEmail:txtEmailLogin.text])
    {
        lblEmailErrorMsgLogin.hidden = false;
        lblEmailLoginLine.backgroundColor = UIColor.redColor;
        lblEmailErrorMsgLogin.text = @"Please enter valid Email address";
    }
    else if ([txtPasswordLogin.text isEqualToString:@""])
    {
        lblPasswordErrorMsgLogin.hidden = false;
        lblPasswordErrorMsgLogin.text = @"Please enter your Password";
        lblPasswordLoginLine.backgroundColor = UIColor.redColor;
    }
    else if([txtPasswordLogin.text length]<6)
    {
        lblPasswordErrorMsgLogin.hidden = false;
        lblPasswordErrorMsgLogin.text = @"Incorrect Password";
        lblPasswordLoginLine.backgroundColor = UIColor.redColor;
    }
    else
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self loginViaEmailWebService];
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
}
-(void)btnTermsClicked
{
    [self.view endEditing:YES];
    if (isTermsClicked == false)
    {
        isTermsClicked = true;
        imgTerms.image = [UIImage imageNamed:@"checkboxSelected.png"];
    }
    else
    {
        isTermsClicked = false;
        imgTerms.image = [UIImage imageNamed:@"checkboxUnselected.png"];
    }
}
-(void)btnRememberClicked
{
    [self.view endEditing:YES];
    if (isRememberClicked == false)
    {
        isRememberClicked = true;
        imgRemember.image = [UIImage imageNamed:@"checkboxSelected.png"];
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isRememberClicked"];
    }
    else
    {
        isRememberClicked = false;
        imgRemember.image = [UIImage imageNamed:@"checkboxUnselected.png"];
        [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isRememberClicked"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)btnTermsAndCondWebViewClicked
{
    WebViewVC*view1 = [[WebViewVC alloc]init];
    view1.btnIndex = 2;
    [self.navigationController pushViewController:view1 animated:true];
}
-(void)btnRegisterClicked
{
    [self.view endEditing:true];
    
    if([txtName.text isEqualToString:@""])
    {
        lblNameErrorMsg.hidden = false;
        lblNameLine.backgroundColor = UIColor.redColor;
    }
    else if ([txtEmailSignUp.text isEqualToString:@""])
    {
        lblEmailErrorMsgSignUp.hidden = false;
        lblEmailSignUpLine.backgroundColor = UIColor.redColor;
        lblEmailErrorMsgSignUp.text = @"Please enter your Email";
    }
    else if(![APP_DELEGATE validateEmail:txtEmailSignUp.text])
    {
        lblEmailErrorMsgSignUp.hidden = false;
        lblEmailSignUpLine.backgroundColor = UIColor.redColor;
        lblEmailErrorMsgSignUp.text = @"Please enter valid Email";
    }
    else if([txtPasswordSignUp.text isEqualToString:@""])
    {
        lblPasswordErrorMsgSigUp.hidden = false;
        lblPasswordSignUpLine.backgroundColor = UIColor.redColor;
    }
    else if([txtPasswordSignUp.text length]<6)
    {
        lblPasswordErrorMsgSigUp.hidden = false;
        lblPasswordSignUpLine.backgroundColor = UIColor.redColor;
        lblPasswordErrorMsgSigUp.text = @"Password should be atleast 6 characters";
    }
    else if([[APP_DELEGATE checkforValidString:txtConfirmPassword.text]isEqualToString:@"NA"])
    {
        lblConfirmPasswordErrorMsgSignUp.hidden = false;
        lblConfirmPasswordErrorMsgSignUp.text = @"Please Confirm Password";
        lblConfirmPasswordLine.backgroundColor = UIColor.redColor;
    }
    else if (![txtPasswordSignUp.text isEqualToString:txtConfirmPassword.text])
    {
        lblConfirmPasswordErrorMsgSignUp.hidden = false;
        lblConfirmPasswordErrorMsgSignUp.text = @"Password & Confirm Password should match";
        lblConfirmPasswordLine.backgroundColor = UIColor.redColor;
        if (IS_IPHONE_5)
        {
            lblConfirmPasswordErrorMsgSignUp.font = [UIFont fontWithName:CGRegular size:txtSize-5];
        }
    }
    else if (isTermsClicked == false)
    {
        [self showMessagewithText:@"Please agree to terms and conditions"];
    }
    else
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [self->socialDict setValue:@"NO" forKey:@"isfromsocial"];
            [self RegisterUser];
            
        }
        else
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        
    }
    
}
-(void)RegisterUser
{
    [APP_DELEGATE endHudProcess];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    [dict setValue:@"2" forKey:@"device_type"];

    
    if ([[socialDict valueForKey:@"isfromsocial"]isEqualToString:@"YES"])
    {
        [APP_DELEGATE startHudProcess:@"Loading...."];

        [dict setValue:[socialDict valueForKey:@"name"] forKey:@"name"];
        [dict setValue:[socialDict valueForKey:@"email"] forKey:@"email"];
        [dict setValue:@"1" forKey:@"is_social_login"];
        [dict setValue:@"" forKey:@"password"];
        [dict setValue:[socialDict valueForKey:@"social_type"] forKey:@"social_type"];
        [dict setValue:[socialDict valueForKey:@"social_id"] forKey:@"social_id"];
        
        if ([[APP_DELEGATE checkforValidString:[socialDict valueForKey:@"email"]]isEqualToString:@"NA"] || [[socialDict valueForKey:@"email"] containsString:@"privaterelay.appleid.com"])
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
                                   alert.colorScheme = [UIColor blackColor];
                                   [alert makeAlertTypeCaution];
                                   alert.delegate = self;
//                                   alert.tag = 201;
                                   [alert showAlertInView:self
                                                withTitle:@"KUURV"
                                             withSubtitle:@"We are not able to fetch email ID. Either you have opted to not to show your email ID through Apple login, please go to Settings -> Apple ID -> Password & Security -> Apple ID Logins ->  KuurvAppID -> Stop using Apple ID. Now try again with Share my email option enabled OR your email is not linked with Apple ID."
                                          withCustomImage:[UIImage imageNamed:@"logo.png"]
                                      withDoneButtonTitle:nil
                                               andButtons:nil];
            
            [APP_DELEGATE endHudProcess];
            
            
            
            return;
        }

                                              
        
    }
    else
    {
        [APP_DELEGATE startHudProcess:@"Registering...."];

        [dict setValue:txtName.text forKey:@"name"];
        [dict setValue:txtEmailSignUp.text forKey:@"email"];
        [dict setValue:@"0" forKey:@"is_social_login"];
        [dict setValue:txtPasswordSignUp.text forKey:@"password"];
        [dict setValue:@"NA" forKey:@"social_type"];
        [dict setValue:@"NA" forKey:@"social_id"];

    }
    
    NSString *deviceToken =globalDeviceToken;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"1234" forKey:@"device_token"];   //for simulator
    }
    else
    {
        [dict setValue:deviceToken forKey:@"device_token"];
    }
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = @"sigup";
    manager.delegate = self;
    NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/sigup";
    [manager urlCall:strServerUrl withParameters:dict];
    NSLog(@"registered info is %@",dict);
    
}
#pragma mark - Web Service Call
-(void)loginViaEmailWebService
{

    [APP_DELEGATE endHudProcess];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];

    [dict setValue:@"2" forKey:@"device_type"];
    NSString * strCommand;
    if ([[socialDict valueForKey:@"isfromsocial"]isEqualToString:@"YES"])
    {
        [APP_DELEGATE startHudProcess:@"Loading...."];

        [dict setValue:[socialDict valueForKey:@"email"] forKey:@"email"];
        [dict setValue:@"1" forKey:@"is_social_login"];
        [dict setValue:@"" forKey:@"password"];
        [dict setValue:[socialDict valueForKey:@"social_type"] forKey:@"social_type"];
        [dict setValue:[socialDict valueForKey:@"social_id"] forKey:@"social_id"];
        strCommand = @"sociallogin";
        
        
    }
    else
    {
        [APP_DELEGATE startHudProcess:@"Logging..."];

        [dict setValue:txtEmailLogin.text forKey:@"email"];
        [dict setValue:txtPasswordLogin.text forKey:@"password"];
        //    [dict setValue:globalDeviceToken forKey:@"device_token"];
        [dict setValue:@"0" forKey:@"is_social_login"];
        [dict setValue:@"NA" forKey:@"social_type"];
        [dict setValue:@"NA" forKey:@"social_id"];
        strCommand = @"login";
    }

    
    NSString *deviceToken =globalDeviceToken;
    if (deviceToken == nil || deviceToken == NULL)
    {
        [dict setValue:@"1234" forKey:@"device_token"];    //for simulator
    }
    else
    {
        [dict setValue:deviceToken forKey:@"device_token"];
    }
    
    URLManager *manager = [[URLManager alloc] init];
    manager.commandName = strCommand;
    manager.delegate = self;
    NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/login";
    [manager urlCall:strServerUrl withParameters:dict];
    NSLog(@"passed info is %@",dict);
    
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    NSLog(@"The result is...%@", result);
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"sigup"])
    {
        [APP_DELEGATE endHudProcess];

        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This email address already registered with us"] || [[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"user already registered with this email adddres."])
            {
                lblEmailErrorMsgSignUp.hidden = false;
                lblEmailSignUpLine.backgroundColor = UIColor.redColor;
                lblEmailErrorMsgSignUp.text = @"This email address already registered with us.";
            }
            else
            {
                if([[result valueForKey:@"result"] valueForKey:@"data"]!=[NSNull null] || [[result valueForKey:@"result"] valueForKey:@"data"] != nil || ![[[result valueForKey:@"result"] valueForKey:@"data"] isEqualToString:@"<null>"])
                {
                    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
                  
                    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"email"] forKey:@"CURRENT_USER_EMAIL"];
                    [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"name"] forKey:@"CURRENT_USER_NAME"];
                  
                    [tmpDict removeObjectForKey:@"password_access_code"];   //password access code is in diff syntax and crashes
//                    [[NSUserDefaults standardUserDefaults] setObject:tmpDict forKey:@"UserDict"];
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[[result valueForKey:@"result"] valueForKey:@"auth_token"] forKey:@"CURRENT_USER_ACCESS_TOKEN"];
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"id"]] forKey:@"CURRENT_USER_ID"];
                    //
                    NSString * strKey = [NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"email"]];
                    long len = [strKey length];
                    if (len > 18)
                    {
                        strKey = [strKey substringWithRange:NSMakeRange(0, 18)];
                    }
                    NSLog(@"rangeeeeeeeeeeeeeeeeeeeeeeeeeeeeee is %@",strKey);

                    [[NSUserDefaults standardUserDefaults] setValue:strKey forKey:@"CURRENT_USER_UNIQUEKEY"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString * strpassword;
                    NSMutableDictionary * socialIDDict = [[NSMutableDictionary alloc]init];
                    NSString * strMsg;
                    bool isFromSocialWithPassword = false;
                    
                    if ([[NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"is_social_login"]]isEqualToString:@"1"])
                    {
                        isUserLoggedAndDontEndHudProcess = true;
                        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isLoggedIn"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        [[NSUserDefaults standardUserDefaults] setValue:[APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"password"]] forKey:@"CURRENT_USER_PASS"];
                        strpassword = [APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"password"]];
                        if (intSocialClicked == 0)
                        {
                            [socialIDDict setValue:[APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"social_id"]] forKey:@"fb_id"];
                            [socialIDDict setValue:@"NA" forKey:@"google_id"];
                            [socialIDDict setValue:@"NA" forKey:@"twitter_id"];
                            [socialIDDict setValue:@"NA" forKey:@"apple_id"];
                        }
                        else if (intSocialClicked == 1)
                        {
                            [socialIDDict setValue:[APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"social_id"]] forKey:@"google_id"];
                            [socialIDDict setValue:@"NA" forKey:@"fb_id"];
                            [socialIDDict setValue:@"NA" forKey:@"twitter_id"];
                            [socialIDDict setValue:@"NA" forKey:@"apple_id"];
                            
                        }
                        else if (intSocialClicked == 2)
                        {
                            [socialIDDict setValue:[APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"social_id"]] forKey:@"twitter_id"];
                            [socialIDDict setValue:@"NA" forKey:@"google_id"];
                            [socialIDDict setValue:@"NA" forKey:@"fb_id"];
                            [socialIDDict setValue:@"NA" forKey:@"apple_id"];
                        }
                        else if (intSocialClicked == 3)
                        {
                            [socialIDDict setValue:[APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"social_id"]] forKey:@"apple_id"];
                            [socialIDDict setValue:@"NA" forKey:@"google_id"];
                            [socialIDDict setValue:@"NA" forKey:@"fb_id"];
                            [socialIDDict setValue:@"NA" forKey:@"twitter_id"];
                        }
                        strMsg = [NSString stringWithFormat:@"You have been registered successfully."];
                        
                        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isFromSocialLogin"];

                        if (![[APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"password"]]isEqualToString:@"NA"])
                        {
                            isFromSocialWithPassword = true;      //user has signed up in our app,same id he is using in social login also
                            [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isFromSocialLogin"]; //password from signed up is used later on to change password
                        }
                        [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isRememberClicked"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:txtPasswordSignUp.text forKey:@"CURRENT_USER_PASS"];
                        strpassword = [APP_DELEGATE checkforValidString:txtPasswordSignUp.text];
                        [socialIDDict setValue:@"NA" forKey:@"google_id"];
                        [socialIDDict setValue:@"NA" forKey:@"fb_id"];
                        [socialIDDict setValue:@"NA" forKey:@"twitter_id"];

                        strMsg = [NSString stringWithFormat:@"Registration successful.\n Please check your Email account and click on \"%@\" link inside.",@"verify"];
                        [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isFromSocialLogin"];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    }
                    NSString * requestStr =[NSString stringWithFormat:@"insert into 'UserAccount_Table'('account_name','user_email','user_pw','is_social_login','google_id','fb_id','twitter_id','device_token','user_unique_key')values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",[tmpDict valueForKey:@"name"],[tmpDict valueForKey:@"email"],strpassword,[NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"is_social_login"]],[socialIDDict valueForKey:@"google_id"],[socialIDDict valueForKey:@"fb_id"],[socialIDDict valueForKey:@"twitter_id"],[tmpDict valueForKey:@"device_token"],[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_UNIQUEKEY"]];
                    [[DataBaseManager dataBaseManager] execute:requestStr];
                    
                    NSString * requestStr2 =[NSString stringWithFormat:@"insert into 'User_Set_Info'('user_id','name','email','mobile') values(\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,[tmpDict valueForKey:@"name"],[tmpDict valueForKey:@"email"],@"NA"];
                    [[DataBaseManager dataBaseManager] execute:requestStr2];
                    
                    if (isFromSocialWithPassword == true)
                    {
                        [APP_DELEGATE goToHome];

                    }
                    else
                    {
                        FCAlertView *alert = [[FCAlertView alloc] init];
                        alert.colorScheme = [UIColor blackColor];
                        [alert makeAlertTypeSuccess];
                        alert.tag = 001;
                        alert.delegate = self;
                        [alert showAlertInView:self
                                     withTitle:@"KUURV"
                                  withSubtitle:strMsg
                               withCustomImage:[UIImage imageNamed:@"logo.png"]
                           withDoneButtonTitle:nil
                                    andButtons:nil];
                    }
                }
                else
                {
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
            
        }
        else
        {
            [[GIDSignIn sharedInstance] signOut];

            if ([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"This email address already registered with us"] || [[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"user already registered with this email adddres."])
            {
                lblEmailErrorMsgSignUp.hidden = false;
                lblEmailSignUpLine.backgroundColor = UIColor.redColor;
                lblEmailErrorMsgSignUp.text = @"This email address has already registered with us";
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"user email already registered with social login  fb."])
            {
                [socialDict setValue:@"NO" forKey:@"isfromsocial"];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"This email address has already registered with us using Facebook Login."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"user email already registered with social login  twitter."])
            {
                [socialDict setValue:@"NO" forKey:@"isfromsocial"];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"This email address has already registered with us using Twitter Login."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"user email already registered with social login  google."])
            {
                [socialDict setValue:@"NO" forKey:@"isfromsocial"];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"This email address has already registered with us using Google Login."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"user email already registered with social login  apple."])
            {
                [socialDict setValue:@"NO" forKey:@"isfromsocial"];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"This email address has already registered with us using Apple Login."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            
            
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
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
                NSString * strMsg = [[result valueForKey:@"result"] valueForKey:@"message"];
                
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:strMsg
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            
        }
    }
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"login"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];

            [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"email"] forKey:@"CURRENT_USER_EMAIL"];
            [[NSUserDefaults standardUserDefaults] setValue:txtPasswordLogin.text forKey:@"CURRENT_USER_PASS"];
            [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"name"] forKey:@"CURRENT_USER_NAME"];
   
            NSString * strKey = [NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"email"]];
            long len = [strKey length];
            if (len > 18)
            {
                strKey = [strKey substringWithRange:NSMakeRange(0, 18)];
            }
            NSLog(@"rangeeeeeeeeeeeeeeeeeeeeeeeeeeeeee is %@",strKey);
            [[NSUserDefaults standardUserDefaults] setValue:strKey forKey:@"CURRENT_USER_UNIQUEKEY"];
            isUserLoggedAndDontEndHudProcess = true;
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isLoggedIn"];
            [[NSUserDefaults standardUserDefaults] setValue:[[result valueForKey:@"result"] valueForKey:@"auth_token"] forKey:@"CURRENT_USER_ACCESS_TOKEN"];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"id"]] forKey:@"CURRENT_USER_ID"];
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isFromSocialLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString * strAccName = [APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"name"]];
            NSString * strEmail = [APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"email"]];
            NSString * strPassword = [APP_DELEGATE checkforValidString:txtPasswordLogin.text];
            NSString * strIsSocial = [APP_DELEGATE checkforValidString:@"0"];
            NSString * StrGoogle = @"NA";
            NSString * strFB = @"NA";
            NSString * strTwitter = @"NA";
            NSString * strDeviceToken = [APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"device_token"]];
            NSString * strUserUniqueKey = strKey;

            NSString * requestStr =[NSString stringWithFormat:@"insert into 'UserAccount_Table'('account_name','user_email','user_pw','is_social_login','google_id','fb_id','twitter_id','device_token','user_unique_key')values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strAccName,strEmail,strPassword,strIsSocial,StrGoogle,strFB,strTwitter,strDeviceToken,strUserUniqueKey];
            [[DataBaseManager dataBaseManager] execute:requestStr];
            
            NSString * requestStr2 =[NSString stringWithFormat:@"insert into 'User_Set_Info'('user_id','name','email','mobile') values(\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,strAccName,strEmail,@"NA"];
            [[DataBaseManager dataBaseManager] execute:requestStr2];
            
            [APP_DELEGATE goToHome];
        }
        else
        {
            [APP_DELEGATE endHudProcess];

            if ([[[result valueForKey:@"result"]valueForKey:@"message"]isEqualToString:@"Email not verified!!, Plase verify your email address."])
            {
                NSString * strTmp = [NSString stringWithFormat:@"Please check your Email account and \"%@\" to log in.",@"verify"];
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:strTmp
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Credentials."])
            {
                [alertGlobal removeFromSuperview];
                alertGlobal = [[FCAlertView alloc] init];
                alertGlobal.colorScheme = [UIColor blackColor];
                alertGlobal.delegate = self;
                [alertGlobal makeAlertTypeCaution];
                [alertGlobal showAlertInView:self
                                   withTitle:@"KUURV"
                                withSubtitle:@"Invalid Login"
                             withCustomImage:[UIImage imageNamed:@"logo.png"]
                         withDoneButtonTitle:nil
                                  andButtons:nil];
            }
            else if ([[[result valueForKey:@"result"]valueForKey:@"message"]isEqualToString:@"You email is registered with fb"])
            {
                [socialDict setValue:@"NO" forKey:@"isfromsocial"];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                alert.delegate = self;
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"This email address has already registered with us using Facebook Login."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else if ([[[result valueForKey:@"result"]valueForKey:@"message"]isEqualToString:@"You email is registered with google"])
            {
                [socialDict setValue:@"NO" forKey:@"isfromsocial"];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                alert.delegate = self;
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"This email address has already registered with us using Google Login."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else if ([[[result valueForKey:@"result"]valueForKey:@"message"]isEqualToString:@"You email is registered with twitter"])
            {
                [socialDict setValue:@"NO" forKey:@"isfromsocial"];

                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                alert.delegate = self;
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"This email address has already registered with us using Twitter Login."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
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
    else if ([[result valueForKey:@"commandName"] isEqualToString:@"sociallogin"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
            

            [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"email"] forKey:@"CURRENT_USER_EMAIL"];
            [[NSUserDefaults standardUserDefaults] setValue:@"NA" forKey:@"CURRENT_USER_PASS"];
            
            [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"name"] forKey:@"CURRENT_USER_NAME"];
            
            NSString * strKey = [NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"email"]];
            long len = [strKey length];
            if (len > 18)
            {
                strKey = [strKey substringWithRange:NSMakeRange(0, 18)];
            }
            NSLog(@"rangeeeeeeeeeeeeeeeeeeeeeeeeeeeeee is %@",strKey);
            [[NSUserDefaults standardUserDefaults] setValue:strKey forKey:@"CURRENT_USER_UNIQUEKEY"];
            isUserLoggedAndDontEndHudProcess = true;
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isLoggedIn"];
            [[NSUserDefaults standardUserDefaults] setValue:[[result valueForKey:@"result"] valueForKey:@"auth_token"] forKey:@"CURRENT_USER_ACCESS_TOKEN"];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"id"]] forKey:@"CURRENT_USER_ID"];
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isFromSocialLogin"];
            [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isRememberClicked"];

            if (![[APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"password"]]isEqualToString:@"NA"])
            {
                [[NSUserDefaults standardUserDefaults] setValue:[tmpDict valueForKey:@"password"] forKey:@"CURRENT_USER_PASS"];
                [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isFromSocialLogin"]; //password from signed up is used later on to change password
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString * strAccName = [APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"name"]];
            NSString * strEmail = [APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"email"]];
            NSString * strPassword = [APP_DELEGATE checkforValidString:txtPasswordLogin.text];
            NSString * strIsSocial = @"1";
            NSString * StrGoogle = @"NA";
            NSString * strFB = @"NA";
            NSString * strTwitter = @"NA";
            if ([[tmpDict valueForKey:@"social_type"] isEqualToString:@"google"])
            {
                StrGoogle = [tmpDict valueForKey:@"social_id"];
                
            }
            else if ([[tmpDict valueForKey:@"social_type"] isEqualToString:@"facebook"])
            {
                strFB = [tmpDict valueForKey:@"social_id"];
            }
            else if ([[tmpDict valueForKey:@"social_type"] isEqualToString:@"twitter"])
            {
                strTwitter = [tmpDict valueForKey:@"social_id"];
            }
           
            NSString * strDeviceToken = [APP_DELEGATE checkforValidString:[tmpDict valueForKey:@"device_token"]];
            NSString * strUserUniqueKey = strKey;
            
          
            NSString * requestStr =[NSString stringWithFormat:@"insert into 'UserAccount_Table'('account_name','user_email','user_pw','is_social_login','google_id','fb_id','twitter_id','device_token','user_unique_key')values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strAccName,strEmail,strPassword,strIsSocial,StrGoogle,strFB,strTwitter,strDeviceToken,strUserUniqueKey];
            [[DataBaseManager dataBaseManager] execute:requestStr];
            
            NSString * requestStr2 =[NSString stringWithFormat:@"insert into 'User_Set_Info'('user_id','name','email','mobile') values(\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,strAccName,strEmail,@"NA"];
            [[DataBaseManager dataBaseManager] execute:requestStr2];
            
            [APP_DELEGATE goToHome];
        }
        else
        {
            
            if ([[[result valueForKey:@"result"]valueForKey:@"message"]isEqualToString:@"Your social login details not found, please try again."])
            {
                [self RegisterUser];
            }
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"Invalid Token"])
            {
                [APP_DELEGATE endHudProcess];

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
                [APP_DELEGATE endHudProcess];

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
#pragma mark - Google Delegates
// Stop the UIActivityIndicatorView animation that was started when the user
// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    //    [myActivityIndicator stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITextfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    lblEmailErrorMsgLogin.text = @"";
    lblEmailErrorMsgLogin.hidden = true;
    lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    lblEmailLoginLine.backgroundColor = UIColor.grayColor;
    
    lblEmailErrorMsgSignUp.text = @"";
    lblEmailErrorMsgSignUp.hidden = true;
    lblEmailSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    lblEmailSignUpLine.backgroundColor = UIColor.grayColor;
    if (textField == txtEmailLogin)
    {
        lblEmailErrorMsgLogin.hidden = true;
        lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblEmailLoginLine.backgroundColor = UIColor.whiteColor;
    }
    else  if (textField == txtPasswordLogin)
    {
        lblPasswordErrorMsgLogin.hidden = true;
        lblPasswordLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblPasswordLoginLine.backgroundColor = UIColor.whiteColor;
    }
    else if (textField == txtName)
    {
        lblNameErrorMsg.hidden = true;
        lblNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblNameLine.backgroundColor = UIColor.whiteColor;
    }
    else if (textField == txtEmailSignUp)
    {
        lblEmailErrorMsgSignUp.hidden = true;
        lblEmailSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblEmailSignUpLine.backgroundColor = UIColor.whiteColor;
    }
    else if (textField == txtPasswordSignUp)
    {
        lblPasswordErrorMsgSigUp.hidden = true;
        lblPasswordSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblPasswordSignUpLine.backgroundColor = UIColor.whiteColor;
    }
    else if (textField == txtConfirmPassword)
    {
        lblConfirmPasswordErrorMsgSignUp.hidden = true;
        lblConfirmPasswordLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblConfirmPasswordLine.backgroundColor = UIColor.whiteColor;
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == txtEmailLogin)
    {
        lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblEmailLoginLine.backgroundColor = global_greyColor;
    }
    else  if (textField == txtPasswordLogin)
    {
        lblPasswordLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblPasswordLoginLine.backgroundColor = global_greyColor;
    }
    else if (textField == txtName)
    {
        lblNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblNameLine.backgroundColor = global_greyColor;
    }
    else if (textField == txtEmailSignUp)
    {
        lblEmailSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblEmailSignUpLine.backgroundColor = global_greyColor;
    }
    else if (textField == txtPasswordSignUp)
    {
        lblPasswordSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblPasswordSignUpLine.backgroundColor = global_greyColor;
    }
    else if (textField == txtConfirmPassword)
    {
        lblConfirmPasswordLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblConfirmPasswordLine.backgroundColor = global_greyColor;
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtEmailSignUp)
    {
        NSInteger oldLength = [textField.text length];
        NSInteger newLength = oldLength + [string length] - range.length;
        if(newLength >= 37)
        {
            lblEmailErrorMsgSignUp.hidden = false;
            lblEmailSignUpLine.backgroundColor = UIColor.redColor;
            lblEmailErrorMsgSignUp.text = @"Email cant be more than 36 characters";
            lblEmailSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
            return NO;
        }
        else
        {
            lblEmailErrorMsgSignUp.text = @"";
            lblEmailErrorMsgSignUp.hidden = true;
            lblEmailSignUpLine.backgroundColor = UIColor.whiteColor;
            lblEmailSignUpLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        }
        return YES;
    }
    else if(textField == txtEmailLogin)
    {
        NSInteger oldLength = [textField.text length];
        NSInteger newLength = oldLength + [string length] - range.length;
        if(newLength >= 37)
        {
            lblEmailErrorMsgLogin.hidden = false;
            lblEmailLoginLine.backgroundColor = UIColor.redColor;
            lblEmailErrorMsgLogin.text = @"Email cant be more than 36 characters";
            lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
            return NO;
        }
        else
        {
            lblEmailErrorMsgLogin.text = @"";
            lblEmailErrorMsgLogin.hidden = true;
            lblEmailLoginLine.backgroundColor = UIColor.whiteColor;
            lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        }
        return YES;
    }
    return true;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmailLogin)
    {
        [txtEmailLogin resignFirstResponder];
        [txtPasswordLogin becomeFirstResponder];
    }
    else  if (textField == txtPasswordLogin)
    {
        [txtPasswordLogin resignFirstResponder];
    }
    else if (textField == txtName)
    {
        [txtName resignFirstResponder];
        [txtEmailSignUp becomeFirstResponder];
    }
    else if (textField == txtEmailSignUp)
    {
        [txtEmailSignUp resignFirstResponder];
        [txtPasswordSignUp becomeFirstResponder];
    }
    else if (textField == txtPasswordSignUp)
    {
        [txtPasswordSignUp resignFirstResponder];
        [txtConfirmPassword becomeFirstResponder];
    }
    else if (textField == txtConfirmPassword)
    {
        [txtConfirmPassword resignFirstResponder];
    }
    return true;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showMessagewithText:(NSString *)strText
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"KUURV"
              withSubtitle:strText
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
#pragma mark - Helper Methods
- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
    //    NSLog(@"Button Clicked: %ld Title:%@", (long)index, title);
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 001)
    {
        if ([[socialDict valueForKey:@"isfromsocial"]isEqualToString:@"YES"])
        {
            isUserLoggedAndDontEndHudProcess = true;
            [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isLoggedIn"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [APP_DELEGATE goToHome];
        }
        else
        {
            txtEmailLogin.text = txtEmailSignUp.text;
            txtPasswordLogin.text = txtPasswordSignUp.text;
            
            [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^(void){
                self->loginView.hidden = false;
                self->signUpView.hidden = true;
            } completion:nil];
        }
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
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)tapClick:(UITapGestureRecognizer *)tapClick
{
    [self.view endEditing:YES];
}


@end
//ios : 1141969653679316992
