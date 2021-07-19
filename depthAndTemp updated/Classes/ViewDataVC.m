//
//  ViewDataVC.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 04/12/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "ViewDataVC.h"
#import "SelectionViewOptionsVC.h"
#import "GraphVC.h"

@interface ViewDataVC ()
{
    NSString * strChoosenBLEAddress;
    
}
@end

@implementation ViewDataVC
- (void)viewDidLoad
{
    isFromCompareButton = false;
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    tblDevice1 = tblDevice2 = tblDive1 = tblDive2 = @"NA";
    
    [self setNavigationViewFrames];
    [self setMainViewFrames];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"View Data"];
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
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
    }
}

-(void)setMainViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 88;
    }
    
    btnSingleData = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSingleData setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
    [btnSingleData setTitle:@"  Single Data Set" forState:UIControlStateNormal];
    [btnSingleData setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSingleData.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnSingleData.frame = CGRectMake(5,yy,180 *(approaxSize), 38);
    btnSingleData.tag = 1;
    [btnSingleData addTarget:self action:@selector(btnConditionalOp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSingleData];
    btnSingleData.backgroundColor = [UIColor clearColor];
    btnSingleData.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    yy = yy+38;
    btnCompare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCompare setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
    [btnCompare setTitle:@"  Compare" forState:UIControlStateNormal];
    [btnCompare setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCompare.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnCompare.frame = CGRectMake(5,yy,180 *(approaxSize), 38);
    btnCompare.tag = 2;
    [btnCompare addTarget:self action:@selector(btnConditionalOp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCompare];
    btnCompare.backgroundColor = [UIColor clearColor];
    btnCompare.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    if (IS_IPHONE_4)
    {
        yy = yy+40;
        
    }
    else
    {
        yy = yy+50;
        
    }
    
    lblSelectDevice = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,DEVICE_WIDTH/2, 44)];
    lblSelectDevice.textColor = UIColor.whiteColor;
    lblSelectDevice.backgroundColor = UIColor.clearColor;
    lblSelectDevice.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblSelectDevice.text = @"Select Device :";
    lblSelectDevice.hidden = false;
    [self.view addSubview:lblSelectDevice];
    
    if (IS_IPHONE_4)
    {
        lblSelectDevice.frame = CGRectMake(5, yy,DEVICE_WIDTH/2, 30);
        yy = yy+30;
    }
    else
    {
        yy = yy+35;
    }
    btnDeviceSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDeviceSelect setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnDeviceSelect.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnDeviceSelect.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 38);
    btnDeviceSelect.backgroundColor = [UIColor clearColor];
    btnDeviceSelect.hidden = false;
    btnDeviceSelect.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnDeviceSelect addTarget:self action:@selector(btnDeviceSelect1Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDeviceSelect];
    btnDeviceSelect.layer.borderWidth = 1;
    btnDeviceSelect.layer.borderColor = [UIColor whiteColor].CGColor;
    btnDeviceSelect.layer.cornerRadius = 5;
    
    
    UIImageView * imgArrow1 = [[UIImageView alloc]initWithFrame:CGRectMake(btnDeviceSelect.frame.size.width-15,(btnDeviceSelect.frame.size.height/2)-3, 12, 7)];
    imgArrow1.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow1.backgroundColor = UIColor.clearColor;
    [btnDeviceSelect addSubview:imgArrow1];
    
    deviceArray = [[NSMutableArray alloc] init];
    NSString *strTbl = [NSString stringWithFormat:@"Select * from tbl_ble_device"];
    [[DataBaseManager dataBaseManager] execute:strTbl resultsArray:deviceArray];
    
    if (deviceArray.count >0)
    {
        NSString * deviceName = [[NSString stringWithFormat:@"%@_%@",[[deviceArray objectAtIndex:0]valueForKey:@"device_name"],[[deviceArray objectAtIndex:0]valueForKey:@"ble_address"]] uppercaseString];
        [btnDeviceSelect setTitle:[NSString stringWithFormat:@"  %@",deviceName] forState:UIControlStateNormal];
        tblDevice1 = [[deviceArray objectAtIndex:0]valueForKey:@"id"];
        strChoosenBLEAddress = [[[deviceArray objectAtIndex:0]valueForKey:@"ble_address"] uppercaseString];
        
        
    }
    
    if (IS_IPHONE_4)
    {
        btnDeviceSelect.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 30);
        yy = yy+30;
    }
    else
    {
        yy = yy+44;
        
    }
    
    
    lblSelectDive = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,DEVICE_WIDTH/2, 44)];
    lblSelectDive.textColor = UIColor.whiteColor;
    lblSelectDive.backgroundColor = UIColor.clearColor;
    lblSelectDive.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblSelectDive.text = @"Select Dive :";
    lblSelectDive.hidden = false;
    [self.view addSubview:lblSelectDive];
    
    if (IS_IPHONE_4)
    {
        lblSelectDive.frame = CGRectMake(5, yy,DEVICE_WIDTH/2, 30);
        yy = yy+30;
    }
    else
    {
        yy = yy+35;
    }
    btnDivePicker1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDivePicker1 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnDivePicker1.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnDivePicker1.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 38);
    btnDivePicker1.backgroundColor = [UIColor clearColor];
    btnDivePicker1.hidden = false;
    btnDivePicker1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnDivePicker1 addTarget:self action:@selector(btnDivePicker1Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDivePicker1];
    btnDivePicker1.layer.borderWidth = 1;
    btnDivePicker1.layer.borderColor = [UIColor whiteColor].CGColor;
    btnDivePicker1.layer.cornerRadius = 5;
    
    UIImageView * imgArrowD = [[UIImageView alloc]initWithFrame:CGRectMake(btnDivePicker1.frame.size.width-15,(btnDivePicker1.frame.size.height/2)-3, 12, 7)];
    imgArrowD.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrowD.backgroundColor = UIColor.clearColor;
    [btnDivePicker1 addSubview:imgArrowD];
    
    diveArray = [[NSMutableArray alloc] init];
    NSString *strTblDive = [NSString stringWithFormat:@"Select * from tbl_dive where ble_address = '%@'",strChoosenBLEAddress];
    [[DataBaseManager dataBaseManager] execute:strTblDive resultsArray:diveArray];
    
    if (diveArray.count > 0)
    {
        [btnDivePicker1 setTitle:[NSString stringWithFormat:@"  Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]] forState:UIControlStateNormal];
        tblDive1 = [[diveArray objectAtIndex:0]valueForKey:@"dive_no"];
        strSelectedDive1 = [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]];
        
    }
    if (IS_IPHONE_4)
    {
        btnDivePicker1.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 30);
        yy = yy+30;
    }
    else
    {
        yy = yy+50;
        
    }
    
    lblselectdevice2 = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,DEVICE_WIDTH/2, 44)];
    lblselectdevice2.textColor = UIColor.whiteColor;
    lblselectdevice2.backgroundColor = UIColor.clearColor;
    lblselectdevice2.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblselectdevice2.text = @"Select 2nd Device:";
    lblselectdevice2.hidden = TRUE;
    [self.view addSubview:lblselectdevice2];
    
    if (IS_IPHONE_4)
    {
        lblselectdevice2.frame = CGRectMake(5, yy,DEVICE_WIDTH/2, 30);
        yy = yy+30;
    }
    else
    {
        yy = yy+35;
        
    }
    btnDeviceSelect2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDeviceSelect2 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnDeviceSelect2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnDeviceSelect2.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 38);
    btnDeviceSelect2.backgroundColor = [UIColor clearColor];
    btnDeviceSelect2.hidden = TRUE;
    //    [btnDeviceSelect2 setTitle:@" " forState:UIControlStateNormal];
    btnDeviceSelect2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnDeviceSelect2 addTarget:self action:@selector(btnDeviceSelect2Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDeviceSelect2];
    btnDeviceSelect2.layer.borderWidth = 1;
    btnDeviceSelect2.layer.borderColor = [UIColor whiteColor].CGColor;
    btnDeviceSelect2.layer.cornerRadius = 5;
    
    UIImageView * imgArrow2 = [[UIImageView alloc]initWithFrame:CGRectMake(btnDeviceSelect2.frame.size.width-15,(btnDeviceSelect2.frame.size.height/2)-3, 12, 7)];
    imgArrow2.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow2.backgroundColor = UIColor.clearColor;
    [btnDeviceSelect2 addSubview:imgArrow2];
    
    if (deviceArray.count > 0)
    {
        NSString * deviceName = [[NSString stringWithFormat:@"%@_%@",[[deviceArray objectAtIndex:0]valueForKey:@"device_name"],[[deviceArray objectAtIndex:0]valueForKey:@"ble_address"]] uppercaseString];
        [btnDeviceSelect2 setTitle:[NSString stringWithFormat:@"  %@",deviceName] forState:UIControlStateNormal];
        tblDevice2 = [[deviceArray objectAtIndex:0]valueForKey:@"id"];
        
    }
    if (IS_IPHONE_4)
    {
        btnDeviceSelect2.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 30);
        yy = yy+30;
    }
    else
    {
        yy = yy+50;
        
    }
    lblSelectDive2 = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,DEVICE_WIDTH/2, 44)];
    lblSelectDive2.textColor = UIColor.whiteColor;
    lblSelectDive2.backgroundColor = UIColor.clearColor;
    lblSelectDive2.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblSelectDive2.text = @"Select 2nd Dive :";
    lblSelectDive2.hidden = TRUE;
    [self.view addSubview:lblSelectDive2];
    
    if (IS_IPHONE_4)
    {
        lblSelectDive2.frame = CGRectMake(5, yy,DEVICE_WIDTH/2, 30);
        yy = yy+30;
    }
    else
    {
        yy = yy+35;
        
    }
    btnDivePicker2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDivePicker2 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnDivePicker2.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnDivePicker2.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 38);
    btnDivePicker2.backgroundColor = [UIColor clearColor];
    btnDivePicker2.hidden = TRUE;
    btnDivePicker2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnDivePicker2 addTarget:self action:@selector(btnDivePicker2Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDivePicker2];
    btnDivePicker2.layer.borderWidth = 1;
    btnDivePicker2.layer.borderColor = [UIColor whiteColor].CGColor;
    btnDivePicker2.layer.cornerRadius = 5;
    
    UIImageView * imgArrow13 = [[UIImageView alloc]initWithFrame:CGRectMake(btnDivePicker2.frame.size.width-15,(btnDivePicker2.frame.size.height/2)-3, 12, 7)];
    imgArrow13.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow13.backgroundColor = UIColor.clearColor;
    [btnDivePicker2 addSubview:imgArrow13];
    
    if (diveArray.count > 0)
    {
        [btnDivePicker2 setTitle:[NSString stringWithFormat:@"  Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_no"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]] forState:UIControlStateNormal];
        tblDive2 = [[diveArray objectAtIndex:0]valueForKey:@"dive_id"];
        strSelectedDive2 = [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]];
        
    }
    
    btnStartDatePicker = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnStartDatePicker setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnStartDatePicker.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+4];
    btnStartDatePicker.frame = CGRectMake(5,yy-10,DEVICE_WIDTH-20 , 38);
    btnStartDatePicker.backgroundColor = [UIColor clearColor];
    btnStartDatePicker.hidden = true;
    btnStartDatePicker.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnStartDatePicker addTarget:self action:@selector(btnStartDatePickerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnStartDatePicker];
    btnStartDatePicker.layer.borderWidth = 1;
    btnStartDatePicker.layer.borderColor = [UIColor whiteColor].CGColor;
    btnStartDatePicker.layer.cornerRadius = 5;
    
    UIImageView * imgArrow3 = [[UIImageView alloc]initWithFrame:CGRectMake(btnStartDatePicker.frame.size.width-15,(btnStartDatePicker.frame.size.height/2)-3, 12, 7)];
    imgArrow3.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow3.backgroundColor = UIColor.clearColor;
    [btnStartDatePicker addSubview:imgArrow3];
    
    if (IS_IPHONE_4)
    {
        btnDivePicker2.frame = CGRectMake(5,yy,DEVICE_WIDTH-10, 30);
    }
    yy = yy +30;
    
    UIButton *btnSubmit = [[UIButton alloc]init];
    btnSubmit.frame = CGRectMake(0, DEVICE_HEIGHT-44, DEVICE_WIDTH, 44);
    btnSubmit.backgroundColor = UIColor.blackColor;
    [btnSubmit setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnSubmit setTitle:@"SUBMIT" forState:UIControlStateNormal];
    btnSubmit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnSubmit.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+4];
    [btnSubmit addTarget:self action:@selector(btnSubmitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSubmit];
    
    if (IS_IPHONE_X)
    {
        btnSubmit.frame = CGRectMake(0, DEVICE_HEIGHT-44-40, DEVICE_WIDTH, 44);
    }
    
}
#pragma mark - Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnConditionalOp:(id)sender
{
    if ([sender tag] ==1)
    {
        isFromCompareButton = false;
        [viewPicker removeFromSuperview];
        [btnSingleData setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [btnCompare setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        
        lblSelectDevice.text = @"Select Device :";
        lblSelectDive.text = @"Select Dive :";
        lblSelectDive2.hidden = true;
        btnDivePicker2.hidden = true;
        lblselectdevice2.hidden = TRUE;
        btnDeviceSelect2.hidden = TRUE;
        lblStartDate.text = @"Choose Date & Time";
        lblEndDate.hidden = true;
        btnEndDatePicker.hidden = true;
    }
    else if([sender tag] ==2)
    {
        isFromCompareButton = true;
        [viewPicker removeFromSuperview];
        [btnSingleData setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnCompare setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        lblSelectDevice.text = @"Select 1st Device :";
        lblSelectDive.text = @"Select 1st Dive :";
        lblSelectDive2.hidden = false;
        btnDivePicker2.hidden = false;
        lblselectdevice2.hidden = FALSE;
        btnDeviceSelect2.hidden = FALSE;
        
        
    }
}
-(void)btnDeviceSelect1Action
{
    if (deviceArray.count<= 0)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"No Devices Found" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        btnDone.tag = 000;
        [self SetAllPickerViewWithTag:000];
        [self ShowPicker:YES andView:viewPicker];
    }
}
-(void)btnDeviceSelect2Action
{
    if (deviceArray.count<= 0)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"No Devices Found" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        btnDone.tag = 222;
        [self SetAllPickerViewWithTag:222];
        [self ShowPicker:YES andView:viewPicker];
    }
}
-(void)btnDivePicker1Action
{
    if (diveArray.count<= 0)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"No Dives Found" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        btnDone.tag = 111;
        [self SetAllPickerViewWithTag:111];
        [self ShowPicker:YES andView:viewPicker];
    }
    
}
-(void)btnDivePicker2Action
{
    if (diveArray.count<= 0)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"No Dives Found" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        btnDone.tag = 333;
        [self SetAllPickerViewWithTag:333];
        [self ShowPicker:YES andView:viewPicker];
    }
}
-(void)btnCancelAction
{
    [self ShowPicker:NO andView:viewPicker];
}

-(void)btnStartDatePickerAction
{
    [self setStartDatePickerFrames];
    [self ShowPicker:YES andView:viewPicker];
}
-(void)btnEndDatePickerAction
{
    [self setStartDatePickerFrames];
    [self ShowPicker:YES andView:viewPicker];
}
-(void)btnDoneAction:(id)sender
{
    if (btnDone.tag == 000)
    {
        if (deviceArray.count > dev1Select)
        {
            [btnDeviceSelect setTitle:[[NSString stringWithFormat:@"  %@_%@",[[deviceArray objectAtIndex:dev1Select]valueForKey:@"device_name"],[[deviceArray objectAtIndex:dev1Select]valueForKey:@"ble_address"]] uppercaseString] forState:UIControlStateNormal];
            indexDevice1 = [[deviceArray valueForKey:@"device_name"] indexOfObject:[[deviceArray objectAtIndex:dev1Select]valueForKey:@"device_name"]];
            if (indexDevice1 == NSNotFound)
            {
                indexDevice1 = 0;
            }
            tblDevice1 = [[deviceArray objectAtIndex:dev1Select]valueForKey:@"id"];
            strChoosenBLEAddress = [[[deviceArray objectAtIndex:dev1Select]valueForKey:@"ble_address"] uppercaseString];
            
            diveArray = [[NSMutableArray alloc] init];
            NSString *strTblDive = [NSString stringWithFormat:@"Select * from tbl_dive where ble_address = '%@'",strChoosenBLEAddress];
            [[DataBaseManager dataBaseManager] execute:strTblDive resultsArray:diveArray];
            
        }
        
        if (diveArray.count > 0)
        {
            [btnDivePicker1 setTitle:[NSString stringWithFormat:@"  Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]] forState:UIControlStateNormal];
            tblDive1 = [[diveArray objectAtIndex:0]valueForKey:@"dive_id"];
            strSelectedDive1 = [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]];
        }
        
    }
    else  if (btnDone.tag ==111)
    {
        if (diveArray.count > dive1Select)
        {
            strSelectedDive1 = [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:dive1Select]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:dive1Select]valueForKey:@"utc_time"]]];
            [btnDivePicker1 setTitle:[NSString stringWithFormat:@"  %@",strSelectedDive1] forState:UIControlStateNormal];
            indexDive1 = [[diveArray valueForKey:@"utc_time"] indexOfObject:[[diveArray objectAtIndex:dive1Select]valueForKey:@"utc_time"]];
            if (indexDive1 == NSNotFound)
            {
                indexDive1 = 0;
            }
            tblDive1 = [[diveArray objectAtIndex:dive1Select]valueForKey:@"dive_id"];

        }
    }
    else if (btnDone.tag == 222)
    {
        if (deviceArray.count > dev2Select)
        {
            [btnDeviceSelect2 setTitle:[[NSString stringWithFormat:@"%@_%@",[[deviceArray objectAtIndex:dev2Select]valueForKey:@"device_name"],[[deviceArray objectAtIndex:dev2Select]valueForKey:@"ble_address"]] uppercaseString] forState:UIControlStateNormal];
            indexDevice2 = [[deviceArray valueForKey:@"device_name"] indexOfObject:[[deviceArray objectAtIndex:dev2Select]valueForKey:@"device_name"]];
            if (indexDevice2 == NSNotFound)
            {
                indexDevice2 = 0;
            }
            tblDevice2 = [[deviceArray objectAtIndex:dev2Select]valueForKey:@"id"];
            
            diveArray = [[NSMutableArray alloc] init];
            NSString *strTblDive = [NSString stringWithFormat:@"Select * from tbl_dive where ble_address = '%@'",[[[deviceArray objectAtIndex:dev2Select]valueForKey:@"ble_address"]uppercaseString]];
            [[DataBaseManager dataBaseManager] execute:strTblDive resultsArray:diveArray];
        }
        if (diveArray.count > 0)
        {
            [btnDivePicker2 setTitle:[NSString stringWithFormat:@"  Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]] forState:UIControlStateNormal];
            tblDive2 = [[diveArray objectAtIndex:0]valueForKey:@"dive_id"];
            strSelectedDive2 = [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:0]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:0]valueForKey:@"utc_time"]]];
        }
    }
    else if (btnDone.tag == 333)
    {
        if (diveArray.count > dive2Select)
        {
            strSelectedDive2 = [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:dive2Select]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:dive2Select]valueForKey:@"utc_time"]]];
            [btnDivePicker2 setTitle:[NSString stringWithFormat:@"  %@",strSelectedDive2] forState:UIControlStateNormal];
            indexDive2 = [[diveArray valueForKey:@"utc_time"] indexOfObject:[[diveArray objectAtIndex:dive2Select]valueForKey:@"utc_time"]];
            if (indexDive2 == NSNotFound)
            {
                indexDive2 = 0;
            }
            tblDive2 = [[diveArray objectAtIndex:dive2Select]valueForKey:@"dive_id"];
        }
       
    }
    if ([sender tag] ==101)
    {
        formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"dd/MM/yy  hh:mm";
        strStartDate = [formatter stringFromDate:startDatePickerView.date];
        ConvertedtoNSdate1 = [formatter dateFromString:strStartDate];
        NSLog(@"finaldate%@",ConvertedtoNSdate1);
        [btnStartDatePicker setTitle:strStartDate forState:UIControlStateNormal];
    }
    [self ShowPicker:NO andView:viewPicker];
}
-(void)btnSubmitAction
{
    if ([[APP_DELEGATE checkforValidString:strSelectedDive1] isEqualToString:@"NA"])
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Choose Data first" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        dictInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:btnDeviceSelect.titleLabel.text,@"dev1",btnDivePicker1.titleLabel.text,@"dive1",btnDeviceSelect2.titleLabel.text,@"dev2",btnDivePicker2.titleLabel.text,@"dive2",nil];
        
        [dictInfo setObject:tblDevice1 forKey:@"device1TableId"];
        [dictInfo setObject:tblDevice2 forKey:@"device2TableId"];
        [dictInfo setObject:tblDive1 forKey:@"dive1TableId"];
        [dictInfo setObject:tblDive2 forKey:@"dive2TableId"];
        
        if (isFromCompareButton == true)
        {
            if ([strSelectedDive1 isEqualToString:strSelectedDive2])
            {
                URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Choose Two Different Dives" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
                GraphVC *view1 = [[GraphVC alloc]init];
                view1.isCompared = true;
                view1.updatedDictInfo = dictInfo;
                [self.navigationController pushViewController:view1 animated:true];
            }
        }
        else if(isFromCompareButton == false)
        {
            GraphVC *view1 = [[GraphVC alloc]init];
            view1.isCompared = false;
            view1.updatedDictInfo = dictInfo;
            [self.navigationController pushViewController:view1 animated:true];
        }
    }
    
}

#pragma mark - PickerView Frames
-(void)SetAllPickerViewWithTag:(int)tagValue
{
    [viewPicker removeFromSuperview];
    viewPicker = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT,DEVICE_WIDTH, 415)];
    viewPicker.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:viewPicker];
    
    divePickerView = [[UIPickerView alloc]init];
    divePickerView.frame = CGRectMake(0,44,viewPicker.frame.size.width, (viewPicker.frame.size.height-44));
    divePickerView.delegate = self;
    divePickerView.dataSource = self;
    divePickerView.tag = tagValue;
    [viewPicker addSubview:divePickerView];
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,44)];
    [btnCancel setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.backgroundColor = UIColor.clearColor;
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnCancel];
    
    lblPickerViewTitle = [[UILabel alloc]init];
    lblPickerViewTitle.frame = CGRectMake(70, 0, DEVICE_WIDTH-140,44);
    lblPickerViewTitle.textColor = UIColor.darkGrayColor;
    lblPickerViewTitle.backgroundColor = UIColor.clearColor;
    lblPickerViewTitle.numberOfLines = 2;
    lblPickerViewTitle.textAlignment = NSTextAlignmentCenter;
    lblPickerViewTitle.font = [UIFont fontWithName:CGRegular size:textSize-3];
    [viewPicker addSubview:lblPickerViewTitle];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70,0,70,44)];
    [btnDone setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = UIColor.clearColor;
    btnDone.tag = tagValue;
    [btnDone addTarget:self action:@selector(btnDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, DEVICE_WIDTH, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [viewPicker addSubview:lblLine];
    
    if (tagValue == 000)
    {
        [divePickerView selectRow:indexDevice1 inComponent:0 animated:true];
        if (isFromCompareButton == true)
        {
            lblPickerViewTitle.text = @"Select 1st Device";
        }
        else
        {
            lblPickerViewTitle.text = @"Select Device";
        }
    }
    else if (tagValue == 111)
    {
        [divePickerView selectRow:indexDive1 inComponent:0 animated:true];
        if (isFromCompareButton == true)
        {
            lblPickerViewTitle.text = @"Select 1st Dive";
        }
        else
        {
            lblPickerViewTitle.text = @"Select Dive";
        }
    }
    else if (tagValue == 222)
    {
        [divePickerView selectRow:indexDevice2 inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Select 2nd Device";
    }
    else if (tagValue == 333)
    {
        [divePickerView selectRow:indexDive2 inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Select 2nd Dive";
    }
    
}
-(void)setStartDatePickerFrames
{
    [viewPicker removeFromSuperview];
    viewPicker = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT,DEVICE_WIDTH, 415)];
    viewPicker.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:viewPicker];
    
    startDatePickerView = [[UIDatePicker alloc]init];
    startDatePickerView.maximumDate = [NSDate date];
    startDatePickerView.frame = CGRectMake(0,44,viewPicker.frame.size.width, (viewPicker.frame.size.height-44));
    startDatePickerView.datePickerMode = UIDatePickerModeDateAndTime;
    [startDatePickerView addTarget:self action:@selector(startDateChangeMethod)forControlEvents:UIControlEventValueChanged];
    [viewPicker addSubview:startDatePickerView];
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,44)];
    [btnCancel setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.backgroundColor = UIColor.clearColor;
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnCancel];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-70,0,70,44)];
    [btnDone setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = UIColor.clearColor;
    btnDone.tag = 101;
    [btnDone addTarget:self action:@selector(btnDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, DEVICE_WIDTH, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [viewPicker addSubview:lblLine];
}

-(void)startDateChangeMethod
{
    formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"dd/MM/yy  hh:mm";
    strStartDate = [formatter stringFromDate:startDatePickerView.date];
    ConvertedtoNSdate1 = [formatter dateFromString:strStartDate];
    NSLog(@"finaldate%@",ConvertedtoNSdate1);
    [btnStartDatePicker setTitle:strStartDate forState:UIControlStateNormal];
}
#pragma mark - PickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView.tag == 000)
    {
        return deviceArray.count;
    }
    else if (pickerView.tag == 111)
    {
        return diveArray.count;
    }
    else if (pickerView.tag == 222)
    {
        return deviceArray.count;
    }
    else if (pickerView.tag == 333)
    {
        return diveArray.count;
    }
    return  true;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView.tag == 000)
    {
        NSString * deviceName = [NSString stringWithFormat:@"%@_%@",[[deviceArray objectAtIndex:row]valueForKey:@"device_name"],[[deviceArray objectAtIndex:row]valueForKey:@"ble_address"]];
        
        return [deviceName uppercaseString];
    }
    else if (pickerView.tag == 111)
    {
        return [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:row]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:row]valueForKey:@"utc_time"]]];
    }
    else if (pickerView.tag == 222)
    {
        return [[NSString stringWithFormat:@"%@_%@",[[deviceArray objectAtIndex:row]valueForKey:@"device_name"],[[deviceArray objectAtIndex:row]valueForKey:@"ble_address"]] uppercaseString];
    }
    else if (pickerView.tag == 333)
    {
        return [NSString stringWithFormat:@"Dive %@_%@",[[diveArray objectAtIndex:row]valueForKey:@"dive_id"],[self GetLocalTimefromUTC:[[diveArray objectAtIndex:row]valueForKey:@"utc_time"]]];
    }
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView.tag == 000)
    {
        dev1Select = row;
    }
    else if (pickerView.tag == 111)
    {
        dive1Select = row;
    }
    else if (pickerView.tag == 222)
    {
        dev2Select = row;
    }
    else if (pickerView.tag == 333)
    {
        dive2Select = row;
    }
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.1
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            if (IS_IPHONE_X)
                            {
                                [myView setFrame:CGRectMake(0,DEVICE_HEIGHT-515,DEVICE_WIDTH, 515)];
                            }
                            else
                            {
                                [myView setFrame:CGRectMake(0,DEVICE_HEIGHT-315,DEVICE_WIDTH, 315)];
                            }
                            self->divePickerView.frame = CGRectMake(0,44,myView.frame.size.width, myView.frame.size.height-44);
                            self->startDatePickerView.frame = CGRectMake(0,44,myView.frame.size.width, myView.frame.size.height-44);
                            self->endDatePickerView.frame = CGRectMake(0,44,myView.frame.size.width, myView.frame.size.height-44);
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.1
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            [myView setFrame:CGRectMake(0,DEVICE_HEIGHT,DEVICE_WIDTH, DEVICE_HEIGHT)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)GetLocalTimefromUTC:(NSString *)strValue
{
    double timeStamp = [strValue doubleValue]/1000;
    NSTimeInterval timeInterval=timeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm:ss",[[NSUserDefaults standardUserDefaults] valueForKey:@"dateFormat"]]];
    NSString *dateString=[dateformatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",dateString];
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

