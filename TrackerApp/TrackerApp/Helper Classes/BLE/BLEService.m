//
//  BLEService.m
//
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
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


/*-----kp--------*/
#define CPTD_SERVICE_UUID_STRING                              @"0000ab00-0143-0800-0008-e5f9b34fb000"
#define CPTD_CHARACTERISTIC_COMM_CHAR                         @"0000AB01-0143-0800-0008-E5F9B34FB000"
#define CPTD_CHARACTERISTICS_DATA_CHAR                        @"0000AB01-0100-0800-0008-05F9B34FB000"

//0001D100AB0011E19B2300025B00A5A5

#define CKPTD_SERVICE_UUID_STRING                             @"0000D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATA_CHAR                       @"0001D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATA_CHAR1                      @"0002D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATAAUTH                        @"0002D200-AB00-11E1-9B23-00025B00A5A5"
#define UUID_SMART_MESH_FACTORY_RESET_CHAR                    @"0003D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_SERVICE                         @"0000180F-0000-1000-8000-00805f9b34fb"
#define CKPTD_CHARACTERISTICS_CHARTERISTICS                   @"00002A19-0000-1000-8000-00805F9B34FB"

//0x0002D100AB0011E19B2300025B00A5A5

//#define CKPTD_SERVICE_UUID_STRING1                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR1                       @"0000AB02-0100-0800-0008-05F9B34FB000"
//
//#define CKPTD_SERVICE_UUID_STRING3                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR3                       @"0000AB03-0100-0800-0008-05F9B34FB000"
//
//#define CKPTD_SERVICE_UUID_STRING4                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR4                       @"0000ab04-0100-0800-0008-05F9B34FB000"

static BLEService    *sharedInstance    = nil;

@interface BLEService ()<CBPeripheralDelegate,AVAudioPlayerDelegate>
{
    NSMutableArray *assignedDevices;
    AVAudioPlayer *songAlarmPlayer1;
    BOOL isCannedMsg,isforAuth;
    double lastConnectTimeStamp;
    NSString * lastDatestr;
    NSString * strOwnerName, * strOwnerEmail, * strOwnerMobile;
    CBPeripheral * tmpPeripheral;
}
@property (nonatomic, strong) CBPeripheral *servicePeripheral;
@property (nonatomic,strong) NSMutableArray *servicesArray;
@end

@implementation BLEService
@synthesize servicePeripheral;

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
        //        [servicePeripheral setDelegate:self];
        servicePeripheral = device;
    }
    return self;
}

-(void)startDeviceService:(CBPeripheral *)kpb
{
    [servicePeripheral discoverServices:@[[CBUUID UUIDWithString:@"0000AB00-0100-0800-0008-05F9B34FB000"]]];
}

-(void) readDeviceBattery:(CBPeripheral *)device
{
    if (device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self notification:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:device on:YES];
    }
}

-(void)readDeviceRSSI:(CBPeripheral *)device
{
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
    if (device == nil || device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self soundBuzzer:0x06 peripheral:device];
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

-(void) readAuthValuefromManager:(CBPeripheral *)peripherals;
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
    
    CBService *service = [self findServiceFromUUID:sUUID p:peripherals];
    
    if (!service)
    {
        //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cUUID service:service];
    if (!characteristic)
    {
        //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cUUID],[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    [peripherals readValueForCharacteristic:characteristic];
}
-(void)EnableNotificationsForCommand:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)EnableNotificationsForDATA:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}

#pragma mark- CBPeripheralDelegate
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray        *services    = nil;
    if (peripheral != servicePeripheral)
    {
        return ;
    }
    if (error != nil)
    {
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count])
    {
        return ;
    }
    if (!error)
    {
//        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else
    {
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSArray        *characteristics    = [service characteristics];
//    NSLog(@"didDiscoverCharacteristicsForService %@",characteristics);
    CBCharacteristic *characteristic;
    
    if (peripheral != servicePeripheral) {
        //NSLog(@"didDiscoverCharacteristicsForService Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        //NSLog(@"didDiscoverCharacteristicsForService Error %@\n", error);
        return ;
    }
    
    for (characteristic in characteristics)
    {
        UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
        
        switch(characteristicUUID){
            case TI_KEYFOB_LEVEL_SERVICE_UUID:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:1];
                if (_delegate) {
                    [_delegate activeDevice:peripheral];
                    NSString *battervalStr = [NSString stringWithFormat:@"%f",(float)batlevel];
//                    NSLog(@"battervalStr=====%@",battervalStr);
                    [_delegate batterySignalValueUpdated:peripheral withBattLevel:battervalStr];
                }
                //sending code to identify the from which app it has benn connected i.e, either Find App/others....
                [self soundBuzzer:0x0E peripheral:peripheral];
                
                //to know, from which OS the device has been connected i.e., iOS/Android
                [self soundBuzzer:0x0D peripheral:peripheral];
                break;
            }
        }
    }
}
-(NSString *)stringFromDeviceToken:(NSData *)deviceToken {
    NSUInteger length = deviceToken.length;
    if (length == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(length * 2)];
    for (int i = 0; i < length; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

#pragma mark- BLE send Notifications Here

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"] == NO)
    {
        return;
    }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
            NSInteger foundIndex;
            NSString * strMessage;
            if ([[arrayDevice valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
            {
                foundIndex = [[arrayDevice valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
            }
            else
            {
                foundIndex = [[arrayDevice valueForKey:@"peripheral"] indexOfObject:peripheral];
            }
            if (foundIndex != NSNotFound) /*If found correct index update else ignore*/
            {
                if (foundIndex < [arrayDevice count])
                {
                    strMessage = [NSString stringWithFormat:@"%@ has been connected to phone.",[[arrayDevice objectAtIndex:foundIndex]valueForKey:@"device_name"]];
                }
            }
            UIApplication *app=[UIApplication sharedApplication];
            if (app.applicationState == UIApplicationStateBackground)
            {
                NSLog(@"We are in the background to connect");
                UIUserNotificationSettings *notifySettings=[[UIApplication sharedApplication] currentUserNotificationSettings];
                if ((notifySettings.types & UIUserNotificationTypeAlert)!=0) {
                    UILocalNotification *notification=[UILocalNotification new];
                    notification.alertBody=[NSString stringWithFormat:@"%@", strMessage];
                    NSDateFormatter * df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"hh:mm:ss"];
                    NSString * strDate= [df stringFromDate:[NSDate date]];
                    NSLog(@"Current time stamp=%@",strDate);
                    if (![self->lastDatestr isEqualToString:strDate])
                    {
                        self->lastDatestr = strDate;
                        [app presentLocalNotificationNow:notification];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidConnectNotificationHome" object:peripheral];
                }
            }
        });
        
    //Kalpesh here notification will come
    NSLog(@"Kalpesh ====>>>>  didUpdateValueForCharacteristic==%@",characteristic);
    NSString * strUUID = [NSString stringWithFormat:@"%@",characteristic.UUID];
    if ([strUUID isEqualToString:@"0000AB01-0143-0800-0008-E5F9B34FB000"])
    {
        NSString * valueStr = [NSString stringWithFormat:@"%@",[self stringFromDeviceToken:characteristic.value]];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        
        if (![[self checkforValidString:valueStr] isEqualToString:@"NA"])
        {
            if ([valueStr length]>=6)
            {
                NSString * strOpcode = [valueStr substringWithRange:NSMakeRange(0, 2)];
                if ([strOpcode isEqualToString:@"05"])
                {
                    NSString * strValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
                    NSLog(@"Key Value=%@",strValue);
                    NSString * strinfromHex = [self stringFroHex:strValue];
                    NSLog(@"String from Hex Value=%@",strinfromHex);
                    NSInteger  valuInt = [self convertAlgo:[strinfromHex integerValue]];
                    NSLog(@"Final Int Value=%ld",(long)valuInt);
                    
                    NSData * authData = [[NSData alloc] initWithBytes:&valuInt length:4];
                    
                    NSInteger opInt = 6;
                    NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
                    
                    NSInteger lengths = 4;
                    NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
                    
                    NSMutableData * finalData = [opCodeData mutableCopy];
                    [finalData appendData:lengthData];
                    [finalData appendData:authData];
                    [self SendCommandNSData:finalData withPeripheral:peripheral];
                    NSLog(@"final data=%@",finalData);
                    [[BLEService sharedInstance] SyncUserTextinfowithDevice:CURRENT_USER_UNIQUEKEY with:peripheral withOpcode:@"11"];
                }
                else if ([strOpcode isEqualToString:@"0b"])
                {
                    NSString * strValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:strValue forKey:@"value"];
                    if (isConnectedtoAdd)
                    {
                        if ([isAddingDeviceStirng isEqualToString:[NSString stringWithFormat:@"%@",peripheral.identifier]])
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationCompleted" object:dict];
                            [[BLEService sharedInstance] SendCommandWithPeripheral:peripheral withValue:@"13"];
                        }
                        else
                        {
                            [self updateDataifConnectedDeviceisnotOwned:peripheral withStatus:strValue];
                        }
                    }
                    else
                    {
                        [self updateDataifConnectedDeviceisnotOwned:peripheral withStatus:strValue];
                    }
                }
                else if ([strOpcode isEqualToString:@"01"] || [strOpcode isEqualToString:@"02"] || [strOpcode isEqualToString:@"03"] || [strOpcode isEqualToString:@"04"])
                {
                    [self SendOwnerdetails:valueStr];
                }
                else if ([strOpcode isEqualToString:@"09"])
                {
                    NSString * strValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:strValue forKey:@"status"];
                    [dict setObject:peripheral forKey:@"peripheral"];

//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteDevice" object:dict];
//                    [homeDashboard deleteDevice:dict];
                    [[BLEManager sharedManager] disconnectDevice:peripheral];

                    if ([strValue isEqualToString:@"01"])
                    {
                        if ([arrGlobalDevices containsObject:peripheral])
                        {
                            [arrGlobalDevices removeObject:peripheral];
                        }
                    }
                }
                else if ([strOpcode isEqualToString:@"0d"])
                {
                    NSString * strValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    NSString * strBattery = [self stringFroHex:strValue];
//                    CGFloat tmpBattery = [strBattery floatValue];
                    
                    [dict setObject:strBattery forKey:@"battery"];
                    [dict setObject:[NSString stringWithFormat:@"%@",peripheral.identifier] forKey:@"identifier"];
                    [dict setObject:peripheral forKey:@"peripheral"];
                    [homeDashboard FetchBatteryofDevice:dict];
                    [[BLEService sharedInstance] SendCommandWithPeripheral:peripheral withValue:@"17"];
                }
                else if ([strOpcode isEqualToString:@"0f"])
                {
                    NSString * strValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
                    if ([strValue isEqualToString:@"01"])
                    {
                        strValue = @"1";
                    }
                    else
                    {
                        strValue = @"0";
                    }
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:[NSString stringWithFormat:@"%@",peripheral.identifier] forKey:@"identifier"];
                    [dict setObject:peripheral forKey:@"peripheral"];
                    [dict setObject:strValue forKey:@"values"];
                    [homeDashboard FetchTrackerAlertStatus:dict];
                }
                else if ([strOpcode isEqualToString:@"11"])
                {
                    NSString * strValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
                    if ([strValue isEqualToString:@"01"])
                    {
                        strValue = @"1";
                    }
                    else
                    {
                        strValue = @"0";
                    }
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:[NSString stringWithFormat:@"%@",peripheral.identifier] forKey:@"identifier"];
                    [dict setObject:peripheral forKey:@"peripheral"];
                    [dict setObject:strValue forKey:@"values"];
                    [homeDashboard FetchBuzzerVolume:dict];
                }

            }
        }
        isforAuth = NO;
    }
}
-(void)SendOwnerdetails:(NSString *)ValueStr
{
    NSString * strValue = [ValueStr substringWithRange:NSMakeRange(4, [ValueStr length]-4)];
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [strValue length])
    {
        NSString * hexChar = [strValue substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    NSLog(@"Final inputs=%@",newString);
    NSDictionary * dict = [NSDictionary dictionaryWithObject:newString forKey:@"value"];

    if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedNamefromDevice" object:dict];
    }
    else if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"02"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedMobilefromDevice" object:dict];
    }
    else if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"03"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedEmail1fromDevice" object:dict];
    }
    else if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"04"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedEmail2fromDevice" object:dict];
    }
}
-(void)updateDataifConnectedDeviceisnotOwned:(CBPeripheral *)peripheral withStatus:(NSString *)strStatus
{
    NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
    NSInteger foundIndex;
    if ([[arrayDevice valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
    {
        foundIndex = [[arrayDevice valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
    }
    else
    {
        foundIndex = [[arrayDevice valueForKey:@"peripheral"] indexOfObject:peripheral];
    }

    if (foundIndex != NSNotFound)
    {
        if (foundIndex < [arrayDevice count])
        {
            if ([strStatus isEqualToString:@"01"])
            {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setObject:strStatus forKey:@"value"];
                [dict setObject:peripheral forKey:@"peripheral"];
                [dict setObject:strCurrentIdentifier forKey:@"identifier"];
                [homeDashboard DeviceStatustoHome:dict];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceStatustoHome" object:dict];
            }
            else if ([strStatus isEqualToString:@"00"] || [strStatus isEqualToString:@"02"])
            {
                [[arrayDevice objectAtIndex:foundIndex] setObject:@"2" forKey:@"is_active"];
                [[arrayDevice objectAtIndex:foundIndex] removeObjectForKey:@"peripheral"];
                [[arrayDevice objectAtIndex:foundIndex] removeObjectForKey:@"identifier"];
                
                if ([strStatus isEqualToString:@"02"])
                {
                    NSMutableArray * tmpArr = [[NSMutableArray alloc]init];
                    NSString * strQuery = [NSString stringWithFormat:@"select * from User_Set_Info"];
                    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:tmpArr];
                    if ([tmpArr count]>0)
                    {
                        strOwnerName = [self checkforValidString:[[tmpArr objectAtIndex:0] valueForKey:@"name"]];
                        strOwnerEmail = [self checkforValidString:[[tmpArr objectAtIndex:0] valueForKey:@"email"]];
                        strOwnerMobile = [self checkforValidString:[[tmpArr objectAtIndex:0] valueForKey:@"mobile"]];
                    }
                    tmpPeripheral = peripheral;
                    [[BLEService sharedInstance] writeUserUniqueValue:CURRENT_USER_UNIQUEKEY with:peripheral];
                    [self performSelector:@selector(SyncOwnerName) withObject:nil afterDelay:0.1];
                }
                if ([[selectedDeviecDict valueForKey:@"ble_address"] isEqualToString:[[arrayDevice objectAtIndex:foundIndex] valueForKey:@"ble_address"]])
                {
                    [selectedDeviecDict removeObjectForKey:@"peripheral"];
                    [selectedDeviecDict removeObjectForKey:@"peripheral"];
                    [selectedDeviecDict setObject:@"2" forKey:@"is_active"];
                }
            }
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
//    NSLog(@"peripheralDidUpdateRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[peripheral.RSSI doubleValue],error);
    
    if (error == nil)
    {
        if(peripheral == nil)
            return;
        if (peripheral != servicePeripheral)
        {
            return ;
        }
        if (peripheral==servicePeripheral)
        {
            if (_delegate)
            {
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
//    NSLog(@"didReadRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[RSSI doubleValue],error);
    
    if(peripheral == nil)
        return;
    
    if (peripheral != servicePeripheral)
    {
        //NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    if (peripheral==servicePeripheral)
    {
        
    }
}

#pragma mark - SEND COMMAND NSDATA WITH TOTAL BYTES
-(void)SendCommandNSData:(NSData *)data withPeripheral:(CBPeripheral *)peri
{
    if (peri != nil)
    {
        if (peri.state == CBPeripheralStateConnected)
        {
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peri data:data];
        }
    }
}
#pragma mark - SYNC NAME WITH BLE DEVICE
-(void)SyncUserTextinfowithDevice:(NSString *)strName with:(CBPeripheral *)peripheral withOpcode:(NSString *)opcode
{
    NSString * str = [self hexFromStr:strName];
    NSData * msgData = [self dataFromHexString:str];
    
    
    NSInteger intLength = [strName length];
    NSData * lengthData = [[NSData alloc] initWithBytes:&intLength length:1];

    NSInteger intOpcode = [opcode integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];

    NSMutableData *completeData = [dataOpcode mutableCopy];
    [completeData appendData:lengthData];
    [completeData appendData:msgData];

    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    NSLog(@"Data====>>>>%@",strName);
    
}
-(void)writeUserUniqueValue:(NSString *)strName with:(CBPeripheral *)peripheral
{
    NSString * str = [self hexFromStr:strName];
    NSData * msgData = [self dataFromHexString:str];
    
    
    NSInteger intLength = [strName length];
    NSData * lengthData = [[NSData alloc] initWithBytes:&intLength length:1];
    
    NSInteger intOpcode = 10;
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];
    
    NSMutableData *completeData = [dataOpcode mutableCopy];
    [completeData appendData:lengthData];
    [completeData appendData:msgData];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
}


#pragma mark - Sending Notification
-(void)sendSignals
{
    CBPeripheral * p;
    CBUUID * sUUID = [CBUUID UUIDWithString:@"0505A000D10211E19B2300025B002B2B"];
    CBUUID * cUUID = [CBUUID UUIDWithString:@"0505A001D10211E19B2300025B002B2B"];
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:p on:YES];
}
#pragma mark - Sending notifications
-(void)CBUUIDnotification:(CBUUID*)su characteristicUUID:(CBUUID*)cu p:(CBPeripheral *)p on:(BOOL)on
{
    
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //isConnectionIssue = YES;
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        //isConnectionIssue = YES;
        
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}

#pragma mark - Write value
-(void) CBUUIDwriteValue:(CBUUID *)su characteristicUUID:(CBUUID *)cu p:(CBPeripheral *)p data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:su p:p];
    
    
    if (!service) {
        //isConnectionIssue = YES;
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        //isConnectionIssue = YES;
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
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
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
//            [self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
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
//            NSLog(@"continuousSendSignalToConnectedDevice %lld : real time-%@",mills,[NSDate date]); // For battery
            
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
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            //[self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
            
            NSInteger test = [dataStr integerValue];
            
            //    buzzerValue = 01;
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
        }
    }
}
//15C8B50CF60
-(void)sendHandleString:(CBPeripheral *)peripheral
{
    Byte *bt =0x1F;
    NSData *d = [[NSData alloc] initWithBytes:&bt length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
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
//            NSLog(@"strings===>>>%@",strData);
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
    
    //    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING1];
    //    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
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






-(void)sendNotifications:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:strUUID];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}

-(void)sendNotificationsForOff:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:NO];
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

-(void)sentAuthentication:(CBPeripheral *)kp withValue:(NSString *)dataStr // This is the method in which we can send value of Command like FF04 or 0004 sending as command before sending actual value
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATAAUTH];
            isforAuth=YES;
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
        }
    }
}
#pragma mark  - Method to send Command Values like FF04, 0004, 0001
-(void)sendCommandbeforeSendingValue:(CBPeripheral *)kp withValue:(NSString *)dataStr // This is the method in which we can send value of Command like FF04 or 0004 sending as command before sending actual value
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATAAUTH];
            isforAuth=NO;
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
        }
    }
}
#pragma mark  - Method to send values and not command
-(void)sendBackAuth:(CBPeripheral *)kp withValue:(NSString *)dataStr //This method is using for writting value to ble device with data characteristics (Not Comman characteristics)
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:4];//Lenght is 2 Bytes
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
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
-(NSInteger)convertAlgo:(NSInteger)originValue
{
//    ((((m_auth_key * 55) + 3391) * 16) - (721*m_auth_key + 452));
//    NSInteger final = ((((originValue * 7) + 19) * 12) -((4*originValue) + 13));
    NSInteger final = ((((originValue * 55) + 3391) * 16) - (721*originValue + 452));

    return final;
    //       key_value_gen = ((((auth_key * 7) + 19) * 12) - (4*auth_key + 13));
}
-(NSInteger)AlgorithmforFactoryReset:(NSInteger)originValue
{
    NSInteger final = ((((originValue * 9) + 17) * 23) -((9*originValue) + 55));
    return final;
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
    if (!service)
    {
        //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}
-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}


-(void)MakeBuzzSound:(CBPeripheral *)kp
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger opcodeInt = 7;
            NSData * indexData = [[NSData alloc] initWithBytes:&opcodeInt length:2];
            
            
            NSLog(@"Final data%@",indexData); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:indexData];
        }
    }
}

-(void)SendCommandWithPeripheral:(CBPeripheral *)kp withValue:(NSString *)strValue
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger indexInt = [strValue integerValue];
            NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
            
            
            NSLog(@"Final data%@",indexData); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:indexData];
        }
    }
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
/*
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
    if (!service)
    {
        [self moveToBridegeView];
        //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        [self moveToBridegeView];
        //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
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
    //    NSLog(@" services array is %@",self.servicesArray);
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
 //    NSLog(@"buzzerValue==%d",buzzerValue);
 //    buzzerValue = 01;
 NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
 //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
 
 CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
 CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
 [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
 }
 -(void)soundBuzzerforNotifydevice1:(NSString *)buzzerValue peripheral:(CBPeripheral *)peripheral
 {
 //    NSLog(@"buzzerValue==%@",buzzerValue);
 NSInteger test = [buzzerValue integerValue];
 
 //    buzzerValue = 01;
 NSData *d = [[NSData alloc] initWithBytes:&test length:2];
 //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
 
 CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
 CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
 [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
 }
 #pragma mark - send Battery to device
 -(void) soundbatteryToDevice:(long long)buzzerValue peripheral:(CBPeripheral *)peripheral
 {
 //    NSInteger test = [buzzerValue integerValue];
 //    NSLog(@"test ==> %ld",(long)buzzerValue);
 NSData *d = [NSData dataWithBytes:&buzzerValue length:6];
 CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
 CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTICS_DATA_CHAR];
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
 if (!service)
 {
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
 return;
 }
 CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
 if (!characteristic)
 {
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
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
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
 return;
 }
 CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
 if (!characteristic)
 {
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
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
 

 */

-(void)FetchDeviceBattery:(CBPeripheral *)kpb
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_SERVICE];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_CHARTERISTICS];
    kpb.delegate = self;
    //
    //
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kpb on:YES];
}
#pragma mark - Assign Unique Key and Owner information to Device

-(void)SyncOwnerName
{
    if ([strOwnerName length]>18)
    {
        strOwnerName = [strOwnerName substringWithRange:NSMakeRange(0, 18)];
    }
    [[BLEService sharedInstance] SyncUserTextinfowithDevice:strOwnerName with:tmpPeripheral withOpcode:@"1"];
    [self performSelector:@selector(SyncOwnerMobile) withObject:nil afterDelay:0.1];
}
-(void)SyncOwnerMobile
{
    if ([strOwnerMobile length]>18)
    {
        strOwnerMobile = [strOwnerMobile substringWithRange:NSMakeRange(0, 18)];
    }
    [[BLEService sharedInstance] SyncUserTextinfowithDevice:strOwnerMobile with:tmpPeripheral withOpcode:@"2"];
    
    [self performSelector:@selector(SyncEmailfirstHalf) withObject:nil afterDelay:0.1];
}
-(void)SyncEmailfirstHalf
{
    if ([strOwnerEmail length]>=18)
    {
        NSString * strHalf1 = [strOwnerEmail substringWithRange:NSMakeRange(0, 18)];
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:strHalf1 with:tmpPeripheral withOpcode:@"3"];
    }
    else
    {
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:strOwnerEmail with:tmpPeripheral withOpcode:@"3"];
    }
    [self performSelector:@selector(SyncEmailsecondHalf) withObject:nil afterDelay:0.1];
}
-(void)SyncEmailsecondHalf
{
    if ([strOwnerEmail length]>=18)
    {
        NSString * strHalf2 = [strOwnerEmail substringWithRange:NSMakeRange(18, [strOwnerEmail length]-18)];
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:strHalf2 with:tmpPeripheral withOpcode:@"4"];
    }
    else
    {
        [[BLEService sharedInstance] SyncUserTextinfowithDevice:@"NA" with:tmpPeripheral withOpcode:@"4"];
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"1" forKey:@"value"];
    [dict setObject:tmpPeripheral forKey:@"peripheral"];
    [dict setObject:[NSString stringWithFormat:@"%@",tmpPeripheral.identifier] forKey:@"identifier"];
    [homeDashboard DeviceStatustoHome:dict];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceStatustoHome" object:dict];
//    [self performSelector:@selector(VerifyOwnerSyncedInfo) withObject:nil afterDelay:1];
}


@end

