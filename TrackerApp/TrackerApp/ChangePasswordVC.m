//
//  ChangePasswordVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 19/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "ChangePasswordVC.h"

@interface ChangePasswordVC ()<URLManagerDelegate,FCAlertViewDelegate>
{
    UIButton * btnShowOldPass,*btnShowNewPass,*btnShowConfirmPass;
    BOOL isShowPassword0,isShowPassword1,isShowPassword2;

}
@end

@implementation ChangePasswordVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
    [self setContentViewFrames];
    [self setNavigationViewFrames];

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
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy)];
    [viewHeader setBackgroundColor:global_greenColor];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Change Password"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGBold size:txtSize+3]];
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
    yy = yy+20;
    txtOldPassword = [[UIFloatLabelTextField alloc]init];
    txtOldPassword.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtOldPassword.textAlignment = NSTextAlignmentLeft;
    txtOldPassword.backgroundColor = UIColor.clearColor;
    txtOldPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    txtOldPassword.floatLabelPassiveColor = global_greenColor;
    txtOldPassword.floatLabelActiveColor = global_greenColor;
    txtOldPassword.placeholder = @"Old Password";
    txtOldPassword.delegate = self;
    txtOldPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtOldPassword.textColor = UIColor.blackColor;
    txtOldPassword.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtOldPassword.keyboardType = UIKeyboardTypeDefault;
    txtOldPassword.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:txtOldPassword];
    txtOldPassword.secureTextEntry = true;
    [APP_DELEGATE getPlaceholderText:txtOldPassword andColor:global_greenColor];

    btnShowOldPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowOldPass.frame = CGRectMake(DEVICE_WIDTH-60, yy, 40, 40);
    btnShowOldPass.backgroundColor = [UIColor clearColor];
    btnShowOldPass.tag = 0;
    [btnShowOldPass addTarget:self action:@selector(showPassclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowOldPass setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
    [self.view addSubview:btnShowOldPass];
    
    lblOldPLine = [[UILabel alloc]init];
    lblOldPLine.backgroundColor = UIColor.lightGrayColor;
    lblOldPLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
    [txtOldPassword addSubview:lblOldPLine];
    
    lblOldError = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblOldError.backgroundColor = UIColor.clearColor;
    lblOldError.text = @"Please enter your old password";
    lblOldError.textColor = UIColor.redColor;
    lblOldError.textAlignment = NSTextAlignmentLeft;
    lblOldError.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblOldError.hidden = true;
    [self.view addSubview:lblOldError];
    
    yy = yy+44+15;
    txtNewPassword = [[UIFloatLabelTextField alloc]init];
    txtNewPassword.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtNewPassword.textAlignment = NSTextAlignmentLeft;
    txtNewPassword.backgroundColor = UIColor.clearColor;
    txtNewPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    txtNewPassword.floatLabelPassiveColor = global_greenColor;
    txtNewPassword.floatLabelActiveColor = global_greenColor;
    txtNewPassword.placeholder = @"New Password";
    txtNewPassword.delegate = self;
    txtNewPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtNewPassword.textColor = UIColor.blackColor;
    txtNewPassword.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtNewPassword.keyboardType = UIKeyboardTypeDefault;
    txtNewPassword.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:txtNewPassword];
    txtNewPassword.secureTextEntry = true;
    [APP_DELEGATE getPlaceholderText:txtNewPassword andColor:global_greenColor];

    btnShowNewPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowNewPass.frame = CGRectMake(DEVICE_WIDTH-60, yy, 40, 40);
    btnShowNewPass.backgroundColor = [UIColor clearColor];
    btnShowNewPass.tag = 1;
    [btnShowNewPass addTarget:self action:@selector(showPassclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowNewPass setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
    [self.view addSubview:btnShowNewPass];
    
    lblNewPLine = [[UILabel alloc]init];
    lblNewPLine.backgroundColor = UIColor.lightGrayColor;
    lblNewPLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
    [txtNewPassword addSubview:lblNewPLine];
    
    lblNewPError = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblNewPError.backgroundColor = UIColor.clearColor;
    lblNewPError.text = @"Please enter your new Password";
    lblNewPError.textColor = UIColor.redColor;
    lblNewPError.textAlignment = NSTextAlignmentLeft;
    lblNewPError.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblNewPError.hidden = true;
    [self.view addSubview:lblNewPError];
    
    yy = yy+44+15;
    txtConfirmPassword = [[UIFloatLabelTextField alloc]init];
    txtConfirmPassword.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtConfirmPassword.textAlignment = NSTextAlignmentLeft;
    txtConfirmPassword.backgroundColor = UIColor.clearColor;
    txtConfirmPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    txtConfirmPassword.floatLabelPassiveColor = global_greenColor;
    txtConfirmPassword.floatLabelActiveColor = global_greenColor;
    txtConfirmPassword.placeholder = @"Confirm Password";
    txtConfirmPassword.delegate = self;
    txtConfirmPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtConfirmPassword.textColor = UIColor.blackColor;
    txtConfirmPassword.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtConfirmPassword.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:txtConfirmPassword];
    txtConfirmPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    txtConfirmPassword.keyboardType = UIKeyboardTypeDefault;
    txtConfirmPassword.secureTextEntry = true;
    [APP_DELEGATE getPlaceholderText:txtConfirmPassword andColor:global_greenColor];

    btnShowConfirmPass = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShowConfirmPass.frame = CGRectMake(DEVICE_WIDTH-60, yy, 40, 40);
    btnShowConfirmPass.backgroundColor = [UIColor clearColor];
    btnShowConfirmPass.tag = 2;
    [btnShowConfirmPass addTarget:self action:@selector(showPassclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowConfirmPass setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
    [self.view addSubview:btnShowConfirmPass];
    
    lblConfirmPLine = [[UILabel alloc]init];
    lblConfirmPLine.backgroundColor = UIColor.lightGrayColor;
    lblConfirmPLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
    [txtConfirmPassword addSubview:lblConfirmPLine];
    
    lblConfirmPError = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblConfirmPError.backgroundColor = UIColor.clearColor;
    lblConfirmPError.text = @"Please confirm your new password";
    lblConfirmPError.textColor = UIColor.redColor;
    lblConfirmPError.textAlignment = NSTextAlignmentLeft;
    lblConfirmPError.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblConfirmPError.hidden = true;
    [self.view addSubview:lblConfirmPError];
    
    yy =yy +70;
    
    UIButton*btnSave = [[UIButton alloc]initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-40, 50)];
    btnSave.backgroundColor = global_greenColor;
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnSave.layer.masksToBounds = true;
    btnSave.layer.cornerRadius = 15;
    [btnSave addTarget:self action:@selector(btnSaveAction) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.view addSubview:btnSave];
}
#pragma mark - All Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnSaveAction
{
    [self.view endEditing:true];
    if([txtOldPassword.text isEqualToString:@""])
    {
        lblOldError.hidden = false;
        lblOldError.text = @"Please enter your old password";
        lblOldPLine.backgroundColor = UIColor.redColor;
    }
//    else if(![txtOldPassword.text isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_PASS"]])
//    {
//        lblOldError.hidden = false;
//        lblOldError.text = @"Old password is incorrect";
//        lblOldPLine.backgroundColor = UIColor.redColor;
//    }
    else if([txtNewPassword.text isEqualToString:@""])
    {
        lblNewPError.hidden = false;
        lblNewPLine.backgroundColor = UIColor.redColor;
    }
    else if([txtNewPassword.text length]<6)
    {
        lblNewPError.hidden = false;
        lblNewPError.text = @"password must be minimum 6 characters";
        lblNewPLine.backgroundColor = UIColor.redColor;
    }
    else if([txtConfirmPassword.text isEqualToString:@""])
    {
        lblConfirmPError.hidden = false;
        lblConfirmPLine.backgroundColor = UIColor.redColor;
    }
    else if(![txtConfirmPassword.text isEqualToString:txtNewPassword.text])
    {
        lblConfirmPError.hidden = false;
        lblConfirmPError.text = @"New & confirm passwords should match";
        lblConfirmPLine.backgroundColor = UIColor.redColor;
    }
    else
    {
        if ([APP_DELEGATE isNetworkreachable])
        {
            [APP_DELEGATE endHudProcess];
            [APP_DELEGATE startHudProcess:@"Updating Password...."];
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            
            [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ID"] forKey:@"user_id"];
            [dict setValue:txtOldPassword.text forKey:@"current_pass"];
            [dict setValue:txtNewPassword.text forKey:@"new_pass"];
            
            
            
            URLManager *manager = [[URLManager alloc] init];
            manager.commandName = @"changepassword";
            manager.delegate = self;
            NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/changepassword";
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
}
-(void)showPassclick:(id)sender
{
    if ([sender tag] == 0)
    {
        if (isShowPassword0)
        {
            isShowPassword0 = NO;
            [btnShowOldPass setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            txtOldPassword.secureTextEntry = YES;
        }
        else
        {
            isShowPassword0 = YES;
            [btnShowOldPass setImage:[UIImage imageNamed:@"visibleGreen.png"] forState:UIControlStateNormal];
            txtOldPassword.secureTextEntry = NO;
        }
    }
    else if ([sender tag] == 1)
    {
        if (isShowPassword1)
        {
            isShowPassword1 = NO;
            [btnShowNewPass setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            txtNewPassword.secureTextEntry = YES;
        }
        else
        {
            isShowPassword1 = YES;
            [btnShowNewPass setImage:[UIImage imageNamed:@"visibleGreen.png"] forState:UIControlStateNormal];
            txtNewPassword.secureTextEntry = NO;
        }
    }
    else if ([sender tag] == 2)
    {
        if (isShowPassword2)
        {
            isShowPassword2 = NO;
            [btnShowConfirmPass setImage:[UIImage imageNamed:@"invisible.png"] forState:UIControlStateNormal];
            txtConfirmPassword.secureTextEntry = YES;
        }
        else
        {
            isShowPassword2 = YES;
            [btnShowConfirmPass setImage:[UIImage imageNamed:@"visibleGreen.png"] forState:UIControlStateNormal];
            txtConfirmPassword.secureTextEntry = NO;
            
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
    
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"changepassword"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            alert.tag = 001;
            alert.delegate = self;
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Password updated successfully"
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
    if (textField == txtOldPassword)
    {
        lblOldPLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblOldError.hidden = true;
        lblOldPLine.backgroundColor = global_greenColor;
    }
    else if (textField == txtNewPassword)
    {
        lblNewPLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblNewPError.hidden = true;
        lblNewPLine.backgroundColor = global_greenColor;
    }
    else if (textField == txtConfirmPassword)
    {
        lblConfirmPLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        lblNewPError.hidden = true;
        lblConfirmPLine.backgroundColor = global_greenColor;

        
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtOldPassword)
    {
        [txtOldPassword resignFirstResponder];
        [txtNewPassword becomeFirstResponder];
    }

    else if (textField == txtNewPassword)
    {
        [txtNewPassword resignFirstResponder];
        [txtConfirmPassword becomeFirstResponder];
    }
    else if (textField == txtConfirmPassword)
    {
        [txtConfirmPassword resignFirstResponder];
    }
    return true;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == txtOldPassword)
    {
        lblOldPLine.backgroundColor = UIColor.lightGrayColor;
        lblOldPLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
    }
    else if (textField == txtNewPassword)
    {
        lblNewPLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblNewPLine.backgroundColor = UIColor.lightGrayColor;
    }
    else if (textField == txtConfirmPassword)
    {
        lblConfirmPLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 1);
        lblConfirmPLine.backgroundColor = UIColor.lightGrayColor;
    }

}
#pragma mark - FCAlert View Delegate
- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 001)
    {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }
    else if (alertView.tag == 111)
    {
        [APP_DELEGATE logoutAndClearDB];
    }
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
