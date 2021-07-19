//
//  AboutVC.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 19/01/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "AboutVC.h"
#import <MessageUI/MessageUI.h>

@interface AboutVC ()<MFMailComposeViewControllerDelegate>
{
    int txtSize;
}
@end

@implementation AboutVC

- (void)viewDidLoad
{
    txtSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        txtSize = 15;
    }
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrame];
   
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)setNavigationViewFrame
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"About"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGBold size:textSize+3]];
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
    
    UIButton * btnExportMail = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnExportMail addTarget:self action:@selector(btnExportClick) forControlEvents:UIControlEventTouchUpInside];
    btnExportMail.frame = CGRectMake(DEVICE_WIDTH-100, 20, 100, 44);
    btnExportMail.backgroundColor = [UIColor clearColor];
    [btnExportMail setTitle:@"Export" forState:UIControlStateNormal];
    [viewHeader addSubview:btnExportMail];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        btnExportMail.frame = CGRectMake(DEVICE_WIDTH-100, 40, 100, 44);

    }
    
    int yy = 64 + 20;
    
    UILabel * lblTop = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 60)];
    [lblTop setBackgroundColor:[UIColor clearColor]];
    [lblTop setText:@"Get in touch if you need help with our DepthNTemp App."];
    [lblTop setFont:[UIFont fontWithName:CGRegular size:txtSize+2]];
    [lblTop setTextColor:[UIColor whiteColor]];
    lblTop.numberOfLines = 0;
    [self.view addSubview:lblTop];
    
    yy = yy + 60 + 20;
    
    UILabel * lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 30)];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setText:@"Succorfish Ltd"];
    [lblName setFont:[UIFont fontWithName:CGBold size:txtSize+1]];
    [lblName setTextColor:[UIColor whiteColor]];
    lblName.numberOfLines = 0;
    [self.view addSubview:lblName];
    
    yy = yy + 20 ;
    
    UILabel * lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, yy, DEVICE_WIDTH-20, 120)];
    [lblAddress setBackgroundColor:[UIColor clearColor]];
    [lblAddress setText:@"1 Liddell Street (Head Office) \nNorth Shields Fish Quay \nTyne & Wear \nNE30 1HE \nUnited Kingdom"];
    [lblAddress setFont:[UIFont fontWithName:CGRegular size:txtSize-1]];
    [lblAddress setTextColor:[UIColor whiteColor]];
    lblAddress.numberOfLines = 0;
    [self.view addSubview:lblAddress];
    
    yy = yy + 120 + 20 ;
    
    UIImageView * imgMail = [[UIImageView alloc] init];
    imgMail.frame = CGRectMake(10, yy+3, 20, 15);
    imgMail.image = [UIImage imageNamed:@"email.png"];
    [self.view addSubview:imgMail];
    
    UILabel * lblMail = [[UILabel alloc] initWithFrame:CGRectMake(40, yy-6, DEVICE_WIDTH-20, 30)];
    [lblMail setBackgroundColor:[UIColor clearColor]];
    [lblMail setText:@"techteam@succorfish.com"];
    [lblMail setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblMail setTextColor:[UIColor redColor]];
    [self.view addSubview:lblMail];
    
    UIButton * btnMail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMail.frame = CGRectMake(0, yy-10, DEVICE_WIDTH-40, 30);
    [btnMail addTarget:self action:@selector(btnMailClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnMail];
    
    yy = yy + 25 + 10 ;
    
    UIImageView * imgCall = [[UIImageView alloc] init];
    imgCall.frame = CGRectMake(10, yy, 20, 20);
    imgCall.image = [UIImage imageNamed:@"contactus.png"];
    [self.view addSubview:imgCall];
    
    UILabel * lblCall = [[UILabel alloc] initWithFrame:CGRectMake(40, yy-5, DEVICE_WIDTH-20, 30)];
    [lblCall setBackgroundColor:[UIColor clearColor]];
    [lblCall setText:@"+44191 4776883"];
    [lblCall setFont:[UIFont fontWithName:CGRegular size:txtSize]];
    [lblCall setTextColor:[UIColor redColor]];
    [self.view addSubview:lblCall];
    
    UIButton * btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCall.frame = CGRectMake(0, yy, DEVICE_WIDTH-40, 30);
    [btnCall addTarget:self action:@selector(btnCallClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCall];
    
}
#pragma mark - Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnCallClick
{
    
    NSString *number = [NSString stringWithFormat:@"+441914476883"];
    NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@",number]];
    
    //check  Call Function available only in iphone
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"This function is only available on the iPhone" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
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
}
-(void)btnMailClick
{
    // Email Subject
    NSString *emailTitle = @"  ";
    // Email Content
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"techteam@succorfish.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:@"" isHTML:NO];
    [mc setToRecipients:toRecipents];
    
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
-(void)btnExportClick
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
