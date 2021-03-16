//
//  AboutUsVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 19/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AboutUsVC.h"
#import "HelpCell.h"
#import "WebViewVC.h"
#import "Doorbell.h"
#import <MessageUI/MessageUI.h>

@interface AboutUsVC ()<MFMailComposeViewControllerDelegate>
{
    Doorbell *feedback;

}
@end

@implementation AboutUsVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
    arrAboutUs = [[NSMutableArray alloc]initWithObjects:@"Privacy Policy",@"Terms of Use",@"Feedback", nil];
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
    [lblTitle setText:@"About Us"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGBold size:txtSize+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgMenu = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+7, 33, 30)];
    imgMenu.image = [UIImage imageNamed:@"menu.png"];
    imgMenu.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgMenu];
    
    UIButton * btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMenu setFrame:CGRectMake(0, 0, 80, yy)];
    [btnMenu addTarget:self action:@selector(btnMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnMenu];
    if (IS_IPHONE_X)
    {
        [btnMenu setFrame:CGRectMake(0, 0, 88, 84)];
        imgMenu.frame = CGRectMake(10,40+7, 33, 30);
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
    [tblContent setBackgroundColor:UIColor.clearColor];
    tblContent.showsVerticalScrollIndicator = NO;
    tblContent.showsHorizontalScrollIndicator=NO;
    tblContent.scrollEnabled = false;
    [tblContent setDelegate:self];
    [tblContent setDataSource:self];
    [tblContent setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tblContent];
}
#pragma mark- UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrAboutUs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HelpCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HelpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblName.text = [arrAboutUs objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        WebViewVC*view1 = [[WebViewVC alloc]init];
        view1.btnIndex = 1;
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if (indexPath.row == 1)
    {
        WebViewVC*view1 = [[WebViewVC alloc]init];
        view1.btnIndex = 2;
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if(indexPath.row == 2)
    {
        [self feedBackBtnClick];
    }
    
}
#pragma mark - feedBackBtn Click
-(void)feedBackBtnClick
{
    
    NSString *appId = @"10300";
    NSString *appKey = @"LvEVqieHMmu6iHxXskQqYLXK9qRaigSqQH7bDkILbLey8WMDshuRIuIQPneQHtMa";
    
    
    if (isFeedbackOpen)
    {
        if (feedback)
        {
            [feedback.dialog.delegate dialogDidCancel:feedback.dialog];
            [feedback.dialog removeFromSuperview];
            feedback=nil;
            feedback = Nil;
            [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            
        }
        else
        {
            [feedback.dialog removeFromSuperview];
            
            feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
            feedback.showEmail = YES;
            feedback.email = @"";
            [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
        isFeedbackOpen = NO;
    }
    else
    {
        feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
        feedback.showEmail = YES;
        feedback.email = @"";
        
        [feedback showFeedbackDialogInViewController:self completion:^(NSError *error, BOOL isCancelled) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        isFeedbackOpen = YES;
    }
}
-(void)DoorbellPopupSuccess
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeSuccess];
    [alert showAlertInView:self
                 withTitle:@"KUURV"
              withSubtitle:@"We appreciate your feedback!"
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)DoorbellPopupFailure
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:@"KUURV"
              withSubtitle:@"Please enter valid email id."
           withCustomImage:[UIImage imageNamed:@"logo.png"]
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)DoorbellPopupNoInternet
{
    [alertGlobal removeFromSuperview];
    alertGlobal = [[FCAlertView alloc] init];
    alertGlobal.colorScheme = [UIColor blackColor];
    [alertGlobal makeAlertTypeCaution];
    [alertGlobal showAlertInView:self
                       withTitle:@"KUURV"
                    withSubtitle:@"There is no internet connection. Please connect to internet first then try again."
                 withCustomImage:[UIImage imageNamed:@"logo.png"]
             withDoneButtonTitle:nil
                      andButtons:nil];
}

#pragma mark - All Button Click Events
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)btnExportClick
{
    NSString * strMsg =  @"file attached";
    // To address
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:strMsg];
    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:nil];
    
    if (mc == nil)
    {
//        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please set up a Mail account in order to send email." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
//
//        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
//        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//            [alertView hideWithCompletionBlock:^{
//            }];
//        }];
//        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
//        if (IS_IPHONE_X)
//        {
//            [alertView showWithAnimation:URBAlertAnimationDefault];
//        }
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:@"tracker.sqlite"];
        NSData *noteData = [NSData dataWithContentsOfFile:txtFilePath];
        [mc addAttachmentData:noteData mimeType:@"sqlite" fileName:@"tracker"];
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 
 
 openssl pkcs12 -in NewTrackerAPNSp12.p12 -out Tracker.pem*/

@end
