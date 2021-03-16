//
//  WelcomeVC.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 11/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "WelcomeVC.h"
#import "LoginVC.h"
#import "LoginVC.h"
@interface WelcomeVC ()

@end

@implementation WelcomeVC

- (void)viewDidLoad
{
//    self.view.backgroundColor = UIColor.whiteColor;
    
    UIImageView * gradienrtImg = [[UIImageView alloc]init];
    gradienrtImg.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    gradienrtImg.image = [UIImage imageNamed:@"gradiantImg"];
    [self.view addSubview: gradienrtImg];
    
    
    
    [self.navigationController setNavigationBarHidden:true];
    
    [self setPageControll];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)setPageControll
{
    [scrlContent removeFromSuperview];
    scrlContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [scrlContent setContentSize:CGSizeMake(scrlContent.frame.size.width*5, DEVICE_HEIGHT-70)];
    
    [scrlContent setBackgroundColor:[UIColor clearColor]];
    scrlContent.pagingEnabled = YES;
    //    scrlContent.bounces = NO;
    scrlContent.delegate = self;
    scrlContent.showsHorizontalScrollIndicator = NO;
    scrlContent.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrlContent];
    
    
    
    
    
    
    if (IS_IPHONE_X)
    {
        scrlContent.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-45);
        [scrlContent setContentSize:CGSizeMake(scrlContent.frame.size.width*5, DEVICE_HEIGHT-40-70)];
    }
    NSArray * imgArr= [NSArray arrayWithObjects:@"screenshot_1.png",@"screenshot_2.png",@"screenshot_3.png",@"screenshot_4.png",@"screenshot_5.png", nil];
    for (int i=0; i<5; i++)
    {
        UILabel * lblBack  = [[UILabel alloc] init];
        [scrlContent addSubview:lblBack];
        UIImageView * imgView = [[UIImageView alloc]init];
         if (IS_IPHONE_4)
        {
            lblBack.frame = CGRectMake(25+(DEVICE_WIDTH*i), 0, 270, 480);
            imgView.frame = CGRectMake(0, 0, 270, 480);
        }
        else if (IS_IPHONE_5 || IS_IPHONE_6 || IS_IPHONE_6plus)
        {
            lblBack.frame = CGRectMake(i*DEVICE_WIDTH, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
            imgView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        }
        else if (DEVICE_WIDTH > 400)
        {
            lblBack.frame = CGRectMake(i*DEVICE_WIDTH, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
            imgView.frame = CGRectMake(((lblBack.frame.size.width -414)/2), ((lblBack.frame.size.height -736)/2), 414, 736);
        }
        else if (IS_IPHONE_X)
        {
            lblBack.frame = CGRectMake(i*DEVICE_WIDTH, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
            imgView.frame = CGRectMake(((lblBack.frame.size.width -384)/2), ((lblBack.frame.size.height -736)/2), 384, 736);
        }
        NSString * imgName = [NSString stringWithFormat:@"%@",[imgArr objectAtIndex:i]];
        [imgView setImage:[UIImage imageNamed:imgName]];
        imgView.backgroundColor = [UIColor clearColor];
        [lblBack addSubview:imgView];
    }
 
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-100)/2, DEVICE_HEIGHT-25, 100, 20)];
    pageControl.numberOfPages = 5;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
    skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    skipBtn.frame = CGRectMake(DEVICE_WIDTH-90, DEVICE_HEIGHT-40, 100, 40);
    [skipBtn setTitle:@"Skip" forState:UIControlStateNormal];
    [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipBtn];
    
    if (IS_IPHONE_X)
    {
        pageControl.frame = CGRectMake((DEVICE_WIDTH-100)/2, DEVICE_HEIGHT-60-10 , 100, 20);
        skipBtn.frame = CGRectMake(DEVICE_WIDTH-90, DEVICE_HEIGHT-60-20, 100, 40);
    }
}
-(void) pageTurn: page
{
    [scrlContent scrollRectToVisible:CGRectMake(scrlContent.frame.size.width * (pageControl.currentPage), 0, scrlContent.frame.size.width, scrlContent.frame.size.height) animated:true];
}
-(void) setIndicatorCurrentPage
{
    int page = (scrlContent.contentOffset.x)/scrlContent.frame.size.width;
    pageControl.currentPage = page;
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setIndicatorCurrentPage];
}
-(void)skipBtnClick
{
    LoginVC *view1 = [[LoginVC alloc]init];
    view1.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:view1 animated:YES completion:nil];

    
//    LoginVC *view1 = [[LoginVC alloc]init];
//    [self.navigationController pushViewController:view1 animated:true];
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

