//
//  HeatMapVC.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 19/01/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "HeatMapVC.h"
#import "HeatMapVCcell.h"
@interface HeatMapVC ()
{
    BOOL isTempCels;
}
@end

@implementation HeatMapVC

- (void)viewDidLoad
{
    intHighestTempSelected85 = 0;
    intVerylowTemp = 1000;
    intlowTemp = 1000;
    intMediumTemp = 1000;
    intHighTemp = 1000;
    intVeryHighTemp = 1000;
    self.view.backgroundColor = UIColor.clearColor;
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    [self.view addSubview:imgBack];
    
    isTempCels = YES;
     TitleArr = [[NSMutableArray alloc]initWithObjects:@"Very High Temperature",@"High Temperature",@"Medium Temperature",@"Low Temperature",@"Very Low Temperature", nil];
    
    colorArr = [[NSMutableArray alloc]init];
    [colorArr addObject:[UIColor colorWithRed:250/255.0f green:83/255.0f blue:46/255.0f alpha:1.0f]];
    [colorArr addObject:[UIColor colorWithRed:250/255.0f green:252/255.0f blue:93/255.0f alpha:1.0f]];
    [colorArr addObject:[UIColor colorWithRed:0/255.0f green:37/255.0f blue:254/255.0f alpha:1.0f]];
    [colorArr addObject:[UIColor colorWithRed:17/255.0f green:255/255.0f blue:253/255.0f alpha:1.0f]];
    [colorArr addObject:[UIColor colorWithRed:191/255.0f green:65/255.0f blue:255/255.0f alpha:1.0f]];

    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    tmpArr = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"HeatMapValues"] mutableCopy];
    
    optionArr = [[NSMutableArray alloc] init];
    for (int i =0; i<[tmpArr count]; i++)
    {
        NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
        tmpDict = [[tmpArr objectAtIndex:i] mutableCopy];
        [optionArr addObject:tmpDict];
        
        if (isTempCels)
        {
            if ([[[tmpArr objectAtIndex:i] valueForKey:@"highC"] isEqualToString:@"85"])
            {
                intHighestTempSelected85 = i;
            }
        }
        else
        {
            if ([[[tmpArr objectAtIndex:i] valueForKey:@"highF"] isEqualToString:@"185"])
            {
                intHighestTempSelected85 = i;
            }
        }
    }
    
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
    [lblTitle setText:@"Heat Map Setting"];
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
    
    tblContent = [[UITableView alloc] init];
    tblContent.frame = CGRectMake(0, yy, DEVICE_WIDTH,250);
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.backgroundColor = [UIColor clearColor];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tblContent.scrollEnabled = NO;
    [self.view addSubview:tblContent];
}
#pragma mark - TableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [optionArr count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HeatMapVCcell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HeatMapVCcell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imgColor.backgroundColor = [colorArr objectAtIndex:indexPath.row];
    cell.lblTitle.text = [TitleArr objectAtIndex:indexPath.row];
    
    if (isTempCels)
    {
        cell.lblTempValues.text  = [NSString stringWithFormat:@"%@ºC to %@ºC",[[optionArr objectAtIndex:indexPath.row] valueForKey:@"lowC"],[[optionArr objectAtIndex:indexPath.row] valueForKey:@"highC"]];
    }
    else
    {
        cell.lblTempValues.text  = [NSString stringWithFormat:@"%@ºF to %@ºF",[[optionArr objectAtIndex:indexPath.row] valueForKey:@"lowF"],[[optionArr objectAtIndex:indexPath.row] valueForKey:@"highF"]];
    }
    if ((indexPath.row < intHighestTempSelected85))
    {
        cell.backgroundColor = [UIColor lightGrayColor];
         cell.lblTempValues.text  = [NSString stringWithFormat:@"-NA- to -NA-"];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
     if ((indexPath.row >= intHighestTempSelected85))
    {
        [self setTemperature];
    }
}

-(void)setTemperature
{
    [blurView removeFromSuperview];
    blurView = [[UIView alloc]init];
    blurView.frame = CGRectMake(0,0, DEVICE_WIDTH,DEVICE_HEIGHT);
    blurView.backgroundColor = UIColor.blackColor;
    blurView.alpha = 0.4;
    blurView.userInteractionEnabled = YES;
    [self.view addSubview:blurView];
    
    [viewBack removeFromSuperview];
    viewBack = [[UIView alloc]init];
    viewBack.backgroundColor = UIColor.whiteColor;
    viewBack.frame = CGRectMake(10, (DEVICE_HEIGHT/2)-75, DEVICE_WIDTH-20,154);
    viewBack.userInteractionEnabled = YES;
    [self.view addSubview:viewBack];
    
    lblTempTitle = [[UILabel alloc]initWithFrame:CGRectMake(5,0,viewBack.frame.size.width-10,30)];
    lblTempTitle.backgroundColor = UIColor.clearColor;
    [lblTempTitle setTextColor:[UIColor grayColor]];
    [lblTempTitle setFont:[UIFont fontWithName:CGRegular size:textSize]];
    lblTempTitle.textAlignment = NSTextAlignmentLeft;
    if (TitleArr.count > selectedIndex)
    {
        lblTempTitle.text = [TitleArr objectAtIndex:selectedIndex];
    }
    [viewBack addSubview:lblTempTitle];
    
    tempSlider = [[UISlider alloc]init];
    tempSlider.frame = CGRectMake(30, 30, viewBack.frame.size.width-60,50);
    tempSlider.backgroundColor = UIColor.clearColor;
    tempSlider.continuous = YES;
    tempSlider.thumbTintColor = UIColor.blackColor;
    tempSlider.minimumTrackTintColor = UIColor.orangeColor;
    tempSlider.maximumTrackTintColor = UIColor.grayColor;
    [tempSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [viewBack addSubview:tempSlider];
    
    lblMinTempDisp = [[UILabel alloc]initWithFrame:CGRectMake(5,70,50,30)];
    lblMinTempDisp.backgroundColor = UIColor.clearColor;
    [lblMinTempDisp setTextColor:[UIColor grayColor]];
    [lblMinTempDisp setFont:[UIFont fontWithName:CGRegular size:textSize]];
    lblMinTempDisp.textAlignment = NSTextAlignmentLeft;
    [viewBack addSubview:lblMinTempDisp];
    
    lblMaxTempDisp = [[UILabel alloc]initWithFrame:CGRectMake(viewBack.frame.size.width-55,70,50,30)];
    lblMaxTempDisp.backgroundColor = UIColor.clearColor;
    [lblMaxTempDisp setTextColor:[UIColor grayColor]];
    [lblMaxTempDisp setFont:[UIFont fontWithName:CGRegular size:textSize]];
    lblMaxTempDisp.textAlignment = NSTextAlignmentLeft;
    [viewBack addSubview:lblMaxTempDisp];

    if (isTempCels)
    {
        if (optionArr.count > selectedIndex)
        {
            int lblLow = [[NSString stringWithFormat:@"%@",[[optionArr objectAtIndex:selectedIndex] valueForKey:@"lowC"]] doubleValue];
            int lblHigh = [[NSString stringWithFormat:@"%@",[[optionArr objectAtIndex:selectedIndex] valueForKey:@"highC"]] doubleValue];
            
            tempSlider.minimumValue = lblLow+1;
            tempSlider.maximumValue = 85;
            tempSlider.value = lblHigh;
            lblMinTempDisp.text = [NSString stringWithFormat:@"%.0d ºC",lblLow];
            lblMaxTempDisp.text = [NSString stringWithFormat:@"%@ ºC",[[optionArr objectAtIndex:selectedIndex] valueForKey:@"highC"]];
        }
    }
    else
    {
        if (optionArr.count > selectedIndex)
        {
            double lblLow = [[[optionArr objectAtIndex:selectedIndex] valueForKey:@"lowF"] doubleValue];
            double lblHigh = [[[optionArr objectAtIndex:selectedIndex] valueForKey:@"highF"] doubleValue];
            
            tempSlider.minimumValue = lblLow + 1;
            tempSlider.maximumValue = (85 * 1.8)+32;
            tempSlider.value = lblHigh;
            lblMinTempDisp.text = [NSString stringWithFormat:@"%.0f ºF",lblLow];
            lblMaxTempDisp.text = [NSString stringWithFormat:@"%@ ºF",[[optionArr objectAtIndex:selectedIndex] valueForKey:@"highF"]];
        }
       
    }

    UIButton *btnCancel = [[UIButton alloc]init];
    btnCancel.frame = CGRectMake(0, viewBack.frame.size.height-44, 100,44 );
    btnCancel.backgroundColor = UIColor.clearColor;
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancel setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [viewBack addSubview:btnCancel];
    
    UIButton *btnSave = [[UIButton alloc]init];
    btnSave.frame = CGRectMake(viewBack.frame.size.width-100, viewBack.frame.size.height-44, 100,44 );
    btnSave.backgroundColor = UIColor.clearColor;
    [btnSave addTarget:self action:@selector(btnSaveAction) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    [btnSave setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    [viewBack addSubview:btnSave];
}
-(void) sliderAction:(id)sender
{
    NSString * strAppends = @"ºF";
    if (isTempCels)
    {
        strAppends = @"ºC";
    }
    lblMaxTempDisp.text = [NSString stringWithFormat:@"%.0f%@",tempSlider.value,strAppends];

}

#pragma mark - Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnCancelAction
{
    [viewBack removeFromSuperview];
    [blurView removeFromSuperview];
}
-(void)btnSaveAction
{
    [viewBack removeFromSuperview];
    [blurView removeFromSuperview];

    if (isTempCels)
    {
        int savedValMax= roundf(tempSlider.value *1.0);
        //Convert Celsius to fahrenheit
        if (optionArr.count > selectedIndex)
        {
            [[optionArr objectAtIndex:selectedIndex] setObject:[NSString stringWithFormat:@"%d",savedValMax] forKey:@"highC"];
        }
        if (selectedIndex > 0)
        {
            NSInteger mainIndex = selectedIndex;
            NSInteger minusIndex = selectedIndex -1;
            if (optionArr.count > mainIndex)
            {
                low = [[[optionArr objectAtIndex:mainIndex]valueForKey:@"highC"] intValue];
                
                if (optionArr.count > minusIndex)
                {
                    [[optionArr objectAtIndex:minusIndex] setObject:[NSString stringWithFormat:@"%d",savedValMax] forKey:@"lowC"];
                    high = [[[optionArr objectAtIndex:selectedIndex-1]valueForKey:@"highC"] intValue];
                    {
                        
                        for (NSInteger i=selectedIndex-1; i<optionArr.count; i--)
                        {
                            low = [[[optionArr objectAtIndex:i]valueForKey:@"lowC"] intValue];
                            //                    if (i-1>=0)
                            {
                                high = [[[optionArr objectAtIndex:i]valueForKey:@"highC"] intValue];
                                if (high < low)
                                {
                                    int prevVal = [[[optionArr objectAtIndex:i] valueForKey:@"lowC"] doubleValue] + 1;
                                    if (prevVal >= 85)
                                    {
                                        prevVal = 85;
                                    }
                                    [[optionArr objectAtIndex:i] setObject:[NSString stringWithFormat:@"%d",prevVal] forKey:@"highC"];
                                    if (i-1>=0)
                                    {
                                        [[optionArr objectAtIndex:i-1] setObject:[NSString stringWithFormat:@"%d",prevVal] forKey:@"lowC"];
                                    }
                                    
                                }
                            }
                        }
                   }
                }
            }
        }
      
    }
    else
    {
        int savedValMax= tempSlider.value;
        //Convert fahrenheit to Celsius
        float savedMaxC = (savedValMax - 32) * (5/9);
        if (optionArr.count > selectedIndex)
        {
            [[optionArr objectAtIndex:selectedIndex] setObject:[NSString stringWithFormat:@"%.0d",savedValMax] forKey:@"highF"];
            [[optionArr objectAtIndex:selectedIndex] setObject:[NSString stringWithFormat:@"%.0f",savedMaxC] forKey:@"highC"];
            if (selectedIndex > 0)
            {
                [[optionArr objectAtIndex:selectedIndex-1] setObject:[NSString stringWithFormat:@"%.0d",savedValMax] forKey:@"lowF"];
                [[optionArr objectAtIndex:selectedIndex-1] setObject:[NSString stringWithFormat:@"%.0f",savedMaxC] forKey:@"lowC"];
            }
        }
    }
    
    for (int i = 0; i<[optionArr count]; i++)
    {
        if (isTempCels)
        {
            if ([[[optionArr objectAtIndex:i] valueForKey:@"highC"] isEqualToString:@"85"])
            {
                intHighestTempSelected85 = i;
            }
        }
        else
        {
            if ([[[optionArr objectAtIndex:i] valueForKey:@"highF"] isEqualToString:@"185"])
            {
                intHighestTempSelected85 = i;
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:optionArr forKey:@"HeatMapValues"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tblContent reloadData];
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
