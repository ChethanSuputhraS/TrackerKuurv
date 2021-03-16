//
//  NotificationVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 09/05/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * arrNotification;
    UITableView * tblContent;
    int yy;
    BOOL isLimitReached;
    NSMutableArray * testArr;
    UILabel * lblNotFound;
}
@end
