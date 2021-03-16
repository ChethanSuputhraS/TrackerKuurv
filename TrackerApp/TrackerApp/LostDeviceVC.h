//
//  LostDeviceVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 29/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LostDeviceVC : UIViewController<UITableViewDelegate,UITableViewDataSource,FCAlertViewDelegate>
{
    CBCentralManager*centralManager;
    UITableView*tblContent;
    NSMutableArray *arrDevice;
    UIView*viewLostDevice,*backShadowView,*contactView;
    FCAlertView *alert2;
    UIButton*btnCancel;
    UILabel * lblInstructuion1;
    UILabel * lblScanning;
    UILabel * lblInstructuions;
    CBPeripheral * classPeripheral;
    NSString * strBleAddress;
    NSTimer * connectionTimer;

}
@end
