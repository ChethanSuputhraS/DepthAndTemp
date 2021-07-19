//
//  SelectionViewOptionsVC.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 07/12/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "SelectionViewOptionsVC.h"
#import "SelectionViewOptionCell.h"
@interface SelectionViewOptionsVC ()
@end

@implementation SelectionViewOptionsVC
@synthesize isCompared,updatedDictInfo;

- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.clearColor;
    
    UIImageView * imgBack = [[UIImageView alloc] init];
    imgBack.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgBack.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgBack.userInteractionEnabled = YES;
    [self.view addSubview:imgBack];
    
    [self setNavigationViewFrames];
    [self setMainViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Device Data"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGBold size:textSize+3]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * backImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12+20, 12, 20)];
    [backImg setImage:[UIImage imageNamed:@"back_icon.png"]];
    [backImg setContentMode:UIViewContentModeScaleAspectFit];
    backImg.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:backImg];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 70, 64);
    btnBack.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:btnBack];
    
    if (IS_IPHONE_X)
    {
        viewHeader.frame = CGRectMake(0, 0, DEVICE_WIDTH, 88);
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        backImg.frame = CGRectMake(10, 12+44, 12, 20);
        btnBack.frame = CGRectMake(0, 0, 70, 88);
    }
}
-(void)setMainViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 88;
    }
    
    
    yy = yy ;
    UILabel * lblDevice1lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,100, 25)];
    lblDevice1lbl.textColor = UIColor.whiteColor;
    lblDevice1lbl.backgroundColor = UIColor.clearColor;
    lblDevice1lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDevice1lbl.textAlignment = NSTextAlignmentLeft;
    lblDevice1lbl.text = @"Device :";
    [self.view addSubview:lblDevice1lbl];
    
    UILabel*lblDevice1Name = [[UILabel alloc]init];
    lblDevice1Name.frame = CGRectMake(DEVICE_WIDTH-170, yy, 170, 25);
    lblDevice1Name.textColor = UIColor.whiteColor;
    lblDevice1Name.backgroundColor = UIColor.clearColor;
    lblDevice1Name.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDevice1Name.textAlignment = NSTextAlignmentLeft;
    lblDevice1Name.text = [updatedDictInfo valueForKey:@"dev1"];
    [self.view addSubview:lblDevice1Name];
    
    yy = yy +20;
    UILabel * lblDive1Lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,100, 25)];
    lblDive1Lbl.textColor = UIColor.whiteColor;
    lblDive1Lbl.backgroundColor = UIColor.clearColor;
    lblDive1Lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDive1Lbl.textAlignment = NSTextAlignmentLeft;
    lblDive1Lbl.text = @"Dive :";
    [self.view addSubview:lblDive1Lbl];
    
    UILabel*lblDive1Name = [[UILabel alloc]init];
    lblDive1Name.frame = CGRectMake(DEVICE_WIDTH-170, yy, 170, 25);
    lblDive1Name.textColor = UIColor.whiteColor;
    lblDive1Name.backgroundColor = UIColor.clearColor;
    lblDive1Name.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDive1Name.textAlignment = NSTextAlignmentLeft;
    lblDive1Name.text = [updatedDictInfo valueForKey:@"dive1"];
    [self.view addSubview:lblDive1Name];
    
    yy = yy+30;
    UILabel * lblDevice2lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,100, 25)];
    lblDevice2lbl.textColor = UIColor.whiteColor;
    lblDevice2lbl.backgroundColor = UIColor.clearColor;
    lblDevice2lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDevice2lbl.textAlignment = NSTextAlignmentLeft;
    lblDevice2lbl.text = @"Device 2 :";
    lblDevice2lbl.hidden = YES;
    [self.view addSubview:lblDevice2lbl];
    
    UILabel*lblDevice2Name = [[UILabel alloc]init];
    lblDevice2Name.frame = CGRectMake(DEVICE_WIDTH-170, yy, 170, 25);
    lblDevice2Name.textColor = UIColor.whiteColor;
    lblDevice2Name.backgroundColor = UIColor.clearColor;
    lblDevice2Name.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDevice2Name.textAlignment = NSTextAlignmentLeft;
    lblDevice2Name.text = [updatedDictInfo valueForKey:@"dev2"];
    lblDevice2Name.hidden = YES;
    [self.view addSubview:lblDevice2Name];
    
    yy = yy +20;
    UILabel * lblDive2Lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, yy,100, 25)];
    lblDive2Lbl.textColor = UIColor.whiteColor;
    lblDive2Lbl.backgroundColor = UIColor.clearColor;
    lblDive2Lbl.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDive2Lbl.textAlignment = NSTextAlignmentLeft;
    lblDive2Lbl.text = @"Dive 2 : ";
    lblDive2Lbl.hidden = YES;
    [self.view addSubview:lblDive2Lbl];
    
    UILabel*lblDive2Name = [[UILabel alloc]init];
    lblDive2Name.frame = CGRectMake(DEVICE_WIDTH-170, yy, 170, 25);
    lblDive2Name.textColor = UIColor.whiteColor;
    lblDive2Name.backgroundColor = UIColor.clearColor;
    lblDive2Name.font = [UIFont fontWithName:CGRegular size:textSize-2];
    lblDive2Name.textAlignment = NSTextAlignmentLeft;
    lblDive2Name.text = [updatedDictInfo valueForKey:@"dive2"];
    lblDive2Name.hidden = YES;
    [self.view addSubview:lblDive2Name];
    
    yy=yy+30;
    
    blueSegmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"Raw Data", @"Line Chart",@"Heat Map"]];
    blueSegmentedControl.titleTextColor = [UIColor blackColor];
    blueSegmentedControl.selectedTitleTextColor = [UIColor whiteColor];
    blueSegmentedControl.segmentIndicatorBackgroundColor = [UIColor blackColor];
    blueSegmentedControl.backgroundColor = [UIColor whiteColor];
    blueSegmentedControl.borderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorBorderWidth = 0.0f;
    blueSegmentedControl.segmentIndicatorInset = 2.0f;
    blueSegmentedControl.segmentIndicatorBorderColor = self.view.backgroundColor;
    blueSegmentedControl.cornerRadius = 20;
    blueSegmentedControl.usesSpringAnimations = YES;
    [blueSegmentedControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
//    [blueSegmentedControl setFrame:CGRectMake(10,yy, DEVICE_WIDTH-20, 50)];
    blueSegmentedControl.layer.cornerRadius = 20;
    blueSegmentedControl.layer.masksToBounds = YES;
    [self.view addSubview:blueSegmentedControl];
    
    if (isCompared == false)
    {
        lblDevice2lbl.hidden = false;
        lblDevice2Name.hidden = false;
        lblDive2Lbl.hidden = false;
        lblDive2Name.hidden = false;
        lblDevice1lbl.text = @"Device 1 :";
        lblDive1Lbl.text = @"Dive 1 :";
        [blueSegmentedControl setFrame:CGRectMake(10,yy, DEVICE_WIDTH-20, 30)];
    }
    else if(isCompared == true)
    {
        lblDevice2lbl.hidden = true;
        lblDevice2Name.hidden = true;
        lblDive2Lbl.hidden = true;
        lblDive2Name.hidden = true;
        lblDevice1lbl.text = @"Device :";
        lblDive1Lbl.text = @"Dive :";
        [blueSegmentedControl setFrame:CGRectMake(10,yy-50, DEVICE_WIDTH-20, 30)];
    }
    yy = yy - 5;
    tblContent = [[UITableView alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH,DEVICE_HEIGHT-yy) style:UITableViewStylePlain];
    tblContent.delegate = self;
    tblContent.dataSource = self;
    [tblContent setShowsVerticalScrollIndicator:NO];
    tblContent.backgroundColor = [UIColor clearColor];
    tblContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblContent.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblContent];
    
}
-(void)segmentClick:(NYSegmentedControl *) sender
{
    if (sender.selectedSegmentIndex==0)
    {
        
        
        
    }
    else if (sender.selectedSegmentIndex==1)
    {
       
    }
    else if (sender.selectedSegmentIndex==2)
    {
        
    }
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 45)];
    headerView.backgroundColor = [UIColor blackColor];
    
    int zz = 50;
    UILabel *lblDive=[[UILabel alloc]init];
    lblDive.text = @"Dive";
    [lblDive setTextColor:[UIColor whiteColor]];
    lblDive.backgroundColor = UIColor.clearColor;
    [lblDive setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    lblDive.frame = CGRectMake(0,0,zz, 35);
    lblDive.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:lblDive];
    
    zz =(DEVICE_WIDTH-195);
    UILabel *lbltime=[[UILabel alloc]init];
    lbltime.text = @"Time";
    [lbltime setTextColor:[UIColor whiteColor]];
    [lbltime setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    lbltime.frame = CGRectMake(50,0, zz, 35);
    lbltime.textAlignment = NSTextAlignmentCenter;
    lbltime.backgroundColor = UIColor.clearColor;
    [headerView addSubview:lbltime];
    
    zz =50+(DEVICE_WIDTH-195);
    UILabel *lblDepth=[[UILabel alloc]init];
    lblDepth.text = @"Depth(m)";
    [lblDepth setTextColor:[UIColor whiteColor]];
    [lblDepth setFont:[UIFont fontWithName:CGRegular size:textSize]];
    lblDepth.frame = CGRectMake(zz, 0, 75, 35);
    lblDepth.textAlignment = NSTextAlignmentCenter;
    lblDepth.backgroundColor = UIColor.clearColor;
    [headerView addSubview:lblDepth];
    
    zz=zz+75;
    UILabel *lblTemp=[[UILabel alloc]init];
    lblTemp.text = @"Temp";
    [lblTemp setTextColor:[UIColor whiteColor]];
    [lblTemp setFont:[UIFont fontWithName:CGRegular size:textSize+1]];
    lblTemp.frame = CGRectMake(zz, 0,70, 35);
    lblTemp.textAlignment = NSTextAlignmentCenter;
    lblTemp.backgroundColor = UIColor.clearColor;
    [headerView addSubview:lblTemp];
    
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 35;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    SelectionViewOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[SelectionViewOptionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
#pragma mark - Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
