//
//  BLEService.m
//
//
//  Created by Oneclick IT Solution on 7/11/14.
//  Copyright (c) 2014 One Click IT Consultancy Pvt Ltd, Ind. All rights reserved.
//

#import "BLEService.h"
#import "BLEManager.h"

#import "AppDelegate.h"

#import "DataBaseManager.h"

#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      0x1802
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             0x2a06


#define KP_BATTERY_SERVICE              0x180F
#define KP_BATTERY_CHARTERISTICS        0x2A19


                                                            //0000AD00-D102-11E1-9B23-00025B002B2B
#define DNT_SERVICE_UUID_STRING4                             @"0000AD00-D102-11E1-9B23-00025B002B2B"
#define DNT_CHARACTERISTICS_DATA_CHAR4                       @"0000AD01-D102-11E1-9B23-00025B002B2B"
#define COMMAND_CHARACTERISTICS                              @"0000AD03-D102-11E1-9B23-00025B002B2B"
#define DATA_CHARACTERISTICS                                 @"0000AD04-D102-11E1-9B23-00025B002B2B"


static BLEService	*sharedInstance	= nil;

@interface BLEService ()<CBPeripheralDelegate,AVAudioPlayerDelegate>
{
    NSMutableArray *assignedDevices;
    AVAudioPlayer *songAlarmPlayer1;
    BOOL isCannedMsg;
    NSInteger mIntPackageLength, mDecodeIndex;
    NSString  * full_utc_time, * utc_time;
    NSString * latitudeFull, *  tempLatitude;
    NSString * longitudeFull, * tempLongitude;
    NSString * strStaionayInterval, * strMoveInterval;
    NSInteger mainIndex, mNextDecodeType;
    NSString * mStoredPressure,* pressure, * tempc;
    NSString * packetBLEAddress, * strDeviceName;
    NSInteger totalPackets;
    NSInteger intIncrementStatsCount;
    NSString * strCurrentPacketNo, * strFullPackets, * strPreviousPacket, * strLastPacktNo;
    int tepmrturAutoIncrement;
    int authKeyVal;
    NSString * decimalCurrentPack;

}
@property (nonatomic,strong) NSMutableArray *servicesArray;
@end

@implementation BLEService

#pragma mark- Self Class Methods
-(id)init{
    self = [super init];
    if (self) {
        //do additional work
    }
    return self;
}

+ (instancetype)sharedInstance
{
    if (!sharedInstance)
        sharedInstance = [[BLEService alloc] init];
    
    return sharedInstance;
}

-(id)initWithDevice:(CBPeripheral*)device andDelegate:(id /*<BLEServiceDelegate>*/)delegate{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        [device setDelegate:self];
        //        [globalPeripheral setDelegate:self];
        globalPeripheral = device;
    }
    return self;
}

-(void)startDeviceService:(CBPeripheral *)kpb
{
    kpb.delegate=self;
    [kpb discoverServices:@[[CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4]]];
    
    //    [globalPeripheral discoverServices:[CBUUID UUIDWithString:@"0000AB00-0100-0800-0008-05F9B34FB000"]];
}

-(void) readDeviceBattery:(CBPeripheral *)device
{
    
    if (device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
//        UInt16 characteristicUUID = [self CBUUIDToInt:[CBUUID UUIDWithString:@""]];
//        char batlevel;
//        [characteristic.value getBytes:&batlevel length:1];
//        NSString *battervalStr = [NSString stringWithFormat:@"%f",(float)batlevel];
//        NSLog(@"battervalStr=====%@",battervalStr);
//        
//        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        

    }
}

-(void)readDeviceRSSI:(CBPeripheral *)device
{
    //    NSLog(@"device==%@",device);
    if (device.state == CBPeripheralStateConnected)
    {
        [device readRSSI];
    }
    else
    {
        return;
    }
}

-(void)startBuzzer:(CBPeripheral*)device
{
    NSLog(@"startBuzzer called");
    NSLog(@"startBuzzer called with device ==%@",device);
    if (device == nil || device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        NSLog(@"startBuzzer==0x10");
        [self soundBuzzer:0x06 peripheral:device];
        //to know, from which OS the device has been connected i.e., iOS/Android
        //        [self soundBuzzer:0x0D peripheral:device];
    }
}

-(void)stopBuzzer:(CBPeripheral*)device{
    if (device == nil || device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self soundBuzzer:0x07 peripheral:device];
    }
}


#pragma mark- CBPeripheralDelegate
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray		*services	= nil;
//    if (peripheral != globalPeripheral)
//    {
//        NSLog(@"Wrong Peripheral.\n");
//        return ;
//    }
//    
//    if (error != nil)
//    {
//        NSLog(@"Error %@\n", error);
//        return ;
//    }
    
    services = [peripheral services];
    
    if (!services || ![services count])
    {
        return ;
    }
    
    if (!error)
    {
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else
    {
        printf("Service discovery was unsuccessfull !\r\n");
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSArray		*characteristics	= [service characteristics];
    NSLog(@"didDiscoverCharacteristicsForService %@",characteristics);
    CBCharacteristic *characteristic;
    
//    if (peripheral != globalPeripheral) {
//        //NSLog(@"didDiscoverCharacteristicsForService Wrong Peripheral.\n");
//        return ;
//    }
//    
//    if (error != nil) {
//        //NSLog(@"didDiscoverCharacteristicsForService Error %@\n", error);
//        return ;
//    }
    
    for (characteristic in characteristics)
    {
        UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
        
        switch(characteristicUUID){
            case TI_KEYFOB_LEVEL_SERVICE_UUID:
            {
                globalBtryChar = characteristic;
                char batlevel;
                [characteristic.value getBytes:&batlevel length:1];
                NSString *battervalStr = [NSString stringWithFormat:@"%f",(float)batlevel];
                NSLog(@"battervalStr=====%@",battervalStr);
                
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];


                if (_delegate) {
                    [_delegate activeDevice:peripheral];
                    NSString *battervalStr = [NSString stringWithFormat:@"%f",(float)batlevel];
                    NSLog(@"battervalStr=====%@",battervalStr);
                    [_delegate batterySignalValueUpdated:peripheral withBattLevel:battervalStr];
                }
                //sending code to identify the from which app it has benn connected i.e, either Find App/others....
//                [self soundBuzzer:0x0E peripheral:peripheral];
                
                //to know, from which OS the device has been connected i.e., iOS/Android
//                [self soundBuzzer:0x0D peripheral:peripheral];
                break;
            }
        }
    }
}
-(void)SendValueAfterDelay
{
    [[BLEService sharedInstance] SendValuestoPeripheral:globalPeripheral withValue:authKeyVal];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startProcess" object:nil];
}
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateValueForCharacteristic==%@",characteristic);
    NSString * charUUIDStr = [NSString stringWithFormat:@"%@",characteristic.UUID];
    if ([charUUIDStr isEqualToString:@"Battery Level"])
    {
        char batlevel;
        [characteristic.value getBytes:&batlevel length:1];
        globBatry = [NSString stringWithFormat:@"%g",(float)batlevel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBattery" object:nil];
        NSLog(@"battervalStr=====%@",globBatry);
    }
    else if ([charUUIDStr isEqualToString:@"0000AD03-D102-11E1-9B23-00025B002B2B"])
    {
        NSString * valueStr = [NSString stringWithFormat:@"%@",characteristic.value];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        NSString * strinfromHex = [self stringFroHex:valueStr];
//
        if ([strTypeNotify isEqualToString:@"Authentication"])
        {
            NSString * strV1 = [self stringFroHex:valueStr];
            int inValue = [strV1 intValue];
            authKeyVal = ((((inValue * 23) + 3896) * 27) - (42*inValue + 3129));
            [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"2048"];
            [self performSelector:@selector(SendValueAfterDelay) withObject:nil afterDelay:2];
        }
        if ([strTypeNotify isEqualToString:@"Memory"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMemory" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"Version"])
        {
            NSRange rangeFirst = NSMakeRange(0, 2);
            NSString * strV1 = [self stringFroHex:[valueStr substringWithRange:rangeFirst]];
            rangeFirst = NSMakeRange(2, 2);
            NSString * strV2 = [self stringFroHex:[valueStr substringWithRange:rangeFirst]];
            NSString * strMainV = [NSString stringWithFormat:@"%@.%@",strV1,strV2];
            
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strMainV forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateVersion" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"UTCTime"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUTCtime" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"Battery"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateManualBattery" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"Intervals"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateFrequencyInterval" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"DepthCutOff"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDepthCutOff" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"BLETransmission"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBLETransmission" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"GPSInterval"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGPSInterval" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"GPStimeout"])
        {
            NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGPSTimeOut" object:dict];
        }
        else if ([strTypeNotify isEqualToString:@"CurrentGPS"])
        {
            if (![[APP_DELEGATE checkforValidString:valueStr] isEqualToString:@"NA"])
            {
                if ([valueStr length]==20)
                {
                    NSRange rangeFirst = NSMakeRange(4, 8);
                    NSString * strV1 = [NSString stringWithFormat:@"%f",[self getLatLongfromHex:[valueStr substringWithRange:rangeFirst]]];
                    rangeFirst = NSMakeRange(12, 8);
                    NSString * strV2 = [NSString stringWithFormat:@"%f",[self getLatLongfromHex:[valueStr substringWithRange:rangeFirst]]];
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:strV1,@"lat", strV2, @"long", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCurrentGPSlocation" object:dict];
                }
            }
        }
    }
    else if ([charUUIDStr isEqualToString:@"0000AD01-D102-11E1-9B23-00025B002B2B"])
    {
        NSString * valueStr = [NSString stringWithFormat:@"%@",characteristic.value];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        valueStr = [valueStr lowercaseString];
        
        if ([valueStr isEqualToString:strPreviousPacket])
        {
            return;
        }
        else
        {
            if (![[APP_DELEGATE checkforValidString:valueStr] isEqualToString:@"NA"])
            {
                strPreviousPacket = valueStr;
                if ([valueStr length]>=24)
                {
                    if ([[valueStr substringWithRange:NSMakeRange(0, 8)] isEqualToString:@"fffffffd"])
                    {
                        NSString * strPackets = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(8, 4)]];
                        totalPackets = [strPackets integerValue];
                        if (totalPackets == 0)
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoDataFoundMessage" object:nil];
                        }
                        packetBLEAddress = [[valueStr substringWithRange:NSMakeRange(12, 12)] uppercaseString];
                        NSString * strQry = [NSString stringWithFormat:@"select * from tbl_ble_device where ble_address = '%@'",packetBLEAddress];
                        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
                        [[DataBaseManager dataBaseManager] execute:strQry resultsArray:tmpArr];
                        if ([tmpArr count]>0)
                        {
                            strDeviceName = [[tmpArr objectAtIndex:0] valueForKey:@"device_name"];
                        }
                        else
                        {
                            strDeviceName = @"DepthNTemp1";
                        }
                        strCurrentPacketNo = @"0";
                        strLastPacktNo = @"0";
                        isDataAlreadyAvailable = false;
                        decimalCurrentPack = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(0, 4)]];

                        [self SendAckPackettoPeripheral:globalPeripheral withComman:3583 withValue:strCurrentPacketNo];
                        
                        return;
                    }
                }
                if (totalPackets > 0)
                {
                    
                    strCurrentPacketNo = [self stringFroHex:[NSString stringWithFormat:@"%@%@",[valueStr substringWithRange:NSMakeRange(2, 2)],[valueStr substringWithRange:NSMakeRange(0, 2)]]];
                    strFullPackets = valueStr;
                    [self CheckPacketwithdetails:[valueStr substringWithRange:NSMakeRange(4, [valueStr length]-4)] withFullPacket:valueStr];
                    
                    decimalCurrentPack = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(0, 4)]];
                    NSLog(@"Full Packets=%ld",(long)totalPackets);
                    
                    if ([strCurrentPacketNo integerValue] >= totalPackets)
                    {
                        if ([strCurrentPacketNo integerValue] == totalPackets)
                        {
                            NSLog(@"Current packet=%@",decimalCurrentPack);
                                isSyncingYet = NO;
                                NSLog(@"SYNCING DONE=%@",strCurrentPacketNo);
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncedSuccessfully" object:nil];
                        }
                    }
                    if ([strLastPacktNo integerValue] == [strCurrentPacketNo integerValue])
                    {
                        double progressre = ((([strCurrentPacketNo doubleValue]+1) * 100)/totalPackets);
                        
                        if ([decimalCurrentPack isEqualToString:@"65535"])
                        {
                            progressre = 1;
                        }
                        NSLog(@"KP Progress=%f",progressre);
                        
                        [APP_DELEGATE ProgresswithPercentage:progressre];

                        [self SendAckPackettoPeripheral:globalPeripheral withComman:3583 withValue:strCurrentPacketNo];
                        return;
                    }
                    strLastPacktNo = strCurrentPacketNo;
                    if (globalPeripheral.state == CBPeripheralStateConnected)
                    {
                    }
                    else
                    {
                        NSLog(@"Disconnected");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"forSuddenDisconnection" object:nil];
                    }
                }
                
            }
        }
    }
 }
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
        NSLog(@"didUpdateNotificationStateForCharacteristic =%@",characteristic);
//    [self readValue:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:peripheral];
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
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"peripheralDidUpdateRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[peripheral.RSSI doubleValue],error);
    
    if (error == nil)
    {
        if(peripheral == nil)
            return;
        
        if (peripheral != globalPeripheral)
        {
            NSLog(@"Wrong peripheral\n");
            return ;
        }
        
        if (peripheral==globalPeripheral)
        {
            if (_delegate) {
                [_delegate updateSignalImage:[peripheral.RSSI doubleValue] forDevice:peripheral];
            }
            
            if (peripheral.state == CBPeripheralStateConnected)
            {
                
            }
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"didReadRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[RSSI doubleValue],error);
    
    if(peripheral == nil)
        return;
    
    if (peripheral != globalPeripheral)
    {
        //NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    if (peripheral==globalPeripheral)
    {
        
    }
}

#pragma mark- Helper Methods
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(const char *) CBUUIDToString:(CBUUID *) UUID
{
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:YES forCharacteristic:characteristic];
}
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p
{
    for (int i=0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        
        if ( self.servicesArray )
        {
            if ( ! [self.servicesArray containsObject:s.UUID] )
                [self.servicesArray addObject:s.UUID];
        }
        else
            self.servicesArray = [[NSMutableArray alloc] initWithObjects:s.UUID, nil];
        
        [p discoverCharacteristics:nil forService:s];
    }
    NSLog(@" services array is %@",self.servicesArray);
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

#pragma mark - SoundBuzzer (Sending signals)
-(void) soundBuzzer:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral
{
    
}
#pragma mark - Sounder buzzer for notify device
-(void)soundBuzzerforNotifydevice:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral
{
    NSLog(@"buzzerValue==%d",buzzerValue);
    //    buzzerValue = 01;
    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
    //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
-(void)soundBuzzerforNotifydevice1:(NSString *)buzzerValue peripheral:(CBPeripheral *)peripheral
{
    NSLog(@"buzzerValue==%@",buzzerValue);
    NSInteger test = [buzzerValue integerValue];
    
    //    buzzerValue = 01;
    NSData *d = [[NSData alloc] initWithBytes:&test length:2];
    //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
#pragma mark - send Battery to device
-(void) soundbatteryToDevice:(long long)buzzerValue peripheral:(CBPeripheral *)peripheral
{
    //    NSInteger test = [buzzerValue integerValue];
    NSLog(@"test ==> %ld",(long)buzzerValue);
    NSData *d = [NSData dataWithBytes:&buzzerValue length:6];
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}


-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p readValueForCharacteristic:characteristic];
}

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
{
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    
//    NSLog(@" ***** find data *****%@",data);
//    NSLog(@" ***** find data *****%@",characteristic);
    //    NSLog(@" ***** find data *****%@",data);
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

#pragma mark play Sound
-(void)playSoundWhenDeviceRSSIisLow
{
    // NSLog(@"IS_Range_Alert_ON==%@",IS_Range_Alert_ON);
    //if ([IS_Range_Alert_ON isEqualToString:@"YES"])
    {
        NSURL *songUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beep.wav", [[NSBundle mainBundle] resourcePath]]];
        
        songAlarmPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:songUrl error:nil];
        songAlarmPlayer1.delegate=self;
        
        AVAudioSession *audioSession1 = [AVAudioSession sharedInstance];
        NSError *err = nil;
        [audioSession1 setCategory :AVAudioSessionCategoryPlayback error:&err];
        [audioSession1 setActive:YES error:&err];
        
        [songAlarmPlayer1 prepareToPlay];
        [songAlarmPlayer1 play];
    }
}

-(void)stopPlaySound
{
    [songAlarmPlayer1 stop];
}



#pragma mark - Sending notifications
-(void)CBUUIDnotification:(CBUUID*)su characteristicUUID:(CBUUID*)cu p:(CBPeripheral *)p on:(BOOL)on {
    
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}

#pragma mark - Write value
-(void) CBUUIDwriteValue:(CBUUID *)su characteristicUUID:(CBUUID *)cu p:(CBPeripheral *)p data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:su p:p];
    
    
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    
//    NSLog(@" ***** find data *****%@",data);
//    NSLog(@" ***** find data *****%@",characteristic);
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}
#pragma mark  - send signal before Before
-(void)sendSignalBeforeBattery:(CBPeripheral *)kp withValue:(NSString *)dataStr
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            [self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
        }
    }
}
#pragma mark  - send signals to device
-(void)sendBatterySignal:(CBPeripheral *)kp
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            double secsUtc1970 = [[NSDate date]timeIntervalSince1970];
            
            long long mills = (long long)([[NSDate date]timeIntervalSince1970]*1000.0);
            NSLog(@"continuousSendSignalToConnectedDevice %lld : real time-%@",mills,[NSDate date]); // For battery
            
            NSString * setUTCTime = [NSString stringWithFormat:@"%f",secsUtc1970];
            [self soundbatteryToDevice:mills peripheral:kp];
        }
    }
}
-(void)sendDeviceType:(CBPeripheral *)kp withValue:(NSString *)dataStr
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            //[self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
            
            NSInteger test = [dataStr integerValue];
            
            //    buzzerValue = 01;
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
            
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
        }
    }
}
//15C8B50CF60
-(void)sendHandleString:(CBPeripheral *)peripheral
{
    Byte *bt =0x1F;
            NSData *d = [[NSData alloc] initWithBytes:&bt length:1];
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
-(void)sendingTestToDevice:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
            NSLog(@"strings===>>>%@",strData);
        }
    }
    else
    {
        NSString * str = [strIndex substringWithRange:NSMakeRange(0,1)];
        NSString * string = [self hexFromStr:str];
        NSData * strData = [self dataFromHexString:string];
        [midData appendData:strData];
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];
    
    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];

    /*NSString * str = [self hexFromStr:message];
    NSLog(@"%@", str);
    
    NSData *bytes = [self dataFromHexString:str];
    NSLog(@"This is sent data===>>>%@",bytes);
    
    NSInteger test = [strIndex integerValue];
    NSData *d = [[NSData alloc] initWithBytes:&test length:1];
    
    NSMutableData *completeData = [d mutableCopy];
    [completeData appendData:bytes];
    NSLog(@"This is sent data===>>>%@",completeData);
    
    //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING1];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];*/
    
}
-(void)sendingTestToDeviceCanned:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    
    NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
        }
    }
    else
    {
        NSString * str = [strIndex substringWithRange:NSMakeRange(0,1)];
        NSString * string = [self hexFromStr:str];
        NSData * strData = [self dataFromHexString:string];
        [midData appendData:strData];
        
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];
    
    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];
    
    NSLog(@"data===>>>%@  and Msg =%@",completeData, message);

    /*NSString * str = [self hexFromStr:message];
    NSLog(@"%@", str);
    
    NSData *bytes = [self dataFromHexString:str];
    NSLog(@"This is sent data===>>>%@",bytes);
    
    NSInteger test = [strIndex integerValue];
    NSData *d = [[NSData alloc] initWithBytes:&test length:1];
    
    NSMutableData *completeData = [d mutableCopy];
    [completeData appendData:bytes];
    NSLog(@"This is sent data===>>>%@",bytes);*/
    
    //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
}
-(void)syncDiverMessage:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
        }
    }
    else
    {
        NSString * str = [strIndex substringWithRange:NSMakeRange(0,1)];
        NSString * string = [self hexFromStr:str];
        NSData * strData = [self dataFromHexString:string];
        [midData appendData:strData];
        
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];
    
    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];
    
    NSLog(@"data===>>>%@  and Msg =%@",completeData, message);

    
    /*NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];

    NSLog(@"%@", str);
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,i+1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
            NSLog(@"strings===>>>%@",str);
        }
    }
    else
    {
        
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];

    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];*/
    
    //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
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

- (NSData *)dataFromHexString:(NSString*)hexStr
{
    const char *chars = [hexStr UTF8String];
    int i = 0, len = hexStr.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}
-(void)writeValuetoDevice:(NSData *)message with:(CBPeripheral *)peripheral
{
  //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:message];
    
}
-(void)writeValuetoDeviceDiverMsg:(NSData *)message with:(CBPeripheral *)peripheral
{
    //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:message];
    
}


-(void)GetBatteryValue:(CBPeripheral*)kp
{
    
//    [kp readValueForCharacteristic:characteristic_battery_level];
//
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    kp.delegate = self;
//
//    
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}


//Types : 1 (SC2), 2 (APP), 3 (BOTH)
-(void)EraseMission:(CBPeripheral *)kp withType:(NSInteger)types
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSData * datas = [NSData dataWithBytes:&types length:1];
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:datas];
        }
    }
}

-(void)setExpertModel:(CBPeripheral *)kp withType:(NSInteger)types
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSData * datas = [NSData dataWithBytes:&types length:1];
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:datas];
        }
    }
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
-(float)getSignedInt32fromHex:(NSString *)hexStr
{
    NSString *tempNumber = hexStr;
    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    float actualInt = (int32_t)(temp);
    return actualInt;
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
#pragma mark  - DEPTH N TEMP APP METHODS
-(void)EnableNotificationsForCommand:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:COMMAND_CHARACTERISTICS];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)EnableNotificationsForDATA:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
    CBUUID * cUUID = [CBUUID UUIDWithString:DNT_CHARACTERISTICS_DATA_CHAR4];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)SendCommandWithPeripheral:(CBPeripheral *)kp withValue:(NSString *)strValue
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger indexInt = [strValue integerValue];
            NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:2];
            
            
            NSLog(@"Final data%@",indexData); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:COMMAND_CHARACTERISTICS];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:indexData];
        }
    }
}
-(void)SetUTCTimetoDevice:(CBPeripheral *)kp
{
    strPreviousPacket = @"";
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSDate * sendDate = [NSDate date];
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"timeUfcType"] isEqualToString:@"+1"])
            {
                sendDate = [[NSDate date] dateByAddingTimeInterval:60*60];
            }
            else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"timeUfcType"] isEqualToString:@"-1"])
            {
                sendDate = [[NSDate date] dateByAddingTimeInterval:-3600];
            }
            
            long long mills = (long long)([sendDate timeIntervalSince1970]);
            NSData *dates = [NSData dataWithBytes:&mills length:4];
            
            NSLog(@"Final data%@ and RTC=%lld",dates,mills); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:DATA_CHARACTERISTICS];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:dates];
        }
    }
}
-(void)SendAckPackettoPeripheral:(CBPeripheral *)kp withComman:(NSInteger)commands withValue:(NSString *)values
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger commandValue  = commands;
            NSData *data1 = [NSData dataWithBytes:&commandValue length:2];

            NSInteger dataValue  = [values integerValue];
            NSData *data2 = [NSData dataWithBytes:&dataValue length:2];
            
            NSMutableData * mainData = [[NSMutableData alloc] initWithData:data1];
            [mainData appendData:data2];

            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:COMMAND_CHARACTERISTICS];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:mainData];
        }
    }
}
-(void)SendValuestoPeripheral:(CBPeripheral *)kp withValue:(NSInteger)strValue
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger dataValue  = strValue;
            NSData *datas = [NSData dataWithBytes:&dataValue length:4];
            
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:DATA_CHARACTERISTICS];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:datas];
        }
    }
}
-(void)SendFrequencyDepthValuestoPeripheral:(CBPeripheral *)kp withValue:(CGFloat)strValue
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            CGFloat dataValue  = strValue;
            NSData *datas = [NSData dataWithBytes:&dataValue length:4];
            
            CBUUID * sUUID = [CBUUID UUIDWithString:DNT_SERVICE_UUID_STRING4];
            CBUUID * cUUID = [CBUUID UUIDWithString:DATA_CHARACTERISTICS];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:globalPeripheral data:datas];
        }
    }
}
-(void)SendAcknowledgemen:(CBPeripheral*)kp withType:(NSInteger)packetNo;
{
    
}
-(void)CheckPacketwithdetails:(NSString *)strPackets withFullPacket:(NSString *)completePacket
{
    mainIndex =0;
    mIntPackageLength = [strPackets length];
    bool data_present;
    while (mIntPackageLength > 0)
    {
        /* Skip the first packet or retrieve the bd address and no of packets if required*/
        data_present = false;
        mainIndex = [self decodeHeader:strPackets withIndex:mainIndex withCompletePacket:completePacket];

        if (mIntPackageLength >= 4 && mNextDecodeType == 0)
        {
            pressure = [strPackets substringWithRange:NSMakeRange(mainIndex, 4)];
            mainIndex += 4;
            mIntPackageLength = mIntPackageLength - 4;
            mNextDecodeType = 1;
            mStoredPressure = pressure;
        }
        
        mainIndex = [self decodeHeader:strPackets withIndex:mainIndex withCompletePacket:completePacket];
        if (mIntPackageLength >= 4 && mNextDecodeType == 1)
        {
            tempc = [strPackets substringWithRange:NSMakeRange(mainIndex, 4)];
            mainIndex += 4;
            mIntPackageLength = mIntPackageLength - 4;
            data_present = true;
            mNextDecodeType = 0;
            if ([pressure isEqualToString:@""])
                pressure = mStoredPressure;
        }

        if (isDataAlreadyAvailable)
        {
        }
        else
        {
            if (data_present == true)
            {
                //Add data to database
                tepmrturAutoIncrement = tepmrturAutoIncrement + 1;
                float tempCell = [self getSignedIntfromHex:tempc]/100;
//                NSLog(@"=======>TEMP=%f",tempCell);
                NSString * tempFar = [NSString stringWithFormat:@"%.02f",(tempCell*1.8)+32];
                NSString * strNormalPressure = [self stringFroHex:pressure];
                NSString * strPressDepth = [NSString stringWithFormat:@"%.02f",([strNormalPressure doubleValue]-1013)/100];
                
                double updatedUTC = [[self stringFroHex:full_utc_time] doubleValue]+ intIncrementStatsCount * tepmrturAutoIncrement;
                NSString * strinfromHex = [NSString stringWithFormat:@"%f",updatedUTC];
                long long currentDateTime = [strinfromHex longLongValue] * 1000;
                NSString * strUTCTime = [NSString stringWithFormat:@"%lld",currentDateTime];
                
                NSString * strDiveid = [NSString stringWithFormat:@"%d",tableDiveId];
                NSString * strCurrentTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date]timeIntervalSince1970])];

                NSString * strQry = [NSString stringWithFormat:@"insert into 'tbl_pre_temp'('pre_temp_dive_id','pressure','pressure_depth','temperature','temperature_far', 'utc_time','full_packet', 'created_at', 'updated_at') values(\"%@\",\"%@\",\"%@\",\"%.02f\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strDiveid,strNormalPressure,strPressDepth,tempCell,tempFar,strUTCTime,completePacket,strCurrentTime,strCurrentTime];
                [[DataBaseManager dataBaseManager] execute:strQry];
                NSLog(@"QUERY ===>>> %@",strQry);
            }
        }
        if (mIntPackageLength == 0)
        {
        }
    }
    
//    double progressre = ((([decimalCurrentPack doubleValue]+1) * 100)/totalPackets);
//
//    if ([decimalCurrentPack isEqualToString:@"65535"])
//    {
//        progressre = 1;
//    }
//    NSLog(@"KP Progress=%f",progressre);
//
//    [APP_DELEGATE ProgresswithPercentage:progressre];
//
//    [self SendAckPackettoPeripheral:globalPeripheral withComman:3583 withValue:strCurrentPacketNo];
//
//    NSLog(@"Current packet=%@",decimalCurrentPack);
//
//    if (progressre == 100)
//    {
//        isSyncingYet = NO;
//        NSLog(@"SYNCING DONE=%@",strCurrentPacketNo);
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncedSuccessfully" object:nil];
//    }
//    [self CheckPacketwithdetails:[@"0002001E0909098908E7098408D0097F08C3097A" lowercaseString] withFullPacket:[@"0002001E0909098908E7098408D0097F08C3097A" lowercaseString]];
}
-(NSInteger)decodeHeader:(NSString *)strHeader withIndex:(NSInteger)index withCompletePacket:(NSString *)strCompletePacket
{

    if ([strHeader length]>index)
    {
        if (mDecodeIndex == 0 && [[strHeader substringWithRange:NSMakeRange(index, 4)] isEqualToString:@"ffff"] && mIntPackageLength>=4)
        {
            mIntPackageLength -= 4;
            mDecodeIndex = 1;
            index += 4;
        }
    }
    
    if ([strHeader length]>index)
    {
        if (mDecodeIndex == 1 && [[strHeader substringWithRange:NSMakeRange(index, 4)] isEqualToString:@"fffe"] && mIntPackageLength >= 4)
        {
            mIntPackageLength -= 4;
            mDecodeIndex = 2;
            index += 4;
            //        mStringReceivedMsgFullTemp = mStringReceivedMsgFull;
        }
    }
    
    if ([strHeader length]>index)
    {
        /* Retrieve the UTC time here 4 bytes */
        if (mDecodeIndex == 2 && mIntPackageLength >= 4)
        {
            utc_time = [strHeader substringWithRange:NSMakeRange(index,  4)];
            full_utc_time = utc_time;
            mIntPackageLength -= 4;
            mDecodeIndex = 3;
            index += 4;
        }
    }
    if ([strHeader length]>index)
    {
        if (mDecodeIndex == 3 && mIntPackageLength >= 4)
        {
            utc_time = [strHeader substringWithRange:NSMakeRange(index, 4)];
            
            
            full_utc_time = [full_utc_time stringByAppendingString:utc_time];
            //creating Date from millisecond
            mIntPackageLength -= 4;
            mDecodeIndex = 4;
            index += 4;
        }
    }
    
    if ([strHeader length]>index)
    {
        /* Retrieve 8 bytes of GPS information here */
        // 4 bytes Latitude
        if (mDecodeIndex == 4 && mIntPackageLength >= 4)
        {
            tempLatitude = [strHeader substringWithRange:NSMakeRange(index, 4)];
            latitudeFull = tempLatitude;
            mIntPackageLength -= 4;
            mDecodeIndex = 5;
            index += 4;
        }
    }
    
    if ([strHeader length]>index)
    {
        if (mDecodeIndex == 5 && mIntPackageLength >= 4)
        {
            tempLatitude = [strHeader substringWithRange:NSMakeRange(index, 4)];
            //        latitudeFull += tempLatitude;
            latitudeFull = [latitudeFull stringByAppendingString:tempLatitude];
            mIntPackageLength -= 4;
            mDecodeIndex = 6;
            index += 4;
        }
    }
    
    if ([strHeader length]>index)
    {
        // 4 bytes Longitude
        if (mDecodeIndex == 6 && mIntPackageLength >= 4)
        {
            tempLongitude = [strHeader substringWithRange:NSMakeRange(index, 4)];
            longitudeFull = tempLongitude;
            mIntPackageLength -= 4;
            mDecodeIndex = 7;
            index += 4;
        }
    }
    
    if ([strHeader length]>index)
    {
        if (mDecodeIndex == 7 && mIntPackageLength >= 4)
        {
            tempLongitude = [strHeader substringWithRange:NSMakeRange(index, 4)];
            //        longitudeFull += tempLongitude;
            longitudeFull = [longitudeFull stringByAppendingString:tempLongitude];
            
            mIntPackageLength -= 4;
            mDecodeIndex = 8;
            index += 4;
        }
    }
    

    if ([strHeader length]>index)
    {
        /* Retrieve stationary measurement interval */
        if (mDecodeIndex == 8 && mIntPackageLength >= 4)
        {
            strStaionayInterval = [strHeader substringWithRange:NSMakeRange(index, 4)];
            mIntPackageLength -= 4;
            mDecodeIndex = 9;
            index += 4;
        }
    }
    
    if ([strHeader length]>=index)
    {
        /* Retrieve Moving measurement interval */
        if (mDecodeIndex == 9 && mIntPackageLength >= 4)
        {
            strMoveInterval = [strHeader substringWithRange:NSMakeRange(index,4)];
            mIntPackageLength -= 4;
            mDecodeIndex = 0;
            index += 4;

            NSMutableString * strHexLat;
            if ([[self stringFroHex:latitudeFull] length]>2)
            {
                NSString *hexValueLat = latitudeFull;
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
                strHexLat = [NSMutableString stringWithString:[NSString stringWithFormat:@"%f",finalSol]];
            }
            
            NSMutableString * strHexLong;
            if ([[self stringFroHex:longitudeFull] length]>2)
            {
                NSString *hexValueLat = longitudeFull;
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
                strHexLong = [NSMutableString stringWithString:[NSString stringWithFormat:@"%f",finalSol]];
            }

            NSString * strinfromHex = [self stringFroHex:full_utc_time];
            long long currentDateTime = [strinfromHex longLongValue] * 1000;
            NSString * strUTCTime = [NSString stringWithFormat:@"%lld",currentDateTime];
            
            NSString * strStats = [self stringFroHex:strStaionayInterval];
            intIncrementStatsCount = [strStats integerValue];
            NSString * strMov = [self stringFroHex:strMoveInterval];
            
            NSString * strCurrentTime = [NSString stringWithFormat:@"%lld",(long long)([[NSDate date]timeIntervalSince1970])];

            NSString * strCheck = [NSString stringWithFormat:@"Select ble_address from tbl_dive where ble_address = '%@' and utc_time = '%@'",packetBLEAddress,strUTCTime];
            NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
            [[DataBaseManager dataBaseManager] execute:strCheck resultsArray:tmpArr];
            if ([tmpArr count]>0)
            {
                isDataAlreadyAvailable = true;
                tableDiveId = [[[tmpArr objectAtIndex:0] valueForKey:@"dive_id"] intValue];
                tepmrturAutoIncrement = 0;
 
            }
            else
            {
                
                isDataAlreadyAvailable = false;
                NSString * strInput = [NSString stringWithFormat:@"insert into 'tbl_dive'('ble_address','device_name','dive_no','utc_time','gps_latitude', 'gps_longitude','stationary_interval', 'moving_interval', 'full_packets','created_at', 'updated_At') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",packetBLEAddress,strDeviceName,@"1",strUTCTime,strHexLat,strHexLong,strStats,strMov,strCompletePacket,strCurrentTime,strCurrentTime];
                tableDiveId = [[DataBaseManager dataBaseManager] executeQuerytoGetTableID:strInput];
                NSLog(@"Enter location%@",strInput);
                tepmrturAutoIncrement = 0;
            }
        }
    }
    return index;
}
@end
