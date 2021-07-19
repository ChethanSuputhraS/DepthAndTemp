//
//  ConfigureSensorCustomCell.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "ConfigureSensorCustomCell.h"

@implementation ConfigureSensorCustomCell
@synthesize lblDeviceName,lblConnect,lblAddress,lblLine,lblBack,btnMap,lblTitle,lblBackView,imgSymbol,lblInfo, btnConnect;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {    // Initialization code

        self.backgroundColor = [UIColor clearColor];

        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(3, 0,DEVICE_WIDTH-6,80)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.7;
//        lblBack.layer.cornerRadius = 5;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor colorWithRed:1 green:1.0 blue:1.0 alpha:.8].CGColor;
        lblBack.layer.borderWidth = 1;
        [self.contentView addSubview:lblBack];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, DEVICE_WIDTH-24, 25)];
        lblDeviceName.numberOfLines = 2;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        lblDeviceName.textColor = UIColor.whiteColor;
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
//        lblDeviceName.text = @"Device Name";
        
        lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(8, 23, DEVICE_WIDTH-24, 20)];
        lblAddress.numberOfLines = 2;
        [lblAddress setBackgroundColor:[UIColor clearColor]];
        [lblAddress setTextColor:[UIColor lightGrayColor]];
        [lblAddress setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [lblAddress setTextAlignment:NSTextAlignmentLeft];
//        lblAddress.text = @"Ble Address";
        
        lblLine = [[UILabel alloc] initWithFrame:CGRectMake(3, 49.8, lblBack.frame.size.width-6, 0.2)];
        lblLine.backgroundColor = [UIColor lightGrayColor];

        imgSymbol = [[UIImageView alloc]init];
        imgSymbol.frame = CGRectMake(DEVICE_WIDTH-80, 30, 80, 30);
        imgSymbol.backgroundColor = UIColor.clearColor;

        btnConnect = [UIButton buttonWithType:UIButtonTypeCustom];
        btnConnect.frame = CGRectMake(3, 45, (DEVICE_WIDTH/2)-3, 35);
        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        [btnConnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnConnect.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+1];
        btnConnect.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btnConnect.layer.borderWidth = 0.5;
        btnConnect.hidden = YES;
        
        btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMap.frame = CGRectMake((DEVICE_WIDTH/2), 45, (DEVICE_WIDTH/2)-3, 35);
//        [btnMap setImage:[UIImage imageNamed:@"map2.png"] forState:UIControlStateNormal];
        [btnMap setTitle:@"Location" forState:UIControlStateNormal];
        [btnMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnMap.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+1];
        btnMap.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btnMap.layer.borderWidth = 0.5;

        btnMap.hidden = YES;
        
        lblBackView = [[UILabel alloc]initWithFrame:CGRectMake(5,0, DEVICE_WIDTH-10, 44)];
        lblBackView.backgroundColor = UIColor.grayColor;
        lblBackView.alpha = 0.3;
        
        lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10,7, 170,30)];
        lblTitle.backgroundColor = UIColor.clearColor;
        [lblTitle setTextColor:[UIColor whiteColor]];
        [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblTitle setTextAlignment:NSTextAlignmentLeft];

        lblInfo = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-45, 7, 40, 30)];
        lblInfo.backgroundColor = UIColor.clearColor;
        [lblInfo setTextColor:[UIColor whiteColor]];
        [lblInfo setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblInfo setTextAlignment:NSTextAlignmentLeft];

        [self.contentView addSubview:lblDeviceName];
        [self.contentView addSubview:lblAddress];
        [self.contentView addSubview:lblConnect];
        [self.contentView addSubview:lblLine];
        [self.contentView addSubview:imgSymbol];
        [self.contentView addSubview:lblBackView];
        [self.contentView addSubview:btnMap];
        [self.contentView addSubview:btnConnect];
        [self.contentView addSubview:lblTitle];
        [self.contentView addSubview:lblInfo];


    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
