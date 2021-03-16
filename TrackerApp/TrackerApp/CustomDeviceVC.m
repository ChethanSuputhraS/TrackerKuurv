//
//  CustomDeviceVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 14/05/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "CustomDeviceVC.h"
#import "AsyncImageView.h"
#import "AddDeviceVC.h"
@interface CustomDeviceVC ()<FCAlertViewDelegate,URLManagerDelegate, UIGestureRecognizerDelegate>
{
    int intDeviceId;
    NSMutableArray * userShardInfo;
    NSTimer * saveTimer;
    BOOL isCompleted;
    NSInteger completedCount;
    UIScrollView * scrllView1;
    UIButton * btnImg ;
    NSMutableDictionary * dictHomeInfo;
    AsyncImageView * imgDevice;
    NSString * strImagePath;
    BOOL isChangesDone,isImageUpdated;
    UIButton*btnFinish;
}
@end

@implementation CustomDeviceVC
@synthesize classPeripheral,deviceDetail, isfromSettings,isDeviceAddedButNoDBInfo,isfromHome,sentIndex;

- (void)viewDidLoad
{
    [APP_DELEGATE endHudProcess];
    completedCount = 0;
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    userShardInfo= [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from User_Set_Info where user_id ='%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:userShardInfo];
    
    [self setContentViewFrames];
    [self setNavigationViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedNamefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedNamefromDevice:) name:@"FetchedNamefromDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail1fromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedEmail1fromDevice:) name:@"FetchedEmail1fromDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail2fromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedEmail2fromDevice:) name:@"FetchedEmail2fromDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedMobilefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FetchedMobilefromDevice:) name:@"FetchedMobilefromDevice" object:nil];
    
    NSLog(@"CUSTOM VIEW WILL APPEAR");
    
    [super viewDidAppear:YES];
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
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Customize Device"];
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
    
    if (isfromSettings)
    {
        [lblTitle setText:@"Account Info"];
    }
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
    
    scrllView1 = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    scrllView1.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    scrllView1.backgroundColor = UIColor.clearColor;
    [scrllView1 setScrollEnabled:true];
    [self.view addSubview:scrllView1];
    
    UITapGestureRecognizer * tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tapGest.delegate = self;
    [scrllView1 addGestureRecognizer:tapGest];

    UIView * viewOwner = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    viewOwner.backgroundColor = UIColor.clearColor;
    viewOwner.hidden = false;
    [scrllView1 addSubview:viewOwner];
    
    yy = 0;
    imgDevice = [[AsyncImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/2)-40,yy+10, 80, 80)];
    imgDevice.layer.masksToBounds = true;
    imgDevice.layer.cornerRadius = 40;
    imgDevice.layer.borderWidth = 1;
    imgDevice.layer.borderColor = global_greyColor.CGColor;
    imgDevice.backgroundColor = UIColor.lightGrayColor;
    [scrllView1 addSubview:imgDevice];
    
    btnImg = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnImg setFrame:CGRectMake((DEVICE_WIDTH/2)-40,yy+10, 80, 80)];
    btnImg.backgroundColor = UIColor.clearColor;
    [btnImg addTarget:self action:@selector(btnImgClick) forControlEvents:UIControlEventTouchUpInside];
    [btnImg setTitle:@"Choose Image" forState:UIControlStateNormal];
    [btnImg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnImg.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize-3];
    btnImg.titleLabel.numberOfLines =0;
    btnImg.layer.cornerRadius = 40;
    btnImg.titleLabel.textAlignment = NSTextAlignmentCenter;
    [scrllView1 addSubview:btnImg];
    
    yy =yy +80+30;
    
    txtDeviceName = [[UIFloatLabelTextField alloc]initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-40, 40)];
    txtDeviceName.textAlignment = NSTextAlignmentLeft;
    txtDeviceName.backgroundColor = UIColor.clearColor;
    //    [txtDeviceName setTranslatesAutoresizingMaskIntoConstraints:NO];
    txtDeviceName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtDeviceName.floatLabelPassiveColor = global_greenColor;
    txtDeviceName.floatLabelActiveColor = global_greenColor;
    txtDeviceName.placeholder = @"Device Name";
    txtDeviceName.delegate = self;
    txtDeviceName.textColor = UIColor.blackColor;
    txtDeviceName.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtDeviceName.keyboardType = UIKeyboardTypeDefault;
    txtDeviceName.returnKeyType = UIReturnKeyDone;
    [scrllView1 addSubview:txtDeviceName];
    [APP_DELEGATE getPlaceholderText:txtDeviceName andColor:global_greenColor];
    
//    if(![[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"bleAddress"]] isEqualToString:@"NA"])
//    {
//        txtDeviceName.text = [deviceDetail valueForKey:@"bleAddress"];
//    }

    lblDeviceNameErrorMsg = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+40, DEVICE_WIDTH-40, 25)];
    lblDeviceNameErrorMsg.backgroundColor = UIColor.clearColor;
    lblDeviceNameErrorMsg.text = @"Please enter device name";
    lblDeviceNameErrorMsg.textColor = UIColor.redColor;
    lblDeviceNameErrorMsg.textAlignment = NSTextAlignmentLeft;
    lblDeviceNameErrorMsg.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblDeviceNameErrorMsg.hidden = true;
    [scrllView1 addSubview:lblDeviceNameErrorMsg];
    
    lblDeviceNameLine = [[UILabel alloc]init];
    lblDeviceNameLine.backgroundColor = UIColor.lightGrayColor;
    lblDeviceNameLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
    [txtDeviceName addSubview:lblDeviceNameLine];
    
    yy =yy +45+25;
    
    if (isfromSettings)
    {
        btnImg.hidden = YES;
        imgDevice.hidden = YES;
        txtDeviceName.hidden = YES;
        lblDeviceNameErrorMsg.hidden = YES;
        yy =10;
        
    }
    
    UILabel * lblOwner = [[UILabel alloc] initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-100, 30)];
    [lblOwner setBackgroundColor:[UIColor clearColor]];
    [lblOwner setText:@"USER INFO"];
    [lblOwner setTextAlignment:NSTextAlignmentLeft];
    [lblOwner setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblOwner setTextColor:global_greyColor];
    [viewOwner addSubview:lblOwner];
    
    
    if (isfromHome)
    {
        yy = yy+20+15;
    }
    else
    {
        yy = yy+20+15;
    }
    txtOwnerName = [[UIFloatLabelTextField alloc]init];
    txtOwnerName.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtOwnerName.textAlignment = NSTextAlignmentLeft;
    txtOwnerName.backgroundColor = UIColor.clearColor;
    txtOwnerName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtOwnerName.floatLabelPassiveColor = global_greenColor;
    txtOwnerName.floatLabelActiveColor = global_greenColor;
    txtOwnerName.placeholder = @"Name";
    txtOwnerName.delegate = self;
    txtOwnerName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtOwnerName.textColor = UIColor.blackColor;
    txtOwnerName.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtOwnerName.keyboardType = UIKeyboardTypeDefault;
    txtOwnerName.returnKeyType = UIReturnKeyNext;
    [viewOwner addSubview:txtOwnerName];
    [APP_DELEGATE getPlaceholderText:txtOwnerName andColor:global_greenColor];

    lblOwnerNameLine = [[UILabel alloc]init];
    lblOwnerNameLine.backgroundColor = UIColor.lightGrayColor;
    lblOwnerNameLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
    [txtOwnerName addSubview:lblOwnerNameLine];
    
    lblOwnerNameErrorMsg = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblOwnerNameErrorMsg.backgroundColor = UIColor.clearColor;
    lblOwnerNameErrorMsg.text = @"Please enter your name";
    lblOwnerNameErrorMsg.textColor = UIColor.redColor;
    lblOwnerNameErrorMsg.textAlignment = NSTextAlignmentLeft;
    lblOwnerNameErrorMsg.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblOwnerNameErrorMsg.hidden = true;
    [viewOwner addSubview:lblOwnerNameErrorMsg];
    
    yy = yy+44+15;
    txtEmail = [[UIFloatLabelTextField alloc]init];
    txtEmail.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtEmail.textAlignment = NSTextAlignmentLeft;
    txtEmail.backgroundColor = UIColor.clearColor;
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmail.floatLabelPassiveColor = global_greenColor;
    txtEmail.floatLabelActiveColor = global_greenColor;
    txtEmail.placeholder = @"Email";
    txtEmail.delegate = self;
    txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtEmail.textColor = UIColor.blackColor;
    txtEmail.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    txtEmail.returnKeyType = UIReturnKeyNext;
    [viewOwner addSubview:txtEmail];
    [APP_DELEGATE getPlaceholderText:txtEmail andColor:global_greenColor];

    lblEmailLine = [[UILabel alloc]init];
    lblEmailLine.backgroundColor = UIColor.lightGrayColor;
    lblEmailLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
    [txtEmail addSubview:lblEmailLine];
    
    lblEmailErrorMsg = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblEmailErrorMsg.backgroundColor = UIColor.clearColor;
    lblEmailErrorMsg.text = @"Please enter your email";
    lblEmailErrorMsg.textColor = UIColor.redColor;
    lblEmailErrorMsg.textAlignment = NSTextAlignmentLeft;
    lblEmailErrorMsg.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblEmailErrorMsg.hidden = true;
    [viewOwner addSubview:lblEmailErrorMsg];
    
    yy = yy+44+15;
    txtMobile = [[UIFloatLabelTextField alloc]init];
    txtMobile.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 40);
    txtMobile.textAlignment = NSTextAlignmentLeft;
    txtMobile.backgroundColor = UIColor.clearColor;
    txtMobile.autocorrectionType = UITextAutocorrectionTypeNo;
    txtMobile.floatLabelPassiveColor = global_greenColor;
    txtMobile.floatLabelActiveColor = global_greenColor;
    txtMobile.placeholder = @"Mobile Number(Optional)";
    txtMobile.delegate = self;
    txtMobile.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txtMobile.textColor = UIColor.blackColor;
    txtMobile.font = [UIFont fontWithName:CGRegular size:txtSize];
    txtMobile.keyboardType = UIKeyboardTypeEmailAddress;
    txtMobile.returnKeyType = UIReturnKeyNext;
    [viewOwner addSubview:txtMobile];
    txtMobile.autocorrectionType = UITextAutocorrectionTypeNo;
    txtMobile.keyboardType = UIKeyboardTypePhonePad;
    [APP_DELEGATE getPlaceholderText:txtMobile andColor:global_greenColor];

    lblMobileLine = [[UILabel alloc]init];
    lblMobileLine.backgroundColor = UIColor.lightGrayColor;
    lblMobileLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
    [txtMobile addSubview:lblMobileLine];
    
    lblMobileErrorMsg = [[UILabel alloc]initWithFrame:CGRectMake(20, yy+35, DEVICE_WIDTH-40, 25)];
    lblMobileErrorMsg.backgroundColor = UIColor.clearColor;
    lblMobileErrorMsg.text = @"Please enter valid mobile number";
    lblMobileErrorMsg.textColor = UIColor.redColor;
    lblMobileErrorMsg.textAlignment = NSTextAlignmentLeft;
    lblMobileErrorMsg.font = [UIFont fontWithName:CGRegular size:txtSize-4];
    lblMobileErrorMsg.hidden = true;
    [viewOwner addSubview:lblMobileErrorMsg];
    
    yy =yy +70;
    
    btnFinish = [[UIButton alloc]initWithFrame:CGRectMake(20, yy, DEVICE_WIDTH-40, 50)];
    btnFinish.backgroundColor = global_greenColor;
    [btnFinish setTitle:@"Finish" forState:UIControlStateNormal];
    btnFinish.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+2];
    btnFinish.layer.masksToBounds = true;
    btnFinish.layer.cornerRadius = 15;
    btnFinish.enabled = true;
    [btnFinish addTarget:self action:@selector(btnFinishClick) forControlEvents:UIControlEventTouchUpInside];
    [btnFinish setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [scrllView1 addSubview:btnFinish];
    
    if (isfromSettings)
    {
        if ([userShardInfo count]>0)
        {
            NSString * strName = [[userShardInfo objectAtIndex:0] valueForKey:@"name"];
            NSString * strEmail = [[userShardInfo objectAtIndex:0] valueForKey:@"email"];
            NSString * strMobile = [[userShardInfo objectAtIndex:0] valueForKey:@"mobile"];
            if (![[APP_DELEGATE checkforValidString:strName] isEqualToString:@"NA"])
            {
                if ([strName length]>18)
                {
                    strName = [strName substringWithRange:NSMakeRange(0, 18)];
                }
                txtOwnerName.text = strName;
            }
            if (![[APP_DELEGATE checkforValidString:strEmail] isEqualToString:@"NA"])
            {
                txtEmail.text = strEmail;
            }
            if (![[APP_DELEGATE checkforValidString:strMobile] isEqualToString:@"NA"])
            {
                txtMobile.text = strMobile;
            }
        }
        else
        {
            txtOwnerName.text = CURRENT_USER_NAME;
            txtEmail.text = CURRENT_USER_EMAIL;
            txtMobile.text = @"";

        }
    }
    else
    {
        if (isfromHome)
        {
            if (userShardInfo.count > 0)
            {
                isInfoAlreadySet = true;
                viewOwner.hidden = true;
                btnFinish.frame = CGRectMake(20, yy-220, DEVICE_WIDTH-40, 50);
                scrllView1.scrollEnabled = false;
            }
            else
            {
                isInfoAlreadySet = false;
                viewOwner.hidden = false;
                btnFinish.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 50);
                scrllView1.scrollEnabled = true;
            }

        }
        else
        {
            isInfoAlreadySet = false;
            viewOwner.hidden = false;
            btnFinish.frame = CGRectMake(20, yy, DEVICE_WIDTH-40, 50);
            scrllView1.scrollEnabled = true;
        }
    
        NSString * strSharedName = [APP_DELEGATE checkforValidString:CURRENT_USER_NAME];
        if (![[APP_DELEGATE checkforValidString:CURRENT_USER_NAME] isEqualToString:@"NA"])
        {
            if ([strSharedName length]>18)
            {
                strSharedName = [strSharedName substringWithRange:NSMakeRange(0, 18)];
            }
            txtOwnerName.text = strSharedName;
        }
        if (![[APP_DELEGATE checkforValidString:CURRENT_USER_EMAIL] isEqualToString:@"NA"])
        {
            txtEmail.text = [APP_DELEGATE checkforValidString:CURRENT_USER_EMAIL];
        }
        
        if (userShardInfo.count > 0)
        {
            NSString * strMobile = [[userShardInfo objectAtIndex:0] valueForKey:@"mobile"];
            if (![[APP_DELEGATE checkforValidString:strMobile] isEqualToString:@"NA"])
            {
                txtMobile.text = strMobile;
            }
        }
    }
    if (isfromHome)
    {
        [btnImg setTitle:@"" forState:UIControlStateNormal];
        imgDevice.backgroundColor = UIColor.clearColor;
        btnImg.backgroundColor = UIColor.clearColor;
        if (![[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"photo_localURL"]] isEqualToString:@"NA"])
        {
            NSString * filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"TrackerDeviceName/%@",[deviceDetail valueForKey:@"photo_localURL"]]];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            UIImage * mainImage = [UIImage imageWithData:pngData];
            UIImage * image = [self scaleMyImage:mainImage];
            imgDevice.image = image;
        }
        else if(![[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"photo_serverURL"]] isEqualToString:@"NA"])
        {
            NSURL * tmpURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[deviceDetail valueForKey:@"photo_serverURL"]]];
            imgDevice.imageURL = tmpURL;
        }
        else
        {
            imgDevice.image = [UIImage imageNamed:@"logoDisplay"];
        }
        
        txtDeviceName.text = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"device_name"]];
    }
}
#pragma mark - UITextfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!isfromSettings)
    {
        if (textField == txtDeviceName)
        {
            lblDeviceNameErrorMsg.hidden = true;
            lblDeviceNameLine.backgroundColor = global_greenColor;
            lblDeviceNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
        }
        else if (textField == txtOwnerName)
        {
            lblOwnerNameLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
            lblOwnerNameErrorMsg.hidden = true;
            lblOwnerNameLine.backgroundColor = global_greenColor;
        }
        else if (textField == txtEmail)
        {
            if(DEVICE_WIDTH == 320)
            {
                [UIView animateWithDuration:0.4 animations:^{
                    [self->scrllView1 setFrame:CGRectMake(0,-80, DEVICE_WIDTH, DEVICE_HEIGHT)];}];
            }
            lblEmailLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
            lblEmailErrorMsg.hidden = true;
            lblEmailLine.backgroundColor = global_greenColor;
        }
        else if (textField == txtMobile)
        {
            if (IS_IPHONE_X)
            {
            }
            else
            {
                if(DEVICE_WIDTH == 320)
                {
                    [UIView animateWithDuration:0.4 animations:^{
                        [self->scrllView1 setFrame:CGRectMake(0,-110, DEVICE_WIDTH, DEVICE_HEIGHT)];}];
                }
                else
                {
                    [UIView animateWithDuration:0.4 animations:^{
                        [self->scrllView1 setFrame:CGRectMake(0,-80, DEVICE_WIDTH, DEVICE_HEIGHT)];}];
                }
            }
            lblMobileLine.frame = CGRectMake(0, 38, DEVICE_WIDTH-40, 2);
            lblEmailErrorMsg.hidden = true;
            lblMobileLine.backgroundColor = global_greenColor;
        }
    }
    
    if (textField == txtMobile)
    {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        numberToolbar.barStyle =  UIBarStyleDefault;
        UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *Done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneKeyBoarde)];
        Done.tintColor=[UIColor blackColor];
        numberToolbar.items = [NSArray arrayWithObjects:space,Done,nil];
        [numberToolbar sizeToFit];
        textField.inputAccessoryView = numberToolbar;
    }
}
-(void)doneKeyBoarde
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 88;
    }
    [UIView animateWithDuration:0.4 animations:^{
        [self->scrllView1 setFrame:CGRectMake(0,yy, DEVICE_WIDTH, DEVICE_HEIGHT)];
    }];
    [txtMobile resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtDeviceName)
    {
        [txtDeviceName resignFirstResponder];
    }
    else if (textField == txtOwnerName)
    {
        [txtOwnerName resignFirstResponder];
        [txtEmail becomeFirstResponder];
    }
    else if (textField == txtEmail)
    {
        [txtEmail resignFirstResponder];
        [txtMobile becomeFirstResponder];
        [self doneKeyBoarde];
    }
    else if (textField == txtMobile)
    {
        [txtMobile resignFirstResponder];
    }
    return true;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!isfromSettings)
    {
        if (textField == txtDeviceName)
        {
            lblDeviceNameLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
            lblDeviceNameLine.backgroundColor = UIColor.grayColor;
        }
        else if (textField == txtOwnerName)
        {
            lblOwnerNameLine.backgroundColor = UIColor.lightGrayColor;
            lblOwnerNameLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
        }
        else if (textField == txtEmail)
        {
            lblEmailLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
            lblEmailLine.backgroundColor = UIColor.lightGrayColor;
        }
        else if (textField == txtMobile)
        {
            lblMobileLine.frame = CGRectMake(0, 39, DEVICE_WIDTH-40, 1);
            lblMobileLine.backgroundColor = UIColor.lightGrayColor;
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    isChangesDone = YES;

    if (textField == txtOwnerName)
    {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 18;
    }
    else if (textField == txtMobile)
    {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 15;
    }
    
    return YES;
}

#pragma mark - All Button Click Events
-(void)btnBackClick
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedNamefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedMobilefromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail1fromDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FetchedEmail2fromDevice" object:nil];

    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnImgClick
{
    [self setUpPhotoView];
}
-(void)btnFinishClick
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 88;
    }
    
    [txtMobile resignFirstResponder];
    [self.view endEditing:true];
    [UIView animateWithDuration:0.4 animations:^{
        [self->scrllView1 setFrame:CGRectMake(0,yy, DEVICE_WIDTH, DEVICE_HEIGHT)];
    }];
    BOOL isSameNameAvail = NO;
    if ([[arrayDevice valueForKey:@"device_name"] containsObject:txtDeviceName.text])
    {
        NSInteger  indexx = [[arrayDevice valueForKey:@"device_name"] indexOfObject:txtDeviceName.text];
        if (indexx != NSNotFound)
        {
            if (indexx < [arrayDevice count])
            {
                if (![[[arrayDevice objectAtIndex:indexx]valueForKey:@"ble_address"]isEqualToString:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"ble_address"]]])
                {
                    isSameNameAvail = YES;
                }
            }
        }
    }
    if (isfromSettings) // IF FROM MENU --> ACCOUNT SETTINGS
    {
        [self SaveShardInfoFromSettings];
    }
    else if (isfromHome)  // IF FROM HOME SCREEN --> MORE
    {
        if ([txtDeviceName.text isEqualToString:@""])
        {
            lblDeviceNameErrorMsg.hidden = false;
            lblDeviceNameLine.backgroundColor = UIColor.redColor;
            lblDeviceNameErrorMsg.text = @"Please enter device name";
            return;
        }
        if (isSameNameAvail)
        {
            lblDeviceNameErrorMsg.hidden = false;
            lblDeviceNameErrorMsg.text = @"This Device name is already in use.";
            lblDeviceNameLine.backgroundColor = UIColor.redColor;
            return;
        }
        if (isChangesDone)
        {
            [self UpdateDeviceinfoToServer];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else //TO SAVE FRESH DEVICE
    {
        if ([txtDeviceName.text isEqualToString:@""])
        {
            lblDeviceNameErrorMsg.hidden = false;
            lblDeviceNameErrorMsg.text = @"Please enter device name";
            lblDeviceNameLine.backgroundColor = UIColor.redColor;
        }
        else if (isSameNameAvail)
        {
            lblDeviceNameErrorMsg.hidden = false;
            lblDeviceNameErrorMsg.text = @"This Device name is already in use.";
            lblDeviceNameLine.backgroundColor = UIColor.redColor;
        }
        else if(isInfoAlreadySet == false)
        {
            if ([txtDeviceName.text isEqualToString:@""])
            {
                lblDeviceNameErrorMsg.hidden = false;
                lblDeviceNameLine.backgroundColor = UIColor.redColor;
            }
            else if([self isOwnerDetailsValid])
            {
                if ([_strDeviceStatus isEqualToString:@"01"])
                {
                    [self SaveDeviceDetailstoDatabase];
                }
                else
                {
                    [self saveFinishInfo];
                }
            }
        }
        else if(isInfoAlreadySet == true)
        {
            if (userShardInfo.count > 0)
            {
                NSString * strName = [[userShardInfo objectAtIndex:0] valueForKey:@"name"];
                if (![[APP_DELEGATE checkforValidString:strName] isEqualToString:@"NA"])
                {
                    if ([strName length]>18)
                    {
                        strName = [strName substringWithRange:NSMakeRange(0, 18)];
                    }
                }
                NSString * strMobile = [[userShardInfo objectAtIndex:0] valueForKey:@"mobile"];
                if (![[APP_DELEGATE checkforValidString:strMobile] isEqualToString:@"NA"])
                {
                    if ([strMobile length]>18)
                    {
                        strMobile = [strMobile substringWithRange:NSMakeRange(0, 18)];
                    }
                }
                txtOwnerName.text = strName;
                txtMobile.text = strMobile;
                txtEmail.text = [[userShardInfo objectAtIndex:0] valueForKey:@"email"];
            }
            if ([_strDeviceStatus isEqualToString:@"01"])
            {
                [self SaveDeviceDetailstoDatabase];
            }
            else
            {
                [self saveFinishInfo];
            }
        }
    }
}
-(void)saveFinishInfo
{
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
        btnFinish.enabled = false;
        [self.view endEditing:true];
        [saveTimer invalidate];
        saveTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(saveTimerUpdate) userInfo:nil repeats:NO];  // 25 to 20 made by chethan
        
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Saving Device..."];
        
        if (![arrGlobalDevices containsObject:classPeripheral])
        {
            [arrGlobalDevices addObject:classPeripheral];
        }
        
        [[BLEService sharedInstance] writeUserUniqueValue:CURRENT_USER_UNIQUEKEY with:classPeripheral];
        [self performSelector:@selector(SyncOwnerName) withObject:nil afterDelay:0.2];
        
    }
    else
    {
        [APP_DELEGATE endHudProcess];
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Device disconnected. Please connect and try again"
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    [alert doneActionBlock:^{
                        // Put your action here
       [self.navigationController popViewControllerAnimated:true];
                    }];
        
    }
}
-(BOOL)isOwnerDetailsValid
{
    BOOL isValidData = YES;
    
    if ([txtOwnerName.text isEqualToString:@""])
    {
        isValidData = NO;
        lblOwnerNameErrorMsg.hidden = false;
        lblOwnerNameLine.backgroundColor = UIColor.redColor;
    }
    else if ([txtEmail.text isEqualToString:@""])
    {
        isValidData = NO;
        lblEmailErrorMsg.hidden = false;
        lblEmailLine.backgroundColor = UIColor.redColor;
    }
    else  if(![APP_DELEGATE validateEmail:txtEmail.text])
    {
        isValidData = NO;
        lblEmailErrorMsg.hidden = false;
        lblEmailLine.backgroundColor = UIColor.redColor;
        lblEmailErrorMsg.text = @"Please enter valid email address";
    }
    else if (txtMobile.text.length > 0 && txtMobile.text.length < 10)
    {
        isValidData = NO;
        lblMobileLine.hidden = false;
        lblMobileLine.backgroundColor = UIColor.redColor;
        lblMobileErrorMsg.hidden = false;
    }
    else if (txtMobile.text.length > 0 && txtMobile.text.length > 15)
    {
        isValidData = NO;
        lblMobileLine.hidden = false;
        lblMobileLine.backgroundColor = UIColor.redColor;
        lblMobileErrorMsg.hidden = false;
    }
    return isValidData;
}

#pragma mark - Method to Save data to DB & Server
-(void)SaveDeviceDetailstoDatabase
{
    [saveTimer invalidate];
    btnFinish.enabled = false;
     strImagePath = @"NA";
    if (imgDevice.image != nil)
    {
        strImagePath =  [self saveImagetoDocumentDirectory];
    }
    else
    {
        imgDevice.image = [UIImage imageNamed:@"logoDisplay"];
        strImagePath =  [self saveImagetoDocumentDirectory];
        [btnImg setTitle:@"" forState:UIControlStateNormal];
    }
    strCurrentDateNTime =  [APP_DELEGATE checkforValidString:[APP_DELEGATE getCurrentTime]];
//    [APP_DELEGATE endHudProcess];
    
    NSString * strBleAddress = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"bleAddress"]];
    NSString * strLat = [NSString stringWithFormat:@"%f", currentLatitude];
    NSString * strLong = [NSString stringWithFormat:@"%f", currentLongitude];
    NSString * strDeviceName = [APP_DELEGATE checkforValidString:txtDeviceName.text];
    NSString * strOwnerName = [APP_DELEGATE checkforValidString:txtOwnerName.text];
    NSString * strOwnerEmail = [APP_DELEGATE checkforValidString:txtEmail.text];
    NSString * strMobile = [APP_DELEGATE checkforValidString:txtMobile.text];
    NSString * strIdentifier = [APP_DELEGATE checkforValidString:[NSString stringWithFormat:@"%@",classPeripheral.identifier]];
    
    if ([strOwnerName length]>18)
    {
        strOwnerName = [strOwnerName substringWithRange:NSMakeRange(0, 18)];
    }
    
    if ([strMobile length]>18)
    {
        strMobile = [strMobile substringWithRange:NSMakeRange(0, 18)];
    }
    
    // adding b4 local db coz server id is fetched onresult
    if ([APP_DELEGATE isNetworkreachable])
    {
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Saving Device...."];
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ID"] forKey:@"user_id"];
        [dict setValue:strBleAddress forKey:@"ble_address"];
        [dict setValue:@"2" forKey:@"device_type"];
        [dict setValue:strLat forKey:@"latitude"];
        [dict setValue:strLong forKey:@"longitude"];
        [dict setValue:@"1" forKey:@"tracker_device_alert"];
        [dict setValue:@"0" forKey:@"marked_lost"];
        [dict setValue:@"1" forKey:@"is_active"];
        [dict setValue:strOwnerName forKey:@"contact_name"];
        [dict setValue:strOwnerEmail forKey:@"contact_email"];
        [dict setValue:strMobile forKey:@"contact_mobile"];
        [dict setValue:strDeviceName forKey:@"device_name"];
        [dict setValue:@"1" forKey:@"correction_status"];
        
        dictHomeInfo = [[NSMutableDictionary alloc] init];
        dictHomeInfo = [dict mutableCopy];
        [dictHomeInfo setObject:strImagePath forKey:@"photo_localURL"];
        
        //to save the image in web
        NSData *pngData;
        pngData = UIImageJPEGRepresentation(imgDevice.image, 0.2);
        NSMutableArray * arrImageData = [[NSMutableArray alloc] init];
        [arrImageData addObject:pngData];
        
        NSMutableArray * arrImageName = [[NSMutableArray alloc] init];
        NSString * strinstller = @"device_image";
        [arrImageName addObject:strinstller];
        
        NSMutableArray * arrImagePath = [[NSMutableArray alloc] init];
        [arrImagePath addObject:[APP_DELEGATE checkforValidString:@"strImagePath"]];
        
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"adddevice";
        manager.delegate = self;
        NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/adddevice";
        [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arrImageData andDataParameterName:arrImageName andFileName:arrImagePath];

        NSLog(@"sent info for Custom Devoce is %@",dict);
    }
    else
    {
        [APP_DELEGATE endHudProcess];

        btnFinish.enabled = true;
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Device has not been updated due to no internet connection."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    if ([[APP_DELEGATE checkforValidString:strServerID]isEqualToString:@"NA"])
    {
        strServerID = @"NA";
    }
    if ([[APP_DELEGATE checkforValidString:strImagePath]isEqualToString:@"NA"])
    {
        strImagePath = @"NA";
    }
    NSString * requestStr =[NSString stringWithFormat:@"insert into 'Device_Table'('user_id','ble_address','device_name','latitude','longitude','tracker_device_alert','marked_lost','is_active','contact_name','contact_email','contact_mobile','photo_localURL','identifier','created_time','updated_time','correction_status','server_id','device_type') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",'Connected',\"%@\",\"%@\")",CURRENT_USER_ID,strBleAddress,strDeviceName,strLat,strLong,@"1", @"0", @"1",strOwnerName,strOwnerEmail,strMobile,strImagePath,strIdentifier,strCurrentDateNTime,strCurrentDateNTime,strServerID,@"2"];
    intDeviceId = [[DataBaseManager dataBaseManager] executeSw:requestStr];
    if ([userShardInfo count]==0)
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'User_Set_Info'('user_id','name','email','mobile') values(\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,strOwnerName,strOwnerEmail,strMobile];
        [[DataBaseManager dataBaseManager] execute:requestStr];
    }
    else
    {
        NSString * strUpdate = [NSString stringWithFormat:@"update User_Set_Info set name=\"%@\", email=\"%@\", mobile =\"%@\"",strOwnerName,strOwnerEmail,strMobile];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
    }
}
-(void)UpdateDeviceinfoToServer
{
    btnFinish.enabled = false;
    if ([APP_DELEGATE isNetworkreachable])
    {
        strCurrentDateNTime =  [APP_DELEGATE checkforValidString:[APP_DELEGATE getCurrentTime]];
        NSString * strMarkedLost = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"marked_lost"]];
        if (isImageUpdated)
        {
            strImagePath = @"NA";
            if (imgDevice.image != nil)
            {
                strImagePath =  [self saveImagetoDocumentDirectory];
            }
            if ([strMarkedLost isEqualToString:@"NA"])
            {
                strMarkedLost = @"0";
            }
        }
        
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Saving Device...."];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ID"] forKey:@"user_id"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"ble_address"]] forKey:@"ble_address"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"device_type"]] forKey:@"device_type"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"tracker_device_alert"]] forKey:@"tracker_device_alert"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"marked_lost"]] forKey:@"marked_lost"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"is_active"]] forKey:@"is_active"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_name"]] forKey:@"contact_name"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_email"]] forKey:@"contact_email"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_mobile"]] forKey:@"contact_mobile"];
        [dict setValue:[APP_DELEGATE checkforValidString:txtDeviceName.text] forKey:@"device_name"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"correction_status"]] forKey:@"correction_status"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"server_id"]] forKey:@"device_id"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"latitude"]] forKey:@"latitude"];
        [dict setValue:[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"longitude"]] forKey:@"longitude"];

        CBPeripheral * p = [deviceDetail objectForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            [dict setValue:[NSString stringWithFormat:@"%f", currentLatitude] forKey:@"latitude"];
            [dict setValue:[NSString stringWithFormat:@"%f", currentLongitude] forKey:@"longitude"];
        }
        if (isImageUpdated)
        {
            NSData *pngData;
            pngData = UIImageJPEGRepresentation(imgDevice.image, 0.2);
            NSMutableArray * arrImageData = [[NSMutableArray alloc] init];
            [arrImageData addObject:pngData];
            
            NSMutableArray * arrImageName = [[NSMutableArray alloc] init];
            NSString * strinstller = @"device_image";
            [arrImageName addObject:strinstller];
            
            NSMutableArray * arrImagePath = [[NSMutableArray alloc] init];
            [arrImagePath addObject:[APP_DELEGATE checkforValidString:@"strImagePath"]];
            
            URLManager *manager = [[URLManager alloc] init];
            manager.commandName = @"updatedevice";
            manager.delegate = self;
            NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/adddevice";
            [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arrImageData andDataParameterName:arrImageName andFileName:arrImagePath];
        }
        else
        {
            URLManager *manager = [[URLManager alloc] init];
            manager.commandName = @"updatedevice";
            manager.delegate = self;
            NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/adddevice";
            [manager urlCall:strServerUrl withParameters:dict];
            NSLog(@"sent info for Custom Device Update is %@",dict);
        }
    }
    else
    {
        btnFinish.enabled = true;
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Device has not been updated due to no internet connection."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
-(void)SaveShardInfoFromSettings
{
    if ([self isOwnerDetailsValid])
    {
        lblMobileErrorMsg.hidden = true;
        lblOwnerNameErrorMsg.hidden = true;
        lblEmailErrorMsg.hidden = true;
        btnFinish.enabled = false;
        NSString * strOwnerName = [APP_DELEGATE checkforValidString:txtOwnerName.text];
        NSString * strOwnerEmail = [APP_DELEGATE checkforValidString:txtEmail.text];
        NSString * strMobile = [APP_DELEGATE checkforValidString:txtMobile.text];
        if ([strOwnerName length]>18)
        {
            strOwnerName = [strOwnerName substringWithRange:NSMakeRange(0, 18)];
        }
        if ([userShardInfo count]==0)
        {
            NSString * requestStr =[NSString stringWithFormat:@"insert into 'User_Set_Info'('user_id','name','email','mobile') values(\"%@\",\"%@\",\"%@\",\"%@\")",CURRENT_USER_ID,strOwnerName,strOwnerEmail,strMobile];
            [[DataBaseManager dataBaseManager] execute:requestStr];
        }
        else
        {
            NSString * strUpdate = [NSString stringWithFormat:@"update User_Set_Info set name=\"%@\", email=\"%@\", mobile =\"%@\"",strOwnerName,strOwnerEmail,strMobile];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
        }
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        btnFinish.enabled = true;
    }
}

-(void)saveTimerUpdate
{
    btnFinish.enabled = true;
    [APP_DELEGATE endHudProcess];
    if (isCompleted)
    {
        
        
    }
    else
    {
        if (completedCount >=4 || completedCount == 0)
        {
//             [self setDeviceTrackerStaus:true];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeCaution];
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Something went wrong , Please try later." //chethan remove this, Something went wrong , Please try later.
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
    }
}
-(void)setDeviceTrackerStaus:(BOOL)isOn
{
    NSInteger valuInt = 1;
    
    NSData * valueData = [[NSData alloc] initWithBytes:&valuInt length:1];
    
    NSInteger opInt = 8;
    NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
    
    NSInteger lengths = 1;
    NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
    
    NSMutableData * finalData = [opCodeData mutableCopy];
    [finalData appendData:lengthData];
    [finalData appendData:valueData];
    [[BLEService sharedInstance] SendCommandNSData:finalData withPeripheral:classPeripheral];
    NSLog(@"final data=%@",finalData);
    
}
#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    
    if ([[result valueForKey:@"commandName"] isEqualToString:@"adddevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            strServerID = [NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"id"]];
            NSString * strServerPhoto = [NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"device_image_path"]];
            NSString * strBleAddress = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"bleAddress"]];
            
            NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set server_id ='%@', photo_serverURL ='%@' where id ='%@' and ble_address ='%@'",strServerID, strServerPhoto,[NSString stringWithFormat:@"%d",intDeviceId],strBleAddress];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            
            [dictHomeInfo setObject:strServerID forKey:@"server_id"];
            [dictHomeInfo setObject:strServerPhoto forKey:@"photo_serverURL"];
            [dictHomeInfo setObject:classPeripheral forKey:@"peripheral"];
            [dictHomeInfo setObject:[NSString stringWithFormat:@"%@",classPeripheral.identifier] forKey:@"identifier"];
            [dictHomeInfo setValue:[NSString stringWithFormat:@"%d",intDeviceId] forKey:@"id"];
            if ([[arrayDevice valueForKey:@"bleAddress"] containsObject:[deviceDetail valueForKey:@"bleAddress"]])
            {
                NSInteger foundIndexx = [[arrayDevice valueForKey:@"bleAddress"] indexOfObject:[deviceDetail valueForKey:@"bleAddress"]];
                if (foundIndexx != NSNotFound)
                {
                    if (foundIndexx < [arrayDevice count])
                    {
                        [arrayDevice replaceObjectAtIndex:foundIndexx withObject:dictHomeInfo];
                    }
                }
            }
            else
            {
                [arrayDevice addObject:dictHomeInfo];
            }
            [homeDashboard SaveAddedDeviceToHome:dictHomeInfo];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveAddedDeviceToHome" object:dictHomeInfo];
            
            [self setDeviceTrackerStaus:true];
            FCAlertView *alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeSuccess];
            alert.delegate = self;
            alert.tag = 222;
            [alert showAlertInView:self
                         withTitle:@"KUURV"
                      withSubtitle:@"Device has been added successfully."
                   withCustomImage:[UIImage imageNamed:@"logo.png"]
               withDoneButtonTitle:nil
                        andButtons:nil];
        }
        else
        {
            [APP_DELEGATE endHudProcess];
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
                btnFinish.enabled = true;
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
    if ([[result valueForKey:@"commandName"] isEqualToString:@"updatedevice"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            strServerID = [deviceDetail valueForKey:@"server_id"];
            NSString * strServerPhoto = [NSString stringWithFormat:@"%@",[tmpDict valueForKey:@"device_image_path"]];
            NSString * strBleAddress = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"ble_address"]];
            NSString * strUpdate = [NSString stringWithFormat:@"update Device_Table set server_id ='%@', photo_serverURL ='%@', photo_localURL ='%@', device_name = \"%@\" where server_id ='%@' and ble_address ='%@'",strServerID, strServerPhoto,strImagePath,txtDeviceName.text,[NSString stringWithFormat:@"%@",strServerID],strBleAddress];
            [[DataBaseManager dataBaseManager] execute:strUpdate];
            if (sentIndex == NSNotFound)
            {
                sentIndex = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:strBleAddress];
            }
            if (sentIndex != NSNotFound)
            {
                if (sentIndex < [arrayDevice count])
                {
                    [[arrayDevice objectAtIndex:sentIndex] setValue:strServerPhoto forKey:@"photo_serverURL"];
                    [[arrayDevice objectAtIndex:sentIndex] setValue:strImagePath forKey:@"photo_localURL"];
                    [[arrayDevice objectAtIndex:sentIndex] setValue:txtDeviceName.text forKey:@"device_name"];
                    [selectedDeviecDict setValue:strServerPhoto forKey:@"photo_serverURL"];
                    [selectedDeviecDict setValue:strImagePath forKey:@"photo_localURL"];
                    [selectedDeviecDict setValue:txtDeviceName.text forKey:@"device_name"];
                }
            }
            [APP_DELEGATE endHudProcess];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [APP_DELEGATE endHudProcess];
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
                btnFinish.enabled = true;
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
//    updatedevice
}
- (void)onError:(NSError *)error
{
    btnFinish.enabled = true;
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

#pragma mark - Photo Events
-(void)setUpPhotoView
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"KUURV"
                                                                   message:@"Set Tracker Device Photo"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* actionCamera = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       //   For taking img by camera
                                       UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                       picker.delegate = self;
                                       picker.allowsEditing = YES;
                                       picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       [self presentViewController:picker animated:YES completion:nil];
                                       
                                   }];
    
    UIAlertAction* actionGallery = [UIAlertAction actionWithTitle:@"Photo From Library" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        // for picking img from gallery
                                        UIImagePickerController *picker2 = [[UIImagePickerController alloc] init];
                                        picker2.delegate = self;
                                        picker2.allowsEditing = YES;
                                        picker2.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        [self presentViewController:picker2 animated:YES completion:nil];
                                    }];
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
    
    [alert addAction:actionCamera];
    [alert addAction:actionGallery];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
//for o/p img
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // output image
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    imgDevice.contentMode = UIViewContentModeScaleAspectFit;
    imgDevice.image = [self scaleMyImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [btnImg setTitle:@" " forState:UIControlStateNormal];
    
    isChangesDone = YES;
    isImageUpdated = YES;
}
-(UIImage *)scaleMyImage:(UIImage *)newImg
{
    UIGraphicsBeginImageContext(CGSizeMake(newImg.size.width/2,newImg.size.height/2));
    
    [newImg drawInRect: CGRectMake(0, 0, newImg.size.width/2, newImg.size.height/2)];
    
    UIImage        *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}
-(NSString *)saveImagetoDocumentDirectory
{
    NSString * imageName;
    // to give unique name based on time stamp
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
    
    //taking random no and assigning to make it more unique
    int randomID = arc4random() % 9000 + 1000;
    imageName = [NSString stringWithFormat:@"/trackerdevice-%@-%d%@.jpg", CURRENT_USER_ID,randomID,timeStampObj];
    
    imageName = [imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"TrackerDeviceName"]; // New Folder is your folder name
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *fileName = [stringPath stringByAppendingString:imageName];
    NSData *data = UIImageJPEGRepresentation(imgDevice.image, 0.2);
    [data writeToFile:fileName atomically:YES];
    
    // to save the taken img in gallery also so that img backup will be there
//    UIImage * mainImage = [UIImage imageWithData:data];
//    UIImageWriteToSavedPhotosAlbum(mainImage, nil, nil, nil);
    
    return imageName;
    
    
    
    //    [manager postUrlCallForMultipleImage:strServerUrl withParameters:dict andMediaData:arr1 andDataParameterName:arr2 andFileName:arr3];
}
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 222)
    {
        [APP_DELEGATE endHudProcess];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else  if (alertView.tag == 111)
    {
        [APP_DELEGATE logoutAndClearDB];
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)tapClick:(UITapGestureRecognizer *)tapClick
{
    [self.view endEditing:YES];
    [self doneKeyBoarde];
}


#pragma mark - Sync info to BLE device

-(void)SyncOwnerName
{
    NSString * strOwnerName = [APP_DELEGATE checkforValidString:txtOwnerName.text];
    if ([strOwnerName length]>18)
    {
        strOwnerName = [strOwnerName substringWithRange:NSMakeRange(0, 18)];
    }
    [[BLEService sharedInstance] SyncUserTextinfowithDevice:strOwnerName with:classPeripheral withOpcode:@"1"];
    [self performSelector:@selector(SyncOwnerMobile) withObject:nil afterDelay:0.2];
}
-(void)SyncOwnerMobile
{
    NSString * strMobile = [APP_DELEGATE checkforValidString:txtMobile.text];
    if ([strMobile length]>18)
    {
        strMobile = [strMobile substringWithRange:NSMakeRange(0, 18)];
    }
    [[BLEService sharedInstance] SyncUserTextinfowithDevice:strMobile with:classPeripheral withOpcode:@"2"];
    
    [self performSelector:@selector(SyncEmailfirstHalf) withObject:nil afterDelay:0.2];
}
-(void)SyncEmailfirstHalf
{
    NSString * strOwnerEmail = [APP_DELEGATE checkforValidString:txtEmail.text];
    if ([strOwnerEmail length]>=18)
    {
        NSString * strHalf1 = [strOwnerEmail substringWithRange:NSMakeRange(0, 18)];
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:strHalf1 with:classPeripheral withOpcode:@"3"];
    }
    else
    {
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:strOwnerEmail with:classPeripheral withOpcode:@"3"];
    }
    [self performSelector:@selector(SyncEmailsecondHalf) withObject:nil afterDelay:0.2];
}
-(void)SyncEmailsecondHalf
{
    NSString * strOwnerEmail = [APP_DELEGATE checkforValidString:txtEmail.text];
    if ([strOwnerEmail length]>=18)
    {
        NSString * strHalf2 = [strOwnerEmail substringWithRange:NSMakeRange(18, [txtEmail.text length]-18)];
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:strHalf2 with:classPeripheral withOpcode:@"4"];
    }
    else
    {
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:@"NA" with:classPeripheral withOpcode:@"4"];
    }
    [self performSelector:@selector(VerifyOwnerSyncedInfo) withObject:nil afterDelay:0.3];
}
-(void)VerifyOwnerSyncedInfo
{
    [[BLEService sharedInstance] SendCommandWithPeripheral:classPeripheral withValue:@"12"];
    
}
-(void)FetchedNamefromDevice:(NSNotification *)notify
{
    completedCount = 1;
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Name===>>>%@",strValue);
}
-(void)FetchedMobilefromDevice:(NSNotification *)notify
{
    completedCount = 2;
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Mobile===>>>%@",strValue);
}
-(void)FetchedEmail1fromDevice:(NSNotification *)notify
{
    completedCount = 3;
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Email Half===>>>%@",strValue);
}
-(void)FetchedEmail2fromDevice:(NSNotification *)notify
{
    completedCount = 4;
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Fetched Email 2 Half===>>>%@",strValue);
    
    isCompleted = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self SaveDeviceDetailstoDatabase];
    });
}

@end
