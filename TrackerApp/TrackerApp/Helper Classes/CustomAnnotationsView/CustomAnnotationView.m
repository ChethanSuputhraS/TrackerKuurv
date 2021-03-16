//
//  CustomAnnotationView.m
//  HomeTribe
//
//  Created by Oneclick IT on 8/23/16.
//  Copyright © 2016 Oneclick IT. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "Constant.h"


@implementation CustomAnnotationView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        [viewCallout removeFromSuperview];
        viewCallout= [[UIView alloc]init];
        [viewCallout setBackgroundColor:[UIColor clearColor]];
        [viewCallout setFrame:CGRectMake(0,0, DEVICE_WIDTH-40, 65)];
        [self addSubview:viewCallout];
        viewCallout.userInteractionEnabled=YES;
        
        [viewBGPopUp removeFromSuperview];
         viewBGPopUp= [[UIView alloc]init];
        [viewBGPopUp setBackgroundColor:[UIColor whiteColor]];
        [viewBGPopUp setFrame:CGRectMake(0,0, DEVICE_WIDTH-40, 55)];
        viewBGPopUp.layer.cornerRadius = 3;
        viewBGPopUp.layer.shadowColor = [UIColor blackColor].CGColor;
        viewBGPopUp.layer.shadowOpacity = 0.6;
        viewBGPopUp.layer.shadowRadius = 10;
        [viewCallout addSubview:viewBGPopUp];
        
         imgArrow= [[UIImageView alloc]init];
        [imgArrow setFrame:CGRectMake(viewBGPopUp.center.x,60, 25, 25)];
        [imgArrow setImage:[UIImage imageNamed:@"down_arrow.png"]];
        [viewCallout addSubview:imgArrow];
        
        imgHome= [[AsyncImageView alloc]init];
        [imgHome setFrame:CGRectMake(5,5, 46, 46)];
        [imgHome setImage:[UIImage imageNamed:@"logoDisplay"]];
        [viewCallout addSubview:imgHome];
        imgHome.layer.masksToBounds = true;
        imgHome.layer.cornerRadius = 23;
        imgHome.layer.borderColor = global_greyColor.CGColor;
        imgHome.contentMode = UIViewContentModeScaleToFill;

        imgHome.layer.borderWidth = 1.6;
        
        if ([[APP_DELEGATE checkforValidString:_img]isEqualToString:@"NA"])
        {
            imgHome.image = _deviceImg;
        }
        else
        {
            imgHome.imageURL = [NSURL URLWithString:_img];

        }
        
        lblName= [[UILabel alloc]initWithFrame:CGRectMake(54, 5, viewBGPopUp.frame.size.width-54, 20)];
        lblName.font=[UIFont fontWithName:CGBold size:txtSize-1];
        lblName.textColor=global_greyColor;
        lblName.textAlignment = NSTextAlignmentLeft;
        [viewCallout addSubview:lblName];
        
        
        lblAddress= [[UILabel alloc]initWithFrame:CGRectMake(54, 25, viewBGPopUp.frame.size.width-54, 28)];
        lblAddress.font=[UIFont fontWithName:CGRegular size:txtSize-8];
        lblAddress.textColor=[UIColor darkGrayColor];
        lblAddress.numberOfLines = 0;
        lblAddress.textAlignment = NSTextAlignmentLeft;
        lblAddress.text = _subtitle1;
        [viewCallout addSubview:lblAddress];
        
        btnTap =[UIButton buttonWithType:UIButtonTypeCustom];
        btnTap.backgroundColor=[UIColor clearColor];
        btnTap.frame=CGRectMake(0, 0, viewCallout.frame.size.width, viewCallout.frame.size.height);
        [btnTap addTarget:self action:@selector(buttonHandlerCallOut:) forControlEvents:UIControlEventTouchUpInside];
        [viewCallout addSubview:btnTap];
        
       
//        imgHome.image =[UIImage imageNamed:_img];
//        imgHome.image = _deviceImg;

       // [lblAddress setText:[NSString stringWithFormat:@"%@",_subtitle2]];
        btnTap.tag=_index;
        
        id title = [NSString stringWithFormat:@"%@",_title];
        NSString * strtitle;
        if (title != [NSNull null])
        {
            strtitle = (NSString *)title;
            if ([strtitle isEqualToString:@""]||[strtitle isEqualToString:@"<null>"]||[strtitle isEqualToString:@"(null)"])
            {
                strtitle=@"";
            }
            else
            {
            }
        }
        else
        {
            strtitle=@"";
        }
         [lblName setText:[NSString stringWithFormat:@"%@",strtitle]];
        id catefory = [NSString stringWithFormat:@"%@",_subtitle1];
        NSString * strCategory;
        if (catefory != [NSNull null])
        {
            strCategory = (NSString *)catefory;
            if ([strCategory isEqualToString:@""]||[strCategory isEqualToString:@"<null>"]||[strCategory isEqualToString:@"(null)"])
            {
                strCategory=@"";
            }
            else
            {
            }
        }
        else
        {
            strCategory=@"";
        }
        [lblPrice setText:strCategory];
        
        if ([_isfromAdd isEqualToString:@"YES"])
        {
            NSLog(@"isaaa");
            lblPrice.frame=CGRectMake(10, 25, 240, 30);
            lblPrice.textAlignment = NSTextAlignmentCenter;
        }
                
        CGRect calloutViewFrame = viewCallout.frame;
        calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2, -calloutViewFrame.size.height);
        viewCallout.frame = calloutViewFrame;
        
        
        animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
        CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
        CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:scale1],
                                [NSValue valueWithCATransform3D:scale2],
                                [NSValue valueWithCATransform3D:scale3],
                                [NSValue valueWithCATransform3D:scale4],
                                nil];
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.5],
                               [NSNumber numberWithFloat:0.9],
                               [NSNumber numberWithFloat:1.0],
                               nil];
        [animation setKeyTimes:frameTimes];
        animation.fillMode = kCAFillModeRemoved;
        animation.removedOnCompletion = NO;
        animation.duration = .2;
        
        [self.layer addAnimation:animation forKey:@"popup"];
        
        
        [viewCallout setUserInteractionEnabled:YES];
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           //Remove your custom view...
                           [self->viewCallout setUserInteractionEnabled:NO];
                           [self->viewCallout removeFromSuperview];
                       });
        
        viewCallout=nil;
    }
}
-(void)setAddress:(NSString *)strAddress
{
    [lblAddress setText:strAddress];
}
-(void)SetUpview
{
    [lblName setText:_title];
    [lblPrice setText:_subtitle1];
    [lblAddress setText:_subtitle1];
//    imgHome.image =[UIImage imageNamed:_img];
    imgHome.image = _deviceImg;

    btnTap.tag=_index;
}
-(void)buttonHandlerCallOut:(UIButton*)sender{

    if (_delegate && [self.delegate respondsToSelector:@selector(buttonHandlerCallOut:)]) {
        [_delegate buttonHandlerCallOut:sender];
    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* v = [super hitTest:point withEvent:event];
    if (v != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return v;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rec = self.bounds;
    BOOL isIn = CGRectContainsPoint(rec, point);
    if(!isIn)
    {
        for (UIView *v in self.subviews)
        {
            isIn = CGRectContainsPoint(v.frame, point);
            if(isIn)
                break;
        }
    }
    return isIn;
}

@end
