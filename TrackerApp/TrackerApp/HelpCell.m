//
//  HelpCell.m
//  TrackerApp
//
//  Created by srivatsa s pobbathi on 18/04/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "HelpCell.h"

@implementation HelpCell
@synthesize lblName,imgArrow,lblLine;
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
        
//        lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(5,0,(DEVICE_WIDTH)-10,30)];
//        lblHeader.backgroundColor = UIColor.clearColor;
//        [lblHeader setText:@"How to delete a Tracker"];
//        [lblHeader setTextAlignment:NSTextAlignmentLeft];
//        [lblHeader setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
//        [lblHeader setTextColor:[UIColor blackColor]];
//        lblHeader.numberOfLines = 0;
//        lblHeader.hidden = true;
//        [self.contentView addSubview:lblHeader];
    
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(10,0,(DEVICE_WIDTH)-40,50)];
        lblName.backgroundColor = UIColor.clearColor;
        [lblName setText:@"Sri"];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setFont:[UIFont fontWithName:CGRegular size:txtSize-2]];
        [lblName setTextColor:[UIColor blackColor]];
        lblName.numberOfLines = 0;
        [self.contentView addSubview:lblName];
        
        
        lblLine = [[UILabel alloc]initWithFrame:CGRectMake(0,49,(DEVICE_WIDTH),0.5)];
        lblLine.backgroundColor = global_greyColor;
        lblLine.layer.masksToBounds = true;
        lblLine.numberOfLines = 0;
        [self.contentView addSubview:lblLine];
        
        imgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-25,20, 7, 12)];
        imgArrow.image = [UIImage imageNamed:@"right_black_arrow.png"];
        imgArrow.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:imgArrow];
        
    }
    return self;
}
@end
