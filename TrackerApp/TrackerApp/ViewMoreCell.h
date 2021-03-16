//
//  ViewMoreCell.h
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 17/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface ViewMoreCell : UITableViewCell
{
    
}
@property(nonatomic,strong)UILabel*lblName;
@property(nonatomic,strong)UISwitch*swtchh;
@property(nonatomic,strong)UILabel*lblback;
@property(nonatomic,strong)UILabel*lblMoreDevices;
@property(nonatomic,strong)AsyncImageView*imgDevice;
@property(nonatomic,strong)UIButton *btnPlay;
@property(nonatomic,strong)UIImageView * imgPlay;
@property(nonatomic,strong)UIImageView * imgRadio;
@property(nonatomic,strong)UILabel*lblTitle;
@property(nonatomic,strong)UIButton *btnRadio;


@end
