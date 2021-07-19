//
//  HeatMapVC.h
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 19/01/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeatMapVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *tblContent;
    UIView *viewBack;
    UIView *blurView;
    UISlider*tempSlider;
    UILabel*lblTempTitle;
    UILabel*lblMinTempDisp;
    UILabel*lblMaxTempDisp;
    NSMutableArray*TitleArr;
    NSInteger selectedIndex;
    double intVerylowTemp;
    double intlowTemp;
    double intMediumTemp;
    double intHighTemp;
    double intVeryHighTemp;
    long intHighestTempSelected85;
    long currentvalue;
//    UIButton *btnOK;
//    UILabel *lblErrMsg;
    int high;
    int low;
    
    NSMutableArray * optionArr;
    NSMutableArray * colorArr;
}

@end
