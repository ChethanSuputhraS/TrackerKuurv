//
//  NotificationCell.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 05/08/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell
@synthesize lblDate,lblNotification,lblBack,imgArrow;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {    // Initialization code
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, DEVICE_WIDTH-10, 55)];
        [lblBack setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:lblBack];
        
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, lblBack.frame.size.width-10, 15)];
        [lblDate setBackgroundColor:[UIColor clearColor]];
        lblDate.textColor = UIColor.blackColor;
        [lblDate setFont:[UIFont fontWithName:CGRegular size:txtSize-4]];
        [lblDate setTextAlignment:NSTextAlignmentLeft];
        lblDate.text = @"12-12-2012";
        [lblBack addSubview:lblDate];
        
        lblNotification = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, lblBack.frame.size.width-30, 40)];
        [lblNotification setBackgroundColor:[UIColor clearColor]];
        lblNotification.textColor = global_greyColor;
        [lblNotification setFont:[UIFont fontWithName:CGRegular size:txtSize-6]];
        [lblNotification setTextAlignment:NSTextAlignmentLeft];
        lblNotification.text = @"Hello ,this is a testing notification";
        lblNotification.numberOfLines = 0;
        [lblBack addSubview:lblNotification];
        
        imgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-25,26, 7, 12)];
        imgArrow.image = [UIImage imageNamed:@"right_black_arrow.png"];
        imgArrow.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgArrow];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
