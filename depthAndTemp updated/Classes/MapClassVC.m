//
//  MapClassVC.m
//  Succorfish Installer App
//
//  Created by stuart watts on 14/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "MapClassVC.h"
#define span1 5000

@interface MapClassVC ()

@end

@implementation MapClassVC
@synthesize detailsDict,isfromCompared, isfromSettings, strLatitude, strLongitude;
- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
//    [APP_DELEGATE hideTabBar:self.tabBarController];
    [super viewWillAppear:YES];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Location on Map"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:17]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        [self setMainViewContent:88];
    }
    else
    {
        [self setMainViewContent:64];
    }
}

-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(float)getLatLong:(NSString *)strval
{
    NSString * strHalf = [NSString stringWithFormat:@"%@.%@", [strval substringWithRange:NSMakeRange(2, 2)],[strval substringWithRange:NSMakeRange(4, 4)]];
    float afterDec = [strHalf floatValue]/60;
    float final = [[strval substringWithRange:NSMakeRange(0, 2)] floatValue] + afterDec;
    return final;
}
-(void)setMainViewContent:(int)yyHeight
{
    detailsMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, yyHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yyHeight)];
    [detailsMap setMapType:MKMapTypeStandard];
    detailsMap.delegate = self;
    detailsMap.showsUserLocation = YES;
    [self.view addSubview:detailsMap];
    
     if (IS_IPHONE_X)
     {
         detailsMap.frame = CGRectMake(0, yyHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yyHeight-45);
     }
    
    float vLat = 0, vLong = 0;
    if (isfromSettings)
    {
        if ([strLatitude isEqualToString:@"0"] && [strLongitude isEqualToString:@"0"])
        {
            [self showErrormessagewithtext:@"GPS positional data not found."];
        }
        else
        {
            vLat = [strLatitude floatValue];
            vLong = [strLongitude floatValue];
        }
    }
    else
    {
        NSMutableArray * tmpsArr = [[NSMutableArray alloc] init];
        NSString * str0 = [NSString stringWithFormat:@"select * from tbl_dive where dive_id = %@",[detailsDict valueForKey:@"dive1TableId"]];
        [[DataBaseManager dataBaseManager] execute:str0 resultsArray:tmpsArr];

        if ([tmpsArr count]>0)
        {
            strLatitude = [[tmpsArr objectAtIndex:0] valueForKey:@"gps_latitude"];
            strLongitude = [[tmpsArr objectAtIndex:0] valueForKey:@"gps_longitude"];

            if ([[APP_DELEGATE checkforValidString:strLatitude] isEqualToString:@"NA"] && [[APP_DELEGATE checkforValidString:strLongitude] isEqualToString:@"NA"])
            {
                [self showErrormessagewithtext:@"GPS positional data not found."];
            }
            else
            {
                vLat = [strLatitude floatValue];
                vLong = [strLongitude floatValue];
            }
            
        }
    }

        CLLocationCoordinate2D coordinate1;
        coordinate1.latitude = vLat;
        coordinate1.longitude =  vLong;

        CLLocationCoordinate2D location=CLLocationCoordinate2DMake(coordinate1.latitude, coordinate1.longitude);
        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(location,span1 ,span1);

     if (region.center.latitude > -89 && region.center.latitude < 89 && region.center.longitude > -179 && region.center.longitude < 179 )
    {
        MKCoordinateRegion adjustedRegion = [detailsMap regionThatFits:region];
        [detailsMap setRegion:adjustedRegion animated:YES];
        
        MKPlacemark *mPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate1 addressDictionary:nil];
        CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithPlacemark:mPlacemark];
        [detailsMap addAnnotation:annotation];
    }
    
    
    if (isfromCompared)
    {
        NSMutableArray * tmpsArr = [[NSMutableArray alloc] init];
        NSString * str0 = [NSString stringWithFormat:@"select * from tbl_dive where dive_id = %@",[detailsDict valueForKey:@"dive2TableId"]];
        [[DataBaseManager dataBaseManager] execute:str0 resultsArray:tmpsArr];
        
        float hLat =0, hLong = 0;
        
        if ([tmpsArr count]>0)
        {
            if (![[APP_DELEGATE checkforValidString:[[tmpsArr objectAtIndex:0] valueForKey:@"gps_latitude"]] isEqualToString:@"NA"])
            {
                if ([[[tmpsArr objectAtIndex:0] valueForKey:@"gps_latitude"] length]>=8)
                {
                    hLat = [[[tmpsArr objectAtIndex:0] valueForKey:@"gps_latitude"] floatValue];
                }
            }
            if (![[APP_DELEGATE checkforValidString:[[tmpsArr objectAtIndex:0] valueForKey:@"gps_longitude"]] isEqualToString:@"NA"])
            {
                if ([[[tmpsArr objectAtIndex:0] valueForKey:@"gps_longitude"] length]>=8)
                {
                    hLong = [[[tmpsArr objectAtIndex:0] valueForKey:@"gps_longitude"] floatValue];
                }
            }
        }
        CLLocationCoordinate2D coordinate1;
        coordinate1.latitude = hLat;
        coordinate1.longitude =  hLong;
        
        if( hLat > -89 && hLat < 89 && hLong > -179 && hLong < 179 )
        {
            MKPlacemark *mPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate1 addressDictionary:nil];
            CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithPlacemark:mPlacemark];
            annotation.title = @"Dive2";
            [detailsMap addAnnotation:annotation];

        }
    }
    
    
    /*for (int i=0; i<2; i++)
    {
        UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-80, DEVICE_HEIGHT-50+i*25, 20, 20)];
        [backImg setImage:[UIImage imageNamed:@"map_pin.png"]];
        [backImg setContentMode:UIViewContentModeScaleAspectFit];
        backImg.backgroundColor = [UIColor clearColor];
        [self.view addSubview:backImg];
        
        UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-50, DEVICE_HEIGHT-50+i*25, 90, 25)];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setText:@"Dive 1"];
        [lblTitle setFont:[UIFont fontWithName:CGBold size:textSize-5]];
        [lblTitle setTextColor:[UIColor redColor]];
        [self.view addSubview:lblTitle];
        if (i==1)
        {
            [backImg setImage:[UIImage imageNamed:@"map_pin2.png"]];
            [lblTitle setTextColor:[UIColor greenColor]];
            [lblTitle setText:@"Dive 2"];
        }
    }*/
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else if ([annotation isKindOfClass:[CustomAnnotation class]]) // use whatever annotation class you used when creating the annotation
    {
        static NSString * const identifier = @"CustomAnnotation";
        
        MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        }else        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage imageNamed:@"map_pin.png"];
        if ([annotation.title isEqualToString:@"Dive2"])
        {
            annotationView.image = [UIImage imageNamed:@"map_pin2.png"];
        }
        
        return annotationView;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showErrormessagewithtext:(NSString *)strMessage
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:strMessage cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
    if (IS_IPHONE_X)
    {
        [alertView showWithAnimation:URBAlertAnimationDefault];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
