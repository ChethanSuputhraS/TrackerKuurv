//
//  ForgotVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 29/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "ForgotVC.h"

@interface ForgotVC ()

@end

@implementation ForgotVC

- (void)viewDidLoad
{
  
    self.view.backgroundColor = UIColor.whiteColor;
    [self.navigationController setNavigationBarHidden:true];
    
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)setNavigationViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    self.view.backgroundColor = global_greenColor;
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy)];
    [viewHeader setBackgroundColor:global_greyColor];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Forgot Password"];
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
    if (IS_IPHONE_X)
    {
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
    yy = yy+70;
    
    txtEmail = [[UIFloatLabelTextField alloc]init];
    txtEmail.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 44);
    txtEmail.textAlignment = NSTextAlignmentLeft;
    txtEmail.backgroundColor = UIColor.clearColor;
//    [txtEmail setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmail.floatLabelPassiveColor = global_greyColor;
    txtEmail.floatLabelActiveColor = global_greyColor;
    txtEmail.placeholder = @"Enter Registered Email";
    txtEmail.delegate = self;
    txtEmail.textColor = global_greyColor;
    txtEmail.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    txtEmail.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:txtEmail];
    [APP_DELEGATE getPlaceholderText:txtEmail andColor:global_greyColor];

    lblEmailLoginLine = [[UILabel alloc]init];
    lblEmailLoginLine.backgroundColor = global_greyColor;
    lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    [txtEmail addSubview:lblEmailLoginLine];
    
    yy =yy+44+40;
    
    UIButton*btnSubmit = [[UIButton alloc]initWithFrame:CGRectMake(60, yy, DEVICE_WIDTH-120, 50)];
    btnSubmit.backgroundColor = global_greyColor;
    [btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
    btnSubmit.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnSubmit.layer.masksToBounds = true;
    btnSubmit.layer.cornerRadius = 25;
    [btnSubmit addTarget:self action:@selector(btnSubmitClick) forControlEvents:UIControlEventTouchUpInside];
    [btnSubmit setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.view addSubview:btnSubmit];


}
#pragma mark - All Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnSubmitClick
{
    [txtEmail resignFirstResponder];
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Verifying Email...."];
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        
       
        [dict setValue:txtEmail.text forKey:@"email"];
        
        
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"forgotpassword";
        manager.delegate = self;
        NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/forgotpassword";
        [manager urlCall:strServerUrl withParameters:dict];
        NSLog(@"sent info for change pw is %@",dict);
        
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
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"forgotpassword"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            
        }
        else
        {
            if ([[[result valueForKey:@"result"]valueForKey:@"message"]isEqualToString:@"New password reset link has been sent to your email address."])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                alert.delegate = self;
                alert.tag = 333;
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"Password reset link has been sent to your email address."
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
            else if([[[result valueForKey:@"result"] valueForKey:@"message"] isEqualToString:@"You can't forgot password because You are logged in with socialid"])
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"Forgot Password wont work for Emails registered through Social Login."
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
#pragma mark - UITextfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtEmail)
    {
        lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblEmailLoginLine.backgroundColor = UIColor.whiteColor;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == txtEmail)
    {
        lblEmailLoginLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblEmailLoginLine.backgroundColor = global_greyColor;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail)
    {
        [txtEmail resignFirstResponder];
    }
    return true;
}
- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 333)
    {
        [self.navigationController popViewControllerAnimated:true];
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
