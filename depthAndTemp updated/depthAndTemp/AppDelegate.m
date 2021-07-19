//
//  AppDelegate.m
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "AppDelegate.h"
#import "DataBaseManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "BLEService.h"
#import "BLEManager.h"
#import "ConfigureSensorVC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Fabric with:@[[Crashlytics class]]];
    
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
    
    self.window = [[UIWindow alloc]init];
    self.window.frame = self.window.bounds;
    [self setUpFrames];
    [self.window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setAllDefaultValues];
    
        [[BLEService sharedInstance] CheckPacketwithdetails:[@"FFFFFFFE5D010EF303474D62FFECB3AF000A" lowercaseString] withFullPacket:[@"FFFFFFFE5D010EF303474D62FFECB3AF000A" lowercaseString]];

    return YES;
}
-(float)GetLatitudeLongitudevalue:(NSString *)strHex
{
    NSString * valueStr = strHex;
    NSString * strFinal = [self stringFroHex:valueStr];
    
    NSString * strHalf = [NSString stringWithFormat:@"%@.%@", [strFinal substringWithRange:NSMakeRange(2, 2)],[strFinal substringWithRange:NSMakeRange(4, 4)]];
//    NSString * strHalf = [strFinal substringWithRange:NSMakeRange(2,[valueStr length]-2)];

    float afterDec = [strHalf floatValue]/60;
    
    float final = [[strFinal substringWithRange:NSMakeRange(0, 2)] floatValue] + afterDec;
    return final;
}
-(float)getSignedIntfromHex:(NSString *)hexStr
{
    NSString *tempNumber = hexStr;
    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    float actualInt = (int16_t)(temp);
    return actualInt;
}
-(float)getSignedInt32fromHex:(NSString *)hexStr
{
    NSString *tempNumber = hexStr;
    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    float actualInt = (int32_t)(temp);
    return actualInt;
}

#pragma mark - SetUp Frames
-(void) setUpFrames
{
//    ConfigureSensorVC *rootView = [[ConfigureSensorVC alloc]init];
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
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""] && ![strRequest isEqualToString:@"(null)"])
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
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"timeUfcType"];
        [[NSUserDefaults standardUserDefaults] setValue:@"°C" forKey:@"temperatureType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setHeatMapValues];
    }
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"GPSInterval"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"GPSInterval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setHeatMapValues];
    }
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"GPStimeout"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"GPStimeout"];
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


-(void)DebuggindCodehere
{
    NSLog(@"HERE>>>%@",[self stringFroHex:@"5CE2C653"]);
    // Override point for customization after application launch.
    
    //    00ba3ae8 048d4c99
    NSString * valueStr = @"00ba3ae8";
    NSRange rangeFirst = NSMakeRange(0, 4);
    NSString * strV1 = [self stringFroHex:valueStr];
    rangeFirst = NSMakeRange(4, 4);
    NSString * strV2 = [self stringFroHex:[valueStr substringWithRange:rangeFirst]];
    strLat = [NSString stringWithFormat:@"%@.%@",strV1,strV2];
    
    /* Logic
     1. convert hex to integer (00ba3ae8 ==> 12204776)
     2. take first two digits separate 12
     3. now take next two digits and divide them by 60 (20/60 = 0.33333)
     4. now last 4 digits, put point between two of them(47.76). Now divide this value by 3600 (47.76/3600 = 0.01326666667)
     5. now do addition of value of step 2 + step 3 + step 4 (12 + 0.33333 + 0.013266666) = 12.346596666
     
     
     Another Logiv
     1. convert hex to integer (00ba3ae8 ==> 12204776)
     2. take first two digits separate 12
     3. now put point after next two digits (20.4776) and divide it by 60 (20.4776/60) = 0.3412933333
     4. do addition of step 2 + step 3 = 12 + 0.3412933333 = 12.3412933333
     */
    //    lat : 03474cd2
    // long :  ffecb3c7
    valueStr = @"03474cd2";
    rangeFirst = NSMakeRange(0, 4);
    NSString * strV12 = [self stringFroHex:[valueStr substringWithRange:rangeFirst]];
    rangeFirst = NSMakeRange(4, 4);
    NSString * strV22 = [self stringFroHex:[valueStr substringWithRange:rangeFirst]];
    strLong = [NSString stringWithFormat:@"%@.%@",strV12,strV22];
    
    NSLog(@"lat=%f", [self GetLatitudeLongitudevalue:@"00ba3ae8"]);
    NSLog(@"long=%f", [self GetLatitudeLongitudevalue:@"048d4c99"]);
    
    //    NSLog(@"VVVVV=%f", [self getSignedInt32fromHex:@"BA3AEA"]/1000000);
    //    float mIntLocationPrefix = [self getSignedInt32fromHex:@"BA3AEA"] / 1000000;
    //    int kkk = [self getSignedInt32fromHex:@"BA3AEA"];
    //    int mIntLocationPostfix = kkk % 1000000;
    //
    //    NSLog(@"%f + %d",mIntLocationPrefix,mIntLocationPostfix);
    //
    //    double mLongDouble = (double)mIntLocationPostfix /600000;
    //    NSLog(@"%f ",mLongDouble);
    //    double finalSol = mLongDouble + (double)mIntLocationPrefix;
    //    NSLog(@"final lat is %f ",finalSol);
    
    //    lat : 03474cd2
    // long :  ffecb3c7
    
    NSLog(@"final lat is %f ",[self getSignedInt32fromHex:[@"ffecb3c7" uppercaseString]]);
    NSString *hexValueLat = [@"ffecb3c7" uppercaseString];
    
    int intConvertedLat = 0;
    
    NSScanner *firstScanner = [NSScanner scannerWithString:hexValueLat];
    
    [firstScanner scanHexInt:&intConvertedLat];
    
    NSLog(@"First: %d",intConvertedLat);
    
    
    int mIntLocationPrefix = intConvertedLat / 1000000;
    int mIntLocationPostfix = intConvertedLat % 1000000;
    NSLog(@"%d + %d",mIntLocationPrefix,mIntLocationPostfix);
    
    double mLongDouble = (double)mIntLocationPostfix /600000;
    NSLog(@"%f ",mLongDouble);
    double finalSol = mLongDouble + (double)mIntLocationPrefix;
    NSLog(@"final lat is %f ",finalSol);
    
    [[BLEManager sharedManager] CheckScnningLatLong];
    //    [[BLEService sharedInstance] CheckPacketwithdetails:[@"0002001e0db008d20e5d09140e9709190eb30907" uppercaseString] withFullPacket:[@"0002001e0db008d20e5d09140e9709190eb30907" uppercaseString]];
    //55.004805
    //    -1.436737

}


@end
