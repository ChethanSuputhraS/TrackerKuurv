//
//  PhoneAlertCell.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 17/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "PhoneAlertCell.h"

@implementation PhoneAlertCell
@synthesize lblName,lblResult,imgArrow,swtchh,lblfooter,viewGroup,btnHigh,btnLow;
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
        
        viewGroup = [[UIView alloc]initWithFrame:CGRectMake(0,2,DEVICE_WIDTH,46)];
        viewGroup.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:viewGroup];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(10,0,(DEVICE_WIDTH/2)+20,viewGroup.frame.size.height)];
        lblName.backgroundColor = UIColor.clearColor;
        [lblName setText:@"Sri"];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblName setTextColor:[UIColor darkGrayColor]];
        lblName.layer.masksToBounds = true;
        lblName.numberOfLines = 0;
        [viewGroup addSubview:lblName];
        
        lblfooter = [[UILabel alloc]initWithFrame:CGRectMake(5,2,(DEVICE_WIDTH),20)];
        lblfooter.backgroundColor = UIColor.clearColor;
        [lblfooter setText:@"Sri"];
        [lblfooter setTextAlignment:NSTextAlignmentLeft];
        [lblfooter setFont:[UIFont fontWithName:CGRegular size:txtSize-4]];
        [lblfooter setTextColor:[UIColor darkGrayColor]];
        lblfooter.layer.masksToBounds = true;
        lblfooter.numberOfLines = 0;
        [self.contentView addSubview:lblfooter];
        
        lblResult = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-110,0,80,viewGroup.frame.size.height)];
        lblResult.backgroundColor = UIColor.clearColor;
        [lblResult setText:@"Sri"];
        [lblResult setTextAlignment:NSTextAlignmentRight];
        [lblResult setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblResult setTextColor:[UIColor blackColor]];
        lblResult.hidden = true;
        [viewGroup addSubview:lblResult];

        imgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-25,18, 7, 12)];
        imgArrow.image = [UIImage imageNamed:@"right_black_arrow.png"];
        imgArrow.backgroundColor = UIColor.clearColor;
        imgArrow.hidden = true;
        [viewGroup addSubview:imgArrow];
        
        swtchh = [[UISwitch alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70,8,50,30)];
        swtchh.hidden = true;
        swtchh.onTintColor = global_greenColor;
        [viewGroup addSubview:swtchh];
        
        btnHigh = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHigh.frame = CGRectMake(DEVICE_WIDTH-180, 0, 80, 46);
        btnHigh.hidden = true;
        [btnHigh setTitle:@" High" forState:UIControlStateNormal];
        [btnHigh setImage:[UIImage imageNamed:@"greenSelected.png"] forState:UIControlStateNormal];
        btnHigh.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnHigh setTitleColor:global_greenColor forState:UIControlStateNormal];
        [viewGroup addSubview:btnHigh];
        
        btnLow = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLow.frame = CGRectMake(DEVICE_WIDTH-80, 0, 80, 46);
        btnLow.hidden = true;
        [btnLow setTitle:@" Low" forState:UIControlStateNormal];
        [btnLow setImage:[UIImage imageNamed:@"radioUnselected.png"] forState:UIControlStateNormal];
        btnLow.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnLow setTitleColor:global_greyColor forState:UIControlStateNormal];
        [viewGroup addSubview:btnLow];

//        btnHigh.backgroundColor = [UIColor redColor];
//        btnLow.backgroundColor=[UIColor blueColor];
    }
    return  self;
}
@end
