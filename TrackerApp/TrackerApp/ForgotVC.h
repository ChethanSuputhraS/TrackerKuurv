//
//  ForgotVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 29/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotVC : UIViewController<UITextFieldDelegate,URLManagerDelegate,FCAlertViewDelegate>
{
    UIFloatLabelTextField *txtEmail;
    UILabel*lblEmailLoginLine;
}
@end
