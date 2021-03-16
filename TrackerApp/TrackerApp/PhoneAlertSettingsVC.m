//
//  PhoneAlertSettingsVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 17/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "PhoneAlertSettingsVC.h"
#import "PhoneAlertCell.h"
#import "ViewMoreCell.h"
@interface PhoneAlertSettingsVC ()

@end
NSString * repeatAlert, * seperationAlert;
NSString * silentModeStatus;
NSMutableArray *arrRingtonesUpdatedNames;
@implementation PhoneAlertSettingsVC
@synthesize phoneAlertDict, arrayIndex;
- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    NSMutableArray * tmpArr = [[NSMutableArray alloc]init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from Device_Table where ble_address = '%@' and user_id ='%@'",[phoneAlertDict valueForKey:@"ble_address"],CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArr];
    
    strVolumeSelected = @"0";
    if ([[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"volume"]] isEqualToString:@"1"])
    {
        strVolumeSelected = @"1";
    }
    
    if (tmpArr.count > 0)
    {
        if ([[APP_DELEGATE checkforValidString:[[tmpArr objectAtIndex:0] valueForKey:@"seperation_alert"]]isEqualToString:@"NA"])
        {
            seperationAlert = @"1";
        }
        else
        {
            seperationAlert = [[tmpArr objectAtIndex:0] valueForKey:@"seperation_alert"];
        }
        if ([[APP_DELEGATE checkforValidString:[[tmpArr objectAtIndex:0] valueForKey:@"repeat_alert"]]isEqualToString:@"NA"])
        {
            repeatAlert = @"1";
        }
        else
        {
            repeatAlert = [[tmpArr objectAtIndex:0] valueForKey:@"repeat_alert"];
        }
    }
    else
    {
        seperationAlert = @"1";
        repeatAlert = @"1";
        [phoneAlertDict setObject:@"1" forKey:@"tracker_device_alert"];
    }
    arrPhoneAlert = [[NSMutableArray alloc]init];
    NSArray * arrNames = [[NSArray alloc]initWithObjects:@"Silent Mode",@"Tracker Volume",@"Separation Alert",@"Repeat Alert", nil];
    
    NSString * strAlertTime;
    if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"alertDuration"]]isEqualToString:@"NA"])
    {
        strAlertTime = [NSString stringWithFormat:@"%@ seconds",[[NSUserDefaults standardUserDefaults]valueForKey:@"alertDuration"]];
    }
    else
    {
        strAlertTime = @"5 seconds";
    }
    NSMutableArray *arrResult = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"Wakey",strAlertTime,nil];
    for (int i=0; i<arrNames.count; i++)
    {
        NSMutableDictionary * tmpDictName = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrNames objectAtIndex:i],@"name",[arrResult objectAtIndex:i],@"result", nil];
        [arrPhoneAlert addObject:tmpDictName];
    }
    arrFooter = [[NSMutableArray alloc]initWithObjects:@"Disable the alerts.",@"Set device volume",@"Receive a phone notification if tracker is separated and out of your range.",@"When locating your tracker, it will ring repeatedly until you stop it.",@"",@"", nil];

    arrRingtones = [[NSMutableArray alloc]init];
//    NSMutableArray * arrTmp = [[NSMutableArray alloc]initWithObjects:@"Ringtone 1",@"Ringtone 2",@"Ringtone 3",@"Ringtone 4",@"Ringtone 5",@"Ringtone 6",@"Ringtone 7", nil];
    
    arrRingtonesUpdatedNames = [[NSMutableArray alloc]initWithObjects:@"Wakey",@"Spark",@"Phone",@"Harp",@"Game Over",@"Ethereal",@"Bonus", nil];

   
    NSMutableArray * tmpArr2 = [[NSMutableArray alloc]initWithObjects:@"YES",@"NO",@"NO",@"NO",@"NO",@"NO",@"NO", nil];
    for (int i=0; i<arrRingtonesUpdatedNames.count; i++)
    {
        NSMutableDictionary * tmpDictName = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[arrRingtonesUpdatedNames objectAtIndex:i],@"name",[tmpArr2 objectAtIndex:i],@"isSelected",@"NO",@"isPlaying", nil];
        [arrRingtones addObject:tmpDictName];
    }
    
    if ([[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"selectedRingtone"]]isEqualToString:@"0"])
    {
//        long intTmp = 0;
        [[arrRingtones objectAtIndex:0]setValue:@"YES" forKey:@"isSelected"];
        [[NSUserDefaults standardUserDefaults]setValue:@"Wakey" forKey:@"selectedRingtone"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        [arrRingtones setValue:@"NO" forKey:@"isSelected"];
        NSString * strTmp = [[NSUserDefaults standardUserDefaults]valueForKey:@"selectedRingtone"];
        if (![[APP_DELEGATE checkforValidString:strTmp]isEqualToString:@"NA"])
        {
            if ([arrRingtonesUpdatedNames containsObject:strTmp])
            {
               long intTmp = [arrRingtonesUpdatedNames indexOfObject:strTmp];
                [[arrRingtones objectAtIndex:intTmp]setValue:@"YES" forKey:@"isSelected"];
            }
        }
    }
    arrAlertDuration = [[NSMutableArray alloc]initWithObjects:@"5 seconds",@"10 seconds",@"15 seconds", nil];
    NSLog(@"array ringtone is %@",arrRingtones);
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
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy)];
    [viewHeader setBackgroundColor:global_greenColor];
    [self.view addSubview:viewHeader];
    
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Alert Settings"];
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
    tblContent =[[UITableView alloc]initWithFrame:CGRectMake(0, yy,DEVICE_WIDTH,DEVICE_HEIGHT-yy) style:UITableViewStylePlain];
    [tblContent setBackgroundColor:[UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1]];
    tblContent.showsVerticalScrollIndicator = NO;
    tblContent.showsHorizontalScrollIndicator=NO;
    tblContent.scrollEnabled = false;
    [tblContent setDelegate:self];
    [tblContent setDataSource:self];
    [tblContent setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tblContent];
    if (IS_IPHONE_4)
    {
        tblContent.scrollEnabled = true;
    }
}
#pragma mark- UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblContent)
    {
        return arrPhoneAlert.count;
    }
    else
    {
        return arrRingtones.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblContent)
    {
        if ( indexPath.row == 2 || indexPath.row == 3)
        {
            return 95;
        }
        else if (indexPath.row == 4  || indexPath.row == 5)
        {
            return 60;
        }
        else
        {
            return 70;
        }
    }
    else
    {
        return 55;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    if (tableView == tblContent)
    {
        PhoneAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (cell == nil)
        {
            cell = [[PhoneAlertCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
        }
        cell.lblName.text = [[arrPhoneAlert objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.lblfooter.text = [arrFooter objectAtIndex:indexPath.row];
        [cell.swtchh setOn:NO];
        
        if (indexPath.row ==0 )
        {
            cell.viewGroup.frame = CGRectMake(0,0,DEVICE_WIDTH,46);
            cell.lblfooter.frame = CGRectMake(5,47,(DEVICE_WIDTH),25);
            cell.lblfooter.hidden = false;
            cell.swtchh.tag = indexPath.row;
            cell.swtchh.hidden = false;
            [cell.swtchh setOn:NO];
            [cell.swtchh addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
            if (phoneAlertDict.count != 0)
            {
                if ([[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"ON"] || [[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"1"])   //is not in silent mode
                {
                    [cell.swtchh setOn:NO];

                }
                else
                {
                    [cell.swtchh setOn:YES];
                    repeatAlert = @"0";
                    seperationAlert = @"0";
                }
            }
            else
            {
                [cell.swtchh setOn:NO];
            }
            CBPeripheral * tmpPeri = [selectedDeviecDict valueForKey:@"peripheral"];
            if (tmpPeri.state == CBPeripheralStateDisconnected)
            {
                [cell.swtchh setOn:false];
            }
        }
        if (indexPath.row == 1)
        {
            if ([[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"volume"]] isEqualToString:@"NA"] || [[APP_DELEGATE checkforValidString:[selectedDeviecDict valueForKey:@"volume"]] isEqualToString:@"0"])
            {
                [cell.btnLow setImage:[UIImage imageNamed:@"greenSelected.png"] forState:UIControlStateNormal];
                [cell.btnLow setTitleColor:global_greenColor forState:UIControlStateNormal];
                [cell.btnHigh setTitleColor:global_greyColor forState:UIControlStateNormal];
                [cell.btnHigh setImage:[UIImage imageNamed:@"radioUnselected.png"] forState:UIControlStateNormal];

            }
            else
            {
                [cell.btnHigh setImage:[UIImage imageNamed:@"greenSelected.png"] forState:UIControlStateNormal];
                [cell.btnHigh setTitleColor:global_greenColor forState:UIControlStateNormal];
                [cell.btnLow setTitleColor:global_greyColor forState:UIControlStateNormal];
                [cell.btnLow setImage:[UIImage imageNamed:@"radioUnselected.png"] forState:UIControlStateNormal];

            }
            cell.btnHigh.tag = 1;
            cell.btnLow.tag = 0;
            [cell.btnHigh addTarget:self action:@selector(btnVolumeTap:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnLow addTarget:self action:@selector(btnVolumeTap:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnHigh.hidden = NO;
            cell.btnLow.hidden = NO;
            cell.lblfooter.frame = CGRectMake(5,47,(DEVICE_WIDTH),25);
        }
        if (indexPath.row == 2)
        {
            cell.swtchh.tag = indexPath.row;
            [cell.swtchh addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
            cell.swtchh.hidden = false;
            if ([seperationAlert isEqualToString:@"1"])
            {
                [cell.swtchh setOn:YES];
            }
            else
            {
                [cell.swtchh setOn:NO];
            }
            cell.lblfooter.hidden = false;
            cell.viewGroup.frame = CGRectMake(0,12,DEVICE_WIDTH,46);
            cell.lblfooter.frame = CGRectMake(5,47+12,(DEVICE_WIDTH),35);
        }
        if (indexPath.row ==3)
        {
            cell.swtchh.hidden = false;
            cell.swtchh.tag = indexPath.row;
            [cell.swtchh addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
          
            if([seperationAlert isEqualToString:@"0"] || [repeatAlert isEqualToString:@"0"])
            {
                [cell.swtchh setOn:NO];
            }
            else
            {
                [cell.swtchh setOn:YES];
            }
            cell.viewGroup.frame = CGRectMake(0,12,DEVICE_WIDTH,46);
            cell.lblfooter.frame = CGRectMake(5,47+12,(DEVICE_WIDTH),35);
        }
        if (indexPath.row == 4)
        {
            if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"selectedRingtone"]]isEqualToString:@"NA"])
            {
                NSString * strTmp = [[NSUserDefaults standardUserDefaults]valueForKey:@"selectedRingtone"];
                if ([[APP_DELEGATE checkforValidString:strTmp]isEqualToString:@"NA"])
                {
                    strTmp = @"Wakey";
                }
                [[arrPhoneAlert objectAtIndex:4]setValue:strTmp forKey:@"result"];
            }
        }
        if (indexPath.row == 4 || indexPath.row == 5 )
        {
            cell.lblResult.frame = CGRectMake(DEVICE_WIDTH-140,0,110,cell.viewGroup.frame.size.height);
            cell.lblfooter.hidden = true;
            cell.lblResult.hidden = false;
            cell.imgArrow.hidden = false;
            cell.viewGroup.frame = CGRectMake(0,12,DEVICE_WIDTH,46);
        }
        cell.lblResult.text = [[arrPhoneAlert objectAtIndex:indexPath.row] valueForKey:@"result"];
        return cell;
    }
    else if (tableView == tblRingtone)
    {
        ViewMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        if (cell == nil)
        {
            cell = [[ViewMoreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
        }
        cell.lblback.hidden = true;
        cell.lblMoreDevices.hidden = true;
        cell.imgRadio.hidden = false;
        cell.lblName.textAlignment = NSTextAlignmentLeft;
        cell.imgPlay.hidden = false;
        cell.lblTitle.hidden =false;
        cell.lblTitle.text = [arrRingtonesUpdatedNames objectAtIndex:indexPath.row];
        cell.lblName.text = @"";
        [cell.lblName setTextColor:UIColor.blackColor];
        cell.swtchh.hidden = true;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.btnPlay.hidden = false;
        cell.btnRadio.hidden = false;

        cell.btnRadio.tag = indexPath.row;
        cell.btnPlay.tag = indexPath.row;
        [cell.btnRadio addTarget:self action:@selector(btnRingtoneSelectClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnPlay addTarget:self action:@selector(btnPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.imgPlay.image = [UIImage imageNamed:@"play.png"];

        
        if ([[[arrRingtones objectAtIndex:indexPath.row]valueForKey:@"isSelected"]isEqualToString:@"YES"])
        {
            cell.imgRadio.image = [UIImage imageNamed:@"radioSelected"];
        }
        else
        {
            cell.imgRadio.image = [UIImage imageNamed:@"radioUnselected"];
        }
        if([[[arrRingtones objectAtIndex:indexPath.row]valueForKey:@"isPlaying"]isEqualToString:@"YES"])
        {
            cell.imgPlay.image = [UIImage imageNamed:@"pause.png"];
        }
        else
        {
            cell.imgPlay.image = [UIImage imageNamed:@"play.png"];
        }
        
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblContent)
    {
        if (indexPath.row == 4)
        {
            if ([[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"1"] || [[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"ON"])
            {
                [backView removeFromSuperview];
                backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
                backView.backgroundColor = UIColor.blackColor;
                backView.alpha = 0.5;
                [self.view addSubview:backView];
                
                [viewMore removeFromSuperview];
                viewMore = [[UIView alloc]initWithFrame:CGRectMake(0,DEVICE_HEIGHT, DEVICE_WIDTH, 385)];
                viewMore.backgroundColor = UIColor.whiteColor;
                [self.view addSubview:viewMore];
                [self ShowPicker:YES andView:viewMore];
                
                tblRingtone =[[UITableView alloc]initWithFrame:CGRectMake(0, 0,DEVICE_WIDTH,viewMore.frame.size.height ) style:UITableViewStylePlain];
                [tblRingtone setBackgroundColor:[UIColor clearColor]];
                tblRingtone.showsVerticalScrollIndicator = NO;
                tblRingtone.showsHorizontalScrollIndicator=NO;
                tblRingtone.scrollEnabled = false;
                [tblRingtone setDelegate:self];
                [tblRingtone setDataSource:self];
                [tblRingtone setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                [viewMore addSubview:tblRingtone];
                
                [arrRingtones setValue:@"NO" forKey:@"isPlaying"];
            }
        }
        else if (indexPath.row == 5)
        {
            if ([[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"1"] || [[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"ON"])
            {
                [self settPickerViewFrames];
                [self ShowPicker:true andView:viewPicker];
            }
        }
    }
    else if (tableView == tblRingtone)
    {
        
    }
}
#pragma mark - PickerView Frames
-(void)settPickerViewFrames
{
    [backView removeFromSuperview];
    backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    backView.backgroundColor = UIColor.blackColor;
    backView.alpha = 0.5;
    [self.view addSubview:backView];
    
    [viewPicker removeFromSuperview];
    viewPicker = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT,DEVICE_WIDTH-0, 250)];
    viewPicker.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:viewPicker];

    alertPickerView = [[UIPickerView alloc]init];
    alertPickerView.frame = CGRectMake(0,44,viewPicker.frame.size.width, (viewPicker.frame.size.height-44));
    alertPickerView.delegate = self;
    alertPickerView.dataSource = self;
    [viewPicker addSubview:alertPickerView];
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,44)];
    [btnCancel setTitleColor:global_greyColor forState:UIControlStateNormal];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.backgroundColor = UIColor.clearColor;
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnCancel];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(viewPicker.frame.size.width-70,0,70,44)];
    [btnDone setTitleColor:global_greenColor forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = UIColor.clearColor;
    //btnDone.tag = 1;
    [btnDone addTarget:self action:@selector(btnDoneAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, DEVICE_WIDTH, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [viewPicker addSubview:lblLine];
    
    if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"alertDuration"]]isEqualToString:@"NA"])
    {
        NSString * strTmp = [NSString stringWithFormat:@"%@ seconds",[[NSUserDefaults standardUserDefaults]valueForKey:@"alertDuration"]];
        long indexDate = [arrAlertDuration indexOfObject:strTmp];
        [alertPickerView selectRow:indexDate inComponent:0 animated:true];
    }

}
#pragma mark - All Button Click Events
-(void)btnBackClick
{
    NSString * strUpdate = [NSString stringWithFormat:@"Update Device_Table set tracker_device_alert ='%@',seperation_alert ='%@',repeat_alert ='%@', volume = '%@' where ble_address = '%@'  and user_id ='%@'",silentModeStatus,seperationAlert,repeatAlert,strVolumeSelected,[phoneAlertDict valueForKey:@"ble_address"],CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strUpdate];
    [[NSUserDefaults standardUserDefaults] setValue:seperationAlert forKey:@"IS_SEPERATION_ALERT"];
    [[NSUserDefaults standardUserDefaults] setValue:repeatAlert forKey:@"IS_REPEAT_ALERT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if (arrayIndex == NSNotFound)
    {
        arrayIndex = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:[phoneAlertDict valueForKey:@"ble_address"]];
    }
    selectedDeviecDict = phoneAlertDict;
    if (arrayIndex != NSNotFound)
    {
        if (arrayIndex < [arrayDevice count])
        {
            [arrayDevice replaceObjectAtIndex:arrayIndex withObject:selectedDeviecDict];
        }
    }
    [self.navigationController popViewControllerAnimated:true];
}

-(void)btnRingtoneSelectClicked:(id)sender
{
    [arrRingtones setValue:@"NO" forKey:@"isSelected"];
    [[arrRingtones objectAtIndex:[sender tag]]setValue:@"YES" forKey:@"isSelected"];
    [tblRingtone reloadData];
    
    NSString * strTmp = [arrRingtonesUpdatedNames objectAtIndex:[sender tag]];
        [[NSUserDefaults standardUserDefaults]setValue:strTmp forKey:@"selectedRingtone"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [audioPlayer stop];
    [tblContent reloadData];
    [backView removeFromSuperview];
    [self ShowPicker:false andView:viewMore];
}
-(void)btnPlayClicked:(id)sender
{
    [tblRingtone reloadData];
    
    NSString * strRingTone;
    if ([[[arrRingtones objectAtIndex:[sender tag]]valueForKey:@"isPlaying"]isEqualToString:@"YES"])
    {
        [[arrRingtones objectAtIndex:[sender tag]]setValue:@"NO" forKey:@"isPlaying"];
    }
    else
    {
        strRingTone = [NSString stringWithFormat:@"%@.mp3",[arrRingtonesUpdatedNames objectAtIndex:[sender tag]]];
        [[arrRingtones objectAtIndex:[sender tag]]setValue:@"NO" forKey:@"isPlaying"];
        [arrRingtones setValue:@"NO" forKey:@"isPlaying"];
        [[arrRingtones objectAtIndex:[sender tag]]setValue:@"YES" forKey:@"isPlaying"];
    }
    
    NSURL * songUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath],strRingTone]];
    
    [audioPlayer stop];
    audioPlayer = nil;
    audioPlayer.delegate = self;
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL: songUrl error:nil];
    AVAudioSession *audioSession1 = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession1 setCategory :AVAudioSessionCategoryPlayback error:&err];
    [audioSession1 setActive:YES error:&err];
    audioPlayer.volume=1.0;
    audioPlayer.numberOfLoops = -1;
//    [audioSession1 addObserver:self
//                    forKeyPath:@"outputVolume"
//                       options:0
//                       context:nil];
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}
-(void)btnCancelAction
{
    [backView removeFromSuperview];
    [self ShowPicker:NO andView:viewPicker];
}
-(void)btnDoneAction
{
    [backView removeFromSuperview];
    [self ShowPicker:NO andView:viewPicker];
    
    if ([[APP_DELEGATE checkforValidString:strSelectedAlert]isEqualToString:@"NA"])
    {
        strSelectedAlert = [NSString stringWithFormat:@"%@ seconds",[[NSUserDefaults standardUserDefaults]valueForKey:@"alertDuration"]];
    }
    [[arrPhoneAlert objectAtIndex:5]setValue:strSelectedAlert forKey:@"result"];
    
    NSString * strtmp = [strSelectedAlert stringByReplacingOccurrencesOfString:@" seconds" withString:@""];
    [[NSUserDefaults standardUserDefaults] setValue:strtmp forKey:@"alertDuration"] ;
    [tblContent reloadData];
}
-(void)switchStatusChanged:(id)sender
{
    UISwitch *mySwitch = (UISwitch *)sender;
    if (mySwitch.tag == 0)
    {
        CBPeripheral * sp = [phoneAlertDict valueForKey:@"peripheral"];
        if (sp)
        {
            if (sp.state == CBPeripheralStateConnected)
            {
                silentModeStatus = @"0";
                NSString * strOtherSetting = @"0";
                if ([mySwitch isOn])   //tracker alert = 0
                {
                    [self setDeviceTrackerStaus:false];
                    silentModeStatus = @"0";
                    repeatAlert = @"0"; seperationAlert = @"0";
                }
                else
                {
                    [self setDeviceTrackerStaus:true];
                    silentModeStatus = @"1"; strOtherSetting = @"1";
                    repeatAlert = @"1"; seperationAlert = @"1";
                }
                [selectedDeviecDict setObject:silentModeStatus forKey:@"tracker_device_alert"];
                if (arrayIndex == NSNotFound)
                {
                    arrayIndex = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:[phoneAlertDict valueForKey:@"ble_address"]];
                }
                if (arrayIndex != NSNotFound)
                {
                    if (arrayIndex < [arrayDevice count])
                    {
                        [[arrayDevice objectAtIndex:arrayIndex] setObject:silentModeStatus forKey:@"tracker_device_alert"];
                    }
                }

               
                [phoneAlertDict setValue:silentModeStatus forKey:@"tracker_device_alert"];
                [[NSUserDefaults standardUserDefaults] setValue:seperationAlert forKey:@"IS_SEPERATION_ALERT"];
                [[NSUserDefaults standardUserDefaults] setValue:repeatAlert forKey:@"IS_REPEAT_ALERT"];
                [[NSUserDefaults standardUserDefaults]synchronize];

                [tblContent reloadData];
            }
            else
            {
                [tblContent reloadData];
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:@"KUURV"
                          withSubtitle:@"Tracker is disconnected.\nPlease connect in order to change settings."
                       withCustomImage:[UIImage imageNamed:@"logo.png"]
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }
        else
        {
            [tblContent reloadData];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Tracker is disconnected.\nPlease connect in order to change settings."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    else if (mySwitch.tag == 2)
    {
        if (arrayDevice.count > 0)
        {
            if ([[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"0"])
            {
                [tblContent reloadData];
            }
            else
            {
                if ([mySwitch isOn])
                {
                    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"IS_SEPERATION_ALERT"];
                    seperationAlert = @"1";
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"IS_SEPERATION_ALERT"];
                    seperationAlert = @"0";
                    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"IS_REPEAT_ALERT"];
                    repeatAlert = @"0";
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                [tblContent reloadData];
            }
        }
        else
        {
            [tblContent reloadData];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Please add atleast one device to change Alert Settings."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        
    }
    else if (mySwitch.tag == 3)
    {
        if (arrayDevice.count > 0)
        {
            if ([[phoneAlertDict valueForKey:@"tracker_device_alert"]isEqualToString:@"0"])
            {
                [tblContent reloadData];
            }
            else
            {
                if ([seperationAlert isEqualToString:@"1"])
                {
                    if ([mySwitch isOn])
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"IS_REPEAT_ALERT"];
                        repeatAlert = @"1";
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"IS_REPEAT_ALERT"];
                        repeatAlert = @"0";
                    }
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                [tblContent reloadData];
            }
        }
        else
        {
            [tblContent reloadData];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Please add atleast one device to change Alert Settings."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        
    }
}
-(void)setDeviceTrackerStaus:(BOOL)isOn
{
    NSInteger valuInt = 0;
    if (isOn)
    {
        valuInt = 1;
    }
    NSData * valueData = [[NSData alloc] initWithBytes:&valuInt length:1];
    
    NSInteger opInt = 8;
    NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
    
    NSInteger lengths = 1;
    NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
    
    NSMutableData * finalData = [opCodeData mutableCopy];
    [finalData appendData:lengthData];
    [finalData appendData:valueData];
    
    CBPeripheral * sp = [phoneAlertDict valueForKey:@"peripheral"];
    [[BLEService sharedInstance] SendCommandNSData:finalData withPeripheral:sp];
    NSLog(@"final data=%@",finalData);
}
-(void)btnVolumeTap:(id)sender
{
    CBPeripheral * sp = [phoneAlertDict valueForKey:@"peripheral"];
    if (sp)
    {
        if (sp.state == CBPeripheralStateConnected)
        {
            NSInteger valuInt = 0;
            strVolumeSelected = @"0";
            if ([sender tag]==1)
            {
                valuInt = 1;
                strVolumeSelected = @"1";
            }
            NSData * valueData = [[NSData alloc] initWithBytes:&valuInt length:1];
            
            NSInteger opInt = 16;
            NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
            
            NSInteger lengths = 1;
            NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
            
            NSMutableData * finalData = [opCodeData mutableCopy];
            [finalData appendData:lengthData];
            [finalData appendData:valueData];
            
            [[BLEService sharedInstance] SendCommandNSData:finalData withPeripheral:sp];
            NSLog(@"final data=%@",finalData);
            
            [selectedDeviecDict setObject:strVolumeSelected forKey:@"volume"];
            [phoneAlertDict setObject:strVolumeSelected forKey:@"volume"];
            if (arrayIndex == NSNotFound)
            {
                arrayIndex = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:[phoneAlertDict valueForKey:@"ble_address"]];
            }
            if (arrayIndex != NSNotFound)
            {
                if (arrayIndex < [arrayDevice count])
                {
                    [[arrayDevice objectAtIndex:arrayIndex] setObject:strVolumeSelected forKey:@"volume"];
                }
            }
            
            [tblContent reloadData];
        }
        else
        {
            [tblContent reloadData];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Tracker is disconnected.\nPlease connect in order to change settings."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
    else
    {
        [tblContent reloadData];
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Tracker is disconnected.\nPlease connect in order to change settings."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.3
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            if (myView == self->viewMore)
                            {
                                self->viewMore.frame = CGRectMake(0,DEVICE_HEIGHT-385, DEVICE_WIDTH, 385);
                            }
                            else if (myView == self->viewPicker)
                            {
                                self->viewPicker.frame = CGRectMake(0,DEVICE_HEIGHT-250,DEVICE_WIDTH-0, 250);
                            }
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            [myView setFrame:CGRectMake(0,DEVICE_HEIGHT,DEVICE_WIDTH, DEVICE_HEIGHT)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
#pragma mark - PickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    if (pickerView == alertPickerView)
    {
        return 1;
    }
    return true;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView == alertPickerView)
    {
        return arrAlertDuration.count;
    }
    return true;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView == alertPickerView)
    {
        return arrAlertDuration[row];
    }
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView == alertPickerView)
    {
        strSelectedAlert = arrAlertDuration[row];
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [audioPlayer stop];

    [backView removeFromSuperview];
    [self ShowPicker:false andView:viewMore];
    [self ShowPicker:false andView:viewPicker];
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
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    [audioPlayer stop];
    
    if ([keyPath isEqual:@"outputVolume"]) {
        NSLog(@"volume changed!");
    }
}

@end
