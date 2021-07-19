//
//  SGFManager.m
//  SGFindSDK
//
//  Created by Oneclick IT Solution on 7/11/14.
//  Copyright (c) 2014 One Click IT Consultancy Pvt Ltd, Ind. All rights reserved.
//


#import "BLEManager.h"
#import "Constant.h"
#import "Header.h"

static BLEManager	*sharedManager	= nil;
//BLEManager	*sharedManager	= nil;

@interface BLEManager()
{
    NSMutableArray *disconnectedPeripherals;
    NSMutableArray *connectedPeripherals;
    NSMutableArray *peripheralsServices;
    CBCentralManager    *centralManager;
    BLEService * blutoothService;
}
@end

@implementation BLEManager
@synthesize delegate,foundDevices,connectedServices,centralManager;

#pragma mark- Self Class Methods
-(id)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

#pragma mark --> Initilazie
-(void)initialize
{
    //  NSLog(@"bleManager initialized");
    
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionRestoreIdentifierKey:  @"CentralManagerIdentifier" }];
    centralManager.delegate = self;
    blutoothService.delegate = self;
    [foundDevices removeAllObjects];
    if(!foundDevices)foundDevices = [[NSMutableArray alloc] init];
    if(!connectedServices)connectedServices = [[NSMutableArray alloc] init];
    if(!disconnectedPeripherals)disconnectedPeripherals = [NSMutableArray new];
}

+ (BLEManager*)sharedManager
{
    if (!sharedManager)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[BLEManager alloc] init];
        });
    }
    return sharedManager;
}

#pragma mark- Scanning Method
-(void)startScan
{
    
    CBPeripheralManager *pm = [[CBPeripheralManager alloc] initWithDelegate:nil queue:nil];
    //  NSLog(@"pm===%@",pm);
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,nil];
    [centralManager scanForPeripheralsWithServices:nil options:options];
}
#pragma mark - > Rescan Method
-(void) rescan
{
    centralManager.delegate = self;
    blutoothService.delegate = self;
    self.serviceDelegate = self;
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,
                              nil];
    [centralManager scanForPeripheralsWithServices:nil options:options];
}

#pragma mark - Stop Method
-(void)stopScan
{
    self.delegate = nil;
    self.serviceDelegate = nil;
    blutoothService.delegate = nil;
    blutoothService = nil;
    centralManager.delegate = nil;
    [foundDevices removeAllObjects];
    [centralManager stopScan];
    [blutoothSearchTimer invalidate];
    
}
-(void)justStopScanning
{
    [centralManager stopScan];
}
#pragma mark - Central manager delegate method stop
-(void)centralmanagerScanStop
{
    [centralManager stopScan];
}
#pragma mark - Connect Ble device
- (void) connectDevice:(CBPeripheral*)device{
    
    if (device == nil)
    {
        return;
    }
    else
    {//3.13.1 is live or testlgijt ?
        if ([disconnectedPeripherals containsObject:device])
        {
            [disconnectedPeripherals removeObject:device];
        }
        [self connectPeripheral:device];
    }
}

#pragma mark - Disconenct Device
- (void)disconnectDevice:(CBPeripheral*)device
{
    if (device == nil) {
        return;
    }else{
        [self disconnectPeripheral:device];
    }
}

-(void)connectPeripheral:(CBPeripheral*)peripheral
{
    NSError *error;
    if (peripheral)
    {
        if (peripheral.state != CBPeripheralStateConnected)
        {
            [centralManager connectPeripheral:peripheral options:nil];
        }
        else
        {
            if(delegate)
            {
                [delegate didFailToConnectDevice:peripheral error:error];
            }
        }
    }
    else
    {
        if(delegate)
        {
            [delegate didFailToConnectDevice:peripheral error:error];
        }
    }
}

-(void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self.delegate didDisconnectDevice:peripheral];
    if (peripheral)
    {
//        if (peripheral.state == CBPeripheralStateConnected)
        {
            [centralManager cancelPeripheralConnection:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotification" object:peripheral];
        }
    }
}


-(void) updateBluetoothState
{
    [self centralManagerDidUpdateState:centralManager];
}

-(void) updateBleImageWithStatus:(BOOL)isConnected andPeripheral:(CBPeripheral*)peripheral
{
}

#pragma mark -  Search Timer Auto Connect
-(void)searchConnectedBluetooth:(NSTimer*)timer
{
    /*----Here we have Auto reconnect based on local database or saved Device----*/
    //  NSLog(@"foundDevices==hari%@",foundDevices);
    
    //    for(CBPeripheral * p in foundDevices)
    //    {
    //        //       // //  NSLog(@"CBPeripheral p hari == %@",p);
    //        //        if (p.state == CBPeripheralStateConnected)
    //        //        {
    //        //            peripheral = p ;
    //        //           // //  NSLog(@"p==%@",[p name]);
    //        //            NSMutableArray * arrIDs = [[NSMutableArray alloc] init];
    //        //            NSString *queryStr = [NSString stringWithFormat:@"Select * from User_Created_Device where device_name = '%@' AND user_id = '%@' AND connection_type='auto'",[p name],CURRENT_USER_ID];
    //        //            // //  NSLog(@"queryStr==%@",queryStr);
    //        //            [[DataBaseManager dataBaseManager] execute:queryStr resultsArray:arrIDs];
    //        //          //  //  NSLog(@"arrIDs== Connected%@",arrIDs);
    //        //
    //        //            if ([arrIDs count]>0)
    //        //            {
    //        //                if ([CURRENT_USER_ID isEqualToString:@""] || [CURRENT_USER_ID isEqual:[NSNull null]] || CURRENT_USER_ID == nil || [CURRENT_USER_ID isEqualToString:@"(null)"])
    //        //                {
    //        //                }
    //        //                else
    //        //                {
    //        //                    [[BLEService sharedInstance] readDeviceBattery:peripheral];
    //        //                }
    //        //            }
    //        //            else
    //        //            {
    //        //                [self disconnectDevice:p];
    //        //            }
    //        //            [[NSNotificationCenter defaultCenter]postNotificationName:@"DeviceConnectedNotification" object:nil];
    //        //            [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckDeviceAvailabilityNotification" object:nil userInfo:nil];
    //        //            [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothSignalUpdateNotification object:peripheral userInfo:nil];
    //        //        }
    //        //        else
    //        //        {
    //        //            NSMutableArray * arrIDs = [[NSMutableArray alloc] init];
    //        //            NSString *queryStr = [NSString stringWithFormat:@"Select * from User_Created_Device where device_name = '%@' AND user_id = '%@' AND connection_type='auto' ",[p name],CURRENT_USER_ID];
    //        //            [[DataBaseManager dataBaseManager] execute:queryStr resultsArray:arrIDs];
    //        //            //  NSLog(@"arrIDs== connecting%@",arrIDs);
    //        //
    //        //            if ([arrIDs count]>0)
    //        //            {
    //        //                //  NSLog(@"self.autoConnect==%d",V_IS_Auto_Connect);
    //        //                if ([CURRENT_USER_ID isEqualToString:@""] || [CURRENT_USER_ID isEqual:[NSNull null]] || CURRENT_USER_ID == nil || [CURRENT_USER_ID isEqualToString:@"(null)"])
    //        //                {
    //        //                }
    //        //                else
    //        //                {
    //        //                         [self connectDevice:p];
    //        //                }
    //        //                [[NSNotificationCenter defaultCenter]postNotificationName:@"DeviceConnectedNotification" object:nil];
    //        //                [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckDeviceAvailabilityNotification" object:nil userInfo:nil];
    //        //                [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothSignalUpdateNotification object:peripheral userInfo:nil];
    //        //            }
    //        //        }*/
    //    }
    
    [self rescan];
}
#pragma mark Scan Sync Timer
-(void)scanDeviceSync:(NSTimer*)timer
{
    //    NSMutableArray * arrRecord = [[NSMutableArray alloc] init];
    //    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM Scanned_Device_History_Table where device_owner_id = '%@' group by device_id order by date_time DESC ",CURRENT_USER_ID];
    //    [[DataBaseManager dataBaseManager] execute:queryStr resultsArray:arrRecord];
    //    //  NSLog(@"arrRecord==>>>>%@",arrRecord);
    
    //    if ([arrRecord count]>0)
    //    {
    //        [self saveScannedDeviceHistoryWebServiceForDevices:arrRecord];
    //    }
    
    
}

#pragma mark --> readRSSITimer
//-(void)readRSSIValueForConnectedDevice:(NSTimer*)timer
//{
//    //    for(CBPeripheral * p in arrCases)
//    for(CBPeripheral * p in foundDevices)
//    {
//        //        if (p.state == CBPeripheralStateConnected)
//        //        {
//        //            NSMutableArray * arrIDs = [[NSMutableArray alloc] init];
//        //            NSString *queryStr = [NSString stringWithFormat:@"Select * from User_Created_Device where device_name = '%@' AND user_id = '%@' ",[p name],CURRENT_USER_ID];
//        //            [[DataBaseManager dataBaseManager] execute:queryStr resultsArray:arrIDs];
//        //
//        //            if ([arrIDs count]>0)
//        //            {
//        //                if ([CURRENT_USER_ID isEqualToString:@""] || [CURRENT_USER_ID isEqual:[NSNull null]] || CURRENT_USER_ID == nil || [CURRENT_USER_ID isEqualToString:@"(null)"])
//        //                {
//        //                }
//        //                else
//        //                {
//        //                    [[BLEService sharedInstance] readDeviceRSSI:p];
//        //                }
//        //            }
//        //        }
//        //        else
//        //        {
//        //           /* if (p.state != CBPeripheralStateConnected)
//        //            {
//        //                NSMutableArray * arrIDs = [[NSMutableArray alloc] init];
//        //                NSString *queryStr = [NSString stringWithFormat:@"Select * from User_Created_Device where device_id = '%@' AND isPrimaryDevice = 'YES' AND user_id = '%@'",[p name],CURRENT_USER_ID];
//        //                [[DataBaseManager dataBaseManager] execute:queryStr resultsArray:arrIDs];
//        //
//        //                if ([arrIDs count]>0)
//        //                {
//        //                    //                    //  NSLog(@"self.autoConnect==%d",V_IS_Auto_Connect);
//        //                    if ([CURRENT_USER_ID isEqualToString:@""] || [CURRENT_USER_ID isEqual:[NSNull null]] || CURRENT_USER_ID == nil || [CURRENT_USER_ID isEqualToString:@"(null)"])
//        //                    {
//        //                    }
//        //                    else
//        //                    {
//        //                        if ([IS_Range_Alert_ON isEqualToString:@"YES"])
//        //                        {
//        //                            if (V_IS_Auto_Connect == YES)
//        //                            {
//        //                                [self playSoundWhenDeviceRSSIisLow];
//        //                            }
//        //                        }
//        //                    }
//        //                }
//        //            }*/
//        //        }
//    }
//}





#pragma mark - CBCentralManagerDelegate

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScan];
    /*----Here we can come to know bluethooth state----*/
    [blutoothSearchTimer invalidate];
    blutoothSearchTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(searchConnectedBluetooth:) userInfo:nil repeats:YES];
    
    switch (central.state)
    {
        case CBPeripheralManagerStateUnknown:
            //The current state of the peripheral manager is unknown; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The current state of the peripheral manager is unknown; an update is imminent."];
            
            break;
        case CBPeripheralManagerStateUnauthorized:
            //The app is not authorized to use the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The app is not authorized to use the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStateResetting:
            //The connection with the system service was momentarily lost; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The connection with the system service was momentarily lost; an update is imminent."];
            
            break;
        case CBPeripheralManagerStatePoweredOff:
            //Bluetooth is currently powered off"
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered off."];
            
            break;
        case CBPeripheralManagerStateUnsupported:
            //The platform doesn't support the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The platform doesn't support the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStatePoweredOn:
            //Bluetooth is currently powered on and is available to use.
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered on and is available to use."];
            break;
    }
}

#pragma mark - Finding Device with in Range
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    //  NSLog(@"peripherals==%@",peripherals);
}

#pragma mark - Discover all devices here
/*-----------if device is in range we can find in this method--------*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString * connectStr = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataIsConnectable"]];

    if ([connectStr isEqualToString:@"1"])
    {
        NSString * strName = [NSString stringWithFormat:@"%@",peripheral.name];

        if (!([strName rangeOfString:@"Succorfish D&T"].location == NSNotFound))
        {
            NSLog(@"device is caning =%@",[advertisementData valueForKey:@"kCBAdvDataManufacturerData"]);
            
            NSString * strAdvData = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataManufacturerData"]]; //this works
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@" " withString:@""];
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@">" withString:@""];
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@"<" withString:@""];
            //BLEaddress Memory Battery Version
            if ([strAdvData length] >=36)
            {
                NSString *nameString = [NSString stringWithFormat:@"%@",strAdvData]; //this works
                NSRange rangeFirst = NSMakeRange(0, 4);
                NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
                
                if ([strOpCodeCheck isEqualToString:@"5900"])
                {
                    NSString * strFinalData = [self getStringConvertedinUnsigned:[strAdvData substringWithRange:NSMakeRange(4, 32)]];

                    NSData * updatedMFData = [self GetDecrypedDataKeyforData:strFinalData withKey:strFinalData withLength:16];
                    NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData];
                    strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
                    strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
                    strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
                    
                    rangeFirst = NSMakeRange(0, 12);
                    NSString * strBleAddress = [strDecrypted substringWithRange:rangeFirst];
                    
                    rangeFirst = NSMakeRange(16, 8);
                    NSString * strHexLat  = [strDecrypted substringWithRange:rangeFirst];
                    
                    rangeFirst = NSMakeRange(24, 8);
                    NSString * strHexLong  = [strDecrypted substringWithRange:rangeFirst];
                    
                    if (![[foundDevices valueForKey:@"address"] containsObject:strBleAddress])
                    {
                        if(![peripheral.name isEqualToString:@"(null)"] && ![peripheral.name isEqual:[NSNull null]] && [peripheral.name length]>0)
                        {
                            if ([foundDevices count]>0)
                            {
                                for (int i=0; i<[foundDevices count]; i++)
                                {
                                    NSString * Cbpd = [[foundDevices objectAtIndex:i] valueForKey:@"address"];
                                    if ([Cbpd isEqualToString:strBleAddress])
                                    {
                                        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                                        [dict setObject:peripheral forKey:@"peripheral"];
                                        [dict setObject:strBleAddress forKey:@"address"];
                                        [dict setObject:peripheral.name forKey:@"name"];
                                        [dict setObject:@"NA" forKey:@"memory"];
                                        [dict setObject:@"NA" forKey:@"battery"];
                                        [dict setObject:@"NA" forKey:@"version"];
                                        [dict setObject:strHexLat forKey:@"lat"];
                                        [dict setObject:strHexLong forKey:@"long"];
                                        [foundDevices replaceObjectAtIndex:i withObject:dict];
                                        break;
                                    }
                                    else
                                    {
                                        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                                        [dict setObject:peripheral forKey:@"peripheral"];
                                        [dict setObject:strBleAddress forKey:@"address"];
                                        [dict setObject:peripheral.name forKey:@"name"];
                                        [dict setObject:@"NA" forKey:@"memory"];
                                        [dict setObject:@"NA" forKey:@"battery"];
                                        [dict setObject:@"NA" forKey:@"version"];
                                        [dict setObject:strHexLat forKey:@"lat"];
                                        [dict setObject:strHexLong forKey:@"long"];
                                        [foundDevices addObject:dict];
                                    }
                                }
                            }
                            else
                            {
                                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                                [dict setObject:peripheral forKey:@"peripheral"];
                                [dict setObject:strBleAddress forKey:@"address"];
                                [dict setObject:peripheral.name forKey:@"name"];
                                [dict setObject:@"NA" forKey:@"memory"];
                                [dict setObject:@"NA" forKey:@"battery"];
                                [dict setObject:@"NA" forKey:@"version"];
                                [dict setObject:strHexLat forKey:@"lat"];
                                [dict setObject:strHexLong forKey:@"long"];
                                [foundDevices addObject:dict];
                            }
                        }
                    }
                    
                    for (int i =0; i<[connectedDevice count]; i++)
                    {
                        CBPeripheral * tmpPeri = [[connectedDevice objectAtIndex:i] objectForKey:@"peripheral"];
                        if (tmpPeri.state == CBPeripheralStateConnected)
                        {
                            if ([[foundDevices valueForKey:@"address"] containsObject:[[connectedDevice objectAtIndex:i] objectForKey:@"address"]])
                            {
                            }
                            else
                            {
                                [foundDevices addObject:[connectedDevice objectAtIndex:i]];
                            }
                        }
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallNotificationforDiscover" object:peripheral userInfo:advertisementData];
                }
            }
        }
        else
        {
            BOOL isAdded = NO;
            for (int i =0; i<[connectedDevice count]; i++)
            {
                CBPeripheral * tmpPeri = [[connectedDevice objectAtIndex:i] objectForKey:@"peripheral"];
                if (tmpPeri.state == CBPeripheralStateConnected)
                {
                    if ([[foundDevices valueForKey:@"address"] containsObject:[[connectedDevice objectAtIndex:i] objectForKey:@"address"]])
                    {
                        
                    }
                    else
                    {
                        isAdded = YES;
                        [foundDevices addObject:[connectedDevice objectAtIndex:i]];
                    }
                }
            }
            
            if (isAdded)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CallNotificationforDiscover" object:peripheral userInfo:advertisementData];
            }
        }
    }
}

#pragma mark - > Resttore state of devices
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSArray *peripherals =dict[CBCentralManagerRestoredStatePeripheralsKey];
    
    if (peripherals.count>0)
    {
        for (CBPeripheral *p in peripherals)
        {
            if (p.state != CBPeripheralStateConnected)
            {
                //[self connectPeripheral:p];
            }
        }
    }
}

#pragma mark - Fail to connect device
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    /*---This method will call if failed to connect device-----*/
    if(delegate)[delegate didFailToConnectDevice:peripheral error:error];
}

- (void)discoverIncludedServices:(nullable NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;
{
    
}
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
{
    
}
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;
{
    
}


#pragma mark - Connect Delegate method
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //    [[BLEManager sharedManager] stopScan];//HARI12*-06-2017
    
    /*-------This method will call after succesfully device Ble device connect-----*/
        peripheral.delegate = self;
    globalPeripheral = peripheral;
    if (peripheral.services)
    {
        [self peripheral:peripheral didDiscoverServices:nil];
    } else
    {
//        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"0000AD01-D102-11E1-9B23-00025B002B2B"]]];
        [peripheral discoverServices:nil];

    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidConnectNotification" object:peripheral];

}
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
//    [APP_DELEGATE endHudProcess];

    BOOL gotService = NO;
    for(CBService* svc in peripheral.services)
    {
        gotService = YES;
          NSLog(@"service=%@",svc);
        if(svc.characteristics)
            [self peripheral:peripheral didDiscoverCharacteristicsForService:svc error:nil]; //already discovered characteristic before, DO NOT do it again
        else
            [peripheral discoverCharacteristics:nil
                                     forService:svc]; //need to discover characteristics
    }
    if (gotService == NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHud" object:nil];
        [self disconnectDevice:peripheral];
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for(CBCharacteristic* c in service.characteristics)
    {
          NSLog(@"characteristics=%@",c);
        
        //Do some work with the characteristic...
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidConnectNotification" object:peripheral];

}

#pragma mark - Disconnect Ble Device
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
{
    NSLog(@"Disconnected=%@",peripheral);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotification" object:peripheral];

}
-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal
{
    NSString * strKey = strNormal;
    long ketLength = [strKey length]/2;
    NSString * strVal;
    for (int i=0; i<ketLength; i++)
    {
        NSRange range73 = NSMakeRange(i*2, 2);
        NSString * str3 = [strKey substringWithRange:range73];
        if ([strVal length]==0)
        {
            strVal = [NSString stringWithFormat:@" 0x%@",str3];
        }
        else
        {
            strVal = [strVal stringByAppendingString:[NSString stringWithFormat:@" 0x%@",str3]];
        }
    }
    return strVal;
}
-(NSData *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    strKey = [NSString stringWithFormat:@"0x23 0x89 0xa2 0x5d 0x88 0xbb 0xca 0x12 0x98 0x44 0x69 0x66 0x74 0x74 0x98 0x54"];
    
    //RAW Data of 16 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[16];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    
    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 0);
    
    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)tempResultOp length:sizeof(unsigned char)*size];
    //    NSLog(@"Data=%@",data);
    return data;
}
-(void)CheckScnningLatLong
{
    NSString * strAdvData = @"59004EFEF5657178FBC50053C8092FC70EEB";
    if ([strAdvData length] >=36)
    {
        NSString *nameString = [NSString stringWithFormat:@"%@",strAdvData]; //this works
        NSRange rangeFirst = NSMakeRange(0, 4);
        NSString * strOpCodeCheck = [nameString substringWithRange:rangeFirst];
        
        if ([strOpCodeCheck isEqualToString:@"5900"])
        {
            NSString * strFinalData = [self getStringConvertedinUnsigned:[strAdvData substringWithRange:NSMakeRange(4, 32)]];
            
            NSData * updatedMFData = [self GetDecrypedDataKeyforData:strFinalData withKey:strFinalData withLength:16];
            NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
            strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            rangeFirst = NSMakeRange(0, 12);
            NSString * strBleAddress = [strDecrypted substringWithRange:rangeFirst];
            
            rangeFirst = NSMakeRange(16, 8);
            NSString * strHexLat  = [strDecrypted substringWithRange:rangeFirst];
            NSLog(@"LAT=%f", [self getLatLongfromHex:strHexLat]);
            rangeFirst = NSMakeRange(24, 8);
            NSString * strHexLong  = [strDecrypted substringWithRange:rangeFirst];
            NSLog(@"LONG=%f", [self getLatLongfromHex:strHexLong]);


        }
    }
}
-(double)getLatLongfromHex:(NSString *)strHex
{
    NSString *hexValueLat = strHex;
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
    return finalSol;
}

@end
