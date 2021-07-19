//
//  ConfigureSensorCustomCell.h
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigureSensorCustomCell : UITableViewCell

@property(nonatomic,strong)UILabel * lblAddress;
@property(nonatomic,strong)UILabel * lblDeviceName;
@property(nonatomic,strong)UILabel * lblConnect;
@property(nonatomic,strong)UILabel * lblLine;
@property(nonatomic,strong)UILabel * lblBack;
@property(nonatomic,strong)UIButton * btnMap;
@property(nonatomic,strong)UIButton * btnConnect;

@property(nonatomic,strong)UILabel * lblBackView;
@property(nonatomic,strong)UILabel * lblTitle;
@property(nonatomic,strong)UIImageView *imgSymbol;
@property(nonatomic,strong)UILabel * lblInfo;

@end
