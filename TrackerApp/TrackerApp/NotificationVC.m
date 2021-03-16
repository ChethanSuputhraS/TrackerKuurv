//
//  NotificationVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 09/05/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "NotificationVC.h"
#import "NotificationCell.h"
@interface NotificationVC ()<URLManagerDelegate,FCAlertViewDelegate>

@end

@implementation NotificationVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    arrNotification = [[NSMutableArray alloc]init];
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
    [lblTitle setText:@"Notifcation"];
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
    
    tblContent =[[UITableView alloc]initWithFrame:CGRectMake(0,yy,DEVICE_WIDTH,DEVICE_HEIGHT-yy) style:UITableViewStylePlain];
    tblContent.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    tblContent.showsVerticalScrollIndicator = NO;
    tblContent.showsHorizontalScrollIndicator=NO;
    [tblContent setDelegate:self];
    [tblContent setDataSource:self];
    [tblContent setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tblContent.scrollEnabled = true;
//    tblContent.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:tblContent];
    
    [self fetchNotifications:0];
    
    lblNotFound = [[UILabel alloc]init];
    lblNotFound.frame = CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy);
    lblNotFound.backgroundColor = UIColor.clearColor;
    lblNotFound.textColor = global_greenColor;
    lblNotFound.text = @"No Notifications Found.";
    lblNotFound.hidden = true;
    lblNotFound.font = [UIFont fontWithName:CGRegular size:txtSize+4];
    lblNotFound.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblNotFound];
}
-(void)fetchNotifications:(int)notificationsCompleted
{
    [APP_DELEGATE startHudProcess:@"loading"];
    if ([APP_DELEGATE isNetworkreachable])
    {
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:CURRENT_USER_ID forKey:@"user_id"];
        [dict setValue:@"10" forKey:@"limit"];
        [dict setValue:[NSString stringWithFormat:@"%d",notificationsCompleted] forKey:@"offset"];
        
        NSLog(@" sent dict is %@",dict);
        URLManager *manager = [[URLManager alloc] init];
        manager.commandName = @"notificationlist";
        manager.delegate = self;
        NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/notificationlist";
        [manager urlCall:strServerUrl withParameters:dict];
        NSLog(@"sent info for devicelist info is %@",dict);
    }
    else
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"There is no internet connection.Connect to internet first to fetch notifications."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
}
- (void)onResult:(NSDictionary *)result
{
    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
//    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
//    tmpDict = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    NSMutableArray * tmpArr = [[[result valueForKey:@"result"] valueForKey:@"data"] mutableCopy];
    if([[result valueForKey:@"commandName"] isEqualToString:@"notificationlist"])
    {
        if ([[[result valueForKey:@"result"] valueForKey:@"response"] isEqualToString:@"true"])
        {
            for (int i = 0; i<tmpArr.count; i++)
            {
                NSString * strConvDate = [self changeDateFormat:[[tmpArr objectAtIndex:i]valueForKey:@"created_at"]];
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:strConvDate,@"created_at",[[tmpArr objectAtIndex:i]valueForKey:@"notification"],@"notification", nil];
                [arrNotification addObject:tmpDict];

            }
            if (tmpArr.count == 0)
            {
                isLimitReached = true;
            }
            NSLog(@"array notification has %@",arrNotification);
            
            if (arrNotification.count == 0)
            {
                lblNotFound.hidden = false;
            }
            [tblContent reloadData];
            
//
        }
        else
        {
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
}
- (void)onError:(NSError *)error
{
        [APP_DELEGATE endHudProcess];
    NSLog(@"The error is...%@", error);
    NSInteger ancode = [error code];
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else
    {
        [APP_DELEGATE ShowErrorPopUpWithErrorCode:customErrorCodeForMessage andMessage:@"Please try again later"];
    }
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
    }
}

-(NSString *)changeDateFormat:(NSString *)dateStr
{
    [APP_DELEGATE endHudProcess];
    NSString * dateString = [APP_DELEGATE checkforValidString:dateStr];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"LLLL dd yyyy 'at' h:mm a"];
    NSString *stringDate = [dateFormatter2 stringFromDate:dateFromString];
    
    return stringDate;
}
#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrNotification.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[NotificationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    if (arrNotification.count > 0)
    {
        lblNotFound.hidden = true;
        NSString * notification = [[arrNotification objectAtIndex:indexPath.row]valueForKey:@"notification"];
        NSString * stringFound  = @"found";
        NSRange finalRange = [notification rangeOfString:stringFound];
        if (finalRange.location != NSNotFound)
        {
            NSLog(@"range is %lu",(unsigned long)finalRange.location);
            NSString * strFinal = [notification substringWithRange:NSMakeRange(0,finalRange.location+5)];
            strFinal = [NSString stringWithFormat:@"%@ here.",strFinal];
            cell.lblNotification.text = strFinal;

        }
        cell.lblDate.text =  [[arrNotification objectAtIndex:indexPath.row]valueForKey:@"created_at"];
        
        
    
    }
    else
    {
        lblNotFound.hidden = false;
    }
    
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (arrNotification.count > 0)
    {
        NSString * notification = [[arrNotification objectAtIndex:indexPath.row]valueForKey:@"notification"];
        NSString * stringLocation  = @"location";
        NSRange finalRange = [notification rangeOfString:stringLocation];
        NSInteger endString = notification.length;
        NSInteger startString = finalRange.location+finalRange.length;
        endString = endString - startString;
        if (finalRange.location != NSNotFound)
        {
            NSLog(@"range is %lu",(unsigned long)finalRange.location);
            NSString * strFinal = [notification substringWithRange:NSMakeRange(startString,endString)];
            NSLog(@"address is %@",strFinal);
            
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString: strFinal]];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{


    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance)
    {
        NSLog(@"scroll  view reached end ---------------------------------------------------------------------------->");

        if (isLimitReached == false)
        {
            yy = yy+10;
            [self fetchNotifications:yy];
        }
    }
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
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    if (alertView.tag == 111)
    {
        [APP_DELEGATE logoutAndClearDB];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
