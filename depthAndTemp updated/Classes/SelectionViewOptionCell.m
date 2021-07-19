//
//  SelectionViewOptionCell.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 17/01/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "SelectionViewOptionCell.h"

@implementation SelectionViewOptionCell
@synthesize lblDive,lblTemp,lblTime,lblDepth;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {    // Initialization code
        
        self.contentView.backgroundColor = [UIColor clearColor];
        int zz = DEVICE_WIDTH/4;
        lblDive = [[UILabel alloc] init];
        [lblDive setBackgroundColor:[UIColor clearColor]];
        lblDive.textColor = UIColor.whiteColor;
        [lblDive setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [lblDive setTextAlignment:NSTextAlignmentCenter];
        lblDive.frame = CGRectMake(0,0,zz, 35);
        lblDive.numberOfLines = 2;
        [self.contentView addSubview:lblDive];
        
//        zz =(DEVICE_WIDTH-195);
        lblTime = [[UILabel alloc] init];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        lblTime.textColor = UIColor.whiteColor;
        [lblTime setFont:[UIFont fontWithName:CGRegular size:textSize-2]];
        [lblTime setTextAlignment:NSTextAlignmentCenter];
        lblTime.frame = CGRectMake(zz,0, zz, 35);
        lblTime.numberOfLines = 2;
        [self.contentView addSubview:lblTime];
        
//        zz =50+(DEVICE_WIDTH-195);
        lblDepth = [[UILabel alloc] init];
        [lblDepth setBackgroundColor:[UIColor clearColor]];
        lblDepth.textColor = UIColor.whiteColor;
        [lblDepth setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [lblDepth setTextAlignment:NSTextAlignmentCenter];
        lblDepth.frame = CGRectMake(zz*2, 0, zz, 35);
        lblDepth.numberOfLines = 2;
        [self.contentView addSubview:lblDepth];
        
//        zz=zz+75;
        lblTemp = [[UILabel alloc] init];
        [lblTemp setBackgroundColor:[UIColor clearColor]];
        lblTemp.textColor = UIColor.whiteColor;
        [lblTemp setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        [lblTemp setTextAlignment:NSTextAlignmentCenter];
        lblTemp.frame = CGRectMake(zz*3, 0,zz, 35);
        lblTemp.numberOfLines = 2;
        [self.contentView addSubview:lblTemp];
        
    }
    return self;
}

@end
