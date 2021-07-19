//
//  HeatMapVCcell.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 19/01/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "HeatMapVCcell.h"

@implementation HeatMapVCcell
@synthesize imgColor,lblTitle,lblTempValues;
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
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {    // Initialization code
        
        imgColor = [[UIImageView alloc]init];
        imgColor.frame = CGRectMake(5,6,32,32);
        imgColor.backgroundColor = UIColor.redColor;
        imgColor.layer.masksToBounds = true;
        imgColor.layer.cornerRadius = 16;
        imgColor.layer.borderWidth = 1;
        imgColor.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:imgColor];

        lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(55,0,DEVICE_WIDTH-50,22)];
        lblTitle.backgroundColor = UIColor.clearColor;
        [lblTitle setTextColor:[UIColor whiteColor]];
        [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblTitle setTextAlignment:NSTextAlignmentLeft];
        lblTitle.textAlignment = NSTextAlignmentLeft;
        lblTitle.text = @"Very High Temperature";
        [self.contentView addSubview:lblTitle];
        
        lblTempValues = [[UILabel alloc]initWithFrame:CGRectMake(55,20,DEVICE_WIDTH-50,22)];
        lblTempValues.backgroundColor = UIColor.clearColor;
        [lblTempValues setTextColor:[UIColor darkGrayColor]];
        [lblTempValues setFont:[UIFont fontWithName:CGRegular size:textSize-2]];
        [lblTempValues setTextAlignment:NSTextAlignmentLeft];
        lblTempValues.textAlignment = NSTextAlignmentLeft;
        lblTempValues.text = @"Temp - -40º C to 30º C";
        [self.contentView addSubview:lblTempValues];
        
    }
    return self;
}
@end
