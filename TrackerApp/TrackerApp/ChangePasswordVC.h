//
//  ChangePasswordVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 19/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordVC : UIViewController<UITextFieldDelegate>
{
    UIFloatLabelTextField *txtOldPassword,*txtNewPassword,*txtConfirmPassword;
 UILabel*lblOldError,*lblOldPLine,*lblNewPLine,*lblNewPError,*lblConfirmPLine,*lblConfirmPError;

}
@end
