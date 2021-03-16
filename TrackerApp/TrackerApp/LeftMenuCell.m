//
//  LeftMenuCell.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 17/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell
@synthesize lblName,imgIcon;
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
        
        imgIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12.5, 25, 25)];
        imgIcon.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgIcon];
        
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, DEVICE_WIDTH-10, 30)];
        [lblName setBackgroundColor:[UIColor clearColor]];
        lblName.textColor = UIColor.blackColor;
        [lblName setFont:[UIFont fontWithName:CGRegular size:txtSize]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        lblName.text = @"Sri";
        [self.contentView addSubview:lblName];
    }
    return self;
}
@end
