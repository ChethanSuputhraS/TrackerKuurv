//
//  AccountsVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 19/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AccountsVC.h"
#import "ChangePasswordVC.h"
#import "CustomDeviceVC.h"

@interface AccountsVC ()

@end

@implementation AccountsVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    arrTableView = [[NSMutableArray alloc]initWithObjects:@"Change Password",@"Account Info", nil];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFromSocialLogin"] == true)
    {
        [arrTableView removeObject:@"Change Password"];
    }
    
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
    [lblTitle setText:@"Account Settings"];
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
    return arrTableView.count;
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
    cell.lblName.text = [arrTableView objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFromSocialLogin"] == true)
    {
        if (indexPath.row ==0)
        {
            CustomDeviceVC *view1 = [[CustomDeviceVC alloc]init];
            view1.isfromSettings = YES;
            [self.navigationController pushViewController:view1 animated:true];
        }
        else if (indexPath.row ==1)
        {
            
            
        }
    }
    else
    {
        if (indexPath.row ==0)
        {
            ChangePasswordVC*view1 = [[ChangePasswordVC alloc]init];
            [self.navigationController pushViewController:view1 animated:true];
        }
        else if (indexPath.row ==1)
        {
            CustomDeviceVC *view1 = [[CustomDeviceVC alloc]init];
            view1.isfromSettings = YES;
            [self.navigationController pushViewController:view1 animated:true];
        }
        else if (indexPath.row ==2)
        {
            
            
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
