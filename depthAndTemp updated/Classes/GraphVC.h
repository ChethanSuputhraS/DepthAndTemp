//
//  GraphVC.h
//  depthAndTemp
//
//  Created by stuart watts on 14/01/2019.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphVC : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    UITableView*tblContent;
    NSMutableArray *rawDataArr;
    UIView * viewRawData, * viewLineChart, * viewHeat;
}
@property(nonatomic,strong) NSArray * options;
@property(nonatomic,strong) NSMutableDictionary  * detailDict;

@property(nonatomic,assign) BOOL isCompared;
@property(nonatomic,strong) NSMutableDictionary *updatedDictInfo;

@end
