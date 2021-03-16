//
//  ViewMoreCell.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 17/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "ViewMoreCell.h"

@implementation ViewMoreCell
@synthesize lblName,swtchh,lblback,lblMoreDevices,imgDevice,imgPlay,imgRadio,btnPlay,lblTitle,btnRadio;
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
        
        lblback = [[UILabel alloc]initWithFrame:CGRectMake(0,2.5,DEVICE_WIDTH-60,50)];
        lblback.layer.masksToBounds = true;
        [self.contentView addSubview:lblback];
        
        lblback.alpha = 0.8;
        lblback.backgroundColor = global_greyColor;
        lblback.layer.masksToBounds = YES;
        lblback.layer.borderColor = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
        lblback.textColor = UIColor.whiteColor;
        [self.contentView addSubview:lblback];
        
        lblback.layer.shadowRadius  = 4.5f;
        lblback.layer.shadowColor   = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
        lblback.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
        lblback.layer.shadowOpacity = 0.2f;
        lblback.layer.masksToBounds = true;
        lblback.layer.cornerRadius = 10;

        imgDevice = [[AsyncImageView alloc]initWithFrame:CGRectMake(5,7.5, 40, 40)];
        imgDevice.layer.masksToBounds = true;
        imgDevice.layer.cornerRadius = 20;
        imgDevice.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:imgDevice];
        
        lblMoreDevices = [[UILabel alloc] initWithFrame:CGRectMake(60,5,DEVICE_WIDTH-130,40)];
        [lblMoreDevices setBackgroundColor:[UIColor clearColor]];
        [lblMoreDevices setText:@"Test 2"];
        [lblMoreDevices setTextAlignment:NSTextAlignmentLeft];
        [lblMoreDevices setFont:[UIFont fontWithName:CGRegular size:txtSize]];
        [lblMoreDevices setTextColor:UIColor.whiteColor];
        [self.contentView addSubview:lblMoreDevices];


        lblName = [[UILabel alloc]initWithFrame:CGRectMake(5,3,DEVICE_WIDTH-10,44)];
        lblName.backgroundColor = UIColor.whiteColor;
        [lblName setText:@"Sri"];
        [lblName setTextAlignment:NSTextAlignmentCenter];
        lblName.layer.masksToBounds = true;
//        lblName.layer.borderWidth = 0.6;
//        lblName.layer.borderColor = global_greyColor.CGColor;
        [lblName setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblName setTextColor:UIColor.blackColor];
        [self.contentView addSubview:lblName];

//        lblName.alpha = 0.3;
//        lblName.layer.cornerRadius = 5;
//        lblName.layer.masksToBounds = YES;
//        lblName.layer.borderColor = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
//        lblName.layer.borderWidth = 0.6;
//        lblName.textColor = UIColor.blackColor;
//        [self.contentView addSubview:lblName];
        
        lblName.layer.shadowRadius  = 4.5f;
        lblName.layer.shadowColor   = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1.0].CGColor;
        lblName.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
        lblName.layer.shadowOpacity = 0.2f;
        lblName.layer.masksToBounds = NO;
        
        UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -4.5f, 0);
        UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(lblName.bounds, shadowInsets)];
        lblName.layer.shadowPath    = shadowPath.CGPath;
    
        
        swtchh = [[UISwitch alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-60,10,50,30)];
        swtchh.hidden = true;
        swtchh.onTintColor = global_greenColor;
        [self.contentView addSubview:swtchh];
        
        swtchh = [[UISwitch alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-60,10,50,30)];
        swtchh.hidden = true;
        swtchh.onTintColor = global_greenColor;
        [self.contentView addSubview:swtchh];
        
        imgPlay = [[UIImageView alloc]initWithFrame:CGRectMake(15,10, 30, 30)];
//        imgPlay.layer.masksToBounds = true;
        imgPlay.hidden = true;
        imgPlay.image = [UIImage imageNamed:@"play.png"];
        imgPlay.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgPlay];
        
        
        lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(60,3,100,44)];
        lblTitle.backgroundColor = UIColor.clearColor;
        [lblTitle setText:@"Sri"];
        [lblTitle setTextAlignment:NSTextAlignmentLeft];
        lblTitle.hidden = true;
        [lblTitle setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblTitle setTextColor:UIColor.blackColor];
        [self.contentView addSubview:lblTitle];
        
        btnPlay = [[UIButton alloc]initWithFrame:CGRectMake(0,3, 160, 44)];
        btnPlay.backgroundColor = UIColor.clearColor;
        btnPlay.hidden = true; 
        [self.contentView addSubview:btnPlay];
        
        imgRadio = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-40),15, 20, 20)];
//        imgRadio.layer.masksToBounds = true;
        imgRadio.hidden = true;
        imgRadio.image = [UIImage imageNamed:@"radioUnselected.png"];
        imgRadio.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgRadio];

        btnRadio = [[UIButton alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-90),3, 90, 44)];
        btnRadio.backgroundColor = UIColor.clearColor;
        btnRadio.hidden = true;
        [self.contentView addSubview:btnRadio];
    }
    return self;
}
@end
