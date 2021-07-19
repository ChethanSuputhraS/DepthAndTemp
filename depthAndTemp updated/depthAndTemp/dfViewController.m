//
//  dfViewController.m
//  depthAndTemp
//
//  Created by stuart watts on 28/06/2019.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "dfViewController.h"

@interface dfViewController ()

@end

@implementation dfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    if (mIntNotificationType == 1)
    {
        //                                    Skip the first packet or retrieve the bd address and no of packets if required
        if (mStringReceivedMsg.startsWith("FFFFFFFD"))
        {
            mIntPacketReceivedLength = BLEUtility.hexToDecimal(mStringReceivedMsg.substring(8, 12));    //packet length
            mStrBleAddress = mStringReceivedMsg.substring(12, 24);    //BLE Address
            intPacketNo = 0;
            intPriviousPacketNo = 0;
            isDataAlreadyAvailable = false;
            setCommandDataAckSignal(mByteAckCommand, (short) intPacketNo);
            if (mIntPacketReceivedLength == 0)
            {
                mUtility.errorDialogWithCallBack("Device data not available.", 0, false, new onAlertDialogCallBack()
                                                 {
                                                     @Override
                                                     public void PositiveMethod(DialogInterface dialog, int id)
                                                     {
                                                     }
                                                     
                                                     @Override
                                                     public void NegativeMethod(DialogInterface dialog, int id)
                                                     {
                                                     }
                                                 });
            }
            return;
        }
        
        if (!mStringReceivedMsg.startsWith("FFFFFFFD"))
        {
            if (mStringReceivedMsg.length() > 4)
            {
                intPacketNo = BLEUtility.hexToDecimal(mStringReceivedMsg.substring(0, 4));
            }
        }
        if (intPacketNo == 1)
        {
            showProgress("Please wait until fetch device data", true);
        }
        if (intPacketNo >= mIntPacketReceivedLength)
        {
            hideProgress();
            if (intPacketNo == mIntPacketReceivedLength)
            {
                if (!isFinishing())
                {
                    mUtility.errorDialogWithCallBack("Device data fetched successfully.", 0, false, new onAlertDialogCallBack()
                                                     {
                                                         @Override
                                                         public void PositiveMethod(DialogInterface dialog, int id)
                                                         {
                                                         }
                                                         
                                                         @Override
                                                         public void NegativeMethod(DialogInterface dialog, int id)
                                                         {
                                                         }
                                                     });
                }
            }
            
        }
        if (intPriviousPacketNo == intPacketNo)
        {
            setCommandDataAckSignal(mByteAckCommand, (short) intPacketNo);
            return;
        }
        intPriviousPacketNo = intPacketNo;
        mStringReceivedMsg = mStringReceivedMsg.substring(4, mStringReceivedMsg.length());
        mIntPackageLength = mStringReceivedMsg.length();
        mStringReceivedMsgProcess = mStringReceivedMsg;
        
        
        
        
        
        
        AsyncTask.execute(new Runnable()
        {
            @Override
            public void run()
            {
                index = 0;
                pressure = "";
                temp = "";
     
                while (mIntPackageLength > 0)
                {
                    // Skip the first packet or retrieve the bd address and no of packets if required
                    data_present = false;
                    index = decodeHeader(mStringReceivedMsgProcess, index);
                    
                    if (mIntPackageLength >= 4 && mNextDecodeType == 0)
                    {
                        pressure = mStringReceivedMsgProcess.substring(index, (index + 4));
                        index += 4;
                        mIntPackageLength = mIntPackageLength - 4;
                        mNextDecodeType = 1;
                        mStoredPressure = pressure;
                    }
                    index = decodeHeader(mStringReceivedMsgProcess, index);
                    if (mIntPackageLength >= 4 && mNextDecodeType == 1)
                    {
                        temp = mStringReceivedMsgProcess.substring(index, (index + 4));
                        index += 4;
                        mIntPackageLength = mIntPackageLength - 4;
                        data_present = true;
                        mNextDecodeType = 0;
                        if (pressure == "")
                            pressure = mStoredPressure;
                    }
                    if (isDataAlreadyAvailable)
                    {
                        System.out.println("JD-DATA SKIPP");
                    } else
                    {
                        if (data_present == true)
                        {
                            
                            mTablePressureTemperature = new TablePressureTemperature();
                            mTablePressureTemperature.setDiveIdFk((int) mLongDiveId);
                            mTablePressureTemperature.setPressure(BLEUtility.hexToDecimal(pressure) + "");
                            mTablePressureTemperature.setTemperature("0");
                            mTablePressureTemperature.setPackets(mStringReceivedMsgFull);
                            mTablePressureTemperature.setPressure_depth("0");
                            mTablePressureTemperature.setTemperature_far("0");
                            try {
                                tempCal = (BLEUtility.hexToDecimal(temp)) / 10;
                                mTablePressureTemperature.setTemperature(tempCal + "");
                                
                                pressCal = (double) BLEUtility.hexToDecimal(pressure);
                                pressCal = (pressCal - 1013) / 100;
                                mTablePressureTemperature.setPressure_depth(pressCal + "");
                                
                                tempCal = ((tempCal * 1.8) + 32);
                                mTablePressureTemperature.setTemperature_far(tempCal + "");
                                full_utc_time = (Long.parseLong(full_utc_time) + (BLEUtility.hexToDecimal(stat_time) * 1000)) + "";
                                mTablePressureTemperature.setUtcTime(Long.parseLong(full_utc_time));
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            mTablePressureTemperature.setCreatedAt((System.currentTimeMillis()));
                            mTablePressureTemperature.setUpdatedAt((System.currentTimeMillis()));
                            mAppRoomDatabase.tempPressDao().insert(mTablePressureTemperature);
                        }
                    }
                }
                setCommandDataAckSignal(mByteAckCommand, (short) intPacketNo);
                
            }
        });
    }*/

    // Do any additional setup after loading the view.
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
