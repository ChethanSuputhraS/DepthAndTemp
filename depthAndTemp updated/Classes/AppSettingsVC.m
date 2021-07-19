//
//  AppSettingsVC.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 05/12/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "AppSettingsVC.h"
#import "HeatMapVC.h"
@interface AppSettingsVC ()

@end

@implementation AppSettingsVC

- (void)viewDidLoad
{
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self setMainViewFrames];
    
    [self setValueForAppSettingScreen];
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
    [lblTitle setText:@"App Settings"];
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
    
    UILabel * lblTimeUfc = [[UILabel alloc]initWithFrame:CGRectMake(5, yy+5,100*approaxSize, 30)];
    lblTimeUfc.textColor = UIColor.whiteColor;
    lblTimeUfc.backgroundColor = UIColor.clearColor;
    lblTimeUfc.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblTimeUfc.text = @"Time Ufc";
    [self.view addSubview:lblTimeUfc];
    
    yy = yy+25;
    btnMinus1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMinus1 setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
    [btnMinus1 setTitle:@"  -1 he" forState:UIControlStateNormal];
    [btnMinus1 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnMinus1.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnMinus1.frame = CGRectMake(5,yy,100, 44);
    btnMinus1.tag = 1;
    [btnMinus1 addTarget:self action:@selector(btnConditionalOp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnMinus1];
    btnMinus1.backgroundColor = [UIColor clearColor];
    btnMinus1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    int zz = 5+100;
    btnPlus1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPlus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
    [btnPlus1 setTitle:@"  +1 he" forState:UIControlStateNormal];
    [btnPlus1 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnPlus1.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnPlus1.frame = CGRectMake(zz+5 ,yy,100 , 44);
    btnPlus1.tag = 2;
    [btnPlus1 addTarget:self action:@selector(btnConditionalOp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPlus1];
    btnPlus1.backgroundColor = [UIColor clearColor];
    btnPlus1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    zz = zz+100;
    btn0 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn0 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
    [btn0 setTitle:@"  0 he" forState:UIControlStateNormal];
    [btn0 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn0.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btn0.frame = CGRectMake(zz+5 ,yy,100 , 44);
    btn0.tag = 3;
    [btn0 addTarget:self action:@selector(btnConditionalOp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn0];
    btn0.backgroundColor = [UIColor clearColor];
    btn0.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    UILabel * lblSep1 = [[UILabel alloc] initWithFrame:CGRectMake(10, yy+40, DEVICE_WIDTH-10, 0.5)];
    lblSep1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lblSep1];

    yy = yy+54;
    UILabel * lblDateFormat = [[UILabel alloc]initWithFrame:CGRectMake(5, yy+7,130, 30)];
    lblDateFormat.textColor = UIColor.whiteColor;
    lblDateFormat.backgroundColor = UIColor.clearColor;
    lblDateFormat.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblDateFormat.text = @"Date Format :";
    [self.view addSubview:lblDateFormat];

    btnDateFormatPick = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDateFormatPick setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnDateFormatPick.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnDateFormatPick.frame = CGRectMake(lblDateFormat.frame.size.width+5,yy+4,160 *(approaxSize), 38);
    btnDateFormatPick.backgroundColor = [UIColor clearColor];
    btnDateFormatPick.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnDateFormatPick addTarget:self action:@selector(btnDateFormatPickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDateFormatPick];
    
    btnDateFormatPick.layer.borderWidth = 1;
    btnDateFormatPick.layer.borderColor = [UIColor whiteColor].CGColor;
    btnDateFormatPick.layer.cornerRadius = 5;

    UIImageView * imgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(btnDateFormatPick.frame.size.width-15,(btnDateFormatPick.frame.size.height/2)-3, 12, 7)];
    imgArrow.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow.backgroundColor = UIColor.clearColor;
    [btnDateFormatPick addSubview:imgArrow];
    
    dateFormatArr = [[NSMutableArray alloc]initWithObjects:@"YYYY-MM-dd",@"DD-MM-YYYY",@"DD/MM/YYYY",@"DD MMM YYYY",@"MM/DD/YYYY",@"YYYY/MM/DD", nil];
    
    valueArr = [NSArray arrayWithObjects:@"YYYY-MM-dd",@"dd-MM-yyyy",@"dd/MM/yyyy",@"dd MMMM yyyy",@"MM/dd/yyyy",@"yyyy/MM/dd", nil];

    UILabel * lblSep2 = [[UILabel alloc] initWithFrame:CGRectMake(10, yy+60, DEVICE_WIDTH-10, 0.5)];
    lblSep2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lblSep2];
    
    yy = yy+54+10;
    
    UILabel * lblTempType = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,150*approaxSize, 30)];
    lblTempType.textColor = UIColor.whiteColor;
    lblTempType.backgroundColor = UIColor.clearColor;
    lblTempType.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblTempType.text = @"Temperature Type";
    [self.view addSubview:lblTempType];
    
    yy = yy+25;
    
    btnC = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnC setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
    [btnC setTitle:@"  °C" forState:UIControlStateNormal];
    [btnC setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnC.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnC.frame = CGRectMake(5,yy,100, 44);
    btnC.tag = 4;
    [btnC addTarget:self action:@selector(btnConditionalOp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnC];
    btnC.backgroundColor = [UIColor clearColor];
    btnC.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    btnF = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnF setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
    [btnF setTitle:@"  °F" forState:UIControlStateNormal];
    [btnF setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnF.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnF.frame = CGRectMake(5+100+5 ,yy,100 , 44);
    btnF.tag = 5;
    [btnF addTarget:self action:@selector(btnConditionalOp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnF];
    btnF.backgroundColor = [UIColor clearColor];
    btnF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    UILabel * lblSep3 = [[UILabel alloc] initWithFrame:CGRectMake(10, yy+50, DEVICE_WIDTH-10, 0.5)];
    lblSep3.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lblSep3];
    
    yy = yy+54;
    
    UILabel * lblSynchint = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,150*approaxSize, 30)];
    lblSynchint.textColor = UIColor.whiteColor;
    lblSynchint.backgroundColor = UIColor.clearColor;
    lblSynchint.font = [UIFont fontWithName:CGRegular size:textSize+2];
    lblSynchint.text = @"Auto Sync";
    [self.view addSubview:lblSynchint];

    yy = yy+35;
    UISwitch * switchSync = [[UISwitch alloc] initWithFrame:CGRectMake(10, yy, 50, 50)];
    switchSync.tintColor = [UIColor grayColor];
    switchSync.onTintColor = [UIColor whiteColor];
    switchSync.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoSync"];
    [switchSync addTarget:self action:@selector(autoSyncChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchSync];
    
    UILabel * lblSep4 = [[UILabel alloc] initWithFrame:CGRectMake(10, yy+40, DEVICE_WIDTH-10, 0.5)];
    lblSep4.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lblSep4];
    
    yy = yy+45;
    
    UIImageView*imgArrowRight = [[UIImageView alloc]init];
    imgArrowRight.backgroundColor = UIColor.clearColor;
    imgArrowRight.userInteractionEnabled = YES;
    imgArrowRight.image = [UIImage imageNamed:@"rightIcon.png"];
    imgArrowRight.frame = CGRectMake((DEVICE_WIDTH-30), yy+16, 9,15);
    imgArrowRight.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imgArrowRight];
    
    UIButton *btnHeatMap = [[UIButton alloc]init];
    btnHeatMap.frame = CGRectMake(5, yy, DEVICE_WIDTH-10, 44);
    btnHeatMap.backgroundColor = UIColor.clearColor;
    btnHeatMap.titleLabel.textColor = UIColor.whiteColor;
    [btnHeatMap setTitle:@"Heat Map Setting" forState:UIControlStateNormal];
    btnHeatMap.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnHeatMap.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnHeatMap addTarget:self action:@selector(btnHeapMapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnHeatMap];
    
    UILabel * lblSep5 = [[UILabel alloc] initWithFrame:CGRectMake(10, yy+50, DEVICE_WIDTH-10, 0.5)];
    lblSep5.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lblSep5];
}
-(void)autoSyncChanged:(id)sender
{
    UISwitch *s = (UISwitch*)sender;
    [[NSUserDefaults standardUserDefaults] setBool:s.isOn forKey:@"isAutoSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        [btnMinus1 setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [btnPlus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btn0 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"-1" forKey:@"timeUfcType"];

    }
    else  if ([sender tag] ==2)
    {
        [btnMinus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnPlus1 setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [btn0 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"+1" forKey:@"timeUfcType"];

    }
    else if ([sender tag] ==3)
    {
        [btnMinus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnPlus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btn0 setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"timeUfcType"];
    }
    else if ([sender tag] ==4)
    {
        [btnC setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [btnF setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"°C" forKey:@"temperatureType"];
    }
    else if ([sender tag] ==5)
    {
        [btnC setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnF setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"°F" forKey:@"temperatureType"];

    }
    [[NSUserDefaults standardUserDefaults]synchronize ];
}
-(void)btnDateFormatPickAction
{
    [self setDateFormatPickerFrames];
    [self ShowPicker:YES andView:viewPicker];
}
-(void)btnCancelAction
{
    [self ShowPicker:NO andView:viewPicker];
    
}
-(void)btnDoneAction
{
    [self ShowPicker:NO andView:viewPicker];
    if (strSelectedDate == nil || strSelectedDate == 0 || strSelectedDate == NULL)
    {
        strSelectedDate = @"YYYY-MM-dd";
    }
    [btnDateFormatPick setTitle:strShowDate forState:UIControlStateNormal];
    indexDate = [dateFormatArr indexOfObject:strSelectedDate];
    if (indexDate == NSNotFound)
    {
        indexDate = 0;
    }

    [[NSUserDefaults standardUserDefaults] setValue:strSelectedDate forKey:@"dateFormat"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)btnHeapMapAction
{
    HeatMapVC *view1 = [[HeatMapVC alloc]init];
    [self.navigationController pushViewController:view1 animated:true];
}
#pragma mark - PickerView Frames
-(void)setDateFormatPickerFrames
{
    [viewPicker removeFromSuperview];
    viewPicker = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT,DEVICE_WIDTH, 415)];
    viewPicker.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:viewPicker];

    dateFormatPickerView = [[UIPickerView alloc]init];
    dateFormatPickerView.frame = CGRectMake(0,44,viewPicker.frame.size.width, (viewPicker.frame.size.height-44));
    dateFormatPickerView.delegate = self;
    dateFormatPickerView.dataSource = self;
  //  [dateFormatPickerView setBackgroundColor:[UIColor blackColor]];
    [viewPicker addSubview:dateFormatPickerView];
    
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
    //btnDone.tag = 1;
    [btnDone addTarget:self action:@selector(btnDoneAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, DEVICE_WIDTH, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [viewPicker addSubview:lblLine];
    
    [dateFormatPickerView selectRow:indexDate inComponent:0 animated:true];
}
#pragma mark - PickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    if (pickerView == dateFormatPickerView)
    {
        return 1;
    }
    return true;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView == dateFormatPickerView)
    {
        return dateFormatArr.count;
    }
    return true;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView == dateFormatPickerView)
    {
        return dateFormatArr[row];
    }
    return nil;
}
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont fontWithName:CGBold size:textSize];
//
//    if (component == 0)
//    {
//        if (pickerView == dateFormatPickerView)
//        {
//            label.text = [dateFormatArr objectAtIndex:row];
//            return label;
//        }
//    }
//    return label;
//}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView == dateFormatPickerView)
    {
        strSelectedDate = valueArr[row];
        strShowDate = dateFormatArr[row];
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
                            self->dateFormatPickerView.frame = CGRectMake(0,44,myView.frame.size.width, myView.frame.size.height-44);

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
                            //                            [self->backShadowView removeFromSuperview];
                            [myView setFrame:CGRectMake(0,DEVICE_HEIGHT,DEVICE_WIDTH, DEVICE_HEIGHT)];
                            
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}
#pragma mark - set Channel's Values
-(void)setValueForAppSettingScreen
{
    // time ufc
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"timeUfcType"] isEqualToString:@"-1"])
    {
        [btnMinus1 setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [btnPlus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btn0 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
    }
    else if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"timeUfcType"] isEqualToString:@"+1"])
    {
        [btnMinus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnPlus1 setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
        [btn0 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
    }
    else if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"timeUfcType"] isEqualToString:@"0"])
    {
        [btnMinus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnPlus1 setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btn0 setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
    }
    //date format
        [btnDateFormatPick setTitle:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"dateFormat"]] forState:UIControlStateNormal];


    
    //temperature type
     if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"temperatureType"] isEqualToString:@"°C"])
     {
         [btnC setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
         [btnF setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
     }
    else if([[[NSUserDefaults standardUserDefaults]valueForKey:@"temperatureType"] isEqualToString:@"°F"])
    {
        [btnC setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnF setImage:[UIImage imageNamed:@"radiobuttonSelected"]  forState:UIControlStateNormal];
    }
}
- (void)didReceiveMemoryWarning
{
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
