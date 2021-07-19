//
//  ConfigureSensorVC.h
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYSegmentedControl.h"


@interface ConfigureSensorVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UIScrollViewDelegate>
{
    NYSegmentedControl *blueSegmentedControl;
    UITableView *tblContent;
    UIView*listView,*viewPicker,*viewBelowWater;
    UIScrollView *settingsView;
    UIButton*btnDone;
    UIPickerView * configPickerView;
    UIImageView * imgRefresh;
    UIButton *refreshBtn,*btnPickerView,*btnFrequencyPostionValue;
    NSMutableArray *pairedDevicesArray,*FrequencyArray,*bleTransmissionArray,*reportArray,*arrDatePickerHH,*arrDatePickerMM,*arrDatePickerSS;
    long selectedIndex;
    NSString*strSelectedDevice, *strSelectedFrequency,*strSelecetedBleTransmission,*strSelectedReport,*strElapsedTimeValueHH,*strElapsedTimeValueMM,*strElapsedTimeValueSS,*strElapsedTimeValue, * strGpsInterval, * strGpsTimeout;
    
    UIButton*btnBelowWater,*btnIntervalValue,*btnApplyChanges;
    UILabel * lblPressureSelect,*lblReportPicker,*lblTimeSelect,*lblGPSTimeout,*lblApplyBack;
    bool isBtnBelowWaterClicked;
    bool isbtnPressureSelectClicked,isBtnTimeClicked,isReportON,isTimeOn;
    UILabel *lblReport,*lblTimelbl,*lblBleTransmission,*lblGPSInterval,*lblTimeDisplay,*lblBatteryLevel,*lblDeviceMemoryDisplay,*lblVersionDisp;
//    UIView *viewOtherOptions;
    
    UIView * viewTimeInterval;
    
    NSMutableArray * arrContent;
    UIButton * btnHrs, * btnMins, * btnSecs;
    NSString * strIntervalType;
    NSString * strDepthMilibar;
    NSInteger timeSentValue;
    UILabel*lblFreqTimeDisplay;
    long indexFreqDepth,indexFreqPos,indexBleTransmission,indexHH,indexMM,indexSS, indexGpsInterval, indexGpstimeout;
    float tmpCount;
    NSTimer * checkConnectionTimer;
    UIView * backProgress;
    UILabel*lblPickerViewTitle;
    NSMutableArray * arrGpsSecondMin;
    UIButton * btnMap;
    UIImageView * mapImg;
    UIView * backViewShadow ;
    NSInteger saveCount;
//    NSTimer *  msgTimer;

}
@end
