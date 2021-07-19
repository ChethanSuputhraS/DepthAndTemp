//
//  SelectionViewOptionsVC.h
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 07/12/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYSegmentedControl.h"

@interface SelectionViewOptionsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NYSegmentedControl *blueSegmentedControl;
    UITableView*tblContent;
    NSMutableArray *rawDataArr;
}
@property(nonatomic,assign)BOOL isCompared;
@property(nonatomic,strong)NSMutableDictionary *updatedDictInfo;
@end
