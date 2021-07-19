//
//  AppSettingsVC.h
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 05/12/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingsVC : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIButton *btnMinus1,*btnPlus1,*btn0,*btnDateFormatPick,*btnDone,*btnC,*btnF;
    UIPickerView*dateFormatPickerView;
    UIView*viewPicker;
    NSMutableArray*dateFormatArr;
    NSString*strSelectedDate, * strShowDate;
    long indexDate;
    NSArray * valueArr;
}
@end
