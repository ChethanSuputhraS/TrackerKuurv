//
//  AddDeviceCell.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 14/05/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AddDeviceCell.h"

@implementation AddDeviceCell

@synthesize lblDeviceName,lblConnect,lblBack;
@synthesize imgIcon,lblAddress;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(3, 0,DEVICE_WIDTH-6,60)];
        lblBack.backgroundColor = [UIColor whiteColor];
        lblBack.alpha = 0.3;
        lblBack.layer.cornerRadius = 5;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
        lblBack.layer.borderWidth = 0.6;
        [self.contentView addSubview:lblBack];
        
        lblBack.layer.shadowRadius  = 4.5f;
        lblBack.layer.shadowColor   = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
        lblBack.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
        lblBack.layer.shadowOpacity = 0.5f;
        lblBack.layer.masksToBounds = NO;
        
        UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -4.5f, 0);
        UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(lblBack.bounds, shadowInsets)];
        lblBack.layer.shadowPath    = shadowPath.CGPath;
        
        imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(3+3, 10, 40, 40)];
        [imgIcon setImage:[UIImage imageNamed:@"Appicon29.png"]];
//        imgIcon.contentMode = UIViewContentModeScaleAspectFit;
        imgIcon.layer.masksToBounds = YES;
        imgIcon.layer.cornerRadius = 20;
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(55, 3, DEVICE_WIDTH-90, 30)];
        lblDeviceName.numberOfLines = 2;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        [lblDeviceName setTextColor:global_greenColor];
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:txtSize]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"Smart Bulb";
        
        lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(55, 25+7, DEVICE_WIDTH-90, 20)];
        lblAddress.numberOfLines = 2;
        [lblAddress setBackgroundColor:[UIColor clearColor]];
        [lblAddress setTextColor:[UIColor grayColor]];
        [lblAddress setFont:[UIFont fontWithName:CGRegular size:txtSize-3]];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
        lblAddress.text = @"FVFVFE233434";
        lblAddress.hidden =YES;
        
        lblConnect = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-70, 0, 70, 60)];
        lblConnect.numberOfLines = 2;
        [lblConnect setBackgroundColor:[UIColor clearColor]];
        [lblConnect setTextColor:[UIColor whiteColor]];
        [lblConnect setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblConnect setTextAlignment:NSTextAlignmentLeft];
        lblConnect.text = @"Add";
        
        [self.contentView addSubview:imgIcon];
        [self.contentView addSubview:lblDeviceName];
        [self.contentView addSubview:lblAddress];
        [self.contentView addSubview:lblConnect];
    }
    return self;
}
@end
