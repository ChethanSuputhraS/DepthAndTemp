//
//  GraphVC.m
//  depthAndTemp
//
//  Created by stuart watts on 14/01/2019.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "GraphVC.h"
#import "depthAndTemp-Swift.h"
#import "NYSegmentedControl.h"
#import "DataBaseManager.h"
#import "DateValueFormatter.h"
#import "SelectionViewOptionCell.h"
#import "MapClassVC.h"

@interface GraphVC ()<ChartViewDelegate>
{
    LineChartView *chartView, * chartTemp, * chartHeat;
    NYSegmentedControl * optionSegmentClick;
    NSMutableArray * dataArr, * data2Arr, * compareArr, * colorArr, * mapSettingArr;
    int finalYY;
    NSString * strTempType;
    BalloonMarker *markerHeat, * markerDepth, * markerTemp;
}
@end

@implementation GraphVC
@synthesize options, detailDict;
@synthesize isCompared,updatedDictInfo;

- (void)viewDidLoad
{
    strTempType = @"temperature";
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"temperatureType"] isEqualToString:@"°F"])
    {
        strTempType = @"temperature_far";
    }
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    dataArr = [[NSMutableArray alloc] init];
    NSString * strQry = [NSString stringWithFormat:@"select * from tbl_pre_temp where pre_temp_dive_id ='%@'",[updatedDictInfo valueForKey:@"dive1TableId"]];
    [[DataBaseManager dataBaseManager] execute:strQry resultsArray:dataArr];
    globalDataArr = [[NSMutableArray alloc] init];
    globalDataArr = [dataArr mutableCopy];
    
    if (isCompared)
    {
        data2Arr = [[NSMutableArray alloc] init];
        strQry = [NSString stringWithFormat:@"select * from tbl_pre_temp where pre_temp_dive_id ='%@'",[updatedDictInfo valueForKey:@"dive2TableId"]];
        [[DataBaseManager dataBaseManager] execute:strQry resultsArray:data2Arr];
        
        compareArr = [[NSMutableArray alloc] init];
        [compareArr addObjectsFromArray:dataArr];
        [compareArr addObjectsFromArray:data2Arr];
    }

    [self setNavigationViewFrames];
    [self setMainViewFrames];
    

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
    [lblTitle setText:@"Device Data"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    lblTitle.numberOfLines = 0;
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20+12, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [self.view addSubview:btnBack];
    
    UIImageView * mapImg = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-45, 20+9, 26, 26)];
    [mapImg setImage:[UIImage imageNamed:@"map.png"]];
    [mapImg setContentMode:UIViewContentModeScaleAspectFit];
    mapImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:mapImg];
    
    UIButton * btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMap addTarget:self action:@selector(btnMapClick) forControlEvents:UIControlEventTouchUpInside];
    btnMap.frame = CGRectMake(DEVICE_WIDTH-65, 0, 70, 64);
    btnMap.backgroundColor = [UIColor clearColor];
    [self.view addSubview:btnMap];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        
        mapImg.frame = CGRectMake(DEVICE_WIDTH-45, 12+44, 20, 20);
        btnMap.frame = CGRectMake(DEVICE_WIDTH-65, 0, 70, 64);

    }
}
-(void)setMainViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 88;
    }
    UILabel * lblDevice1lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,DEVICE_WIDTH-20, 25)];
    lblDevice1lbl.textColor = UIColor.whiteColor;
    lblDevice1lbl.backgroundColor = UIColor.clearColor;
    lblDevice1lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDevice1lbl.textAlignment = NSTextAlignmentLeft;
    lblDevice1lbl.text = [NSString stringWithFormat:@"Device :"];
    [self.view addSubview:lblDevice1lbl];
    
    UILabel*lblDevice1Name = [[UILabel alloc]init];
    lblDevice1Name.frame = CGRectMake(100, yy, DEVICE_WIDTH-110, 25);
    lblDevice1Name.textColor = UIColor.whiteColor;
    lblDevice1Name.backgroundColor = UIColor.clearColor;
    lblDevice1Name.font = [UIFont fontWithName:CGBold size:textSize-2];
    lblDevice1Name.textAlignment = NSTextAlignmentRight;
    lblDevice1Name.text = [[APP_DELEGATE checkforValidString:[updatedDictInfo valueForKey:@"dev1"]] uppercaseString];
    [self.view addSubview:lblDevice1Name];
    
    yy = yy+20;

    UILabel * lblDive1Lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,100, 25)];
    lblDive1Lbl.textColor = UIColor.whiteColor;
    lblDive1Lbl.backgroundColor = UIColor.clearColor;
    lblDive1Lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDive1Lbl.textAlignment = NSTextAlignmentLeft;
    lblDive1Lbl.text = @"Dive :";
    [self.view addSubview:lblDive1Lbl];

    UILabel*lblDive1Name = [[UILabel alloc]init];
    lblDive1Name.frame = CGRectMake(100, yy, DEVICE_WIDTH-110, 25);
    lblDive1Name.textColor = UIColor.whiteColor;
    lblDive1Name.backgroundColor = UIColor.clearColor;
    lblDive1Name.font = [UIFont fontWithName:CGBold size:textSize-2];
    lblDive1Name.textAlignment = NSTextAlignmentRight;
    lblDive1Name.text = [APP_DELEGATE checkforValidString:[updatedDictInfo valueForKey:@"dive1"]];
    [self.view addSubview:lblDive1Name];

    if(isCompared == true)
    {
        lblDevice1lbl.text = [NSString stringWithFormat:@"Device 1 :"];
        lblDive1Lbl.text = @"Dive 1 :";

        yy = yy+30;
        
        UILabel * lblDevice2lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,100, 25)];
        lblDevice2lbl.textColor = UIColor.whiteColor;
        lblDevice2lbl.backgroundColor = UIColor.clearColor;
        lblDevice2lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblDevice2lbl.textAlignment = NSTextAlignmentLeft;
        lblDevice2lbl.text = @"Device 2 :";
        [self.view addSubview:lblDevice2lbl];
        
        UILabel*lblDevice2Name = [[UILabel alloc]init];
        lblDevice2Name.frame = CGRectMake(100, yy,DEVICE_WIDTH-110, 25);
        lblDevice2Name.textColor = UIColor.whiteColor;
        lblDevice2Name.backgroundColor = UIColor.clearColor;
        lblDevice2Name.font = [UIFont fontWithName:CGBold size:textSize-2];
        lblDevice2Name.textAlignment = NSTextAlignmentRight;
        lblDevice2Name.text = [[APP_DELEGATE checkforValidString:[updatedDictInfo valueForKey:@"dev2"]] uppercaseString];
        [self.view addSubview:lblDevice2Name];
        
        yy = yy+20;
        
        UILabel * lblDive2Lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,100, 25)];
        lblDive2Lbl.textColor = UIColor.whiteColor;
        lblDive2Lbl.backgroundColor = UIColor.clearColor;
        lblDive2Lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
        lblDive2Lbl.textAlignment = NSTextAlignmentLeft;
        lblDive2Lbl.text = @"Dive 2 : ";
        [self.view addSubview:lblDive2Lbl];
        
        UILabel*lblDive2Name = [[UILabel alloc]init];
        lblDive2Name.frame = CGRectMake(100, yy, DEVICE_WIDTH-110, 25);
        lblDive2Name.textColor = UIColor.whiteColor;
        lblDive2Name.backgroundColor = UIColor.clearColor;
        lblDive2Name.font = [UIFont fontWithName:CGBold size:textSize-2];
        lblDive2Name.textAlignment = NSTextAlignmentRight;
        lblDive2Name.text = [APP_DELEGATE checkforValidString:[updatedDictInfo valueForKey:@"dive2"]];
        [self.view addSubview:lblDive2Name];
    }
    
    yy=yy+30;
    
    optionSegmentClick = [[NYSegmentedControl alloc] initWithItems:@[@"Raw Data", @"Line Chart",@"Heat Map"]];
    optionSegmentClick.titleTextColor = [UIColor blackColor];
    optionSegmentClick.selectedTitleTextColor = [UIColor whiteColor];
    optionSegmentClick.segmentIndicatorBackgroundColor = [UIColor blackColor];
    optionSegmentClick.backgroundColor = [UIColor whiteColor];
    optionSegmentClick.borderWidth = 0.0f;
    optionSegmentClick.segmentIndicatorBorderWidth = 0.0f;
    optionSegmentClick.segmentIndicatorInset = 2.0f;
    optionSegmentClick.segmentIndicatorBorderColor = self.view.backgroundColor;
    optionSegmentClick.cornerRadius = 10;
    optionSegmentClick.usesSpringAnimations = YES;
    [optionSegmentClick addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    [optionSegmentClick setFrame:CGRectMake(10,yy, DEVICE_WIDTH-20, 30)];
    optionSegmentClick.layer.cornerRadius = 10;
    optionSegmentClick.layer.masksToBounds = YES;
    [self.view addSubview:optionSegmentClick];
    
    finalYY = yy;
    [self setUpforRawDataTable];
}

#pragma mark - Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)segmentClick:(NYSegmentedControl *) sender
{
    if (sender.selectedSegmentIndex==0)
    {
        viewRawData.hidden = NO;
        viewLineChart.hidden = YES;
        viewHeat.hidden = YES;
    }
    else if (sender.selectedSegmentIndex==1)
    {
        viewRawData.hidden = YES;
        viewLineChart.hidden = NO;
        viewHeat.hidden = YES;
        if (!viewLineChart)
        {
            [self SetupForLineGraphs];
        }
    }
    else if (sender.selectedSegmentIndex==2)
    {
        viewRawData.hidden = YES;
        viewLineChart.hidden = YES;
        viewHeat.hidden = NO;
        if (!viewHeat)
        {
            colorArr = [[NSMutableArray alloc]init];
            [colorArr addObject:[UIColor colorWithRed:250/255.0f green:83/255.0f blue:46/255.0f alpha:1.0f]];
            [colorArr addObject:[UIColor colorWithRed:250/255.0f green:252/255.0f blue:93/255.0f alpha:1.0f]];
            [colorArr addObject:[UIColor colorWithRed:0/255.0f green:37/255.0f blue:254/255.0f alpha:1.0f]];
            [colorArr addObject:[UIColor colorWithRed:17/255.0f green:255/255.0f blue:253/255.0f alpha:1.0f]];
            [colorArr addObject:[UIColor colorWithRed:191/255.0f green:65/255.0f blue:255/255.0f alpha:1.0f]];
            colorArr=[[[colorArr reverseObjectEnumerator] allObjects] mutableCopy];

            mapSettingArr = [[NSMutableArray alloc] init];
            mapSettingArr = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"HeatMapValues"] mutableCopy];
            mapSettingArr=[[[mapSettingArr reverseObjectEnumerator] allObjects] mutableCopy];

            [self SetupForHeatMap];
        }
    }
}
-(void)btnMapClick
{
    MapClassVC * mapV = [[MapClassVC alloc] init];
    mapV.detailsDict = updatedDictInfo;
    mapV.isfromCompared = isCompared;
    [self.navigationController pushViewController:mapV animated:YES];
}

#pragma mark - SETUP for RAWDATA TABLE
-(void)setUpforRawDataTable
{
    [viewRawData removeFromSuperview];
    viewRawData = [[UIView alloc] init];
    viewRawData.frame = CGRectMake(0, finalYY + 30, DEVICE_WIDTH, DEVICE_HEIGHT-finalYY-30);
    viewRawData.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewRawData];

    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,viewRawData.frame.size.height) style:UITableViewStylePlain];
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.backgroundColor = [UIColor clearColor];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tblContent.separatorColor = [UIColor darkGrayColor];
    [viewRawData addSubview:tblContent];
    if (IS_IPHONE_X)
    {
        viewRawData.frame = CGRectMake(0, finalYY + 30, DEVICE_WIDTH, DEVICE_HEIGHT-finalYY-30-40);
        tblContent.frame = CGRectMake(0, 0, DEVICE_WIDTH,viewRawData.frame.size.height);
    }
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 30)];
    headerView.backgroundColor = [UIColor blackColor];
    
    int zz = DEVICE_WIDTH/4;
    UILabel *lblDive=[[UILabel alloc]init];
    lblDive.text = @"Dive";
    [lblDive setTextColor:[UIColor whiteColor]];
    lblDive.backgroundColor = UIColor.clearColor;
    [lblDive setFont:[UIFont fontWithName:CGRegular size:textSize]];
    lblDive.frame = CGRectMake(0,0,zz, 30);
    lblDive.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:lblDive];
    
    UILabel *lbltime=[[UILabel alloc]init];
    lbltime.text = @"Time";
    [lbltime setTextColor:[UIColor whiteColor]];
    [lbltime setFont:[UIFont fontWithName:CGRegular size:textSize]];
    lbltime.frame = CGRectMake(zz,0, zz, 30);
    lbltime.textAlignment = NSTextAlignmentCenter;
    lbltime.backgroundColor = UIColor.clearColor;
    [headerView addSubview:lbltime];
    
    UILabel *lblDepth=[[UILabel alloc]init];
    lblDepth.text = @"Depth(m)";
    [lblDepth setTextColor:[UIColor whiteColor]];
    [lblDepth setFont:[UIFont fontWithName:CGRegular size:textSize]];
    lblDepth.frame = CGRectMake(zz*2, 0, zz, 35);
    lblDepth.textAlignment = NSTextAlignmentCenter;
    lblDepth.backgroundColor = UIColor.clearColor;
    [headerView addSubview:lblDepth];
    
    UILabel *lblTemp=[[UILabel alloc]init];
    lblTemp.text = @"Temp";
    [lblTemp setTextColor:[UIColor whiteColor]];
    [lblTemp setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    lblTemp.frame = CGRectMake(zz*3, 0,zz, 35);
    lblTemp.textAlignment = NSTextAlignmentCenter;
    lblTemp.backgroundColor = UIColor.clearColor;
    [headerView addSubview:lblTemp];
    
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isCompared)
    {
        return [compareArr count];
    }
    else
    {
        return [dataArr count];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.backgroundColor = [UIColor clearColor];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    SelectionViewOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[SelectionViewOptionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
 
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (isCompared)
    {
        cell.lblDive.text = [NSString stringWithFormat:@"Dive %@",[APP_DELEGATE checkforValidString:[[compareArr objectAtIndex:indexPath.row] valueForKey:@"pre_temp_dive_id"]]];
        cell.lblTime.text = [self GetLocalTimefromUTC:[APP_DELEGATE checkforValidString:[[compareArr objectAtIndex:indexPath.row] valueForKey:@"utc_time"]]];
        cell.lblDepth.text = [APP_DELEGATE checkforValidString:[[compareArr objectAtIndex:indexPath.row] valueForKey:@"pressure_depth"]];
        cell.lblTemp.text = @"NA";
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"temperatureType"] isEqualToString:@"°C"])
        {
            if (![[APP_DELEGATE checkforValidString:[[compareArr objectAtIndex:indexPath.row] valueForKey:@"temperature"]] isEqualToString:@"NA"])
            {
                cell.lblTemp.text = [NSString stringWithFormat:@"%@ °C",[[compareArr objectAtIndex:indexPath.row] valueForKey:@"temperature"]];
            }
        }
        else
        {
            if (![[APP_DELEGATE checkforValidString:[[compareArr objectAtIndex:indexPath.row] valueForKey:@"temperature"]] isEqualToString:@"NA"])
            {
                cell.lblTemp.text = [NSString stringWithFormat:@"%@ °F",[[compareArr objectAtIndex:indexPath.row] valueForKey:@"temperature_far"]];
            }
        }
    }
    else
    {
        cell.lblDive.text = [NSString stringWithFormat:@"Dive %@",[APP_DELEGATE checkforValidString:[[dataArr objectAtIndex:indexPath.row] valueForKey:@"pre_temp_dive_id"]]];
        cell.lblTime.text = [self GetLocalTimefromUTC:[APP_DELEGATE checkforValidString:[[dataArr objectAtIndex:indexPath.row] valueForKey:@"utc_time"]]];;
        cell.lblDepth.text = [APP_DELEGATE checkforValidString:[[dataArr objectAtIndex:indexPath.row] valueForKey:@"pressure_depth"]];
        cell.lblTemp.text = @"NA";
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"temperatureType"] isEqualToString:@"°C"])
        {
            if (![[APP_DELEGATE checkforValidString:[[dataArr objectAtIndex:indexPath.row] valueForKey:@"temperature"]] isEqualToString:@"NA"])
            {
                cell.lblTemp.text = [NSString stringWithFormat:@"%@ °C",[[dataArr objectAtIndex:indexPath.row] valueForKey:@"temperature"]];
            }
        }
        else
        {
            if (![[APP_DELEGATE checkforValidString:[[dataArr objectAtIndex:indexPath.row] valueForKey:@"temperature"]] isEqualToString:@"NA"])
            {
                cell.lblTemp.text = [NSString stringWithFormat:@"%@ °F",[[dataArr objectAtIndex:indexPath.row] valueForKey:@"temperature_far"]];
            }
        }
    }

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
#pragma mark - SETUP for LINE CHART
-(void)SetupForLineGraphs
{
    [viewLineChart removeFromSuperview];
    viewLineChart = [[UIView alloc] init];
    viewLineChart.frame = CGRectMake(0, finalYY + 40, DEVICE_WIDTH, DEVICE_HEIGHT-finalYY-40);
    viewLineChart.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewLineChart];
    if (IS_IPHONE_X)
    {
        viewLineChart.frame = CGRectMake(0, finalYY + 40, DEVICE_WIDTH, DEVICE_HEIGHT-finalYY-40-40);
    }
    
    chartView = [[LineChartView alloc] init];
    chartView.frame = CGRectMake(20, 0, DEVICE_WIDTH-20, viewLineChart.frame.size.height/2 );
    chartView.backgroundColor = [UIColor clearColor];
    chartView.delegate = self;
    chartView.tag = 111;
    chartView.layer.borderColor = [UIColor whiteColor].CGColor;
    chartView.layer.borderWidth = 0.5;
    [viewLineChart addSubview:chartView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-138, 125, 300, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"Depth(M)"];
    label.transform=CGAffineTransformMakeRotation( M_PI+89.55 );
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:CGRegular size:textSize-3];
    label.textColor = [UIColor whiteColor];
    [viewLineChart addSubview:label];
    
    chartTemp = [[LineChartView alloc] init];
    chartTemp.frame = CGRectMake(20, viewLineChart.frame.size.height/2, DEVICE_WIDTH-20, viewLineChart.frame.size.height/2 );
    chartTemp.backgroundColor = [UIColor clearColor];
    chartTemp.delegate = self;
    chartTemp.layer.borderColor = [UIColor whiteColor].CGColor;
    chartTemp.layer.borderWidth = 0.5;
    chartTemp.tag = 222;
    [viewLineChart addSubview:chartTemp];

    UILabel * lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(-88, (viewLineChart.frame.size.height/2)+120, 200, 20)];
    [lblTemp setBackgroundColor:[UIColor clearColor]];
    [lblTemp setText:[NSString stringWithFormat:@"Temperature in Celsius"]];
    lblTemp.transform=CGAffineTransformMakeRotation( M_PI+89.55 );
    lblTemp.textAlignment = NSTextAlignmentCenter;
    lblTemp.font = [UIFont fontWithName:CGRegular size:textSize-3];
    lblTemp.textColor = [UIColor whiteColor];
    [viewLineChart addSubview:lblTemp];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"temperatureType"] isEqualToString:@"°F"])
    {
        [lblTemp setText:[NSString stringWithFormat:@"Temperature in Fehrenheit"]];
    }
    chartView.rightAxis.enabled = NO;
    chartTemp.rightAxis.enabled = NO;

    
    ChartLegend *l = chartView.legend;
    l.form = ChartLegendFormLine;
    l.font = [UIFont fontWithName:CGRegular size:11.f];
    l.textColor = UIColor.whiteColor;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;

    
    ChartLegend *lk = chartTemp.legend;
    lk.form = ChartLegendFormLine;
    lk.font = [UIFont fontWithName:CGRegular size:11.f];
    lk.textColor = UIColor.whiteColor;
    lk.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    lk.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    lk.orientation = ChartLegendOrientationHorizontal;
    lk.drawInside = NO;
    
    ChartXAxis *xAxis = chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont fontWithName:CGRegular size:10.f];
    xAxis.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    xAxis.drawAxisLineEnabled = NO;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.granularity = 1.0;
    xAxis.valueFormatter = [[DateValueFormatter alloc] init];
    
    ChartXAxis *xAxisTemp = chartTemp.xAxis;
    xAxisTemp.labelPosition = XAxisLabelPositionBottom;
    xAxisTemp.labelFont = [UIFont fontWithName:CGRegular size:10.f];
    xAxisTemp.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    xAxisTemp.drawAxisLineEnabled = NO;
    xAxisTemp.drawGridLinesEnabled = YES;
    xAxisTemp.centerAxisLabelsEnabled = YES;
    xAxisTemp.granularity = 1.0;
    xAxisTemp.valueFormatter = [[DateValueFormatter alloc] init];
    
    ChartYAxis *leftAxis = chartView.leftAxis;
    leftAxis.labelTextColor = [UIColor whiteColor];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawZeroLineEnabled = NO;

    ChartYAxis *leftAxisTemp = chartTemp.leftAxis;
    leftAxisTemp.labelTextColor = [UIColor whiteColor];
    leftAxisTemp.drawGridLinesEnabled = YES;
    leftAxisTemp.drawZeroLineEnabled = NO;
    leftAxisTemp.inverted = YES;

    [chartView animateWithXAxisDuration:2.5];
    [chartTemp animateWithXAxisDuration:2.5];
    
    markerDepth = [[BalloonMarker alloc]
              initWithColor: [UIColor blackColor]
              font: [UIFont systemFontOfSize:12.0]
              textColor: UIColor.whiteColor
              insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    markerDepth.chartView = chartView;
    markerDepth.minimumSize = CGSizeMake(80.f, 40.f);
    chartView.marker = markerDepth;
    
    markerTemp = [[BalloonMarker alloc]
                   initWithColor: [UIColor blackColor]
                   font: [UIFont systemFontOfSize:12.0]
                   textColor: UIColor.whiteColor
                   insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    markerTemp.chartView = chartTemp;
    markerTemp.minimumSize = CGSizeMake(80.f, 40.f);
    chartTemp.marker = markerTemp;

    [self updateChartData];

}
- (void)updateChartData
{
    [self setDataCountforSingleDive];
}
- (void)setDataCountforTemperature:(int)count range:(double)range
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dataArr count]; i++)
    {
        double val = [[[dataArr objectAtIndex:i] valueForKey:strTempType] doubleValue];
        [yVals1 addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
    }
    
    if (isCompared)
    {
        for (int i = 0; i < [data2Arr count]; i++)
        {
            double val = [[[data2Arr objectAtIndex:i] valueForKey:strTempType] doubleValue];
            [yVals2 addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
        }
    }
    
    LineChartDataSet *set1 = nil, *set2 = nil;
    if (chartTemp.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)chartTemp.data.dataSets[0];
        set1.values = yVals1;
        if (isCompared)
        {
            set2 = (LineChartDataSet *)chartTemp.data.dataSets[1];
            set2.values = yVals2;
        }
        [chartTemp.data notifyDataChanged];
        [chartTemp notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:yVals1 label:@"Dive 1"];
        [self setPropertyforDive1:set1];
        
        if (isCompared)
        {
            set2 = [[LineChartDataSet alloc] initWithValues:yVals2 label:@"Dive 2"];
            set2.axisDependency = AxisDependencyLeft;
            [set2 setColor:Dive2_Color];
            [set2 setCircleColor:Dive2_Color];
            set2.lineWidth = 2.0;
            set2.circleRadius = 3.0;
            set2.fillAlpha = 65/255.0;
            set2.fillColor = Dive2_Color;
            set2.highlightColor = Dive2_Color;
            set2.drawCircleHoleEnabled = NO;
        }
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        if (isCompared)
        {
            [dataSets addObject:set2];
        }
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        chartTemp.data = data;
    }
}
- (void)setDataCountforSingleDive
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dataArr count]; i++)
    {
        double val = [[[dataArr objectAtIndex:i] valueForKey:@"pressure_depth"] doubleValue];
        if (i==0)
        {
            globFirstDate = [[[dataArr objectAtIndex:i] valueForKey:@"utc_time"] doubleValue]/1000;
        }
        [yVals1 addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
    }
    
    if (isCompared)
    {
        for (int i = 0; i < [data2Arr count]; i++)
        {
            double val = [[[data2Arr objectAtIndex:i] valueForKey:@"pressure_depth"] doubleValue];
            [yVals2 addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
        }
    }
    
    LineChartDataSet *set1 = nil, *set2 = nil;
    if (chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)chartView.data.dataSets[0];
        set1.values = yVals1;
        
        if (isCompared)
        {
            set2 = (LineChartDataSet *)chartView.data.dataSets[1];
            set2.values = yVals2;
        }
        [chartView.data notifyDataChanged];
        [chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:yVals1 label:@"Dive 1"];
        [self setPropertyforDive1:set1];
        if (isCompared)
        {
            set2 = [[LineChartDataSet alloc] initWithValues:yVals2 label:@"Dive 2"];
            set2.axisDependency = AxisDependencyLeft;
            [set2 setColor:Dive2_Color];
            [set2 setCircleColor:Dive2_Color];
            set2.lineWidth = 2.0;
            set2.circleRadius = 3.0;
            set2.fillAlpha = 65/255.0;
            set2.fillColor = Dive2_Color;
            set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
            set2.drawCircleHoleEnabled = NO;
        }
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        if (isCompared)
        {
            [dataSets addObject:set2];
        }
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        chartView.data = data;
    }
    [self setDataCountforTemperature:40 range:70];
}

-(void)setPropertyforDive1:(LineChartDataSet *)set1
{
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:Dive1_Color];
    [set1 setCircleColor:Dive1_Color];
    set1.lineWidth = 2.0;
    set1.circleRadius = 3.0;
    set1.fillAlpha = 65/255.0;
    set1.fillColor = Dive1_Color;
    set1.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set1.drawCircleHoleEnabled = NO;
}
-(void)setPropertyforDive2:(LineChartDataSet *)set2
{
    set2.axisDependency = AxisDependencyLeft;
    [set2 setColor:Dive2_Color];
    [set2 setCircleColor:Dive2_Color];
    set2.lineWidth = 2.0;
    set2.circleRadius = 3.0;
    set2.fillAlpha = 65/255.0;
    set2.fillColor = Dive2_Color;
    set2.highlightColor = [UIColor colorWithRed:244/255.f green:117/255.f blue:117/255.f alpha:1.f];
    set2.drawCircleHoleEnabled = NO;
}
#pragma mark - ChartViewDelegate
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    if(chartView.tag == 111)
    {
        [markerDepth setLabel:[NSString stringWithFormat:@"%.02f at %@",entry.y,[APP_DELEGATE GetLocalTimefromUTC:[[dataArr objectAtIndex:entry.x] valueForKey:@"utc_time"]]]];
    }
    else if (chartView.tag == 222)
    {
        [markerTemp setLabel:[NSString stringWithFormat:@"%.02f at %@",entry.y,[APP_DELEGATE GetLocalTimefromUTC:[[dataArr objectAtIndex:entry.x] valueForKey:@"utc_time"]]]];
    }
    else if (chartView.tag == 333)
    {
        [markerHeat setLabel:[NSString stringWithFormat:@"%.02f at %@",entry.y,[APP_DELEGATE GetLocalTimefromUTC:[[dataArr objectAtIndex:entry.x] valueForKey:@"utc_time"]]]];
    }
    NSLog(@"chartValueSelected =%@",[APP_DELEGATE GetLocalTimefromUTC:[[dataArr objectAtIndex:entry.x] valueForKey:@"utc_time"]]);
}
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)GetLocalTimefromUTC:(NSString *)strValue
{
//    double timeStamp = [strValue doubleValue];
//    NSTimeInterval unixTimeStamp = timeStamp;
//    NSDate *exactDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
//
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = [NSString stringWithFormat:@"YYYY-MM-DD HH:mm:ss"];
//    NSString * strDateform = [dateFormatter stringFromDate:exactDate];
//
//    dateFormatter.dateFormat = [NSString stringWithFormat:@"%@ HH:mm:ss",[[NSUserDefaults standardUserDefaults] valueForKey:@"dateFormat"]];
//    NSDate  *finalate = [dateFormatter dateFromString:strDateform];
    
    double timeStamp = [strValue doubleValue]/1000;
    NSTimeInterval timeInterval=timeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm:ss",[[NSUserDefaults standardUserDefaults] valueForKey:@"dateFormat"]]];
    NSString *dateString=[dateformatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",dateString];
}
#pragma mark - SETUP for LINE CHART
-(void)SetupForHeatMap
{
    [viewHeat removeFromSuperview];
    viewHeat = [[UIView alloc] init];
    viewHeat.frame = CGRectMake(0, finalYY + 40, DEVICE_WIDTH, DEVICE_HEIGHT-finalYY-40);
    viewHeat.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewHeat];
    
    if (IS_IPHONE_X)
    {
        viewHeat.frame = CGRectMake(0, finalYY + 40, DEVICE_WIDTH, DEVICE_HEIGHT-finalYY-40-40);
    }
    chartHeat = [[LineChartView alloc] init];
    chartHeat.frame = CGRectMake(18, 0, DEVICE_WIDTH-22, viewHeat.frame.size.height-50 );
    chartHeat.backgroundColor = [UIColor clearColor];
    chartHeat.delegate = self;
    chartHeat.tag = 333;
    chartHeat.layer.borderColor = [UIColor whiteColor].CGColor;
    chartHeat.layer.borderWidth = 0.5;
    [viewHeat addSubview:chartHeat];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-138, 125, 300, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"Temperature in Celsius"];
    label.transform=CGAffineTransformMakeRotation( M_PI+89.55 );
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:CGRegular size:textSize-3];
    label.textColor = [UIColor whiteColor];
    [viewHeat addSubview:label];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"temperatureType"] isEqualToString:@"°F"])
    {
        [label setText:[NSString stringWithFormat:@"Temperature in Fehrenheit"]];
    }
    
    UIView * infoView = [[UIView alloc] init];
    infoView.frame = CGRectMake(0, viewHeat.frame.size.height-48, DEVICE_WIDTH, 50);
    infoView.backgroundColor = [UIColor clearColor];
    [viewHeat addSubview:infoView];
    
    int xx = 15;
    int yy = 0;
    int cnt = 0;
    int vWidth = (DEVICE_WIDTH/2);
    int vHeighth = 15;
    
    NSArray * nameArr = [NSArray arrayWithObjects:@"48 C to 56 C",@"30 C to 48 C",@"10 C to 48 C",@"-10 C to 10 C",@"-40 C to -10 C",@"-40 C to -10 C", nil];

    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    tmpArr = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"HeatMapValues"] mutableCopy];
    
    NSArray * colorArr = [NSArray arrayWithObjects:[UIColor colorWithRed:250/255.0f green:83/255.0f blue:46/255.0f alpha:1.0f], [UIColor colorWithRed:250/255.0f green:252/255.0f blue:93/255.0f alpha:1.0f],[UIColor colorWithRed:0/255.0f green:37/255.0f blue:254/255.0f alpha:1.0f],[UIColor colorWithRed:17/255.0f green:255/255.0f blue:253/255.0f alpha:1.0f],[UIColor colorWithRed:191/255.0f green:65/255.0f blue:255/255.0f alpha:1.0f],[UIColor colorWithRed:191/255.0f green:65/255.0f blue:255/255.0f alpha:1.0f],nil];
    
    for (int i=0; i<3; i++)
    {
        xx=15;
        for (int j=0; j<2; j++)
        {
            if (cnt == 5)
            {
                break;
            }
            UILabel * lblTmp = [[UILabel alloc] init];
            lblTmp.frame = CGRectMake(xx, yy, vWidth, vHeighth);
            lblTmp.backgroundColor = [UIColor clearColor];
            lblTmp.userInteractionEnabled = YES;
            lblTmp.text = @" ";
            [infoView addSubview:lblTmp];
            
            UILabel * lblColor = [[UILabel alloc] init];
            lblColor.frame = CGRectMake(5,2.5,10,10);
            lblColor.backgroundColor = [colorArr objectAtIndex:cnt];
            lblColor.layer.masksToBounds = YES;
            lblColor.layer.cornerRadius = 5;
            lblColor.layer.borderColor = (__bridge CGColorRef _Nullable)([colorArr objectAtIndex:cnt]);
            [lblTmp addSubview:lblColor];
            
            UILabel * lblName = [[UILabel alloc] init];
            lblName.frame = CGRectMake(20, 0, vWidth, 15);
            [lblName setFont:[UIFont fontWithName:CGRegular size:textSize-2]];
            lblName.textColor = [UIColor whiteColor];
            lblName.text = [NSString stringWithFormat:@"%@",[nameArr objectAtIndex:cnt]];
            [lblTmp addSubview:lblName];
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"temperatureType"] isEqualToString:@"°F"])
            {
                lblName.text = [NSString stringWithFormat:@"%@ºF to %@ºF",[[tmpArr objectAtIndex:cnt] valueForKey:@"lowF"],[[tmpArr objectAtIndex:cnt] valueForKey:@"highF"]];
            }
            else
            {
                lblName.text = [NSString stringWithFormat:@"%@ºC to %@ºC",[[tmpArr objectAtIndex:cnt] valueForKey:@"lowC"],[[tmpArr objectAtIndex:cnt] valueForKey:@"highC"]];
            }
            
            xx = vWidth + xx;
            cnt = cnt +1;
        }
        yy = yy + vHeighth + 1 ;
    }

    chartHeat.rightAxis.enabled = NO;
    
    
    ChartLegend *l = chartHeat.legend;
    l.form = ChartLegendFormLine;
    l.font = [UIFont fontWithName:CGRegular size:11.f];
    l.textColor = UIColor.whiteColor;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    
    ChartXAxis *xAxis = chartHeat.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont fontWithName:CGRegular size:10.f];
    xAxis.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    xAxis.drawAxisLineEnabled = NO;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.granularity = 1.0;
    xAxis.valueFormatter = [[DateValueFormatter alloc] init];
    
    ChartYAxis *leftAxis = chartHeat.leftAxis;
    leftAxis.labelTextColor = [UIColor whiteColor];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawZeroLineEnabled = NO;
    
    [chartHeat animateWithXAxisDuration:2.5];
    
    markerHeat = [[BalloonMarker alloc]
                             initWithColor: [UIColor blackColor]
                             font: [UIFont systemFontOfSize:12.0]
                             textColor: UIColor.whiteColor
                             insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    markerHeat.chartView = chartHeat;
    markerHeat.minimumSize = CGSizeMake(80.f, 40.f);
    chartHeat.marker = markerHeat;

    [self UpdateHeatMapData];
}
-(void)UpdateHeatMapData
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    
    NSMutableArray * colors1Arr = [[NSMutableArray alloc] init];
    NSMutableArray * colors2Arr = [[NSMutableArray alloc] init];

    for (int i = 0; i < [dataArr count]; i++)
    {
        double val = [[[dataArr objectAtIndex:i] valueForKey:strTempType] doubleValue];
        [yVals1 addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
        [colors1Arr addObject:[self GetColorbasedonTemp:val]];
    }
    
    if (isCompared)
    {
        
        for (int i = 0; i < [data2Arr count]; i++)
        {
            double val = [[[data2Arr objectAtIndex:i] valueForKey:strTempType] doubleValue];
            [yVals2 addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
            [colors2Arr addObject:[self GetColorbasedonTemp:val]];
        }
    }
    
    LineChartDataSet *set1 = nil, *set2 = nil;
    if (chartHeat.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)chartHeat.data.dataSets[0];
        set1.values = yVals1;
        if (isCompared)
        {
            set2 = (LineChartDataSet *)chartHeat.data.dataSets[1];
            set2.values = yVals2;
        }
        [chartTemp.data notifyDataChanged];
        [chartTemp notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:yVals1 label:@"Dive 1"];
        set1.axisDependency = AxisDependencyLeft;
        [set1 setColor:[UIColor grayColor]];
        [set1 setCircleColor:[UIColor grayColor]];
        set1.lineWidth = 2.0;
        set1.circleRadius = 3.0;
        set1.fillAlpha = 65/255.0;
        set1.fillColor = [UIColor grayColor];
        set1.highlightColor = [UIColor grayColor];
        set1.drawCircleHoleEnabled = NO;
        [set1 setCircleColors:colors1Arr];
        
        if (isCompared)
        {
            set2 = [[LineChartDataSet alloc] initWithValues:yVals2 label:@"Dive 2"];
            set2.axisDependency = AxisDependencyLeft;
            [set2 setColor:[UIColor whiteColor]];
            [set2 setCircleColor:[UIColor whiteColor]];
            set2.lineWidth = 2.0;
            set2.circleRadius = 3.0;
            set2.fillAlpha = 65/255.0;
            set2.fillColor = [UIColor whiteColor];
            set2.highlightColor = [UIColor whiteColor];
            set2.drawCircleHoleEnabled = NO;
            [set2 setCircleColors:colors2Arr];
        }
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        if (isCompared)
        {
            [dataSets addObject:set2];
        }
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont systemFontOfSize:9.f]];
        
        chartHeat.data = data;
    }
}
-(UIColor *)GetColorbasedonTemp:(double)val
{
    
    for (int i =0; i<[mapSettingArr count]; i++)
    {
        double valH = [[[mapSettingArr objectAtIndex:i] valueForKey:@"highC"] doubleValue]+1;
        double valL = [[[mapSettingArr objectAtIndex:i] valueForKey:@"lowC"] doubleValue];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"temperatureType"] isEqualToString:@"°F"])
        {
             valH = [[[mapSettingArr objectAtIndex:i] valueForKey:@"highF"] doubleValue]+1;
             valL = [[[mapSettingArr objectAtIndex:i] valueForKey:@"lowF"] doubleValue];
        }
        if (val >= valL && val <= valH)
        {
            return [colorArr objectAtIndex:i];
            break;
        }
    }
    return [UIColor redColor];
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
