//
//  ConfigureSensorVC.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "ConfigureSensorVC.h"
#import "ConfigureSensorCustomCell.h"
#import "MNMPullToRefreshManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEManager.h"
#import "DataBaseManager.h"
#import "MapClassVC.h"

@interface ConfigureSensorVC ()<MNMPullToRefreshManagerClient,CBCentralManagerDelegate>
{
    MNMPullToRefreshManager * topPullToRefreshManager;
    CBPeripheral * myPeripheral;
    int connectionCount;
    BOOL isConnecting;
    NSString * strSelectedBLEAddress;
    CBCentralManager *centralManager;
    NSMutableDictionary * bleRememberDict;
    UILabel *lblConnectedDevice;
    NSTimer * connectionTimer;
    BOOL isManualGPSCall;
    UIButton * btnGPSHrs, * btnGPSMins;
    BOOL isGpsMinute, isleftscreen;
    URBAlertView * alertGPSPopup;
    NSMutableArray * arrayData;
}
@end

@implementation ConfigureSensorVC

- (void)viewDidLoad
{
    arrayData = [[NSMutableArray alloc]init];
    
    NSArray * tmpArr = [[NSArray alloc]initWithObjects:@"1280",@"256",@"3584",@"1024",@"1792",@"NA",@"NA",@"NA", nil];
    NSArray * tmpArr2 = [[NSArray alloc]initWithObjects:@"FreqDepth",@"FreqInterval",@"BleTransmission",@"GPSintervalMM",@"GPStimeOut",@"UTCTime",@"BatteryLevel",@"DeviceMemory", nil];
    NSMutableDictionary * tmpDict2;
    for (int i = 0; i<tmpArr2.count; i++)
    {
       tmpDict2 = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",@"isChanged",@"NA",[tmpArr2 objectAtIndex:i],[tmpArr objectAtIndex:i],@"opcode", nil];
        [arrayData addObject:tmpDict2];
    }
    [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalHH"];
    [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalMM"];
    [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalSS"];
    [[arrayData objectAtIndex:1]removeObjectForKey:@"FreqInterval"];
    [[arrayData objectAtIndex:3]setValue:@"NA" forKey:@"GPSintervalHH"];

    isBtnBelowWaterClicked = true;
    isbtnPressureSelectClicked = true;
    isBtnTimeClicked = true;
    
    pairedDevicesArray = [[NSMutableArray alloc]init];
    connectedDevice = [[NSMutableArray alloc] init];
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    isGpsMinute = YES;
    [self setNavigationViewFrames];
    [self setMainViewFrames];
    
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
    [topPullToRefreshManager setPullToRefreshViewVisible:NO];
    
//    arrContent = [[NSMutableArray alloc] init];
//    NSArray * arrData = [NSArray arrayWithObjects:@"UTC Time",@"Battery Level", @"Device Memory",@"Firmware Version",@"Erase Device Data?", nil];
//    for (int i =0; i<[arrData count]; i++)
//    {
//        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//        [dict setObject:[arrData objectAtIndex:i] forKey:@"keys"];
//        if (i==0)
//        {
//            [dict setObject:@"NA" forKey:@"values"];
//        }
//        else
//        {
//            [dict setObject:@"0" forKey:@"values"];
//        }
//        [arrContent addObject:dict];
//    }
    [super viewDidLoad];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    
    [self InitialBLE];
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateBattery" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateBattery:) name:@"UpdateBattery" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateMemory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMemory:) name:@"updateMemory" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateVersion" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVersion:) name:@"updateVersion" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUTCtime" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUTCtime:) name:@"updateUTCtime" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateManualBattery" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateManualBattery:) name:@"UpdateManualBattery" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateFrequencyInterval" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateFrequencyInterval:) name:@"UpdateFrequencyInterval" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateDepthCutOff" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateDepthCutOff:) name:@"UpdateDepthCutOff" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateBLETransmission" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateBLETransmission:) name:@"UpdateBLETransmission" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"forSuddenDisconnection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forSuddenDisconnection) name:@"forSuddenDisconnection" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SyncedSuccessfully" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SyncedSuccessfully) name:@"SyncedSuccessfully" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoDataFoundMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoDataFoundMessage) name:@"NoDataFoundMessage" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateGPSInterval" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateGPSInterval:) name:@"UpdateGPSInterval" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateGPSTimeOut" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateGPSTimeOut:) name:@"UpdateGPSTimeOut" object:nil];


    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateCurrentGPSlocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateCurrentGPSlocation:) name:@"UpdateCurrentGPSlocation" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startProcess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startProcess) name:@"startProcess" object:nil];

    
    if (isCentralAssigned == NO)
    {
        centralManager = nil;
        centralManager.delegate = nil;
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        isCentralAssigned = YES;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforDiscover" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeviceDidDisConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeviceDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateBattery" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateMemory" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateVersion" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUTCtime" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateManualBattery" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateFrequencyInterval" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateDepthCutOff" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"forSuddenDisconnection" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateBLETransmission" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SyncedSuccessfully" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NoDataFoundMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateGPSInterval" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateGPSTimeOut" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateCurrentGPSlocation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startProcess" object:nil];

    [super viewWillDisappear:YES];
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Configure Sensor"];
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
    
    imgRefresh = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-30, 20+13, 18, 18)];
    [imgRefresh setImage:[UIImage imageNamed:@"ic_sync.png"]];
    [imgRefresh setContentMode:UIViewContentModeScaleAspectFit];
    imgRefresh.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:imgRefresh];
    
    refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    refreshBtn.frame = CGRectMake(DEVICE_WIDTH-60, 0, 60, 64);
    refreshBtn.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:refreshBtn];
    
    mapImg = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-35, 20+9, 25, 25)];
    [mapImg setImage:[UIImage imageNamed:@"map.png"]];
    [mapImg setContentMode:UIViewContentModeScaleAspectFit];
    mapImg.backgroundColor = [UIColor clearColor];
    mapImg.hidden = YES;
    [viewHeader addSubview:mapImg];
    
    btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMap addTarget:self action:@selector(btnMapClick) forControlEvents:UIControlEventTouchUpInside];
    btnMap.frame = CGRectMake(DEVICE_WIDTH-65, 0, 70, 64);
    btnMap.backgroundColor = [UIColor clearColor];
    btnMap.hidden = YES;
    [self.view addSubview:btnMap];

    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
        imgRefresh.frame = CGRectMake(DEVICE_WIDTH-30, 44+13, 18, 18);
        refreshBtn.frame = CGRectMake(DEVICE_WIDTH-60, 0, 60, 88);
        mapImg.frame = CGRectMake(DEVICE_WIDTH-35, 44+9, 25, 25);
        btnMap.frame = CGRectMake(DEVICE_WIDTH-65, 0, 70, 88);
    }
}
-(void)setMainViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 88;
    }
    
    blueSegmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"Pair Device", @"Device Settings"]];
    blueSegmentedControl.titleTextColor = [UIColor blackColor];
    blueSegmentedControl.selectedTitleTextColor = [UIColor whiteColor];
    blueSegmentedControl.segmentIndicatorBackgroundColor = [UIColor blackColor];
    blueSegmentedControl.backgroundColor = [UIColor whiteColor];
    blueSegmentedControl.borderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorInset = 2.0f;
    blueSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
    blueSegmentedControl.cornerRadius = 20;
    blueSegmentedControl.usesSpringAnimations = YES;
    [blueSegmentedControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    [blueSegmentedControl setFrame:CGRectMake(0,yy, DEVICE_WIDTH-0, 40)];
    blueSegmentedControl.layer.cornerRadius = 20;
    blueSegmentedControl.layer.masksToBounds = YES;
    blueSegmentedControl.titleFont = [UIFont fontWithName:CGRegular size:textSize];
    blueSegmentedControl.selectedTitleFont = [UIFont fontWithName:CGRegular size:textSize];
    [self.view addSubview:blueSegmentedControl];
    
    // List View //
    
    listView = [[UIView alloc]init];
    listView.frame = CGRectMake(0, yy+40, DEVICE_WIDTH, DEVICE_HEIGHT-yy-40);
    listView.backgroundColor = UIColor.clearColor;
    listView.hidden = false;
    [self.view addSubview:listView];
    
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH,listView.frame.size.height) style:UITableViewStylePlain];
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.backgroundColor = [UIColor clearColor];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.separatorColor = [UIColor darkGrayColor];
    [listView addSubview:tblContent];
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblContent withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
    
    // Settings View //
    settingsView = [[UIScrollView alloc]init];
    settingsView.frame = CGRectMake(0, yy+40, DEVICE_WIDTH, DEVICE_HEIGHT-yy-50);
    settingsView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    settingsView.userInteractionEnabled = YES;
    settingsView.hidden = true;
    settingsView.scrollEnabled = false;
    [self.view addSubview:settingsView];
    if (IS_IPHONE_4)
    {
        settingsView.scrollEnabled = true;
        settingsView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT+90);
    }
    else if (IS_IPHONE_5)
    {
        settingsView.scrollEnabled = true;
        settingsView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    }
    else if (IS_IPHONE_X)
    {
        settingsView.contentSize = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT-100);
    }
    yy = 5;
    
    [backViewShadow removeFromSuperview];
    backViewShadow = [[UIView alloc]init];
    backViewShadow.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    backViewShadow.backgroundColor = UIColor.blackColor;
    backViewShadow.alpha = 0.4;
    backViewShadow.hidden = true;
    [self.view addSubview:backViewShadow];
    
    lblConnectedDevice = [[UILabel alloc]init];
    lblConnectedDevice.frame = CGRectMake(5, yy, DEVICE_WIDTH-10, 20);
    lblConnectedDevice.text = @"Connected Device : Test Dev12";
    lblConnectedDevice.font = [UIFont fontWithName:CGRegular size:textSize-1];
    lblConnectedDevice.textColor = UIColor.whiteColor;
    lblConnectedDevice.textAlignment = NSTextAlignmentRight;
    lblConnectedDevice.backgroundColor = UIColor.clearColor;
    [settingsView addSubview:lblConnectedDevice];
    lblConnectedDevice.hidden = YES;
   
    
    yy = yy+20;
    btnBelowWater = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBelowWater setTitle:@"Below Water" forState:UIControlStateNormal];
    [btnBelowWater setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    btnBelowWater.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+4];
    btnBelowWater.frame = CGRectMake(5,yy,200 , 25);
    btnBelowWater.tag = 1;
//    [btnBelowWater addTarget:self action:@selector(btnBelowWaterAction) forControlEvents:UIControlEventTouchUpInside];
    btnBelowWater.backgroundColor = [UIColor clearColor];
    btnBelowWater.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [settingsView addSubview:btnBelowWater];
    
    if (IS_IPHONE_6plus || IS_IPHONE_X)
    {
        btnBelowWater.frame = CGRectMake(5,yy,200 , 30);
        yy = yy+35;
    }
    else
    {
        yy = yy+30;
    }
    
    viewBelowWater = [[UIView alloc]init];
    viewBelowWater.frame = CGRectMake(0, yy,DEVICE_WIDTH, DEVICE_HEIGHT-yy);
    viewBelowWater.backgroundColor = UIColor.clearColor;
    viewBelowWater.hidden = false;
    [settingsView addSubview:viewBelowWater];
    
    yy = 0;
    
    UILabel * lblReportDepthView = [[UILabel alloc]init];
    lblReportDepthView.backgroundColor = UIColor.blackColor;
    lblReportDepthView.alpha = 0.4;
    lblReportDepthView.frame = CGRectMake(0,yy,DEVICE_WIDTH , 44);
    [viewBelowWater addSubview:lblReportDepthView];
    
    lblPressureSelect = [[UILabel alloc]init];
    lblPressureSelect.text = @"Reporting Frequency Depth :";
    lblPressureSelect.textColor = UIColor.whiteColor;
    lblPressureSelect.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblPressureSelect.frame = CGRectMake(5,yy,DEVICE_WIDTH - 70 , 44);
    lblPressureSelect.backgroundColor = [UIColor clearColor];
    [viewBelowWater addSubview:lblPressureSelect];
    
    lblReportPicker = [[UILabel alloc]init];
    lblReportPicker.textColor = UIColor.greenColor;
    lblReportPicker.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblReportPicker.frame = CGRectMake(DEVICE_WIDTH- 80,yy+3,50, 38);
    lblReportPicker.backgroundColor = [UIColor clearColor];
    [viewBelowWater addSubview:lblReportPicker];
    lblReportPicker.text = @"1.0m";

    UIButton * btnReportPicker  = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReportPicker.frame = CGRectMake(DEVICE_WIDTH- 150,yy,150, 44);
        [btnReportPicker addTarget:self action:@selector(btnReportPickerAction) forControlEvents:UIControlEventTouchUpInside];
    btnReportPicker.backgroundColor = [UIColor clearColor];
    [viewBelowWater addSubview:btnReportPicker];
    
    UIImageView * imgArrow3 = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH- 30,yy+20,12, 7)];
    imgArrow3.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow3.backgroundColor = UIColor.clearColor;
    [viewBelowWater addSubview:imgArrow3];
    
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_pre_depth_cut_off"];
    reportArray= [[NSMutableArray alloc]init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:reportArray];
    if ([reportArray count]==0)
    {
        [self setCutoffArrayManually];
    }
    if (IS_IPHONE_6plus || IS_IPHONE_X)
    {
        yy = yy+44+10;
    }
    else
    {
        yy = yy+44+5;
    }
    
    UILabel * lblReportIntervalView = [[UILabel alloc]init];
    lblReportIntervalView.backgroundColor = UIColor.blackColor;
    lblReportIntervalView.alpha = 0.4;
    lblReportIntervalView.frame = CGRectMake(0,yy,DEVICE_WIDTH , 25+100);
    [viewBelowWater addSubview:lblReportIntervalView];
    
    lblTimeSelect = [[UILabel alloc]init];
    lblTimeSelect.text = @"Reporting Frequency Interval : ";
    lblTimeSelect.textColor = UIColor.whiteColor;
    lblTimeSelect.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblTimeSelect.frame = CGRectMake(5,yy,DEVICE_WIDTH-70 , 44);
    lblTimeSelect.backgroundColor = [UIColor clearColor];
    [viewBelowWater addSubview:lblTimeSelect];
    
    lblFreqTimeDisplay = [[UILabel alloc]init];
    lblFreqTimeDisplay.frame = CGRectMake(DEVICE_WIDTH-75, yy, 75, 44);
    lblFreqTimeDisplay.backgroundColor = UIColor.clearColor;
    lblFreqTimeDisplay.textColor = UIColor.greenColor;
    lblFreqTimeDisplay.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblFreqTimeDisplay.text =[NSString stringWithFormat:@"1 Hr"];
    [viewBelowWater addSubview:lblFreqTimeDisplay];
    
    strIntervalType = @"H";
    yy = yy+44-5;
    viewTimeInterval = [[UIView alloc] init];
    viewTimeInterval.frame = CGRectMake(0, yy, DEVICE_WIDTH, 100);
    viewTimeInterval.backgroundColor = [UIColor clearColor];
    viewTimeInterval.hidden = NO;
    [viewBelowWater addSubview:viewTimeInterval];
    
    btnHrs = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHrs setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
    [btnHrs setTitle:@"  Hour" forState:UIControlStateNormal];
    [btnHrs setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnHrs.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnHrs.frame = CGRectMake(0,0,DEVICE_WIDTH/3, 35);
    btnHrs.tag = 1;
    [btnHrs addTarget:self action:@selector(btnTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    [viewTimeInterval addSubview:btnHrs];
    btnHrs.backgroundColor = [UIColor clearColor];
    btnHrs.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    int zz = 5+100;
    btnMins = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMins setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
    [btnMins setTitle:@"  Minutes" forState:UIControlStateNormal];
    [btnMins setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnMins.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnMins.frame = CGRectMake(DEVICE_WIDTH/3 ,0,DEVICE_WIDTH/3 , 35);
    btnMins.tag = 2;
    [btnMins addTarget:self action:@selector(btnTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    [viewTimeInterval addSubview:btnMins];
    btnMins.backgroundColor = [UIColor clearColor];
    btnMins.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    zz = zz+100;
    btnSecs = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSecs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
    [btnSecs setTitle:@"  Second" forState:UIControlStateNormal];
    [btnSecs setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSecs.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
    btnSecs.frame = CGRectMake((DEVICE_WIDTH/3)*2 ,0,DEVICE_WIDTH/3 , 35);
    btnSecs.tag = 3;
    [btnSecs addTarget:self action:@selector(btnTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    [viewTimeInterval addSubview:btnSecs];
    btnSecs.backgroundColor = [UIColor clearColor];
    btnSecs.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    btnIntervalValue = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnIntervalValue setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnIntervalValue.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnIntervalValue.frame = CGRectMake(5,44,DEVICE_WIDTH-10, 35);
    btnIntervalValue.backgroundColor = [UIColor clearColor];
    btnIntervalValue.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnIntervalValue addTarget:self action:@selector(btnIntervalValueAction) forControlEvents:UIControlEventTouchUpInside];
    [viewTimeInterval addSubview:btnIntervalValue];
    btnIntervalValue.layer.borderWidth = 1;
    [btnIntervalValue setTitle:@"Click Here To Change" forState:UIControlStateNormal] ;
    btnIntervalValue.layer.borderColor = [UIColor whiteColor].CGColor;
    btnIntervalValue.layer.cornerRadius = 5;
    btnIntervalValue.titleLabel.numberOfLines = 0;
    
    UIImageView * imgArrow4 = [[UIImageView alloc]initWithFrame:CGRectMake(btnIntervalValue.frame.size.width-15,(btnIntervalValue.frame.size.height/2)-3, 12, 7)];
    imgArrow4.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow4.backgroundColor = UIColor.clearColor;
    [btnIntervalValue addSubview:imgArrow4];
    
    arrDatePickerHH = [[NSMutableArray alloc]init];
    for (int i=0; i<4;i++)
    {
        [arrDatePickerHH addObject:[NSString stringWithFormat:@"%d",i+1]];
    }
    arrDatePickerMM = [[NSMutableArray alloc]init];
    for (int i=5; i<60;i++)
    {
        [arrDatePickerMM addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    arrGpsSecondMin = [[NSMutableArray alloc] init];
    for (int i=0; i<61;i++)
    {
        [arrGpsSecondMin addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    arrDatePickerSS = [[NSMutableArray alloc]init];
    for (int i=1; i<299;i++)
    {
        [arrDatePickerSS addObject:[NSString stringWithFormat:@"%d",i]];
    }
    if (IS_IPHONE_6plus || IS_IPHONE_X)
    {
        yy = yy+100+44+5;
    }
    else
    {
        yy = yy+100+44;
    }
    UILabel* lblAboveWater = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,215*approaxSize, 25)];
    lblAboveWater.textColor = UIColor.grayColor;
    lblAboveWater.backgroundColor = UIColor.clearColor;
    lblAboveWater.font = [UIFont fontWithName:CGRegular size:textSize+4];
    lblAboveWater.text = @"Above Water";
    [settingsView addSubview:lblAboveWater];
    
    lblVersionDisp = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-185,yy,185,25)];
    lblVersionDisp.textColor = UIColor.whiteColor;
    lblVersionDisp.backgroundColor = UIColor.clearColor;
    lblVersionDisp.font = [UIFont fontWithName:CGRegular size:textSize];
    lblVersionDisp.text = @"(Firmware Version : V0)";
    lblVersionDisp.numberOfLines = 1;
    [settingsView addSubview:lblVersionDisp];
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        lblVersionDisp.frame = CGRectMake(DEVICE_WIDTH-170,yy,170,25);
    }
    
   
    if (IS_IPHONE_6plus || IS_IPHONE_X)
    {
        lblAboveWater.frame = CGRectMake(5, yy,215*approaxSize, 30);
        lblVersionDisp.frame = CGRectMake(DEVICE_WIDTH-185,yy,185,30);
        yy = yy+40;
    }
    else
    {
        yy = yy+30;
    }

    UILabel * lblBleView = [[UILabel alloc]init];
    lblBleView.backgroundColor = UIColor.blackColor;
    lblBleView.alpha = 0.4;
    lblBleView.frame = CGRectMake(0,yy,DEVICE_WIDTH , 44);
    [settingsView addSubview:lblBleView];
    
    UILabel *lbTransmission = [[UILabel alloc]initWithFrame:CGRectMake(5, yy,DEVICE_WIDTH-140, 44)];
    lbTransmission.textColor = UIColor.whiteColor;
    lbTransmission.backgroundColor = UIColor.clearColor;
    lbTransmission.font = [UIFont fontWithName:CGRegular size:textSize];
    lbTransmission.text = @"Bluetooth Transmission :";
    lbTransmission.numberOfLines = 1;
    [settingsView addSubview:lbTransmission];
    
    lblBleTransmission = [[UILabel alloc]init];
    lblBleTransmission.textColor = UIColor.greenColor;
    lblBleTransmission.font = [UIFont fontWithName:CGRegular size:textSize];
    lblBleTransmission.frame = CGRectMake(DEVICE_WIDTH-165,yy,160, 44);
    lblBleTransmission.backgroundColor = [UIColor clearColor];
    lblBleTransmission.textAlignment = NSTextAlignmentCenter;
    [settingsView addSubview:lblBleTransmission];
    lblBleTransmission.text = @"Always";
    
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        lblBleTransmission.frame = CGRectMake(DEVICE_WIDTH-143,yy,125, 44);
    }
    UIImageView * imgArrow2 = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-18,yy+20, 12, 7)];
    imgArrow2.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrow2.backgroundColor = UIColor.clearColor;
    [settingsView addSubview:imgArrow2];
    
    UIButton * btnBleTransmission = [[UIButton alloc]init];
    btnBleTransmission.backgroundColor = UIColor.clearColor;
    btnBleTransmission.frame = CGRectMake(DEVICE_WIDTH-200,yy,200, 44);
    [btnBleTransmission addTarget:self action:@selector(btnBleTransmissionAction) forControlEvents:UIControlEventTouchUpInside];
    [settingsView addSubview:btnBleTransmission];
    
    if (IS_IPHONE_6plus || IS_IPHONE_X)
    {
        yy = yy+44+10;
    }
    else
    {
        yy = yy+44+5;
    }
    
    UILabel * lblGPSView = [[UILabel alloc]init];
    lblGPSView.backgroundColor = UIColor.blackColor;
    lblGPSView.alpha = 0.4;
    lblGPSView.frame = CGRectMake(0,yy,DEVICE_WIDTH , 65);
    [settingsView addSubview:lblGPSView];
    
    UILabel * lblInterval = [[UILabel alloc]initWithFrame:CGRectMake(5, yy+5,(DEVICE_WIDTH/2)-10, 25)];
    lblInterval.textColor = UIColor.whiteColor;
    lblInterval.backgroundColor = UIColor.clearColor;
    lblInterval.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblInterval.text = @"Set GPS Interval";
    lblInterval.textAlignment = NSTextAlignmentCenter;
    lblInterval.numberOfLines = 2;
    [settingsView addSubview:lblInterval];
    
    lblGPSInterval = [[UILabel alloc]init];
    lblGPSInterval.textColor = UIColor.greenColor;
    lblGPSInterval.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblGPSInterval.frame = CGRectMake(5, yy+30,(DEVICE_WIDTH/2)-10, 25);
    lblGPSInterval.backgroundColor = [UIColor clearColor];
    lblGPSInterval.textAlignment = NSTextAlignmentCenter;
    lblGPSInterval.text = @"0 Minutes";
    [settingsView addSubview:lblGPSInterval];
    
    UIButton * btnGPSInterval = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGPSInterval.frame = CGRectMake(5,yy+5,(DEVICE_WIDTH/2)-10 , 55);
    btnGPSInterval.backgroundColor = [UIColor clearColor];
    btnGPSInterval.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnGPSInterval addTarget:self action:@selector(btnGPSIntervalClick) forControlEvents:UIControlEventTouchUpInside];
    btnGPSInterval.layer.borderWidth = 1;
    btnGPSInterval.layer.borderColor = [UIColor whiteColor].CGColor;
    btnGPSInterval.layer.cornerRadius = 5;
    [settingsView addSubview:btnGPSInterval];
    
//    int gpsint = [[[NSUserDefaults standardUserDefaults] valueForKey:@"GPSInterval"] intValue];
//    if (gpsint >=60)
//    {
//        isGpsMinute = NO;
//        lblGPSInterval.text = [NSString stringWithFormat:@"%d Hours",gpsint/60];
//
//    }
//    indexGpsInterval = [arrGpsSecondMin indexOfObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"GPSInterval"]];
//    if (indexGpsInterval == NSNotFound)
//    {
//        indexGpsInterval = 0;
//    }

    UIImageView * imgArrowGps1 = [[UIImageView alloc]initWithFrame:CGRectMake(lblGPSInterval.frame.size.width-15,(lblGPSInterval.frame.size.height/2)-2, 12, 7)];
    imgArrowGps1.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrowGps1.backgroundColor = UIColor.clearColor;
    [lblGPSInterval addSubview:imgArrowGps1];
    
    
    UILabel * lblTimeOut = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/2)+5, yy+5,(DEVICE_WIDTH/2)-10, 25)];
    lblTimeOut.textColor = UIColor.whiteColor;
    lblTimeOut.backgroundColor = UIColor.clearColor;
    lblTimeOut.textAlignment = NSTextAlignmentCenter;
    lblTimeOut.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblTimeOut.text = @"Set GPS Timeout";
    lblTimeOut.numberOfLines = 2;
    [settingsView addSubview:lblTimeOut];
    
    lblGPSTimeout = [[UILabel alloc]init];
    lblGPSTimeout.textColor = UIColor.greenColor;
    lblGPSTimeout.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblGPSTimeout.frame = CGRectMake((DEVICE_WIDTH/2)+5, yy+30,(DEVICE_WIDTH/2)-10, 25);
    lblGPSTimeout.backgroundColor = [UIColor clearColor];
    lblGPSTimeout.textAlignment = NSTextAlignmentCenter;
    [settingsView addSubview:lblGPSTimeout];
    lblGPSTimeout.text = @"1 Minute";
    
    UIImageView * imgArrowGps2 = [[UIImageView alloc]initWithFrame:CGRectMake(lblGPSTimeout.frame.size.width-15,(lblGPSTimeout.frame.size.height/2)-2, 12, 7)];
    imgArrowGps2.image = [UIImage imageNamed:@"whiteArrow.png"];
    imgArrowGps2.backgroundColor = UIColor.clearColor;
    [lblGPSTimeout addSubview:imgArrowGps2];

    UIButton * btnGPSOut = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGPSOut.frame = CGRectMake((DEVICE_WIDTH/2)+5,yy+5,(DEVICE_WIDTH/2)-10 , 55);
    btnGPSOut.backgroundColor = [UIColor clearColor];
    btnGPSOut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnGPSOut addTarget:self action:@selector(btnlGPSTimeoutClick) forControlEvents:UIControlEventTouchUpInside];
    btnGPSOut.layer.borderWidth = 1;
    btnGPSOut.layer.borderColor = [UIColor whiteColor].CGColor;
    btnGPSOut.layer.cornerRadius = 5;
    [settingsView addSubview:btnGPSOut];
    
    bleTransmissionArray = [[NSMutableArray alloc]initWithObjects:@"Always",@"After dive 10 min", nil];
    
    if (IS_IPHONE_6plus || IS_IPHONE_X)
    {
        yy = yy + 75;
    }
    else
    {
        yy = yy + 70;
    }
    
    UILabel * lblUTCView = [[UILabel alloc]init];
    lblUTCView.backgroundColor = UIColor.blackColor;
    lblUTCView.alpha = 0.4;
    lblUTCView.frame = CGRectMake(0,yy,DEVICE_WIDTH , 65);
    [settingsView addSubview:lblUTCView];
    
    UILabel * lblUTCTime = [[UILabel alloc]initWithFrame:CGRectMake(5, yy+5,(DEVICE_WIDTH/2)-10, 25)];
    lblUTCTime.textColor = UIColor.whiteColor;
    lblUTCTime.backgroundColor = UIColor.clearColor;
    lblUTCTime.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblUTCTime.text = @"Set UTC Time";
    lblUTCTime.textAlignment = NSTextAlignmentCenter;
    lblUTCTime.numberOfLines = 2;
    [settingsView addSubview:lblUTCTime];
    
    lblTimeDisplay = [[UILabel alloc]init];
    lblTimeDisplay.textColor = UIColor.greenColor;
    lblTimeDisplay.font = [UIFont fontWithName:CGRegular size:textSize];
    lblTimeDisplay.frame = CGRectMake(5, yy+30,(DEVICE_WIDTH/2)-10, 25);
    lblTimeDisplay.backgroundColor = [UIColor clearColor];
    lblTimeDisplay.textAlignment = NSTextAlignmentCenter;
    lblTimeDisplay.text = @"NA";
    [settingsView addSubview:lblTimeDisplay];
    
    UIButton * btnUTCTime = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUTCTime.frame = CGRectMake(5,yy+5,(DEVICE_WIDTH/2)-10 , 55);
    btnUTCTime.backgroundColor = [UIColor clearColor];
    btnUTCTime.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnUTCTime addTarget:self action:@selector(btnUTCTimeClick) forControlEvents:UIControlEventTouchUpInside];
    btnUTCTime.layer.borderWidth = 1;
    btnUTCTime.layer.borderColor = [UIColor whiteColor].CGColor;
    btnUTCTime.layer.cornerRadius = 5;
    [settingsView addSubview:btnUTCTime];
    
    UILabel * lblBattery = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/2)+5, yy+5,(DEVICE_WIDTH/2)-10, 25)];
    lblBattery.textColor = UIColor.whiteColor;
    lblBattery.backgroundColor = UIColor.clearColor;
    lblBattery.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblBattery.text = @"Battery Level";
    lblBattery.textAlignment = NSTextAlignmentCenter;
    lblBattery.numberOfLines = 2;
    [settingsView addSubview:lblBattery];
    
    lblBatteryLevel = [[UILabel alloc]init];
    lblBatteryLevel.textColor = UIColor.greenColor;
    lblBatteryLevel.font = [UIFont fontWithName:CGRegular size:textSize];
    lblBatteryLevel.frame = CGRectMake((DEVICE_WIDTH/2)+5, yy+30,(DEVICE_WIDTH/2)-10, 25);
    lblBatteryLevel.backgroundColor = [UIColor clearColor];
    lblBatteryLevel.textAlignment = NSTextAlignmentCenter;
    lblBatteryLevel.text = @"0%";
    [settingsView addSubview:lblBatteryLevel];
    
    UIButton * btnBattery = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBattery.frame = CGRectMake((DEVICE_WIDTH/2)+5,yy+5,(DEVICE_WIDTH/2)-10 , 55);
    btnBattery.backgroundColor = [UIColor clearColor];
    btnBattery.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    [btnUTCTime addTarget:self action:@selector(btnBattery) forControlEvents:UIControlEventTouchUpInside];
    btnBattery.layer.borderWidth = 1;
    btnBattery.layer.borderColor = [UIColor whiteColor].CGColor;
    btnBattery.layer.cornerRadius = 5;
    [settingsView addSubview:btnBattery];
    
    if (IS_IPHONE_6plus || IS_IPHONE_X)
    {
        yy = yy + 75;
    }
    else
    {
        yy = yy + 70;
    }
    UILabel * deviceView = [[UILabel alloc]init];
    deviceView.backgroundColor = UIColor.blackColor;
    deviceView.alpha = 0.4;
    deviceView.frame = CGRectMake(0,yy,DEVICE_WIDTH , 65);
    [settingsView addSubview:deviceView];
    
    UILabel * lblDevice = [[UILabel alloc]initWithFrame:CGRectMake(5, yy+5,(DEVICE_WIDTH/2)-10, 25)];
    lblDevice.textColor = UIColor.whiteColor;
    lblDevice.backgroundColor = UIColor.clearColor;
    lblDevice.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblDevice.text = @"Device Memory";
    lblDevice.textAlignment = NSTextAlignmentCenter;
    lblDevice.numberOfLines = 2;
    [settingsView addSubview:lblDevice];
    
    lblDeviceMemoryDisplay = [[UILabel alloc]init];
    lblDeviceMemoryDisplay.textColor = UIColor.greenColor;
    lblDeviceMemoryDisplay.font = [UIFont fontWithName:CGRegular size:textSize];
    lblDeviceMemoryDisplay.frame = CGRectMake(5, yy+30,(DEVICE_WIDTH/2)-10, 25);
    lblDeviceMemoryDisplay.backgroundColor = [UIColor clearColor];
    lblDeviceMemoryDisplay.textAlignment = NSTextAlignmentCenter;
    lblDeviceMemoryDisplay.text = @"0%";
    [settingsView addSubview:lblDeviceMemoryDisplay];
    
    UIButton * btnDeviceMemory = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeviceMemory.frame = CGRectMake(5,yy+5,(DEVICE_WIDTH/2)-10 , 55);
    btnDeviceMemory.backgroundColor = [UIColor clearColor];
    btnDeviceMemory.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btnDeviceMemory.layer.borderWidth = 1;
    btnDeviceMemory.layer.borderColor = [UIColor whiteColor].CGColor;
    btnDeviceMemory.layer.cornerRadius = 5;
    [settingsView addSubview:btnDeviceMemory];
    
    UILabel * lblErase = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/2)+5, yy+5,(DEVICE_WIDTH/2)-10, 50)];
    lblErase.textColor = UIColor.redColor;
    lblErase.backgroundColor = UIColor.clearColor;
    lblErase.font = [UIFont fontWithName:CGRegular size:textSize+1];
    lblErase.text = @"Erase Device Data?";
    lblErase.textAlignment = NSTextAlignmentCenter;
    lblErase.numberOfLines = 2;
    [settingsView addSubview:lblErase];

    
    UIButton * btnEraseDeviceData = [UIButton buttonWithType:UIButtonTypeCustom];
    btnEraseDeviceData.frame = CGRectMake((DEVICE_WIDTH/2)+5,yy+5,(DEVICE_WIDTH/2)-10 , 55);
    btnEraseDeviceData.backgroundColor = [UIColor clearColor];
    btnEraseDeviceData.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnEraseDeviceData addTarget:self action:@selector(btnEraseDeviceDataClick) forControlEvents:UIControlEventTouchUpInside];
    btnEraseDeviceData.layer.borderWidth = 1;
    btnEraseDeviceData.layer.borderColor = [UIColor whiteColor].CGColor;
    btnEraseDeviceData.layer.cornerRadius = 5;
    [settingsView addSubview:btnEraseDeviceData];
    
    
    lblApplyBack = [[UILabel alloc]init];
    lblApplyBack.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1];
    lblApplyBack.frame = CGRectMake(0,DEVICE_HEIGHT-50,DEVICE_WIDTH,50);
    lblApplyBack.hidden = true;
    [self.view addSubview:lblApplyBack];
    
    btnApplyChanges = [[UIButton alloc]init];
    [btnApplyChanges setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnApplyChanges.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize];
    btnApplyChanges.frame = CGRectMake(0,DEVICE_HEIGHT-50,DEVICE_WIDTH,50);
    btnApplyChanges.backgroundColor = [UIColor clearColor];
    btnApplyChanges.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnApplyChanges addTarget:self action:@selector(btnApplyChangesClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnApplyChanges setTitle:@"Apply Changes" forState:UIControlStateNormal];
    btnApplyChanges.hidden = true;
    [self.view addSubview:btnApplyChanges];
    
    
    if ([[[NSUserDefaults standardUserDefaults]arrayForKey:@"arrayData"]mutableCopy]!= nil)
    {
        NSArray * tmpArr = [[NSArray alloc]init];
        tmpArr = [[[NSUserDefaults standardUserDefaults]arrayForKey:@"arrayData"]mutableCopy];
        arrayData = [[NSMutableArray alloc]init];

        for (int i=0; i<tmpArr.count; i++)
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc]init];
            tmpDict = [[tmpArr objectAtIndex:i] mutableCopy];
            [arrayData addObject:tmpDict];
        }
        NSLog(@"array data is %@",arrayData);
        //for freqdepth
        if ([[[arrayData objectAtIndex:0]valueForKey:@"FreqDepth"]isEqualToString:@"NA"])
        {
            lblReportPicker.text = @"1.0m";
            indexFreqDepth = 0;
        }
        else
        {
            lblReportPicker.text = [NSString stringWithFormat:@"%@m",[[arrayData objectAtIndex:0]valueForKey:@"FreqDepth"]];
            indexFreqDepth = [[reportArray valueForKey:@"pre_depth_meter"] indexOfObject:[[arrayData objectAtIndex:0]valueForKey:@"FreqDepth"]];
            if (indexFreqDepth == NSNotFound)
            {
                indexFreqDepth = 0;
            }
        }
        //for time interval
        if (![[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]isEqualToString:@"NA"])
        {
            strIntervalType = @"H";
            indexHH = [arrDatePickerHH indexOfObject:[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]];
            if (indexHH == NSNotFound)
            {
                indexHH = 0;
            }
            [btnHrs setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
            [btnMins setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
            [btnSecs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
            
            if ([[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]isEqualToString:@"1"])
            {
                lblFreqTimeDisplay.text = @"1 Hr";
            }
            else
            {
                lblFreqTimeDisplay.text = [NSString stringWithFormat:@"%@ Hrs",[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]];
                
            }
        }
        else if (![[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"]isEqualToString:@"NA"])
        {

            strIntervalType = @"M";
            indexMM = [arrDatePickerMM indexOfObject:[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"]];
            if (indexMM == NSNotFound)
            {
                indexMM = 0;
            }
            [btnHrs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
            [btnMins setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
            [btnSecs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
            
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Mins",[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"]];

        }
        else if (![[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]isEqualToString:@"NA"])
        {
            strIntervalType = @"S";
            indexSS = [arrDatePickerSS indexOfObject:[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]];
            if (indexSS == NSNotFound)
            {
                indexSS = 0;
            }
            [btnHrs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
            [btnMins setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
            [btnSecs setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
            
            if ([[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]isEqualToString:@"1"])
            {
                lblFreqTimeDisplay.text = @"1 Sec";
            }
            else
            {
                lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Secs",[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]];
            }
        }
        else
        {
            strIntervalType = @"H";
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"1 Hr"];
            indexHH = 0;

        }
        
        //for ble Transmission
        if ([[[arrayData objectAtIndex:2]valueForKey:@"BleTransmission"]isEqualToString:@"NA"])
        {
            lblBleTransmission.text = @"Always";
            indexBleTransmission = 0;
        }
        else
        {
            lblBleTransmission.text =  [[arrayData objectAtIndex:2]valueForKey:@"BleTransmission"];
            indexBleTransmission = [bleTransmissionArray indexOfObject:[[arrayData objectAtIndex:2]valueForKey:@"BleTransmission"]];
            if (indexBleTransmission == NSNotFound)
            {
                indexBleTransmission = 0;
            }
        }
        
        //for gps interval
        if (![[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalHH"]isEqualToString:@"NA"])
        {
            if ([[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalHH"]isEqualToString:@"1"])
            {
                lblGPSInterval.text = @"1 Hour";

            }
            else
            {
                lblGPSInterval.text = [NSString stringWithFormat:@"%@ Hours",[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalHH"]];
            }
            indexGpsInterval = [arrGpsSecondMin indexOfObject:[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalHH"]];
            if (indexGpsInterval == NSNotFound)
            {
                indexGpsInterval = 0;
            }
        }
        else if (![[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalMM"]isEqualToString:@"NA"])
        {
            if ([[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalMM"]isEqualToString:@"1"])
            {
                lblGPSInterval.text = @"1 Minute";
            }
            else
            {
                lblGPSInterval.text = [NSString stringWithFormat:@"%@ Minutes",[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalMM"]];
            }
            indexGpsInterval = [arrGpsSecondMin indexOfObject:[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalMM"]];
            if (indexGpsInterval == NSNotFound)
            {
                indexGpsInterval = 0;
            }
        }
        else
        {
            lblGPSInterval.text = @"0 Minutes";
            indexGpsInterval = 0;
        }
        
        //for time out
        if ([[[arrayData objectAtIndex:4]valueForKey:@"GPStimeOut"]isEqualToString:@"NA"])
        {
            lblGPSTimeout.text = @"1 Minute";
            indexGpstimeout = 0;
        }
        else
        {
            if ([[[arrayData objectAtIndex:4]valueForKey:@"GPStimeOut"]isEqualToString:@"1"])
            {
                lblGPSTimeout.text = @"1 Minute";
                
            }
            else
            {
                lblGPSTimeout.text = [NSString stringWithFormat:@"%@ Minutes",[[arrayData objectAtIndex:4]valueForKey:@"GPStimeOut"]];
            }
            indexGpstimeout = [arrGpsSecondMin indexOfObject:[[arrayData objectAtIndex:4]valueForKey:@"GPStimeOut"]];
            indexGpstimeout = indexGpstimeout -1;
            if (indexGpstimeout == NSNotFound)
            {
                indexGpstimeout = 0;
            }
        }
 
    }
}
-(void)setCutoffArrayManually
{
    reportArray = [[NSMutableArray alloc] init];
    NSArray * depthArr = [NSArray arrayWithObjects:@"1.0",@"1.1",@"1.2",@"1.3",@"1.4",@"1.5",@"1.6",@"1.7",@"1.8",@"1.9",@"2.0", nil];
    NSArray * barArr = [NSArray arrayWithObjects:@"1113",@"1123",@"1133",@"1143",@"1153",@"1163",@"1173",@"1183",@"1193",@"1203",@"1213", nil];
    for (int i=0; i<[depthArr count]; i++)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[depthArr objectAtIndex:i] forKey:@"pre_depth_meter"];
        [dict setObject:[barArr objectAtIndex:i] forKey:@"pre_depth_milibar"];
        [reportArray addObject:dict];
    }
}
-(void)segmentClick:(NYSegmentedControl *) sender
{
    if (sender.selectedSegmentIndex==0)
    {
        listView.hidden = false;
        settingsView.hidden = true;
        imgRefresh.hidden = false;
        refreshBtn.hidden = false;
        mapImg.hidden = true;
        btnMap.hidden = true;
        btnApplyChanges.hidden = true;
        lblApplyBack.hidden = true;
        [self ShowPicker:NO andView:viewPicker];
    }
    else if (sender.selectedSegmentIndex==1)
    {
//        if (globalPeripheral.state == CBPeripheralStateConnected)
        {
            [APP_DELEGATE endHudProcess];
//            [APP_DELEGATE startHudProcess:@"Fetching Device Settings..."];

            strTypeNotify = @"Memory";
            [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"3071"];
            
            [viewPicker removeFromSuperview];
            listView.hidden = true;
            settingsView.hidden = false;
            imgRefresh.hidden = true;
            refreshBtn.hidden = true;
            mapImg.hidden = false;
            btnMap.hidden = false;
            btnApplyChanges.hidden = false;
            lblApplyBack.hidden = false;

            if ([[APP_DELEGATE checkforValidString:strSelectedBLEAddress] isEqualToString:@"NA"])
            {
            }
            else
            {
                lblConnectedDevice.hidden = NO;
                CGFloat boldTextFontSize = textSize-1;
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"Connected device : %@",strSelectedBLEAddress]];
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,18)];
                [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:boldTextFontSize] range:NSMakeRange(0,18)];
                [lblConnectedDevice setAttributedText:string];
            }
        }
//        else
//        {
//            blueSegmentedControl.selectedSegmentIndex = 0;
//            URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please connect device first." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
//             [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
//             [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//             [alertView hideWithCompletionBlock:^{}];
//             }];
//             [alertView showWithAnimation:URBAlertAnimationTopToBottom];
//             if (IS_IPHONE_X)
//             {
//                 [alertView showWithAnimation:URBAlertAnimationDefault];
//             }
//
//        }
        
    }
}
#pragma mark - Button Click Events
-(void)btnBackClick
{
    [connectedDevice removeAllObjects];
    isSyncingYet = NO;
    isleftscreen = YES;
    [checkConnectionTimer invalidate];
    [[BLEManager sharedManager] disconnectDevice:globalPeripheral];
    [[BLEManager sharedManager] stopScan];
    [self.navigationController popViewControllerAnimated:true];
}
-(void)refreshBtnClick
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        isSyncingYet = YES;
        [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"3327"];
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Percentage"];
        lblProgress.text = @"0%";
        
        [checkConnectionTimer invalidate];
        checkConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(forSuddenDisconnection) userInfo:nil repeats:YES];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please connect device first." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
-(void)btnCancelAction
{
    backViewShadow.hidden = true;
    [self ShowPicker:NO andView:viewPicker];
}
-(void)btnDoneAction
{
    backViewShadow.hidden = true;
    if(btnDone.tag == 111)
    {
        [self ShowPicker:NO andView:viewPicker];
        if (strSelectedFrequency == nil || strSelectedFrequency == 0 || strSelectedFrequency == NULL)
        {
            strSelectedFrequency = @"10 Sec";
        }
        [btnFrequencyPostionValue setTitle:strSelectedFrequency forState:UIControlStateNormal];
        indexFreqPos = [FrequencyArray indexOfObject:strSelectedFrequency];
        if (indexFreqPos == NSNotFound)
        {
            indexFreqPos = 0;
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:strSelectedFrequency forKey:@"frequencyPosition"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(btnDone.tag == 222)
    {
        [self ShowPicker:NO andView:viewPicker];
        if ([[[arrayData objectAtIndex:2]valueForKey:@"BleTransmission"]isEqualToString:@"NA"])
        {
            if ([[APP_DELEGATE checkforValidString:strSelecetedBleTransmission]isEqualToString:@"NA"])
            {
                strSelecetedBleTransmission = @"Always";
            }
        }
        else
        {
            if ([[APP_DELEGATE checkforValidString:strSelecetedBleTransmission]isEqualToString:@"NA"])
            {
                strSelecetedBleTransmission = [[arrayData objectAtIndex:2]valueForKey:@"BleTransmission"];
            }
        }
        
        lblBleTransmission.text =strSelecetedBleTransmission;
        indexBleTransmission = [bleTransmissionArray indexOfObject:strSelecetedBleTransmission];
        if (indexBleTransmission == NSNotFound) {
            indexBleTransmission = 0;
        }
//        [[NSUserDefaults standardUserDefaults] setValue:strSelecetedBleTransmission forKey:@"BLETransmission"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        if ([strSelecetedBleTransmission isEqualToString:@"Always"])
        {
            timeSentValue = 255 ;
        }
        else
        {
            timeSentValue = 10 ;
        }
        [[arrayData objectAtIndex:2]setValue:@"YES" forKey:@"isChanged"];
        [[arrayData objectAtIndex:2]setValue:strSelecetedBleTransmission forKey:@"BleTransmission"];
    }
    else if (btnDone.tag == 333)
    {
        [self ShowPicker:NO andView:viewPicker];
        if ([[[arrayData objectAtIndex:0]valueForKey:@"FreqDepth"]isEqualToString:@"NA"])
        {
            if ([[APP_DELEGATE checkforValidString:strSelectedReport]isEqualToString:@"NA"])
            {
                strSelectedReport = @"1.0";
                strDepthMilibar = @"1113";
            }
        }
        else
        {
            if ([[APP_DELEGATE checkforValidString:strSelectedReport]isEqualToString:@"NA"])
            {
                strSelectedReport = [[arrayData objectAtIndex:0]valueForKey:@"FreqDepth"];
            }
        }
        lblReportPicker.text = [NSString stringWithFormat:@"%@m",strSelectedReport];
        
        indexFreqDepth = [[reportArray valueForKey:@"pre_depth_meter"] indexOfObject:strSelectedReport];
        if (indexFreqDepth == NSNotFound)
        {
            indexFreqDepth = 0;
        }
        timeSentValue = [strDepthMilibar integerValue] ;
        
        [[arrayData objectAtIndex:0]setValue:@"YES" forKey:@"isChanged"];
        [[arrayData objectAtIndex:0] setValue:strSelectedReport forKey:@"FreqDepth"];
    }
    else if(btnDone.tag == 444)
    {
        strElapsedTimeValueMM = @"5";
        strElapsedTimeValueSS = @"1";
        indexMM = 0;
        indexSS = 0;
        
        [self ShowPicker:NO andView:viewPicker];
//        [[NSUserDefaults standardUserDefaults] setValue:@"H" forKey:@"SentIntervalType"];
//        [[NSUserDefaults standardUserDefaults] setValue:strElapsedTimeValueHH forKey:@"SentIntervalValue"];
        
        if ([[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]isEqualToString:@"NA"])
        {
            if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueHH]isEqualToString:@"NA"])
            {
                strElapsedTimeValueHH = @"1";
            }
        }
        else
        {
            if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueHH]isEqualToString:@"NA"])
            {
                strElapsedTimeValueHH = [[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"];
            }
        }
        if (![strElapsedTimeValueHH isEqualToString:@"1"])
        {
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Hrs",strElapsedTimeValueHH];
        }
        else
        {
            strElapsedTimeValueHH = @"1";
            lblFreqTimeDisplay.text = @"1 Hr";
        }
    
        indexHH = [arrDatePickerHH indexOfObject:strElapsedTimeValueHH];
        if (indexHH == NSNotFound)
        {
            indexHH = 0;
        }
        timeSentValue = [strElapsedTimeValueHH integerValue] * 3600;
        
        [[arrayData objectAtIndex:1]setValue:@"YES" forKey:@"isChanged"];
        [[arrayData objectAtIndex:1]setValue:strElapsedTimeValueHH forKey:@"FreqIntervalHH"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalMM"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalSS"];


    }
    else if(btnDone.tag == 555)
    {
        strElapsedTimeValueSS = @"1";
        strElapsedTimeValueHH = @"1";
        indexSS = 0;
        indexHH = 0;
        if (([[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"]isEqualToString:@"NA"]))
        {
            if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueMM]isEqualToString:@"NA"])
            {
                strElapsedTimeValueMM = @"5";
            }
        }
        else
        {
            if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueMM]isEqualToString:@"NA"])
            {
                strElapsedTimeValueMM = [[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"];
            }
        }
        if (![strElapsedTimeValueMM isEqualToString:@"5"])
        {
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Mins",strElapsedTimeValueMM];
        }
        else
        {
            strElapsedTimeValueMM = @"5";
            lblFreqTimeDisplay.text = @"5 Mins";
        }
        indexMM = [arrDatePickerMM indexOfObject:strElapsedTimeValueMM];
        if (indexMM == NSNotFound)
        {
            indexMM = 0;
        }
        [self ShowPicker:NO andView:viewPicker];
//        [[NSUserDefaults standardUserDefaults] setValue:@"M" forKey:@"SentIntervalType"];
//        [[NSUserDefaults standardUserDefaults] setValue:strElapsedTimeValueMM forKey:@"SentIntervalValue"];
        
        lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Mins",strElapsedTimeValueMM];
        
        timeSentValue = [strElapsedTimeValueMM integerValue] * 60;
       
        [[arrayData objectAtIndex:1]setValue:@"YES" forKey:@"isChanged"];
        [[arrayData objectAtIndex:1]setValue:strElapsedTimeValueMM forKey:@"FreqIntervalMM"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalHH"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalSS"];

    }
    else if(btnDone.tag == 666)
    {
        strElapsedTimeValueMM = @"5";
        strElapsedTimeValueHH = @"1";
        indexMM = 0;
        indexHH = 0;
        
        [self ShowPicker:NO andView:viewPicker];
//        [[NSUserDefaults standardUserDefaults] setValue:@"S" forKey:@"SentIntervalType"];
//        [[NSUserDefaults standardUserDefaults] setValue:strElapsedTimeValueSS forKey:@"SentIntervalValue"];
        if (([[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]isEqualToString:@"NA"]))
        {
            if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueSS]isEqualToString:@"NA"])
            {
                strElapsedTimeValueSS = @"1";
            }
        }
        else
        {
            if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueSS]isEqualToString:@"NA"])
            {
                strElapsedTimeValueSS = [[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"];
            }
        }
        if (![strElapsedTimeValueSS isEqualToString:@"1"])
        {
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Secs",strElapsedTimeValueSS];
        }
        else
        {
            strElapsedTimeValueSS = @"1";
            lblFreqTimeDisplay.text = @"1 Sec";
        }
        indexSS = [arrDatePickerSS indexOfObject:strElapsedTimeValueSS];
        if (indexSS == NSNotFound)
        {
            indexSS = 0;
        }
        timeSentValue = [strElapsedTimeValueSS integerValue] ;
       
        [[arrayData objectAtIndex:1]setValue:@"YES" forKey:@"isChanged"];
        [[arrayData objectAtIndex:1]setValue:strElapsedTimeValueSS forKey:@"FreqIntervalSS"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalHH"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalMM"];
    }
    else if(btnDone.tag == 777)
    {
        [self ShowPicker:NO andView:viewPicker];
        if (![[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalHH"]isEqualToString:@"NA"])
        {
            if ([[APP_DELEGATE checkforValidString:strGpsInterval]isEqualToString:@"NA"])
            {
                strGpsInterval = [[arrayData objectAtIndex:3]valueForKey:@"GPSintervalHH"];
            }
        }
        else if ((![[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalMM"]isEqualToString:@"NA"]))
        {
            if ([[APP_DELEGATE checkforValidString:strGpsInterval]isEqualToString:@"NA"])
            {
                strGpsInterval = [[arrayData objectAtIndex:3]valueForKey:@"GPSintervalMM"];
            }
        }
        else
        {
            if ([[APP_DELEGATE checkforValidString:strGpsInterval]isEqualToString:@"NA"])
            {
                strGpsInterval = @"0";
            }
        }
        
//        [[NSUserDefaults standardUserDefaults] setValue:strGpsInterval forKey:@"GPSInterval"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        indexGpsInterval = [arrGpsSecondMin indexOfObject:strGpsInterval];
        if (indexGpsInterval == NSNotFound)
        {
            indexGpsInterval = 0;
        }
        if ([strGpsInterval isEqualToString:@"1"])
        {
            lblGPSInterval.text = @"1 Minute";
        }
        else
        {
            lblGPSInterval.text = [NSString stringWithFormat:@"%@ Minutes",strGpsInterval];
        }
        [[arrayData objectAtIndex:3]setValue:@"NA" forKey:@"GPSintervalHH"];
        [[arrayData objectAtIndex:3]setValue:strGpsInterval forKey:@"GPSintervalMM"];
        timeSentValue = [strGpsInterval integerValue];
        if (isGpsMinute == NO)
        {
           timeSentValue =  timeSentValue * 60;
            if ([strGpsInterval isEqualToString:@"1"])
            {
                lblGPSInterval.text = @"1 Hour";
            }
            else
            {
                lblGPSInterval.text = [NSString stringWithFormat:@"%@ Hours",strGpsInterval];
            }
            [[arrayData objectAtIndex:3]setValue:strGpsInterval forKey:@"GPSintervalHH"];
            [[arrayData objectAtIndex:3]setValue:@"NA" forKey:@"GPSintervalMM"];

        }
        
        [[arrayData objectAtIndex:3]setValue:@"YES" forKey:@"isChanged"];

    }
    else if(btnDone.tag == 888)
    {
        [self ShowPicker:NO andView:viewPicker];
        if ([[[arrayData objectAtIndex:4]valueForKey:@"GPStimeOut"]isEqualToString:@"NA"])
        {
            if ([[APP_DELEGATE checkforValidString:strGpsTimeout]isEqualToString:@"NA"])
            {
                strGpsTimeout = @"1";
            }
        }
        else
        {
            if ([[APP_DELEGATE checkforValidString:strGpsTimeout]isEqualToString:@"NA"])
            {
                strGpsTimeout = [[arrayData objectAtIndex:4]valueForKey:@"GPStimeOut"];
            }
        }
//        [[NSUserDefaults standardUserDefaults] setValue:strGpsTimeout forKey:@"GPStimeout"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([strGpsTimeout isEqualToString:@"1"])
        {
            lblGPSTimeout.text = @"1 Minute";
        }
        else
        {
            lblGPSTimeout.text = [NSString stringWithFormat:@"%@ Minutes",strGpsTimeout];
        }
        indexGpstimeout = [arrGpsSecondMin indexOfObject:strGpsTimeout];
        if (indexGpstimeout == NSNotFound)
        {
            indexGpstimeout = 0;
        }
        timeSentValue = [strGpsTimeout integerValue] ;
        
        [[arrayData objectAtIndex:4]setValue:@"YES" forKey:@"isChanged"];
        [[arrayData objectAtIndex:4]setValue:strGpsTimeout forKey:@"GPStimeOut"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"updated data is %@",arrayData);
}



-(void)btnFrequencyPostionValueAction
{
    [self setAllPickerviewFrames:111];
    [self ShowPicker:YES andView:viewPicker];
}
-(void)btnBleTransmissionAction
{
    [self setAllPickerviewFrames:222];
    [self ShowPicker:YES andView:viewPicker];
}

-(void)btnReportPickerAction
{
    [self setAllPickerviewFrames:333];
    [self ShowPicker:YES andView:viewPicker];
}
-(void)btnGPSIntervalClick
{
    [self setAllPickerviewFrames:777];
    viewPicker.tag = 777;
    [self ShowPicker:YES andView:viewPicker];
}
-(void)btnlGPSTimeoutClick
{
    arrGpsSecondMin = [[NSMutableArray alloc] init];
    for (int i=0; i<60;i++)
    {
        [arrGpsSecondMin addObject:[NSString stringWithFormat:@"%d",i+1]];
    }
    
    [self setAllPickerviewFrames:888];
    [self ShowPicker:YES andView:viewPicker];
}

-(void)btnIntervalValueAction
{
    if ([strIntervalType isEqualToString:@"H"])
    {
        [self setAllPickerviewFrames:444];
    }
    else if ([strIntervalType isEqualToString:@"M"])
    {
        [self setAllPickerviewFrames:555];
    }
    else if ([strIntervalType isEqualToString:@"S"])
    {
        [self setAllPickerviewFrames:666];
    }
    [self ShowPicker:YES andView:viewPicker];
}
-(void)btnTimeInterval:(id)sender
{
    if ([sender tag] == 1)
    {
        [self ShowPicker:NO andView:viewPicker];
        strIntervalType = @"H";
        [btnHrs setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
        [btnMins setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
        [btnSecs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
        
        if (![[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]isEqualToString:@"NA"])
        {
            if ([[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]isEqualToString:@"1"])
            {
                lblFreqTimeDisplay.text =[NSString stringWithFormat:@"1 Hr"];
            }
            else
            {
                lblFreqTimeDisplay.text = [NSString stringWithFormat:@"%@ Hrs",[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"]];
                [[arrayData objectAtIndex:1]setValue:[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalHH"] forKey:@"FreqIntervalHH"];
            }
        }
        else
        {
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"1 Hr"];
            [[arrayData objectAtIndex:1]setValue:@"1" forKey:@"FreqIntervalHH"];
            indexMM = 0;
            indexSS = 0;
            strElapsedTimeValueMM = @"5";
            strElapsedTimeValueSS = @"1";
        }
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalMM"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalSS"];
    }
    else if ([sender tag] ==2)
    {
        [self ShowPicker:NO andView:viewPicker];
        strIntervalType = @"M";
        [btnHrs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
        [btnMins setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
        [btnSecs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
        if (![[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"]isEqualToString:@"NA"])
        {
            lblFreqTimeDisplay.text = [NSString stringWithFormat:@"%@ Mins",[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"]];
            [[arrayData objectAtIndex:1]setValue:[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalMM"] forKey:@"FreqIntervalMM"];
        }
        else
        {
            lblFreqTimeDisplay.text = [NSString stringWithFormat:@"5 Mins"];
            [[arrayData objectAtIndex:1]setValue:@"5" forKey:@"FreqIntervalMM"];
            indexHH = 0;
            indexSS = 0;
            strElapsedTimeValueHH = @"1";
            strElapsedTimeValueSS = @"1";
        }
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalHH"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalSS"];
    }
    else if ([sender tag] ==3)
    {
        [self ShowPicker:NO andView:viewPicker];
        strIntervalType = @"S";
        [btnHrs setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
        [btnMins setImage:[UIImage imageNamed:@"radiobuttonUnselected.png"]  forState:UIControlStateNormal];
        [btnSecs setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
        if (![[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]isEqualToString:@"NA"])
        {
            if ([[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]isEqualToString:@"1"])
            {
                lblFreqTimeDisplay.text = @"1 Sec";
            }
            else
            {
                lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Secs",[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"]];
            }
            [[arrayData objectAtIndex:1]setValue:[[arrayData objectAtIndex:1]valueForKey:@"FreqIntervalSS"] forKey:@"FreqIntervalSS"];

        }
        else
        {
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"1 Sec"];
            [[arrayData objectAtIndex:1]setValue:@"1" forKey:@"FreqIntervalSS"];
            indexMM = 0;
            indexHH = 0;
            strElapsedTimeValueHH = @"1";
            strElapsedTimeValueMM = @"5";
        }
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalHH"];
        [[arrayData objectAtIndex:1]setValue:@"NA" forKey:@"FreqIntervalMM"];
    }
    [[arrayData objectAtIndex:1]setValue:@"YES" forKey:@"isChanged"];
    [[NSUserDefaults standardUserDefaults] setValue:strIntervalType forKey:@"intervaltype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"updated array is %@",arrayData);
}
-(void)btnMapClick
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        isManualGPSCall = YES;
        strTypeNotify = @"CurrentGPS";
        [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1023"];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please connect device first to get current location." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:textSize]];
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
-(void)btnGpsMinClick
{
    arrGpsSecondMin = [[NSMutableArray alloc] init];
    for (int i=0; i<61;i++)
    {
        [arrGpsSecondMin addObject:[NSString stringWithFormat:@"%d",i]];
    }

    
    [btnGPSMins setImage:[UIImage imageNamed:@"blackselected.png"]  forState:UIControlStateNormal];
    [btnGPSMins setTitle:@"  Minutes" forState:UIControlStateNormal];
    
    [btnGPSHrs setImage:[UIImage imageNamed:@"blackUnselected.png"]  forState:UIControlStateNormal];
    [btnGPSHrs setTitle:@"  Hours" forState:UIControlStateNormal];

    isGpsMinute = YES;
    lblPickerViewTitle.text = @"Set GPS Interval in Minutes";

    [configPickerView reloadAllComponents];
}

-(void)btnGpsHourClick
{
    arrGpsSecondMin = [[NSMutableArray alloc] init];
    for (int i=0; i<61;i++)
    {
        [arrGpsSecondMin addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [btnGPSHrs setImage:[UIImage imageNamed:@"blackselected.png"]  forState:UIControlStateNormal];
    [btnGPSHrs setTitle:@"  Hours" forState:UIControlStateNormal];

    [btnGPSMins setImage:[UIImage imageNamed:@"blackUnselected.png"]  forState:UIControlStateNormal];
    [btnGPSMins setTitle:@"  Minutes" forState:UIControlStateNormal];
    lblPickerViewTitle.text = @"Set GPS Interval in Hours";
    isGpsMinute = NO;

    [configPickerView reloadAllComponents];
}
-(void)btnMapListClick:(id)sender
{
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    if ([arrayDevices count]>0)
    {
        MapClassVC * mapV = [[MapClassVC alloc] init];
        mapV.isfromSettings = YES;
        mapV.strLatitude = [NSString stringWithFormat:@"%f",[self getLatLongfromHex:[[arrayDevices objectAtIndex:[sender tag]] valueForKey:@"lat"]]];
        mapV.strLongitude = [NSString stringWithFormat:@"%f",[self getLatLongfromHex:[[arrayDevices objectAtIndex:[sender tag]] valueForKey:@"long"]]];
        [self.navigationController pushViewController:mapV animated:YES];
    }
}
-(void)btnConnectClick:(id)sender
{
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:[sender tag]] valueForKey:@"peripheral"];
        myPeripheral = p;
        strSelectedBLEAddress = [[arrayDevices objectAtIndex:[sender tag]] valueForKey:@"address"];
        bleRememberDict = [[NSMutableDictionary alloc] init];
        bleRememberDict = [arrayDevices objectAtIndex:[sender tag]];
        
        [connectionTimer invalidate];
        connectionTimer  = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeOutMethodCall) userInfo:nil repeats:NO];
        
        if (p.state == CBPeripheralStateConnected)
        {
            isConnecting = NO;
            [APP_DELEGATE startHudProcess:@"Disconnecting..."];
            [self onDisconnectWithDevice:p];
        }
        else
        {
            isConnecting = YES;
            if (globalPeripheral.state == CBPeripheralStateConnected)
            {
                [[BLEManager sharedManager] disconnectDevice:globalPeripheral];
            }
            connectionCount = 0;
            [APP_DELEGATE startHudProcess:@"Connecting..."];
            [self onConnectWithDevice:p];
        }
    }

}
-(double)getLatLongfromHex:(NSString *)strHex
{
    NSString *hexValueLat = strHex;
    int intConvertedLat = 0;
    NSScanner *firstScanner = [NSScanner scannerWithString:hexValueLat];
    [firstScanner scanHexInt:&intConvertedLat];
    NSLog(@"First: %d",intConvertedLat);
    int mIntLocationPrefix = intConvertedLat / 1000000;
    int mIntLocationPostfix = intConvertedLat % 1000000;
    NSLog(@"%d + %d",mIntLocationPrefix,mIntLocationPostfix);
    double mLongDouble = (double)mIntLocationPostfix /600000;
    NSLog(@"%f ",mLongDouble);
    double finalSol = mLongDouble + (double)mIntLocationPrefix;
    return finalSol;
}
-(void)btnUTCTimeClick
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        [APP_DELEGATE startHudProcess:@"Setting Time..."];
        [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1536"];
        [self performSelector:@selector(SendtimManually) withObject:nil afterDelay:2];
    }
    else
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please connect device first." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
-(void)btnEraseDeviceDataClick
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure you want to erase device Data?" cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex==0)
            {
                [APP_DELEGATE startHudProcess:@"Erasing data..."];
                
                [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"768"];
                [self performSelector:@selector(finishProcess) withObject:nil afterDelay:2];
                
            }
        }];
    }];
    [alertView showWithAnimation:Alert_Animation_Type];
    if (IS_IPHONE_X)
    {
        [alertView showWithAnimation:URBAlertAnimationDefault];
    }
}
-(void)btnApplyChangesClicked
{
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Are you sure you want to apply Changes?" cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex==0)
            {
                [APP_DELEGATE startHudProcess:@"Saving Changes"];
                self->saveCount = 0;
                [self sendDataToDevice];
            }
        }];
    }];
    [alertView showWithAnimation:Alert_Animation_Type];
    if (IS_IPHONE_X)
    {
        [alertView showWithAnimation:URBAlertAnimationDefault];
    }
    /*
    // for freq depth
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1280"];
    [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];
    
    //for hh
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"256"];
    [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];
    
    //for mm
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"256"];
    [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];
    
    //for ss
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"256"];
    [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];
    
    //for ble transmission
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"3584"];
    [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];

    //for gps interval
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1024"];
    [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];
    
    //for gps timeout
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1792"];
    [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];
*/
}
-(void)sendDataToDevice
{
    if (saveCount > 5)
    {
        NSLog(@"its done=%ld",(long)saveCount);
        [APP_DELEGATE endHudProcess];

        [arrayData setValue:@"NO" forKey:@"isChanged"];
        [[NSUserDefaults standardUserDefaults]setObject:[arrayData mutableCopy] forKey:@"arrayData"];
        [[NSUserDefaults standardUserDefaults]synchronize];
       
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Changes Updated Successfully" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
        if (arrayData.count > saveCount)
        {
            if ([[[arrayData objectAtIndex:saveCount]valueForKey:@"isChanged"]isEqualToString:@"YES"])
            {
                [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:[[arrayData objectAtIndex:saveCount]valueForKey:@"opcode"]];
                [self sendChangedValueToDevice];
                
            }
            saveCount = saveCount +1;
            [self performSelector:@selector(sendDataToDevice) withObject:nil afterDelay:1];
        }
    }

}
-(void)sendChangedValueToDevice
{
    NSLog(@"datadict updated values are %@",arrayData);
    if (saveCount == 0)
    {
        if (arrayData.count > saveCount)
        {
            CGFloat tmpValue = [[[arrayData objectAtIndex:saveCount]valueForKey:@"FreqDepth"] floatValue];
            [[BLEService sharedInstance] SendFrequencyDepthValuestoPeripheral:globalPeripheral withValue:tmpValue];
            return;
        }
    }
    else if (saveCount == 1)
    {
        if (arrayData.count > saveCount)
        {
            if (![[[arrayData objectAtIndex:saveCount] valueForKey:@"FreqIntervalHH"] isEqualToString:@"NA"])
            {
                timeSentValue = [[[arrayData objectAtIndex:saveCount] valueForKey:@"FreqIntervalHH"] integerValue] * 3600;
            }
            else if (![[[arrayData objectAtIndex:saveCount] valueForKey:@"FreqIntervalMM"] isEqualToString:@"NA"])
            {
                timeSentValue = [[[arrayData objectAtIndex:saveCount] valueForKey:@"FreqIntervalMM"] integerValue] * 60;
            }
            else if (![[[arrayData objectAtIndex:saveCount] valueForKey:@"FreqIntervalSS"] isEqualToString:@"NA"])
            {
                timeSentValue = [[[arrayData objectAtIndex:saveCount] valueForKey:@"FreqIntervalSS"] integerValue] ;
            }
        }
    }
    else if (saveCount == 2)
    {
        if (arrayData.count >saveCount)
        {
            if ([[[arrayData objectAtIndex:saveCount]valueForKey:@"BleTransmission"] isEqualToString:@"Always"])
            {
                timeSentValue = 255 ;
            }
            else
            {
                timeSentValue = 10 ;
            }
        }
    }
    else if (saveCount == 3)
    {
        if (arrayData.count >saveCount)
        {
            if (![[[arrayData objectAtIndex:saveCount]valueForKey:@"GPSintervalHH"] isEqualToString:@"NA"])
            {
                timeSentValue = [[[arrayData objectAtIndex:saveCount] valueForKey:@"GPSintervalHH"] integerValue];
                
            }
            else if (![[[arrayData objectAtIndex:saveCount]valueForKey:@"GPSintervalMM"] isEqualToString:@"NA"])
            {
                timeSentValue =  [[[arrayData objectAtIndex:saveCount] valueForKey:@"GPSintervalMM"] integerValue]*60;
                
            }
        }
    }
    else  if (saveCount == 4)
    {
        if (arrayData.count >saveCount)
        {
            timeSentValue = [[[arrayData objectAtIndex:saveCount]valueForKey:@"GPStimeOut"]integerValue];
        }
    }
    [[BLEService sharedInstance] SendValuestoPeripheral:globalPeripheral withValue:timeSentValue];

}
-(void)SendValueAfterDelay
{
    [[BLEService sharedInstance] SendValuestoPeripheral:globalPeripheral withValue:timeSentValue];
}

#pragma mark - PickerView Frames

-(void)setAllPickerviewFrames:(int)sender
{
    backViewShadow.hidden = false;

    [viewPicker removeFromSuperview];
    viewPicker = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT,DEVICE_WIDTH, 215)];
    viewPicker.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:viewPicker];
    
    [configPickerView removeFromSuperview];
    configPickerView = [[UIPickerView alloc]init];
    configPickerView.frame = CGRectMake(0,44,viewPicker.frame.size.width, (viewPicker.frame.size.height-44));
    configPickerView.delegate = self;
    configPickerView.dataSource = self;
    configPickerView.tag = sender;
    [viewPicker addSubview:configPickerView];
    
    lblPickerViewTitle = [[UILabel alloc]init];
    lblPickerViewTitle.frame = CGRectMake(70, 0, DEVICE_WIDTH-140,44);
    lblPickerViewTitle.textColor = UIColor.darkGrayColor;
    lblPickerViewTitle.backgroundColor = UIColor.clearColor;
    lblPickerViewTitle.numberOfLines = 2;
    lblPickerViewTitle.textAlignment = NSTextAlignmentCenter;
    lblPickerViewTitle.font = [UIFont fontWithName:CGRegular size:textSize-3];
    [viewPicker addSubview:lblPickerViewTitle];
    
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
    btnDone.tag = sender;
    [btnDone addTarget:self action:@selector(btnDoneAction) forControlEvents:UIControlEventTouchUpInside];
    [viewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, DEVICE_WIDTH, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [viewPicker addSubview:lblLine];
    
    if (sender == 111)
    {
        [configPickerView selectRow:indexFreqPos inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Set Frequency of Position";
    }
    else if(sender == 222)
    {
        [configPickerView selectRow:indexBleTransmission inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Bluetooth Transmission";
    }
    else if(sender == 333)
    {
        [configPickerView selectRow:indexFreqDepth inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Reporting Frequency Depth";
    }
    else if (sender == 444)
    {
        [configPickerView selectRow:indexHH inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Hour";
    }
    else if (sender == 555)
    {
        [configPickerView selectRow:indexMM inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Minutes";
    }
    else if (sender == 666)
    {
        [configPickerView selectRow:indexSS inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Second";
    }
    else if (sender == 777)
    {
        if (indexGpsInterval < [arrGpsSecondMin count])
        {
            [configPickerView selectRow:indexGpsInterval inComponent:0 animated:true];
        }
        
        lblPickerViewTitle.text = @"Set GPS Interval in Minutes";
        viewPicker.frame = CGRectMake(0, DEVICE_HEIGHT,DEVICE_WIDTH, 215+50);
        configPickerView.frame = CGRectMake(0,44+50,viewPicker.frame.size.width, (viewPicker.frame.size.height-44-50));
        lblPickerViewTitle.frame = CGRectMake(70, 0, DEVICE_WIDTH-140,44);
        btnCancel.frame = CGRectMake(0,0,70,44);
        btnDone.frame = CGRectMake(DEVICE_WIDTH-70,0,70,44);
        lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, DEVICE_WIDTH, 0.5);

        btnGPSMins = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnGPSMins setImage:[UIImage imageNamed:@"blackselected.png"]  forState:UIControlStateNormal];
        [btnGPSMins setTitle:@"  Minutes" forState:UIControlStateNormal];
        [btnGPSMins setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        btnGPSMins.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
        btnGPSMins.frame = CGRectMake(0 ,45,DEVICE_WIDTH/2 , 45);
        btnGPSMins.tag = 2;
        [btnGPSMins addTarget:self action:@selector(btnGpsMinClick) forControlEvents:UIControlEventTouchUpInside];
        [viewPicker addSubview:btnGPSMins];
        btnGPSMins.backgroundColor = [UIColor clearColor];
        btnGPSMins.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

        btnGPSHrs = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnGPSHrs setImage:[UIImage imageNamed:@"blackUnselected.png"]  forState:UIControlStateNormal];
        [btnGPSHrs setTitle:@"  Hours" forState:UIControlStateNormal];
        [btnGPSHrs setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        btnGPSHrs.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+2];
        btnGPSHrs.frame = CGRectMake(DEVICE_WIDTH/2 ,45,DEVICE_WIDTH/2 , 45);
        btnGPSHrs.tag = 2;
        [btnGPSHrs addTarget:self action:@selector(btnGpsHourClick) forControlEvents:UIControlEventTouchUpInside];
        [viewPicker addSubview:btnGPSHrs];
        btnGPSHrs.backgroundColor = [UIColor clearColor];
        btnGPSHrs.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        if (![[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalHH"]isEqualToString:@"NA"])
        {
            [btnGPSMins setImage:[UIImage imageNamed:@"blackUnselected.png"]  forState:UIControlStateNormal];
            [btnGPSHrs setImage:[UIImage imageNamed:@"blackselected.png"]  forState:UIControlStateNormal];
            
            [self btnGpsHourClick];
        }
        else if (![[[arrayData objectAtIndex:3]valueForKey:@"GPSintervalMM"]isEqualToString:@"NA"])
        {
            [btnGPSMins setImage:[UIImage imageNamed:@"blackselected.png"]  forState:UIControlStateNormal];
            [btnGPSHrs setImage:[UIImage imageNamed:@"blackUnselected.png"]  forState:UIControlStateNormal];
            
            [self btnGpsMinClick];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"GPSIntervalType"] isEqualToString:@"M"])
        {
            lblPickerViewTitle.text = @"Set GPS Interval in Minutes";

            [self btnGpsMinClick];
        }
        else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"GPSIntervalType"] isEqualToString:@"H"])
        {
            lblPickerViewTitle.text = @"Set GPS Interval in Hours";

            [self btnGpsHourClick];
        }
    }
    else if (sender == 888)
    {
        [configPickerView selectRow:indexGpstimeout inComponent:0 animated:true];
        lblPickerViewTitle.text = @"Set GPS Timeout";
    }
}
#pragma mark - MEScrollToTopDelegate Methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [topPullToRefreshManager tableViewScrolled];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y >=360.0f)
    {
    }
    else
        [topPullToRefreshManager tableViewReleased];
}
- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    [self performSelector:@selector(stoprefresh) withObject:nil afterDelay:1.5];
}
-(void)stoprefresh
{
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    [tblContent reloadData];

    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
}
#pragma mark - PickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView.tag == 111)
    {
        return FrequencyArray.count;
    }
    else if (pickerView.tag == 222)
    {
        return bleTransmissionArray.count;
    }
    else if(pickerView.tag == 333)
    {
        return reportArray.count;
    }
    else if (pickerView.tag == 444)
    {
        return arrDatePickerHH.count;
    }
    else if(pickerView.tag == 555)
    {
        return arrDatePickerMM.count;
    }
    else if (pickerView.tag == 666)
    {
        return arrDatePickerSS.count;
    }
    else if (pickerView.tag == 777)
    {
        return arrGpsSecondMin.count;
    }
    else if (pickerView.tag == 888)
    {
        return arrGpsSecondMin.count;
    }
    return true;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView.tag == 111)
    {
        return FrequencyArray[row];
    }
    else if (pickerView.tag == 222)
    {
        return bleTransmissionArray[row];
    }
    else if (pickerView.tag == 333)
    {
        return [reportArray[row] valueForKey:@"pre_depth_meter"];
    }
    else if (pickerView.tag == 444)
    {
        return arrDatePickerHH[row];
    }
    else if(pickerView.tag == 555)
    {
        return arrDatePickerMM[row];
    }
    else if (pickerView.tag == 666)
    {
        return arrDatePickerSS[row];
    }
    else if (pickerView.tag == 777)
    {
        if (isGpsMinute)
        {
            return [NSString stringWithFormat:@"%@ Minutes",arrGpsSecondMin[row]];
        }
        return [NSString stringWithFormat:@"%@ Hours",arrGpsSecondMin[row]];
    }
    else if (pickerView.tag == 888)
    {
        return arrGpsSecondMin[row];
    }
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView.tag == 111)
    {
        strSelectedFrequency = FrequencyArray[row];
    }
    else if (pickerView.tag == 222)
    {
        strSelecetedBleTransmission = bleTransmissionArray[row];
    }
    else if(pickerView.tag == 333)
    {
        strSelectedReport = [reportArray[row] valueForKey:@"pre_depth_meter"];
        strDepthMilibar = [reportArray[row] valueForKey:@"pre_depth_milibar"];
    }
    else if (pickerView.tag == 444)
    {
        strElapsedTimeValueHH = arrDatePickerHH[row];
    }
    else if(pickerView.tag == 555)
    {
        strElapsedTimeValueMM = arrDatePickerMM[row];
    }
    else if (pickerView.tag == 666)
    {
        strElapsedTimeValueSS = arrDatePickerSS[row];
    }
    else if (pickerView.tag == 777)
    {
        strGpsInterval = arrGpsSecondMin[row];
    }
    else if (pickerView.tag == 888)
    {
        strGpsTimeout = arrGpsSecondMin[row];
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
                                [myView setFrame:CGRectMake(0,DEVICE_HEIGHT-315,DEVICE_WIDTH, 315)];
                            }
                            else
                            {
                                if (myView.tag == 777)
                                {
                                    [myView setFrame:CGRectMake(0,DEVICE_HEIGHT-215-50,DEVICE_WIDTH, 215+50)];
                                }
                                else
                                {
                                    [myView setFrame:CGRectMake(0,DEVICE_HEIGHT-215-50,DEVICE_WIDTH, 215+50)];
                                }
                            }
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
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    if (tableView == tblContent)
    {
        UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 45)];
        headerView.backgroundColor = [UIColor blackColor];
        
        UILabel *lblmenu=[[UILabel alloc]init];
        lblmenu.text = @" Tap on Connect button to pair with device";
        [lblmenu setTextColor:[UIColor whiteColor]];
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        lblmenu.frame = CGRectMake(5, 0, DEVICE_WIDTH, 45);
        [headerView addSubview:lblmenu];
        return headerView;
    }
    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == tblContent)
    {
        return 45;
    }
    return true;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblContent)
    {
        return [[[BLEManager sharedManager] foundDevices] count];
//        return 3;
    }
    return true;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblContent)
    {
        return 90;
    }
    return true;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    ConfigureSensorCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[ConfigureSensorCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    if (tableView == tblContent)
    {
        NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
        arrayDevices =[[BLEManager sharedManager] foundDevices];
        
        cell.btnMap.hidden = NO;

        if ([arrayDevices count]>0)
        {
            CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"peripheral"];
            cell.lblDeviceName.text = p.name;
            cell.lblAddress.text = [[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"address"];
            if (p.state == CBPeripheralStateConnected)
            {
                [cell.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            }
            
            NSString * strCheckLat = [APP_DELEGATE checkforValidString:[[arrayDevices objectAtIndex:indexPath.row] objectForKey:@"lat"]];
            if ([strCheckLat isEqualToString:@"0"] || [strCheckLat isEqualToString:@"NA"])
            {
                [cell.btnMap setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                cell.btnMap.enabled = NO;
            }
            else
            {
                [cell.btnMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                cell.btnMap.enabled = YES;
            }
        }
        
        cell.lblBack.hidden = NO;
        cell.lblDeviceName.hidden = NO;
        cell.lblAddress.hidden = NO;
        cell.lblConnect.hidden = NO;
        cell.lblLine.hidden = YES;
        cell.lblBackView.hidden = YES;
        cell.lblTitle.hidden = YES;
        cell.imgSymbol.hidden = YES;
        cell.lblInfo.hidden = YES;
        cell.btnConnect.hidden = NO;
        cell.btnMap.tag = indexPath.row;
        cell.btnConnect.tag = indexPath.row;
        [cell.btnMap addTarget:self action:@selector(btnMapListClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnConnect addTarget:self action:@selector(btnConnectClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView == tblContent)
    {
      /*  NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
        arrayDevices =[[BLEManager sharedManager] foundDevices];
        if ([arrayDevices count]>0)
        {
            CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
            myPeripheral = p;
            strSelectedBLEAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"address"];
            bleRememberDict = [[NSMutableDictionary alloc] init];
            bleRememberDict = [arrayDevices objectAtIndex:indexPath.row];
            
            [connectionTimer invalidate];
            connectionTimer  = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeOutMethodCall) userInfo:nil repeats:NO];
            
            if (p.state == CBPeripheralStateConnected)
            {
                isConnecting = NO;
                [APP_DELEGATE startHudProcess:@"Disconnecting..."];
                [self onDisconnectWithDevice:p];
            }
            else
            {
                isConnecting = YES;
                if (globalPeripheral.state == CBPeripheralStateConnected)
                {
                    [[BLEManager sharedManager] disconnectDevice:globalPeripheral];
                }
                connectionCount = 0;
                [APP_DELEGATE startHudProcess:@"Connecting..."];
                [self onConnectWithDevice:p];
            }
        }*/
    }
    
}
-(NSString *)GetBatteryImageName:(int)batValue
{
    NSString * strImageName = @"battery_0.png";
    if (batValue == 0)
    {
        strImageName = @"battery_0.png";
    }
    else if (batValue > 0 && batValue <= 25)
    {
        strImageName = @"battery_1.png";
    }
    else if (batValue > 25 && batValue <= 50)
    {
        strImageName = @"battery_2.png";
    }
    else if (batValue > 50 && batValue <= 90)
    {
        strImageName = @"battery_3.png";
    }
    else if (batValue == 100)
    {
        strImageName = @"battery_4.png";
    }
    return strImageName;
}
-(void)SendtimManually
{
    [APP_DELEGATE endHudProcess];
    [[BLEService sharedInstance] SetUTCTimetoDevice:globalPeripheral];

    NSDate * sendDate = [NSDate date];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"timeUfcType"] isEqualToString:@"+1"])
    {
        sendDate = [[NSDate date] dateByAddingTimeInterval:60*60];
    }
    else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"timeUfcType"] isEqualToString:@"-1"])
    {
        sendDate = [[NSDate date] dateByAddingTimeInterval:-3600];
    }

    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm:ss",[[NSUserDefaults standardUserDefaults] valueForKey:@"dateFormat"]]];
    NSString *dateString=[dateformatter stringFromDate:sendDate];
    NSLog(@"Time=%@",dateString);
    
    lblTimeDisplay.text = [NSString stringWithFormat:@"%@",dateString];
//    [tblBelowWater reloadData];

    [[arrayData objectAtIndex:5]setValue:[NSString stringWithFormat:@"%@",dateString] forKey:@"UTCTime"];
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Time has been set successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
    [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
    [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
        }];
    }];
    [alertView showWithAnimation:URBAlertAnimationTopToBottom];
}

#pragma mark - BLE Methods
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallNotificationforDiscover" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDeviceDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDeviceDidDisConnectNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CallNotificationforDiscover:) name:@"CallNotificationforDiscover" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:kDeviceDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:kDeviceDidDisConnectNotification object:nil];
}

-(void)CallNotificationforDiscover:(NSNotification*)notification//Update peripheral
{
    NSDictionary *dict = [notification userInfo];
    NSLog(@"NonConnectable dict=%@",dict);
    [tblContent reloadData];
}
-(void)callfirstAuthMethod
{
    strTypeNotify = @"Authentication";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"2303"];

}
-(void)startProcess
{
    [self performSelector:@selector(CallforSettingUTCTime) withObject:nil afterDelay:2];
    
    [tblContent reloadData];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    dict = [bleRememberDict mutableCopy];
    if (dict != nil)
    {
        if ([[[BLEManager sharedManager] foundDevices] count]>selectedIndex)
        {
            [dict setObject:globalPeripheral forKey:@"peripheral"];
            if ([[connectedDevice valueForKey:@"address"] containsObject:strSelectedBLEAddress])
            {
                for (int i =0; i< [connectedDevice count]; i++)
                {
                    if ([[[connectedDevice objectAtIndex:i] valueForKey:@"address"] isEqualToString:strSelectedBLEAddress])
                    {
                        [connectedDevice replaceObjectAtIndex:i withObject:dict];
                    }
                }
            }
            else
            {
                [connectedDevice addObject:dict];
            }
        }
    }
    
    
    NSString * strCheck = [NSString stringWithFormat:@"Select * from tbl_ble_device where ble_address = '%@'",strSelectedBLEAddress];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strCheck resultsArray:tmpArr];
    if ([tmpArr count] ==0)
    {
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Enter Device Name" cancelButtonTitle:OK_BTN otherButtonTitles:@"Cancel", nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView addTextFieldWithPlaceholder:@"Enter Device Name" secure:NO];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{
                if (buttonIndex ==0)
                {
                    if ([[alertView textForTextFieldAtIndex:0] length]>0)
                    {
                        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                        NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
                        
                        NSString * strInput = [NSString stringWithFormat:@"insert into 'tbl_ble_device'('device_id','ble_address','device_name','created_at','updated_at') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",self->strSelectedBLEAddress,self->strSelectedBLEAddress,[alertView textForTextFieldAtIndex:0],[NSString stringWithFormat:@"%@",timeStampObj],[NSString stringWithFormat:@"%@",timeStampObj]];
                        [[DataBaseManager dataBaseManager] execute:strInput];
                    }
                    else
                    {
                        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                        NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
                        
                        NSString * strInput = [NSString stringWithFormat:@"insert into 'tbl_ble_device'('device_id','ble_address','device_name','created_at','updated_at') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",self->strSelectedBLEAddress,self->strSelectedBLEAddress,@"DNT",[NSString stringWithFormat:@"%@",timeStampObj],[NSString stringWithFormat:@"%@",timeStampObj]];
                        [[DataBaseManager dataBaseManager] execute:strInput];
                        
                        /*URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enter valid device name." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
                         [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
                         [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                         [alertView hideWithCompletionBlock:^{
                         }];
                         }];
                         [alertView showWithAnimation:URBAlertAnimationTopToBottom];*/
                    }
                }
                [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1536"];
                [self performSelector:@selector(afterDelayCallforSyncing) withObject:nil afterDelay:2];
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
        [self performSelector:@selector(afterDelayCallforSyncing) withObject:nil afterDelay:2];
    }

}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
    NSLog(@"Device Connet Stop progress");
    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Device Connected..."];
    [[BLEService sharedInstance] EnableNotificationsForCommand:globalPeripheral withType:YES];
    [[BLEService sharedInstance] EnableNotificationsForDATA:globalPeripheral withType:YES];
    [self performSelector:@selector(callfirstAuthMethod) withObject:nil afterDelay:2];
}
-(void)afterDelayCallforSyncing
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoSync"])
    {
        NSLog(@"CallforSyncing STOPED");

        isSyncingYet = YES;
        [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"3327"];
        [APP_DELEGATE endHudProcess];
        [APP_DELEGATE startHudProcess:@"Percentage"];
        lblProgress.text = @"0%";
        
        [checkConnectionTimer invalidate];
        checkConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(forSuddenDisconnection) userInfo:nil repeats:YES];
    }
    else
    {
        [APP_DELEGATE endHudProcess];
        
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Device has been connected successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        
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
-(void)CallforSettingUTCTime
{
    [[BLEManager sharedManager] justStopScanning];
    [[BLEService sharedInstance] SetUTCTimetoDevice:globalPeripheral];
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
    NSLog(@"Disconnect STOPED");
    [APP_DELEGATE endHudProcess];
    isConnecting = NO;
    [tblContent reloadData];
    
    if (isSyncingYet == YES)
    {
        [APP_DELEGATE endHudProcess];

        if (isDataAlreadyAvailable == NO)
        {
            NSMutableArray * tmpsArr = [[NSMutableArray alloc] init];
            NSString * str0 = [NSString stringWithFormat:@"select * from tbl_dive where dive_id = %d",tableDiveId];
            [[DataBaseManager dataBaseManager] execute:str0 resultsArray:tmpsArr];
            NSLog(@"MY Data=%@",tmpsArr);
            
            NSString * str1 = [NSString stringWithFormat:@"delete from tbl_dive where dive_id = %d",tableDiveId];
            [[DataBaseManager dataBaseManager] execute:str1];
            
            
            NSString * str2 = [NSString stringWithFormat:@"delete from tbl_pre_temp where pre_temp_dive_id = %d",tableDiveId];
            [[DataBaseManager dataBaseManager] execute:str2];
        }
    }
}
-(void)onConnectButton:(NSInteger)sender//Connect & DisconnectClicked
{
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    
    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [arrayDevices objectAtIndex:sender];
        globalPeripheral = p;
        if (p.state == CBPeripheralStateConnected)
        {
            [self onDisconnectWithDevice:p];
        }
        else
        {
            [self onConnectWithDevice:p];
        }
    }
}
#pragma mark - Ble device Disconnect method
-(void)onDisconnectWithDevice:(CBPeripheral*)peripheral
{
    [[BLEManager sharedManager] disconnectDevice:peripheral];
}
#pragma mark - Ble device Connect method

-(void)onConnectWithDevice:(CBPeripheral*)peripheral
{
    [[BLEManager sharedManager] connectDevice:peripheral];
}
#pragma mark - CentralManager Ble delegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"DidupdateCenterlState=%ld",(long)central.state);
    
    if (@available(iOS 10.0, *))
    {
        if (central.state == CBCentralManagerStatePoweredOff || central.state == CBManagerStateUnknown)
        {
            [self GlobalBLuetoothCheck];
        }
    }
    else
    {
        if (central.state == CBCentralManagerStatePoweredOff)
        {
            [self GlobalBLuetoothCheck];
        }
    }
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        NSArray* connectedDevices = [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000AD00-D102-11E1-9B23-00025B002B2B"]]];
        for (CBPeripheral *uuid in connectedDevices)
        {
            NSLog(@"Device Found. UUID = %@", uuid);
            //            [[BLEManager sharedManager] disconnectDevice:uuid];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)UpdateBattery:(NSNotification *)notify
{
    NSLog(@"Btr Vl=%@",globBatry);
    lblBatteryLevel.text = [NSString stringWithFormat:@"%@%@",globBatry,@"%"];
    
    [[arrayData objectAtIndex:6]setValue:[NSString stringWithFormat:@"%@",globBatry] forKey:@"BatteryLevel"];
//    [[arrContent objectAtIndex:1] setValue:[NSString stringWithFormat:@"%@",globBatry] forKey:@"values"];
//    [tblBelowWater reloadData];
}
-(void)updateMemory:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Memory=%@",strValue);
    
    lblDeviceMemoryDisplay.text = [NSString stringWithFormat:@"%@%@",strValue,@"%"];
    [[arrayData objectAtIndex:7]setValue:[NSString stringWithFormat:@"%@",strValue] forKey:@"DeviceMemory"];

//    [[arrContent objectAtIndex:2] setValue:[NSString stringWithFormat:@"%@",strValue] forKey:@"values"];
//    [tblBelowWater reloadData];
    
    strTypeNotify = @"Version";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"2559"];
}
-(void)updateVersion:(NSNotification *)notify
{
    strTypeNotify = @"Version";
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Version=%@",strValue);
    
    lblVersionDisp.text =  [NSString stringWithFormat:@"(Firmware Version : %@)",strValue];
//    [[arrContent objectAtIndex:3] setValue:[NSString stringWithFormat:@"%@",strValue] forKey:@"values"];
//    [tblBelowWater reloadData];
    
    strTypeNotify = @"Battery";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"2815"];
}
-(void)UpdateManualBattery:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Time=%@",strValue);
    
    lblBatteryLevel.text = [NSString stringWithFormat:@"%@%@",strValue,@"%"];
    [[arrayData objectAtIndex:6]setValue:[NSString stringWithFormat:@"%@",strValue] forKey:@"BatteryLevel"];

//    [[arrContent objectAtIndex:1] setValue:[NSString stringWithFormat:@"%@",strValue] forKey:@"values"];
//    [tblBelowWater reloadData];
    
    strTypeNotify = @"UTCTime";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1791"];
}
-(void)updateUTCtime:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Time=%@",strValue);
    
    double timeStamp = [strValue doubleValue];
    NSTimeInterval timeInterval=timeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm:ss",[[NSUserDefaults standardUserDefaults] valueForKey:@"dateFormat"]]];
    NSString *dateString=[dateformatter stringFromDate:date];
    NSLog(@"Time=%@",dateString);
    
    lblTimeDisplay.text = [NSString stringWithFormat:@"%@",dateString];
    [[arrayData objectAtIndex:5]setValue:[NSString stringWithFormat:@"%@",dateString] forKey:@"UTCTime"];

//    [[arrContent objectAtIndex:0] setValue:[NSString stringWithFormat:@"%@",dateString] forKey:@"values"];
//    [tblBelowWater reloadData];
    
    strTypeNotify = @"Intervals";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"511"];
}
-(void)UpdateFrequencyInterval:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Frequency Interval=%@",strValue);
    
    NSInteger intervals = [strValue integerValue];
    if (intervals >= 3600)
    {
        NSString * strHrs = [NSString stringWithFormat:@"%ld",intervals/3600];
        if ([strHrs isEqualToString:@"1"])
        {
            lblFreqTimeDisplay.text =@"1 Hr";
        }
        else
        {
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Hrs",strHrs];
        }
        [[arrayData objectAtIndex:1]setValue:strHrs forKey:@"FreqIntervalHH"];
        strIntervalType = @"H";
        [btnHrs setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
        [btnMins setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnSecs setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:strIntervalType forKey:@"intervaltype"];
//        [[NSUserDefaults standardUserDefaults] setValue:strIntervalType forKey:@"SentIntervalType"];
//        [[NSUserDefaults standardUserDefaults] setValue:strHrs forKey:@"SentIntervalValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (intervals<3600 && intervals >=59)
    {
        NSString * strMins = [NSString stringWithFormat:@"%ld",intervals/60];
        lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Mins",strMins];
        strIntervalType = @"M";
        [[arrayData objectAtIndex:1]setValue:strMins forKey:@"FreqIntervalMM"];

        [btnHrs setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnMins setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
        [btnSecs setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:strIntervalType forKey:@ "intervaltype"];
//        [[NSUserDefaults standardUserDefaults] setValue:strIntervalType forKey:@"SentIntervalType"];
//        [[NSUserDefaults standardUserDefaults] setValue:strMins forKey:@"SentIntervalValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSString * strSecs = [NSString stringWithFormat:@"%ld",intervals];
        if ([strSecs isEqualToString:@"1"])
        {
            lblFreqTimeDisplay.text =@"1 Sec";
        }
        else
        {
            lblFreqTimeDisplay.text =[NSString stringWithFormat:@"%@ Secs",strSecs];
        }
        strIntervalType = @"S";
        [[arrayData objectAtIndex:1]setValue:strSecs forKey:@"FreqIntervalSS"];

        [btnHrs setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnMins setImage:[UIImage imageNamed:@"radiobuttonUnselected"]  forState:UIControlStateNormal];
        [btnSecs setImage:[UIImage imageNamed:@"radiobuttonSelectedWhite.png"]  forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:strIntervalType forKey:@"intervaltype"];
//        [[NSUserDefaults standardUserDefaults] setValue:strIntervalType forKey:@"SentIntervalType"];
//        [[NSUserDefaults standardUserDefaults] setValue:strSecs forKey:@"SentIntervalValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    strTypeNotify = @"DepthCutOff";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1535"];
}
-(void)UpdateDepthCutOff:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"Cut oFF=%@",strValue);
    
    NSString * strQuery = [NSString stringWithFormat:@"select * from tbl_pre_depth_cut_off where pre_depth_milibar ='%@'",strValue];
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArr];
    if ([tmpArr count]>0)
    {
        strSelectedReport = [[tmpArr objectAtIndex:0] valueForKey:@"pre_depth_meter"];
        strDepthMilibar = [[tmpArr objectAtIndex:0] valueForKey:@"pre_depth_milibar"];
        
        lblReportPicker.text = [NSString stringWithFormat:@"%@m",strSelectedReport];
        
        [[arrayData objectAtIndex:0] setValue:strSelectedReport forKey:@"FreqDepth"];

    }
    else
    {
        strSelectedReport = @"1.0";
        strDepthMilibar = @"1113";
    }
    strTypeNotify = @"BLETransmission";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"3839"];
}
-(void)UpdateBLETransmission:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"BLE Transmission=%@",strValue);
    
    
    if ([strValue isEqualToString:@"255"])
    {
        strSelecetedBleTransmission = @"Always";
    }
    else
    {
        strSelecetedBleTransmission = @"After dive 10 min";
    }
    lblBleTransmission.text = strSelecetedBleTransmission;
    indexBleTransmission = [bleTransmissionArray indexOfObject:strSelecetedBleTransmission];
    if (indexBleTransmission == NSNotFound)
    {
        indexBleTransmission = 0;
    }
//    [[NSUserDefaults standardUserDefaults] setValue:strSelecetedBleTransmission forKey:@"BLETransmission"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[arrayData objectAtIndex:2]setValue:strSelecetedBleTransmission forKey:@"BleTransmission"];
    strTypeNotify = @"GPSInterval";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1279"];

}
-(void)UpdateGPSInterval:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"GPS Interval=%@",strValue);

    NSString * strType = @"M";
    if ([strValue intValue] >=60)
    {
         strType = @"H";
        isGpsMinute = NO;
        strValue = [NSString stringWithFormat:@"%d",[strValue intValue]/60];
        if ([strValue isEqualToString:@"1"])
        {
            lblGPSInterval.text = @"1 Hour";
        }
        else
        {
            lblGPSInterval.text = [NSString stringWithFormat:@"%@ Hours",strValue];
        }
        [[arrayData objectAtIndex:3]setValue:strValue forKey:@"GPSintervalHH"];
    }
    else
    {
        strType = @"M";

        isGpsMinute = YES;
        if ([strValue isEqualToString:@"1"])
        {
            lblGPSInterval.text = @"1 Minute";
        }
        else
        {
            lblGPSInterval.text = [NSString stringWithFormat:@"%@ Minutes",strValue];
        }
        [[arrayData objectAtIndex:3]setValue:strValue forKey:@"GPSintervalMM"];
    }
    indexGpsInterval = [arrGpsSecondMin indexOfObject:strValue];
    if (indexGpsInterval == NSNotFound)
    {
        indexGpsInterval = 0;
    }
//    [[NSUserDefaults standardUserDefaults] setValue:strValue forKey:@"GPSInterval"];
    [[NSUserDefaults standardUserDefaults] setValue:strType forKey:@"GPSIntervalType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    strTypeNotify = @"GPStimeout";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"2047"];

}
-(void)UpdateGPSTimeOut:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strValue = [tmpDict valueForKey:@"value"];
    NSLog(@"GPS Timeout=%@",strValue);

    if ([strValue isEqualToString:@"1"])
    {
        lblGPSTimeout.text = @"1 Minute";

    }
    else
    {
        lblGPSTimeout.text = [NSString stringWithFormat:@"%@ Minutes",strValue];
    }
    indexGpstimeout = [arrGpsSecondMin indexOfObject:strValue];
    if (indexGpstimeout == NSNotFound)
    {
        indexGpstimeout = 0;
    }
//    [[NSUserDefaults standardUserDefaults] setValue:strValue forKey:@"GPStimeout"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [[arrayData objectAtIndex:3]setValue:strValue forKey:@"GPStimeOut"];

    isManualGPSCall = NO;
    strTypeNotify = @"CurrentGPS";
    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"1023"];
    
}
-(void)UpdateCurrentGPSlocation:(NSNotification *)notify
{
    NSDictionary * tmpDict = [notify object];
    NSString * strLat = [tmpDict valueForKey:@"lat"];
    NSString * strLong = [tmpDict valueForKey:@"long"];

    NSLog(@"Current GPS lat=%@ & long=%@",strLat,strLong);
    NSString * strValue = [NSString stringWithFormat:@"%@%@",strLat,strLong];
    [[NSUserDefaults standardUserDefaults] setValue:strValue forKey:@"CurrentGPS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [APP_DELEGATE endHudProcess];
    
    if (isManualGPSCall)
    {
        if (isleftscreen == YES)
        {
        }
        else
        {
            [alertGPSPopup removeFromSuperview];
            alertGPSPopup = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Recieved GPS data from device. Do you want to see location on Map?" cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
            [alertGPSPopup setMessageFont:[UIFont fontWithName:CGRegular size:12]];
            [alertGPSPopup setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithCompletionBlock:^{
                    if (buttonIndex==0)
                    {
                        MapClassVC * mapV = [[MapClassVC alloc] init];
                        mapV.isfromSettings = YES;
                        mapV.strLatitude = [APP_DELEGATE checkforValidString:strLat];
                        mapV.strLongitude = [APP_DELEGATE checkforValidString:strLong];
                        [self.navigationController pushViewController:mapV animated:YES];
                        
                    }
                }];
            }];
            [alertGPSPopup showWithAnimation:Alert_Animation_Type];
            if (IS_IPHONE_X)
            {
                [alertGPSPopup showWithAnimation:URBAlertAnimationDefault];
            }
        }
    }
}

-(void)timeOutMethodCall
{
    if (isConnecting)
    {
        [APP_DELEGATE endHudProcess];
    }
    else
    {
        if (globalPeripheral.state != CBPeripheralStateConnected)
        {
            NSLog(@"timeout Stop progress");
            [APP_DELEGATE endHudProcess];
        }
    }
}
-(void)forSuddenDisconnection
{
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        NSLog(@"all of sudden Stop progress");
        [APP_DELEGATE endHudProcess];
        [tblContent reloadData];
        if (isSyncingYet == YES)
        {
            if (isDataAlreadyAvailable == NO)
            {
                NSMutableArray * tmpsArr = [[NSMutableArray alloc] init];
                NSString * str0 = [NSString stringWithFormat:@"select * from tbl_dive where dive_id = %d",tableDiveId];
                [[DataBaseManager dataBaseManager] execute:str0 resultsArray:tmpsArr];
                
                NSString * str1 = [NSString stringWithFormat:@"delete from tbl_dive where dive_id = %d",tableDiveId];
                [[DataBaseManager dataBaseManager] execute:str1];
                
                NSString * str2 = [NSString stringWithFormat:@"delete from tbl_pre_temp where pre_temp_dive_id = %d",tableDiveId];
                [[DataBaseManager dataBaseManager] execute:str2];
            }
        }
        isSyncingYet = NO;
    }
}
-(void)SyncedSuccessfully
{
    [APP_DELEGATE endHudProcess];
    [checkConnectionTimer invalidate];

    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Data has been synced successfully." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
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
#pragma mark - CentralManager Ble delegate Methods
-(void)GlobalBLuetoothCheck
{
    URBAlertView * alertBlePopup = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Please enablooth Connection. To enable swipe up from the bottom of display and tap on Bluetooth icon." cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
    [alertBlePopup setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertBlePopup setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex==0)
            {
            }
        }];
    }];
    [alertBlePopup showWithAnimation:Alert_Animation_Type];
    if (IS_IPHONE_X)
    {
        [alertBlePopup showWithAnimation:URBAlertAnimationDefault];
    }
}
-(void)finishProcess
{
    [APP_DELEGATE endHudProcess];
    URBAlertView * alertBlePopup = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Data has been erased successfully from device." cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
    [alertBlePopup setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertBlePopup setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex==0)
            {
            }
        }];
    }];
    [alertBlePopup showWithAnimation:Alert_Animation_Type];
    if (IS_IPHONE_X)
    {
        [alertBlePopup showWithAnimation:URBAlertAnimationDefault];
    }
}
-(void)NoDataFoundMessage
{
    [checkConnectionTimer invalidate];
    [APP_DELEGATE endHudProcess];
    
    URBAlertView * alertBlePopup = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"No data found on device." cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
    [alertBlePopup setMessageFont:[UIFont fontWithName:CGRegular size:12]];
    [alertBlePopup setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        [alertView hideWithCompletionBlock:^{
            if (buttonIndex==0)
            {
            }
        }];
    }];
    [alertBlePopup showWithAnimation:Alert_Animation_Type];
    if (IS_IPHONE_X)
    {
        [alertBlePopup showWithAnimation:URBAlertAnimationDefault];
    }

}
//have to write nsnotificatio method for interval and then have to work on cutoff and then refresh send UTC time
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
//590052736674

