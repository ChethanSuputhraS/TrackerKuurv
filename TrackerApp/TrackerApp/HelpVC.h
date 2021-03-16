//
//  HelpVC.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 18/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HelpVC : UIViewController<MFMailComposeViewControllerDelegate,WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate>
{
    UITableView * tblContent;
    NSMutableArray * arrQuestions, * arrAnswers;
    UIScrollView * helpView;
}
@end
