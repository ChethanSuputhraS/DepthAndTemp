//
//  AppDelegate.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "AppDelegate.h"
#import "DataBaseManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    savedMaxC = (savedValMax - 32) * (5/9)
    
//    NSDate *lastUpdate = [[NSDate alloc] initWithTimeIntervalSince1970:946699800];
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    
    if (IS_IPHONE_6plus)
    {
        approaxSize = 1.29;
    }
    else if (IS_IPHONE_6 || IS_IPHONE_X)
    {
        approaxSize = 1.17;
    }
    else
    {
        approaxSize = 1;
    }
    
    if (IS_IPHONE_X)
    {
        statusHeight = 88;
    }
    else
    {
        statusHeight = 64;
    }
    
    textSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        textSize = 15;
    }
    
    [[DataBaseManager dataBaseManager] openDatabase];
//    [[DataBaseManager dataBaseManager] Create_tbl_dive];
//    [[DataBaseManager dataBaseManager] Create_tbl_pre_temp];
    
//    NSString *strDesc = [NSString stringWithFormat:@"insert into 'tbl_dive' ('ble_address','dive_no','utc_time','gps_latitude','gps_longitude','created_at','updated_at') values('test1','1','test','test','test','test','test')"];
//    [[DataBaseManager dataBaseManager] execute:strDesc];
//
//    NSString *strResult = [NSString stringWithFormat:@"insert into 'tbl_pre_temp'('dive_id','pressure','utc_time','created_at','updated_at') values('1','test','test','test','test')"];
//    [[DataBaseManager dataBaseManager] execute:strResult];
    
    self.window = [[UIWindow alloc]init];
    self.window.frame = self.window.bounds;
    [self setUpFrames];
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setAllDefaultValues];
    // Override point for customization after application launch.
    return YES;
}
#pragma mark - SetUp Frames
-(void) setUpFrames
{
    HomeVC *rootView = [[HomeVC alloc]init];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:rootView];
    navigation.navigationBarHidden = YES;
    
    self.window.rootViewController = navigation;
    
}
#pragma mark Hud Method
#pragma mark Hud Method
-(void)startHudProcess:(NSString *)text
{
    [HUD removeFromSuperview];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    HUD.labelText = text;
    [self.window addSubview:HUD];
    [HUD show:YES];
    
    if ([text isEqualToString:@"Percentage"])
    {
        HUD.mode = MBProgressHUDModeAnnularDeterminate;
        HUD.labelText = @"Downloading... \n\n";
        [lblProgress removeFromSuperview];
        lblProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, (HUD.frame.size.height-30)/2+40, HUD.frame.size.width, 40)];
        lblProgress.textAlignment = NSTextAlignmentCenter;
        lblProgress.font = [UIFont fontWithName:CGBold size:textSize+3];
        lblProgress.textColor = [UIColor whiteColor];
        lblProgress.backgroundColor = [UIColor clearColor];
        [HUD addSubview:lblProgress];
    }
}
-(void)endHudProcess
{
    [HUD hide:YES];
    [lblProgress removeFromSuperview];
}
-(void)ProgresswithPercentage:(float)progressVal;
{
    HUD.progress = progressVal/100;
    lblProgress.text = [NSString stringWithFormat:@"%.0f%%",progressVal];
}

-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return strValid;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}
-(NSString*)hexFromStr:(NSString*)str
{
    NSData* nsData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const char* data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString* hex = [NSMutableString string];
    for(int i = 0; i < len; ++i)
        [hex appendFormat:@"%02X", data[i]];
    return hex;
}

-(void)setAllDefaultValues
{
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"intervaltype"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"H" forKey:@"intervaltype"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"frequencyPosition"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"10 Sec" forKey:@"frequencyPosition"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"BLETransmission"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"Always" forKey:@"BLETransmission"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"PressureDepth"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"0.1" forKey:@"PressureDepth"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"dateFormat"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"YYYY-MM-dd" forKey:@"dateFormat"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"HeatMapValues"] count]==0)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAutoSync"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setHeatMapValues];
    }
}
-(void)setHeatMapValues
{
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    NSArray * arrlow = [NSArray arrayWithObjects:@"50",@"30",@"10",@"-10",@"-40", nil];
    NSArray * arrHigh = [NSArray arrayWithObjects:@"85",@"50",@"30",@"10",@"-10", nil];
    NSArray * arrName = [NSArray arrayWithObjects:@"Very High Temperature",@"High Temperature",@"Medium Temperature",@"Low Temperature",@"Very Low Temperature", nil];

    for (int i = 0; i<[arrlow count]; i++)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[arrlow objectAtIndex:i] forKey:@"lowC"];
        [dict setObject:[arrHigh objectAtIndex:i] forKey:@"highC"];
        [dict setObject:[arrName objectAtIndex:i] forKey:@"name"];
        
        double tmpLowF = (([[arrlow objectAtIndex:i] doubleValue] )*1.8) + 32;
        double tmpHighF = (([[arrHigh objectAtIndex:i] doubleValue] )*1.8) + 32;
        [dict setObject:[NSString stringWithFormat:@"%.0f",tmpLowF] forKey:@"lowF"];
        [dict setObject:[NSString stringWithFormat:@"%.0f",tmpHighF] forKey:@"highF"];
        [tmpArr addObject:dict];
    }
    [[NSUserDefaults standardUserDefaults] setObject:tmpArr forKey:@"HeatMapValues"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(NSString *)GetLocalTimefromUTC:(NSString *)strValue
{
    double timeStamp = [strValue doubleValue]/1000;
    NSTimeInterval timeInterval=timeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"HH:mm:ss"];
    NSString *dateString=[dateformatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",dateString];
}


@end
