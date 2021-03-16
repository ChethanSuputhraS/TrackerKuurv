//
//  LostDeviceCell.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 29/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "LostDeviceCell.h"

@implementation LostDeviceCell
@synthesize lblResult,lblName,lblBack;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {    // Initialization code
        
        lblBack = [[UILabel alloc]initWithFrame:CGRectMake(5,2,(DEVICE_WIDTH-10),46)];
        lblBack.backgroundColor = UIColor.whiteColor;
        [lblBack setTextColor:[UIColor blackColor]];
        lblBack.layer.masksToBounds = true;
        lblBack.layer.borderWidth = 1;
        lblBack.layer.borderColor = UIColor.blackColor.CGColor;
        [self.contentView addSubview:lblBack];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(10,2,(DEVICE_WIDTH/2)+20,46)];
        lblName.backgroundColor = UIColor.clearColor;
        [lblName setText:@"Sri"];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblName setTextColor:[UIColor blackColor]];
        lblName.layer.masksToBounds = true;
        lblName.numberOfLines = 0;
        [self.contentView addSubview:lblName];
        
        lblResult = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-100,2,90,46)];
        lblResult.backgroundColor = UIColor.clearColor;
        [lblResult setText:@"Sri"];
        [lblResult setTextAlignment:NSTextAlignmentRight];
        [lblResult setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblResult setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:lblResult];

    }
    return self;
}
@end
