//
//  ViewDataVC.h
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 04/12/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewDataVC : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIView *viewPicker;
    UIButton *btnSingleData,*btnCompare,*btndive,*btnTimeSelect,*btnDivePicker1,*btnDivePicker2,*btnDone,*btnStartDatePicker,*btnEndDatePicker;
    UILabel*lblSelectDive,*lblSelectDive2,*lblStartDate,*lblEndDate;
    UIPickerView*divePickerView;
    UIDatePicker *startDatePickerView,*endDatePickerView;
    NSMutableArray *diveArray, * deviceArray;
    NSDateFormatter *formatter;
    NSString *strStartDate,*strEndDate,*strSelectedDive1,*strSelectedDive2;
    NSDate *ConvertedtoNSdate1,*ConvertedtoNSdate2;
    long indexDevice1,indexDevice2,indexDive1,indexDive2;
    UILabel * lblSelectDevice,*lblselectdevice2;
    UIButton * btnDeviceSelect,*btnDeviceSelect2;
    BOOL isFromCompareButton;
    NSMutableDictionary*dictInfo;
    
    NSString * tblDevice1, * tblDevice2, * tblDive1, * tblDive2;
    NSInteger dev1Select, dev2Select, dive1Select, dive2Select;
    UILabel*lblPickerViewTitle;
}

@end
