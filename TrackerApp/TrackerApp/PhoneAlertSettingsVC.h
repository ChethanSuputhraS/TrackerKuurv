//
//  PhoneAlertSettingsVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 17/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneAlertSettingsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UITableView*tblContent,*tblRingtone;
    NSMutableArray*arrPhoneAlert;
    NSMutableArray*arrFooter,*arrRingtones,*arrAlertDuration;
    UIView *viewMore,*backView,*viewPicker;
    AVAudioPlayer * audioPlayer;
    UIButton * btnDone;
    UIPickerView * alertPickerView;
    NSString * strSelectedAlert;
    NSString * strVolumeSelected;
//    long selectedIndex;
}
@property(nonatomic,strong)NSMutableDictionary * phoneAlertDict;
@property NSInteger arrayIndex;

@end
