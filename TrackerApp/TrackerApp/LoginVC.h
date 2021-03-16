//
//  LoginVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 26/03/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFloatLabelTextField.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import GoogleSignIn;

@interface LoginVC : UIViewController<UITextFieldDelegate,GIDSignInDelegate,UIAlertViewDelegate>
{
    UIFloatLabelTextField *txtEmailLogin,*txtPasswordLogin;
    UIFloatLabelTextField *txtName,*txtEmailSignUp,*txtPasswordSignUp,*txtConfirmPassword;
    UIView*loginView,*signUpView;
    UILabel * lblSocial, *lblPasswordLoginLine, *lblEmailLoginLine,*lblNameLine,*lblEmailSignUpLine,*lblPasswordSignUpLine,*lblConfirmPasswordLine,*lblEmailErrorMsgLogin,*lblPasswordErrorMsgLogin,*lblEmailErrorMsgSignUp,*lblPasswordErrorMsgSigUp,*lblConfirmPasswordErrorMsgSignUp,*lblNameErrorMsg;
    UIImageView * imgTerms,*imgRemember;
    BOOL isTermsClicked,isShowPassword0,isShowPassword1,isShowPassword2,isRememberClicked;
    NSString*deviceTokenStr;
    UIActivityIndicatorView * activityIndicator;
    UIButton*btnShowPassLogin,*btnShowPassSignUp,*btnShowConfirmPassSignup;
    NSMutableDictionary * socialDict;
    NSString*setCurrentIdentifier;

}
@end
