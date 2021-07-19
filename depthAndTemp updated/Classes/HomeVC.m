//
//  HomeVC.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "HomeVC.h"
#import "ConfigureSensorVC.h"
#import "ViewDataVC.h"
#import "AppSettingsVC.h"
#import "GraphVC.h"
#import "AboutVC.h"
#import <MessageUI/MessageUI.h>

@interface HomeVC ()<MFMailComposeViewControllerDelegate>

@end

@implementation HomeVC

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.clearColor;

    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self setMainViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set View Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UIImageView * img = [[UIImageView alloc] init];
    img.frame = CGRectMake((DEVICE_WIDTH-200)/2,34, 200, 40);
    img.image = [UIImage imageNamed:@"logo.png"];
    img.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:img];
    
    UIView * topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 86*approaxSize, DEVICE_WIDTH-0, 70*approaxSize);
    topView.backgroundColor = [UIColor clearColor];
    topView.layer.cornerRadius = 10;
    topView.layer.masksToBounds = YES;
    [self.view addSubview:topView];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        img.frame = CGRectMake((DEVICE_WIDTH-200)/2,34+20, 200, 40);
    }
}
-(void)setMainViewFrames
{
    UILabel * lblAppName = [[UILabel alloc] init];
    lblAppName.frame = CGRectMake(((DEVICE_WIDTH/2)-150),64,300,50);
    lblAppName.text = @"Marine Sensing App";
    [lblAppName setFont:[UIFont fontWithName:CGBold size:textSize+2]];
    lblAppName.textColor = [UIColor whiteColor];
    lblAppName.backgroundColor = UIColor.clearColor;
    lblAppName.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblAppName];
    
    int xx = 15;
    int yy = 150;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/2);
    int vHeighth = (DEVICE_WIDTH/2);
    
    if (IS_IPHONE_4)
    {
        vHeighth = (DEVICE_WIDTH/2);
        yy = 120;
    }
    else if (IS_IPHONE_X)
    {
        yy = 250;
        lblAppName.frame = CGRectMake(((DEVICE_WIDTH/2)-150),88,300,50);
    }
    NSArray * nameArr = [NSArray arrayWithObjects:@"View Data",@"Connect & Configure Sensor",@"App Settings",@"About",nil];
    NSArray * imgArr = [NSArray arrayWithObjects:@"viewData.png",@"ConfigureSensor.png",@"settings.png",@"about.png", nil];
    
    for (int i=0; i<2; i++)
    {
        xx=0;
        for (int j=0; j<2; j++)
        {
            UILabel * lblTmp = [[UILabel alloc] init];
            lblTmp.frame = CGRectMake(xx+5, yy+5, vWidth-10, vHeighth);
            lblTmp.backgroundColor = [UIColor clearColor];
            lblTmp.userInteractionEnabled = YES;
            lblTmp.layer.masksToBounds = true;
            lblTmp.layer.borderWidth = 1;
            lblTmp.layer.borderColor = UIColor.whiteColor.CGColor;
            lblTmp.text = @" ";
            [self.view addSubview:lblTmp];
            
            UIImageView * img = [[UIImageView alloc] init];
            img.frame = CGRectMake((vWidth-60)/2,((vHeighth-60)/2)-20, 60, 60);
            img.image = [UIImage imageNamed:[imgArr objectAtIndex:cnt]];
            img.backgroundColor = [UIColor clearColor];
            img.contentMode = UIViewContentModeScaleAspectFit;
            [lblTmp addSubview:img];
            
            UILabel * lblName = [[UILabel alloc] init];
            lblName.frame = CGRectMake(0, img.frame.origin.y+60+20, vWidth, 30);
            lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:cnt]];
            [lblName setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
            lblName.textColor = [UIColor whiteColor];
            lblName.textAlignment = NSTextAlignmentCenter;
            [lblTmp addSubview:lblName];
           
            if (cnt==1)
            {
                lblName.frame = CGRectMake(0, img.frame.origin.y+60+10, vWidth, 50);
                lblName.numberOfLines = 0;
            }
            
            UIButton * btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
            btnTap.frame =CGRectMake(xx+10, yy+10, vWidth-20, vHeighth-20);
            [btnTap addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btnTap.tag = cnt;
            btnTap.backgroundColor = UIColor.clearColor;
            [self.view addSubview:btnTap];
            
            xx = vWidth + xx;
            cnt = cnt +1;
        }
        yy = yy + vHeighth + 10 ;
    }
}
#pragma mark - All Button Click Events
-(void)btnClick:(id)sender
{
    if ([sender tag] == 0)
    {
        ViewDataVC *view1 = [[ViewDataVC alloc]init];
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if ([sender tag] == 1)
    {
        ConfigureSensorVC*view1 = [[ConfigureSensorVC alloc]init];
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if ([sender tag] == 2)
    {
        AppSettingsVC*view1 = [[AppSettingsVC alloc]init];
        [self.navigationController pushViewController:view1 animated:true];
    }
    else if ([sender tag] == 3)
    {
        AboutVC*view1 = [[AboutVC alloc]init];
        [self.navigationController pushViewController:view1 animated:true];
    }
}


//to fetch database
-(void)toFetchDataBase
{
        NSString * strMsg =  @"file attached";
        // To address
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:strMsg];
        [mc setMessageBody:strMsg isHTML:NO];
        [mc setToRecipients:nil];

        if (mc == nil)
        {
            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please set up a Mail account in order to send email." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];

            [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                }];
            }];
            [alertView showWithAnimation:URBAlertAnimationTopToBottom];
            if (IS_IPHONE_X)
            {
                [alertView showWithAnimation:URBAlertAnimationDefault];
            }
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:@"depthNtemp.sqlite"];
            NSData *noteData = [NSData dataWithContentsOfFile:txtFilePath];
            [mc addAttachmentData:noteData mimeType:@"sqlite" fileName:@"kp"];
            [self.navigationController presentViewController:mc animated:YES completion:nil];
        }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
