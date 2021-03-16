//
//  AboutUsVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 19/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView*tblContent;
    NSMutableArray*arrAboutUs;
}

@end
