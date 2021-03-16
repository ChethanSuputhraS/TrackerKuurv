//
//  AddDeviceVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 29/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDeviceVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *tblContent;
    NSMutableArray * arrDevice;
    UILabel * lblScanning;
    UILabel * lblInstructuions;
    UIView* viewLostDevice, *backShadowView, *contactView;
    FCAlertView *alert2;
    UIButton *btnCancel;
}
@end
