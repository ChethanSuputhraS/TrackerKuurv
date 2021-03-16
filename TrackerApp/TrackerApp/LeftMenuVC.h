//
//  LeftMenuVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 12/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * tblLeftMenu;
    NSMutableArray *arrOptions;
}
@end
