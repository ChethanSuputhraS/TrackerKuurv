//
//  HelpVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 18/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "HelpVC.h"
#import "AnswerVC.h"
#import "HelpCell.h"
#import "WebViewVC.h"
@interface HelpVC ()<UIGestureRecognizerDelegate>

@end

UIView * backShadowView,*viewAnswer;
@implementation HelpVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
    /*
    arrQuestions = [[NSMutableArray alloc]initWithObjects:@"1. My Bluetooth is on but I can’t Access my Kuurv Tracker",@"2. How to Place Your Kuurv Tracker on a Device",@"3. How to Physically Remove the Tracker off of a Device",@"4. How to delete your tracker",@"5. How to Re-Apply the Adhesive Tape to Your Tracker",@"6. More Help", nil];
    
    arrAnswers = [[NSMutableArray alloc]init];
    [arrAnswers addObject:@"Sometimes you may need to exit out of the app itself and then go back into in app to access your Kuurv tracker successfully."];
    [arrAnswers addObject:@"  a. Make sure surface of device being placed on is clean and dry (you may clean with rubbing alcohol, if needed)\n\n  b. Gently peel off the blue adhesive peel off of the bottom of the tracker\n\n  c. Gently place the tracker on your device (Make sure it is on the spot you want, and also be aware that the tracker is not obstructing any charging outlets)\n\n  d. Now press down firmly and on the top of the tracker and all sides of it (Do it for 30 seconds)"];
    [arrAnswers addObject:@"You may use rubbing alcohol and a dull butter knife to gently pry the tracker off of any device. Please be cautious when doing this."];
    [arrAnswers addObject:@"  a. Select the Kuurv tracker you wish you delete (if there are multiples on your account)\n\n  b. Press the more options (3 dots icon) on the top right corner of the homepage\n\n  c. Select Delete Tracker\n*Note Kuurv tracker must be connected in order to delete"];
    [arrAnswers addObject:@"  a. Use rubbing alcohol and a cloth to clean the adhesive residue off of the bottom of the tracker\n\n  b. Make sure the bottom of the tracker is pretty clean and dry\n\n  c. Use the pull tab on the blue adhesive to remove it from its original display\n\n  d. Carefully place the adhesive on the bottom of the tracker fitting as best as possible\n\n  e. Press down firmly on all sides of the adhesive to make sure the adhesive transfers over onto the bottom of the tracker when you are ready to remove it\n\n  f. Firmly press down on the tape for 20-30 seconds\n\n  g. When you are ready to place the tracker on an item, remove the blue strip and apply "];
    [arrAnswers addObject:@"Please reach out to connect@kuurvtracker.com and we will respond within 24 hours or sooner!"];
    
    NSURL *url = [NSURL URLWithString:@"connect@kuurvtracker.com"];
    NSAttributedString * str = [[NSAttributedString alloc] initWithString:@"Please reach out to " attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:CGRegularItalic size:txtSize]}];
    NSAttributedString * str2 = [[NSAttributedString alloc] initWithString:@"connect@kuurvtracker.com" attributes:@{NSForegroundColorAttributeName:[UIColor blueColor], NSFontAttributeName:[UIFont fontWithName:CGRegularItalic size:txtSize], NSLinkAttributeName:url}];
    NSAttributedString * str3 = [[NSAttributedString alloc] initWithString:@" and we will respond within 24 hours or sooner!" attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:CGRegularItalic size:txtSize]}];

//    NSAttributedString *my = [NSAttributedString attributedStringWithString:@"my"
//                                                                 attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontWithSize:16]}];
//    NSAttributedString *link = [NSAttributedString attributedStringWithString:@"Link"
//                                                                   attributes:@{NSForegroundColorAttributeName:[UIColor blue], NSFontAttributeName:[UIFont systemFontWithSize:16], NSLinkAttributeName:url}];
    NSMutableAttributedString *attr = [str mutableCopy];
    [attr appendAttributedString:str2];
    [attr appendAttributedString:str3];
    [arrAnswers addObject:str3];

     */
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
    [lblTitle setText:@"Help"];
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
    long helpHeight = 750;
    if(IS_IPHONE_5 )
    {
        helpHeight = 1150;
    }
    else if (IS_IPHONE_6)
    {
        helpHeight = 860;
    }
    else if(IS_IPHONE_4)
    {
        helpHeight = 1250;
    }
    helpView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    helpView.backgroundColor = [UIColor clearColor];
    helpView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+helpHeight);
    [self.view addSubview:helpView];
    
    UILabel *lblNo1 = [[UILabel alloc]init];
    lblNo1.frame =  CGRectMake(20,0, 35*approaxSize, 35*approaxSize);
    [lblNo1 setBackgroundColor:UIColor.clearColor];
    [lblNo1 setText:@"1)"];
    [lblNo1 setTextAlignment:NSTextAlignmentLeft];
    [lblNo1 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblNo1 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblNo1];
    
    UILabel * lblQ1 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, 6*approaxSize, DEVICE_WIDTH-45, 45)];
    [lblQ1 setBackgroundColor:[UIColor clearColor]];
    lblQ1.text = [NSString stringWithFormat:@"My Bluetooth is on but I can’t Access my Kuurv Tracker"];
    lblQ1.numberOfLines = 0;
    [lblQ1 setTextAlignment:NSTextAlignmentLeft];
    [lblQ1 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblQ1 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblQ1];
    
    long sol1Height = 75;
    if(IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_4)
    {
        sol1Height = 90;
    }
    else if (IS_IPHONE_X)
    {
        sol1Height = 95;
    }
    
    long hh = 40+(6);
    UILabel *lblSol1 = [[UILabel alloc]init];
    lblSol1.frame =  CGRectMake(40,hh,DEVICE_WIDTH-45,sol1Height);
    [lblSol1 setBackgroundColor:UIColor.clearColor];
    [lblSol1 setText:@"Sometimes you may need to exit out of the app itself and then go back into in app to access your Kuurv tracker successfully."];
    [lblSol1 setTextAlignment:NSTextAlignmentLeft];
    lblSol1.numberOfLines = 0;
    [lblSol1 setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblSol1 setTextColor:[UIColor grayColor]];
    [helpView addSubview:lblSol1];
    
    hh = hh+sol1Height+(5);
   
    UILabel *lblNo2 = [[UILabel alloc]init];
    lblNo2.frame =  CGRectMake(20,hh, 35*approaxSize, 35*approaxSize);
    [lblNo2 setBackgroundColor:UIColor.clearColor];
    [lblNo2 setText:@"2)"];
    [lblNo2 setTextAlignment:NSTextAlignmentLeft];
    [lblNo2 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblNo2 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblNo2];
    
    UILabel * lblQ2 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+(6*approaxSize), DEVICE_WIDTH-45, 45)];
    [lblQ2 setBackgroundColor:[UIColor clearColor]];
    lblQ2.text = [NSString stringWithFormat:@"How to Place Your Kuurv Tracker on a Device"];
    lblQ2.numberOfLines = 0;
    [lblQ2 setTextAlignment:NSTextAlignmentLeft];
    [lblQ2 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblQ2 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblQ2];
    
    long sol2Height = 290;
    if(IS_IPHONE_5 || IS_IPHONE_4)
    {
        sol2Height = 360;
    }
    else if (IS_IPHONE_X)
    {
        sol2Height = 310;
    }
    
    hh = hh+40+(8);
    UILabel *lblSol2 = [[UILabel alloc]init];
    lblSol2.frame =  CGRectMake(40,hh,DEVICE_WIDTH-45, sol2Height);
    [lblSol2 setBackgroundColor:UIColor.clearColor];
    [lblSol2 setText:@"a. Make sure surface of device being placed on is clean and dry (you may clean with rubbing alcohol, if needed)\n\nb. Gently peel off the blue adhesive peel off of the bottom of the tracker\n\nc. Gently place the tracker on your device (Make sure it is on the spot you want, and also be aware that the tracker is not obstructing any charging outlets)\n\nd. Now press down firmly and on the top of the tracker and all sides of it (Do it for 30 seconds)"];
    [lblSol2 setTextAlignment:NSTextAlignmentLeft];
    lblSol2.numberOfLines = 0;
    [lblSol2 setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblSol2 setTextColor:[UIColor grayColor]];
    [helpView addSubview:lblSol2];
    
    hh = hh+sol2Height+(5);
    
    UILabel *lblNo3 = [[UILabel alloc]init];
    lblNo3.frame =  CGRectMake(20,hh, 35*approaxSize, 35*approaxSize);
    [lblNo3 setBackgroundColor:UIColor.clearColor];
    [lblNo3 setText:@"3)"];
    [lblNo3 setTextAlignment:NSTextAlignmentLeft];
    [lblNo3 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblNo3 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblNo3];
    
    UILabel * lblQ3 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+(6*approaxSize), DEVICE_WIDTH-45, 45)];
    [lblQ3 setBackgroundColor:[UIColor clearColor]];
    lblQ3.text = [NSString stringWithFormat:@"How to Physically Remove the Tracker off of a Device"];
    lblQ3.numberOfLines = 0;
    [lblQ3 setTextAlignment:NSTextAlignmentLeft];
    [lblQ3 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblQ3 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblQ3];
    
    long sol3Height = 75;
    if(IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_4)
    {
        sol3Height = 90;
    }
    else if (IS_IPHONE_X)
    {
        sol3Height = 95;
    }
    hh = hh+40+(8);
    UILabel *lblSol3 = [[UILabel alloc]init];
    lblSol3.frame =  CGRectMake(40,hh,DEVICE_WIDTH-45, sol3Height);
    [lblSol3 setBackgroundColor:UIColor.clearColor];
    [lblSol3 setText:@"You may use rubbing alcohol and a dull butter knife to gently pry the tracker off of any device. Please be cautious when doing this."];
    [lblSol3 setTextAlignment:NSTextAlignmentLeft];
    lblSol3.numberOfLines = 0;
    [lblSol3 setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblSol3 setTextColor:[UIColor grayColor]];
    [helpView addSubview:lblSol3];
    
    hh = hh+sol3Height+(5);
    
    UILabel *lblNo4 = [[UILabel alloc]init];
    lblNo4.frame =  CGRectMake(20,hh, 35*approaxSize, 35*approaxSize);
    [lblNo4 setBackgroundColor:UIColor.clearColor];
    [lblNo4 setText:@"4)"];
    [lblNo4 setTextAlignment:NSTextAlignmentLeft];
    [lblNo4 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblNo4 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblNo4];
    
    UILabel * lblQ4 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+(6*approaxSize), DEVICE_WIDTH-45, 25)];
    [lblQ4 setBackgroundColor:[UIColor clearColor]];
    lblQ4.text = [NSString stringWithFormat:@"How to delete your tracker"];
    lblQ4.numberOfLines = 0;
    [lblQ4 setTextAlignment:NSTextAlignmentLeft];
    [lblQ4 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblQ4 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblQ4];
    
    long sol4Height = 210;
    if(IS_IPHONE_5 || IS_IPHONE_4 )
    {
        sol4Height = 240;
    }
    else if (IS_IPHONE_6)
    {
        sol4Height = 220;
    }
    else if (IS_IPHONE_X)
    {
        sol4Height = 225;
    }
    hh = hh+20;
    UILabel *lblSol4 = [[UILabel alloc]init];
    lblSol4.frame =  CGRectMake(40,hh,DEVICE_WIDTH-45, sol4Height);
    [lblSol4 setBackgroundColor:UIColor.clearColor];
    [lblSol4 setText:@"a. Select the Kuurv tracker you wish you delete (if there are multiples on your account)\n\nb. Press the more options (3 dots icon) on the top right corner of the homepage\n\nc. Select Delete Tracker\n*Note Kuurv tracker must be connected in order to delete"];
    [lblSol4 setTextAlignment:NSTextAlignmentLeft];
    lblSol4.numberOfLines = 0;
    [lblSol4 setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblSol4 setTextColor:[UIColor grayColor]];
    [helpView addSubview:lblSol4];
    
    
    hh = hh+sol4Height+(5);
    
    UILabel *lblNo5 = [[UILabel alloc]init];
    lblNo5.frame =  CGRectMake(20,hh, 35*approaxSize, 35*approaxSize);
    [lblNo5 setBackgroundColor:UIColor.clearColor];
    [lblNo5 setText:@"5)"];
    [lblNo5 setTextAlignment:NSTextAlignmentLeft];
    [lblNo5 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblNo5 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblNo5];
    
    UILabel * lblQ5 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+(6*approaxSize), DEVICE_WIDTH-45, 45)];
    [lblQ5 setBackgroundColor:[UIColor clearColor]];
    lblQ5.text = [NSString stringWithFormat:@"How to Re-Apply the Adhesive Tape to Your Tracker"];
    lblQ5.numberOfLines = 0;
    [lblQ5 setTextAlignment:NSTextAlignmentLeft];
    [lblQ5 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblQ5 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblQ5];
    
    long sol5Height = 475;
    if(IS_IPHONE_5 || IS_IPHONE_4)
    {
        sol5Height = 550;
    }
    else if (IS_IPHONE_6)
    {
        sol5Height = 500;
    }
    else if (IS_IPHONE_X)
    {
        sol5Height = 510;
    }
    hh = hh+40+(8);
    UILabel *lblSol5 = [[UILabel alloc]init];
    lblSol5.frame =  CGRectMake(40,hh,DEVICE_WIDTH-45, sol5Height);
    [lblSol5 setBackgroundColor:UIColor.clearColor];
    [lblSol5 setText:@"a. Use rubbing alcohol and a cloth to clean the adhesive residue off of the bottom of the tracker\n\nb. Make sure the bottom of the tracker is pretty clean and dry\n\nc. Use the pull tab on the blue adhesive to remove it from its original display\n\nd. Carefully place the adhesive on the bottom of the tracker fitting as best as possible\n\ne. Press down firmly on all sides of the adhesive to make sure the adhesive transfers over onto the bottom of the tracker when you are ready to remove it\n\nf. Firmly press down on the tape for 20-30 seconds\n\ng. When you are ready to place the tracker on an item, remove the blue strip and apply "];
    [lblSol5 setTextAlignment:NSTextAlignmentLeft];
    lblSol5.numberOfLines = 0;
    [lblSol5 setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblSol5 setTextColor:[UIColor grayColor]];
    [helpView addSubview:lblSol5];
    
    hh = hh+sol5Height+(5);
    
    UILabel *lblNo6 = [[UILabel alloc]init];
    lblNo6.frame =  CGRectMake(20,hh, 35*approaxSize, 35*approaxSize);
    [lblNo6 setBackgroundColor:UIColor.clearColor];
    [lblNo6 setText:@"6)"];
    [lblNo6 setTextAlignment:NSTextAlignmentLeft];
    [lblNo6 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblNo6 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblNo6];
    
    UILabel * lblQ6 = [[UILabel alloc] initWithFrame:CGRectMake(40*approaxSize, hh+(6*approaxSize), DEVICE_WIDTH-45, 25)];
    [lblQ6 setBackgroundColor:[UIColor clearColor]];
    lblQ6.text = [NSString stringWithFormat:@"More Help"];
    lblQ6.numberOfLines = 0;
    [lblQ6 setTextAlignment:NSTextAlignmentLeft];
    [lblQ6 setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblQ6 setTextColor:[UIColor blackColor]];
    [helpView addSubview:lblQ6];
    
    long sol6Height = 75;
    if(IS_IPHONE_5 || IS_IPHONE_4 )
    {
        sol6Height = 90;
    }
    hh = hh+20+(6);
    UILabel *lblSol6 = [[UILabel alloc]init];
    lblSol6.frame =  CGRectMake(40,hh,DEVICE_WIDTH-45, sol6Height);
    [lblSol6 setBackgroundColor:UIColor.clearColor];
    [lblSol6 setText:@"Please reach out to connect@kuurvtracker.com and we will respond within 24 hours or sooner!"];
    [lblSol6 setTextAlignment:NSTextAlignmentLeft];
    lblSol6.numberOfLines = 0;
    [lblSol6 setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
    [lblSol6 setTextColor:[UIColor grayColor]];
    [helpView addSubview:lblSol6];
    
    
//    CGFloat boldTextFontSize = txtSize-2;
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:lblSol6.text];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(19,25)];
    [lblSol6 setAttributedText:string];
    
    UIButton * btnEmail = [[UIButton alloc]init];
    [btnEmail addTarget:self action:@selector(launchMailAppOnDevice) forControlEvents:UIControlEventTouchUpInside];
    btnEmail.frame = CGRectMake(40,hh+15,DEVICE_WIDTH-45, sol6Height-15);
    btnEmail.backgroundColor = UIColor.clearColor;
    [helpView addSubview:btnEmail];
}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//- (void)tapAction:(UITapGestureRecognizer *)sender
//{
//    NSLog(@"touched");
//
//}
//-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
//{
//    [scrollView.pinchGestureRecognizer setEnabled:false];
//    [scrollView.panGestureRecognizer setEnabled:false];
//    [scrollView.directionalPressGestureRecognizer setEnabled:false];
//    [scrollView setBouncesZoom:false];
//}
//-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return nil;
//}
//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
//
//    [webView evaluateJavaScript:javascript completionHandler:nil];
//}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // for mail to
}
// WKWebViewNavigationDelegate
//func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//    guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("http") else {
//        // This is not HTTP link - can be a local file or a mailto
//        decisionHandler(.cancel)
//        return
//    }
//    // This is a HTTP link
//    open(url: url)
//    decisionHandler(.allow)
//}
//-(void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    [scrollView.pinchGestureRecognizer setEnabled:false];
//}
-(void)launchMailAppOnDevice
{
//    NSString * strName = [APP_DELEGATE checkforValidString:[dictOwner valueForKey:@"name"]];
//    if ([strName isEqualToString:@"NA"])
//    {
//        strName = @"Hello";
//    }
//    else
//    {
//        strName = [NSString stringWithFormat:@"Hello %@", strName];
//    }
    NSString *recipients = [APP_DELEGATE checkforValidString:@"connect@kuurvtracker.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Help"];
//    [mc setMessageBody:strMsg isHTML:NO];
    [mc setToRecipients:@[recipients]];
    
    if (mc == nil)
    {
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:@"KUURV"
                  withSubtitle:@"Please set up a Mail account in order to send email."
               withCustomImage:[UIImage imageNamed:@"logo.png"]
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else
    {
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
#pragma mark - All Button Click Events
-(void)btnMenuClicked:(id)sender
{
    [self.menuContainerViewController setMenuSlideAnimationFactor:0.5f];
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
-(void)btnOkClicked
{
    [backShadowView removeFromSuperview];
    [backShadowView removeFromSuperview];

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

@end
