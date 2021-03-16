//
//  CustomAnnotationView.h
//  HomeTribe
//
//  Created by Oneclick IT on 8/23/16.
//  Copyright © 2016 Oneclick IT. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AsyncImageView.h"
#import "AppDelegate.h"
@protocol SampleProtocolDelegate <NSObject>
@required
-(void)buttonHandlerCallOut:(UIButton*)sender;
@end


@interface CustomAnnotationView : MKAnnotationView
{
    UIView * viewCallout;
    AsyncImageView * imgHome;
    UILabel * lblName;
    UILabel * lblPrice;
    UILabel * lblAddress;
    UIButton  * btnTap;
    CAKeyframeAnimation *animation;
    UIView * viewBGPopUp;
    UIImageView * imgArrow;
}
@property (strong, nonatomic) UIButton *buttonCustomeCallOut;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSMutableDictionary * Dic;

@property (strong, nonatomic) NSString * subtitle1;
@property (strong, nonatomic) NSString * subtitle2;
@property (strong, nonatomic) NSString * img;
@property (strong,nonatomic) UIButton *btn;
@property (strong, nonatomic) UIImage  * deviceImg;

@property (nonatomic) NSUInteger index;
@property (nonatomic,strong) id delegate;
@property (nonatomic,strong)NSString * isfromAdd;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
-(void)setAddress:(NSString *)strAddress;

@end
