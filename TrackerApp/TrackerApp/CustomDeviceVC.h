//
//  CustomDeviceVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 14/05/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFloatLabelTextField.h"

@interface CustomDeviceVC : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIFloatLabelTextField*txtDeviceName,*txtOwnerName,*txtEmail,*txtMobile;
    UILabel*lblDeviceNameErrorMsg,*lblDeviceNameLine,*lblOwnerNameErrorMsg,*lblOwnerNameLine,*lblEmailLine,*lblEmailErrorMsg,*lblMobileLine,*lblMobileErrorMsg;
    UIView*ViewPicker;
    UIPickerView *devicePicker;
    BOOL isInfoAlreadySet;
    NSString * strServerID;
}
@property (nonatomic, strong) CBPeripheral * classPeripheral;
@property (nonatomic, strong) NSMutableDictionary * deviceDetail;
@property bool isfromSettings;
@property bool isDeviceAddedButNoDBInfo;
@property bool isfromHome;
@property NSInteger sentIndex;
@property (nonatomic, strong) NSString * strDeviceStatus;

@end
