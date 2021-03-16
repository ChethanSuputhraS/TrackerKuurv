//
//  AccountsVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 19/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpCell.h"
@interface AccountsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView*tblContent;
    NSMutableArray *arrTableView;
}
@end
