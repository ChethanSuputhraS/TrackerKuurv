//
//  AnswerVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 06/08/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AnswerVC.h"

@interface AnswerVC ()

@end

@implementation AnswerVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
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
    [lblTitle setText:@"Delete Tracker"];
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
    yy = yy+10;
    UILabel * lblStep1 = [[UILabel alloc]init];
    lblStep1 = [[UILabel alloc]initWithFrame:CGRectMake(10,yy,100,30)];
    lblStep1.backgroundColor = UIColor.clearColor;
    lblStep1.text = @"Instruction :";
    lblStep1.textColor = UIColor.blackColor;
    lblStep1.textAlignment = NSTextAlignmentLeft;
    lblStep1.font = [UIFont fontWithName:CGRegular size:txtSize];
    [self.view addSubview:lblStep1];
    
    UILabel * lblText1 = [[UILabel alloc]init];
    lblText1 = [[UILabel alloc]initWithFrame:CGRectMake(10,yy,DEVICE_WIDTH-20,150)];
    lblText1.backgroundColor = UIColor.clearColor;
    lblText1.text = @"Delete Tracker from the original account when it is connected,so that this tracker can be paired with another account.You cannot delete the tracker device when it is disconnected.";
    lblText1.textColor = global_greyColor;
    lblText1.textAlignment = NSTextAlignmentLeft;
    lblText1.numberOfLines = 0;
    lblText1.font = [UIFont fontWithName:CGRegular size:txtSize-3];
    [self.view addSubview:lblText1];
    
    yy = yy+150;
    UILabel * lblStep2 = [[UILabel alloc]init];
    lblStep2 = [[UILabel alloc]initWithFrame:CGRectMake(10,yy,DEVICE_WIDTH-10,30)];
    lblStep2.backgroundColor = UIColor.clearColor;
    lblStep2.text = @"How to delete :";
    lblStep2.textColor = UIColor.blackColor;
    lblStep2.textAlignment = NSTextAlignmentLeft;
    lblStep2.font = [UIFont fontWithName:CGRegular size:txtSize];
    [self.view addSubview:lblStep2];
    
    UILabel * lblText2 = [[UILabel alloc]init];
    lblText2 = [[UILabel alloc]initWithFrame:CGRectMake(10,yy+10,DEVICE_WIDTH-20,150)];
    lblText2.backgroundColor = UIColor.clearColor;
    lblText2.text = @"1)Select the tracker device need to be deleted \n2)Click on View more button on the right top corner \n3)Tap on delete tracker to delete you;re device.";
    lblText2.textColor = global_greyColor;
    lblText2.textAlignment = NSTextAlignmentLeft;
    lblText2.numberOfLines = 0;
    lblText2.font = [UIFont fontWithName:CGRegular size:txtSize-3];
    [self.view addSubview:lblText2];
}
#pragma mark - All Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
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
