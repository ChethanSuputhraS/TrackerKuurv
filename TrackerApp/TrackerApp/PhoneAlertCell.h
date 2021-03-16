//
//  PhoneAlertCell.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 17/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneAlertCell : UITableViewCell
{
    
}
@property(nonatomic,strong)UILabel*lblName;
@property(nonatomic,strong)UILabel*lblfooter;
//@property(nonatomic,strong)UILabel*lblBack;
@property(nonatomic,strong)UILabel*lblResult;
@property(nonatomic,strong)UIView*viewGroup;
@property(nonatomic,strong)UIImageView*imgArrow;
@property(nonatomic,strong)UISwitch*swtchh;
@property(nonatomic,strong)UIButton*btnHigh;
@property(nonatomic,strong)UIButton*btnLow;

@end
