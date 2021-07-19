//
//  AppDelegate.h
//  depthAndTemp
//
//  Created by srivatsa s pobbathi on 28/11/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"
#import "MBProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>


int textSize;
CGFloat approaxSize;
int statusHeight;
MBProgressHUD *HUD;
NSString * globBatry;
CBCharacteristic * globalBtryChar;
NSNumber * stationarySecs;
NSNumber * movingSecs;
NSNumber * gpsSeconds;
NSNumber  * bleGpsCutoffSec;
 CBPeripheral *globalPeripheral;
NSString * strTypeNotify;
NSMutableArray * globalDataArr;
double globFirstDate;
BOOL isDataAlreadyAvailable;
int tableDiveId;
BOOL isSyncingYet;
UILabel * lblProgress;
BOOL isCentralAssigned;
NSMutableArray * connectedDevice;
NSString * strLat, * strLong;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
   

}
@property (strong, nonatomic) UIWindow *window;

#pragma mark - Helper Methods

-(void)startHudProcess:(NSString *)text;
-(void)endHudProcess;
-(NSString *)checkforValidString:(NSString *)strRequest;

-(NSString*)stringFroHex:(NSString *)hexStr;
-(NSString*)hexFromStr:(NSString*)str;
-(NSString *)GetLocalTimefromUTC:(NSString *)strValue;
-(void)ProgresswithPercentage:(float)progressVal;
-(float)GetLatitudeLongitudevalue:(NSString *)strHex;
@end

