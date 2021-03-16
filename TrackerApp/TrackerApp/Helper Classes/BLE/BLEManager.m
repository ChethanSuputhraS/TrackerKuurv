//
//  SGFManager.m
//  SGFindSDK
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//


#import "BLEManager.h"
#import "Constant.h"

static BLEManager    *sharedManager    = nil;
//BLEManager    *sharedManager    = nil;

@interface BLEManager()<URLManagerDelegate>
{
    NSMutableArray *disconnectedPeripherals;
    NSMutableArray *connectedPeripherals;
    NSMutableArray *peripheralsServices;
    CBCentralManager    *centralManager;
    BLEService * blutoothService;
    BOOL isVitDeviceFound;
    NSTimer * checkDeviceTimer, * songalarmTimer;

    CBPeripheral * disconnectedPeripheral;
    BOOL isAllowtoConnect;
    NSString * strCurrentIdentifier, * strCurrentAddress;
}
@end

@implementation BLEManager
@synthesize delegate,foundDevices,connectedServices,centralManager,nonConnectArr;

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
    centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)];
    centralManager.delegate = self;
    blutoothService.delegate = self;
    [foundDevices removeAllObjects];
    [nonConnectArr removeAllObjects];
    if(!foundDevices)foundDevices = [[NSMutableArray alloc] init];
    if(!nonConnectArr)nonConnectArr = [[NSMutableArray alloc] init];
    if(!connectedServices)connectedServices = [[NSMutableArray alloc] init];
    if(!disconnectedPeripherals)disconnectedPeripherals = [NSMutableArray new];
//    [checkDeviceTimer invalidate];
//    checkDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDeviceWithmas) userInfo:nil repeats:YES];
}

-(void)checkDeviceWithmas
{
    isCheckforDashScann = YES;
    if (isVitDeviceFound)
    {
        isVitDeviceFound = NO;
    }
    else
    {
        updatedRSSI = 0;
    }
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
-(NSArray *)getLastConnected
{
//    if (isConnectionIssue)
//    {
//        //isConnectionIssue = NO;
//    }
    return [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000ab00-0143-0800-0008-e5f9b34fb000"]]];
}
#pragma mark- Scanning Method
-(void)startScan
{
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
        if (peripheral.state == CBPeripheralStateConnected)
        {
            [centralManager cancelPeripheralConnection:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotification" object:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidDisConnectNotificationHome" object:peripheral];
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
    //    NSLog(@"its scanning");
    [self rescan];
}
#pragma mark Scan Sync Timer
-(void)scanDeviceSync:(NSTimer*)timer
{
}
#pragma mark - Finding Device with in Range
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    //  NSLog(@"peripherals==%@",peripherals);
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


#pragma mark - CBCentralManagerDelegate
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScan];
    /*----Here we can come to know bluethooth state----*/
    [blutoothSearchTimer invalidate];
    blutoothSearchTimer = nil;
    blutoothSearchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(searchConnectedBluetooth:) userInfo:nil repeats:YES];
    
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
-(void)WaittoConnectAgain
{
    isAllowtoConnect = YES;
}
#pragma mark - Discover all devices here
/*-----------if device is in range we can find in this method--------*/
- (void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                 RSSI:(NSNumber *)RSSI;
{
    
    NSString * checkNameStr = [NSString stringWithFormat:@"%@",peripheral.name];
    if ([checkNameStr rangeOfString:@"KUURV"].location != NSNotFound)
    {
        NSLog(@"*****************AdvData**************=%@",peripheral);

        NSString * strConnect = [NSString stringWithFormat:@"%@",[advertisementData valueForKey:@"kCBAdvDataIsConnectable"]];
        if ([strConnect isEqualToString:@"1"])
        {
           
            NSString * tmpSri  = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
           NSString * manufacturerData =  [self stringFromDeviceToken:tmpSri];
            
//          NSLog(@"*****************AdvData**************=%@",[advertisementData valueForKey:@"kCBAdvDataManufacturerData"]);
//
//            NSLog(@"*****************AdvData**************=%@",manufacturerData);
            
            NSString * strAdvData = [NSString stringWithFormat:@"%@",manufacturerData]; //this works
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@" " withString:@""];
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@">" withString:@""];
            strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@"<" withString:@""];
            
            if ([strAdvData length] >15)
            {
                NSString * nameString = [NSString stringWithFormat:@"%@",strAdvData]; //this works
                NSString * strOpCodeCheck = [nameString substringWithRange:NSMakeRange(0, 4)];
                if ([strOpCodeCheck isEqualToString:@"5900"])
                {
                    NSString * strBleAddress = [nameString substringWithRange:NSMakeRange(4, 12)];
                    NSInteger foundArrIndex = [[foundDevices valueForKey:@"ble_address"] indexOfObject:strBleAddress];
                    if (foundArrIndex != NSNotFound)
                    {
                        if (foundArrIndex < [foundDevices count])
                        {
                            [[foundDevices objectAtIndex:foundArrIndex] setObject:peripheral forKey:@"peripheral"];
                        }
                    }
                    else
                    {
                        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                        [dict setObject:peripheral forKey:@"peripheral"];
                        [dict setObject:strBleAddress forKey:@"ble_address"];
                        [dict setObject:checkNameStr forKey:@"name"];
                        [foundDevices addObject:dict];
                    }
                    if ([foundDevices count]>0)
                    {
                        if ([arrayDevice count]>0)
                        {
                            NSInteger idxAddress = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:strBleAddress];
                            if (idxAddress != NSNotFound)
                            {
                                if (isAllowtoConnect)
                                {
                                    if (idxAddress < [arrayDevice count])
                                    {
                                        strCurrentAddress = strBleAddress;
                                        strCurrentIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
                                        [self connectDevice:peripheral];
                                        isAllowtoConnect = NO;
                                        [self performSelector:@selector(WaittoConnectAgain) withObject:nil afterDelay:4];
                                        [[arrayDevice objectAtIndex:foundArrIndex] setObject:strCurrentIdentifier forKey:@"identifier"];
                                        [[arrayDevice objectAtIndex:foundArrIndex] setObject:peripheral forKey:@"peripheral"];
                                        if ([[selectedDeviecDict valueForKey:@"ble_address"] isEqualToString:strBleAddress])
                                        {
                                            [selectedDeviecDict setObject:strCurrentIdentifier forKey:@"identifier"];
                                            [selectedDeviecDict setObject:peripheral forKey:@"peripheral"];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (isAddDeviceScreen)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotofiyDiscoveredDevices" object:nil];
                }
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
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"device connected=%@",peripheral);
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"] == NO)
    {
        return;
    }
    /*-------This method will call after succesfully device Ble device connect-----*/
    peripheral.delegate = self;
    if (peripheral.services)
    {
        [self peripheral:peripheral didDiscoverServices:nil];
    }
    else
    {
        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"0000ab00-0143-0800-0008-e5f9b34fb000"]]];
    }
    
    NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
    strCurrentDateNTime =  [self checkforValidString:[self getCurrentTime]];

    //Update Connection status to Server & Database
    NSMutableDictionary * dictDevice = [[NSMutableDictionary alloc] init];
    NSInteger foundIndex;
    /*first check with identifier*/
    if ([[arrayDevice valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
    {
         foundIndex = [[arrayDevice valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
    }
    else /*if identifier not matched then check with Peripheral*/
    {
        foundIndex = [[arrayDevice valueForKey:@"peripheral"] indexOfObject:peripheral];
    }
    NSString * strAddress;
    BOOL isRecordExist = NO;
    if (foundIndex != NSNotFound) /*If found correct index update else ignore*/
    {
        if (foundIndex < [arrayDevice count])
        {
            isRecordExist = YES;
            dictDevice = [arrayDevice objectAtIndex:foundIndex];
            [dictDevice setObject:@"1" forKey:@"correction_status"];
            [[arrayDevice objectAtIndex:foundIndex] setObject:@"1" forKey:@"correction_status"];
            [[arrayDevice objectAtIndex:foundIndex] setObject:strCurrentDateNTime forKey:@"updated_time"];
            strAddress = [[arrayDevice objectAtIndex:foundIndex] valueForKey:@"ble_address"];
            if ([[selectedDeviecDict valueForKey:@"ble_address"] isEqualToString:strAddress])
            {
                [selectedDeviecDict setObject:strCurrentIdentifier forKey:@"identifier"];
                [selectedDeviecDict setObject:peripheral forKey:@"peripheral"];
                [selectedDeviecDict setObject:@"1" forKey:@"correction_status"];
                [selectedDeviecDict setObject:strCurrentDateNTime forKey:@"updated_time"];
            }
            if (![self isNetworkreachable])
            {
                NSString * strUpdate = [NSString stringWithFormat:@"Update 'Device_Table' set updated_time ='%@',identifier ='%@',latitude ='%f',longitude ='%f',correction_status = '1' where ble_address = '%@'",strCurrentDateNTime,strCurrentIdentifier,currentLatitude,currentLongitude,strAddress];
                [[DataBaseManager dataBaseManager] execute:strUpdate];
            }
        }
    }

    [[BLEService sharedInstance] SendCommandWithPeripheral:peripheral withValue:@"14"];
    UIApplication *app=[UIApplication sharedApplication];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (app.applicationState == UIApplicationStateBackground)
        {
            if ([self isNetworkreachable])
            {
                if (isRecordExist)
                {
                    NSString * strUpdate = [NSString stringWithFormat:@"Update 'Device_Table' set updated_time ='%@',identifier ='%@',latitude ='%f',longitude ='%f',correction_status = '1' where ble_address = '%@'",strCurrentDateNTime,strCurrentIdentifier,currentLatitude,currentLongitude,strAddress];
                    [[DataBaseManager dataBaseManager] execute:strUpdate];
                }
            }
            NSLog(@"We are in the background to connect");
            UIUserNotificationSettings *notifySettings=[[UIApplication sharedApplication] currentUserNotificationSettings];
            if ((notifySettings.types & UIUserNotificationTypeAlert)!=0) {
                if ([dictDevice count]>0)
                {
                    [self updateDatatoServer:dictDevice];
                }
            }
        }
        else
        {
            if ([dictDevice count]>0)
            {
                [self updateDatatoServer:dictDevice];
            }
        }
    });
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLoggedIn"] == NO)
    {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidDisConnectNotification" object:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidDisConnectNotificationHome" object:peripheral];
    
    NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
    strCurrentDateNTime = [self checkforValidString:[self getCurrentTime]];
    
    NSMutableDictionary * dictDevice = [[NSMutableDictionary alloc] init];
    NSString * strMessage;
    BOOL isRecordFound = NO;
    BOOL isActiveDevice = NO;
    NSString * strAddress;
    NSInteger foundIndex;
    /*first check with identifier*/
    if ([[arrayDevice valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
    {
        foundIndex = [[arrayDevice valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
    }
    else /*if identifier not matched then check with Peripheral*/
    {
        foundIndex = [[arrayDevice valueForKey:@"peripheral"] indexOfObject:peripheral];
    }

    if (foundIndex != NSNotFound) /*If found correct index update else ignore*/
    {
        if (foundIndex < [arrayDevice count])
        {
            dictDevice = [arrayDevice objectAtIndex:foundIndex];
            [dictDevice setObject:@"0" forKey:@"correction_status"];
            [[arrayDevice objectAtIndex:foundIndex] setObject:@"0" forKey:@"correction_status"];
            [[arrayDevice objectAtIndex:foundIndex] setObject:strCurrentDateNTime forKey:@"updated_time"];

            strAddress = [[arrayDevice objectAtIndex:foundIndex] valueForKey:@"ble_address"];
            if ([[selectedDeviecDict valueForKey:@"ble_address"] isEqualToString:strAddress])
            {
                [selectedDeviecDict setObject:strCurrentIdentifier forKey:@"identifier"];
                [selectedDeviecDict setObject:peripheral forKey:@"peripheral"];
                [selectedDeviecDict setObject:@"0" forKey:@"correction_status"];
                [selectedDeviecDict setObject:strCurrentDateNTime forKey:@"updated_time"];
            }
            strMessage = [NSString stringWithFormat:@"%@ has been disconnected or is out of range.",[[arrayDevice objectAtIndex:foundIndex]valueForKey:@"device_name"]];
            
            if (![self isNetworkreachable])
            {
                NSString * strUpdate = [NSString stringWithFormat:@"Update 'Device_Table' set updated_time ='%@',identifier ='%@',latitude ='%f',longitude ='%f',correction_status = '0' where ble_address = '%@'",strCurrentDateNTime,strCurrentIdentifier,currentLatitude,currentLongitude,strAddress];
                [[DataBaseManager dataBaseManager] execute:strUpdate];
            }
            isRecordFound = YES;
            if ([[[arrayDevice objectAtIndex:foundIndex] valueForKey:@"is_active"] isEqualToString:@"1"])
            {
                isActiveDevice = YES;
            }
        }
    }
    if (isRecordFound == NO)
    {
        foundIndex = [[foundDevices valueForKey:@"peripheral"] indexOfObject:peripheral];
        if (foundIndex != NSNotFound)
        {
            if (foundIndex < [foundDevices count])
            {
                strAddress = [[foundDevices objectAtIndex:foundIndex]valueForKey:@"ble_address"];
                NSInteger bleIndex = [[arrayDevice valueForKey:@"ble_address"] indexOfObject:strAddress];
                if (bleIndex != NSNotFound) /*If found correct index update else ignore*/
                {
                    if (bleIndex < [arrayDevice count])
                    {
                        isRecordFound = YES;
                        dictDevice = [arrayDevice objectAtIndex:bleIndex];
                        [dictDevice setObject:@"0" forKey:@"correction_status"];
                        [[arrayDevice objectAtIndex:bleIndex] setObject:@"0" forKey:@"correction_status"];
                        [[arrayDevice objectAtIndex:bleIndex] setObject:strCurrentDateNTime forKey:@"updated_time"];
                        strAddress = [[arrayDevice objectAtIndex:bleIndex] valueForKey:@"ble_address"];
                        if ([[selectedDeviecDict valueForKey:@"ble_address"] isEqualToString:strAddress])
                        {
                            [selectedDeviecDict setObject:strCurrentIdentifier forKey:@"identifier"];
                            [selectedDeviecDict setObject:peripheral forKey:@"peripheral"];
                            [selectedDeviecDict setObject:@"0" forKey:@"correction_status"];
                            [selectedDeviecDict setObject:strCurrentDateNTime forKey:@"updated_time"];
                        }
                        strMessage = [NSString stringWithFormat:@"%@ has been disconnected or is out of range.",[[arrayDevice objectAtIndex:bleIndex]valueForKey:@"device_name"]];
                        if (![self isNetworkreachable])
                        {
                            NSString * strUpdate = [NSString stringWithFormat:@"Update 'Device_Table' set updated_time ='%@',identifier ='%@',latitude ='%f',longitude ='%f',correction_status = '0' where ble_address = '%@'",strCurrentDateNTime,strCurrentIdentifier,currentLatitude,currentLongitude,strAddress];
                            [[DataBaseManager dataBaseManager] execute:strUpdate];
                        }
                        if ([[[arrayDevice objectAtIndex:bleIndex] valueForKey:@"is_active"] isEqualToString:@"1"])
                        {
                            isActiveDevice = YES;
                        }
                    }
                }
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([IS_SEPERATION_ALERT isEqualToString:@"1"])
        {
            if (isRecordFound)
            {
                if (isActiveDevice)
                {
                    if ([IS_SEPERATION_ALERT isEqualToString:@"1"])
                    {
                        [self delayToCheckAutoConnect:peripheral];
                    }
                }
            }
        }
        UIApplication *app=[UIApplication sharedApplication];
        if (app.applicationState == UIApplicationStateBackground)
        {
            if (isRecordFound)
            {
                if (isActiveDevice)
                {
                    if ([IS_SEPERATION_ALERT isEqualToString:@"1"])
                    {
                        [self delayToCheckAutoConnect:peripheral];
                    }
                    if ([self isNetworkreachable])
                    {
                        NSString * strUpdate = [NSString stringWithFormat:@"Update 'Device_Table' set updated_time ='%@',identifier ='%@',latitude ='%f',longitude ='%f',correction_status = '0' where ble_address = '%@'",strCurrentDateNTime,strCurrentIdentifier,currentLatitude,currentLongitude,strAddress];
                        [[DataBaseManager dataBaseManager] execute:strUpdate];
                    }
                }
            }
            NSLog(@"We are in the background Disconnect");
            UIUserNotificationSettings *notifySettings=[[UIApplication sharedApplication] currentUserNotificationSettings];
            if ((notifySettings.types & UIUserNotificationTypeAlert)!=0)
            {
                UILocalNotification *notification=[UILocalNotification new];
                notification.alertBody=strMessage;
                notification.soundName = UILocalNotificationDefaultSoundName;
                [app presentLocalNotificationNow:notification];
                if ([dictDevice count]>0)
                {
                    [self updateDatatoServer:dictDevice];
                }
            }
        }
        else if(app.applicationState == UIApplicationStateActive)
        {
            if (![[APP_DELEGATE checkforValidString:strMessage] isEqualToString:@"NA"])
            {
                if ([dictDevice count]>0)
                {
                    if (isActiveDevice)
                    {
                        [self updateDatatoServer:dictDevice];
                        
                        UIAlertView *disconnectedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Device Disconnected", nil)  message:strMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                        disconnectedAlert.tag = 8000;
                        [disconnectedAlert show];
                    }
                }
            }
        }
    });
    if (isConnectedtoAdd == NO)
    {
        if ([[arrayDevice valueForKey:@"identifier"] containsObject:[NSString stringWithFormat:@"%@",peripheral.identifier]])
        {
            NSInteger indexID = [[arrayDevice valueForKey:@"identifier"]indexOfObject:[NSString stringWithFormat:@"%@",peripheral.identifier]];
            if (indexID != NSNotFound)
            {
                if (arrayDevice.count > indexID)
                {
                    if ([[[arrayDevice objectAtIndex:indexID]valueForKey:@"is_active"]isEqualToString:@"1"])
                    {
                        NSLog(@"Retrying");
                        if (peripheral.state != CBPeripheralStateConnected)
                        {
                            [self.centralManager connectPeripheral:peripheral options:nil];
                        }
                    }
                }
            }
        }
        else if ([[arrayDevice valueForKey:@"peripheral"] containsObject:peripheral])
        {
            NSInteger indexID = [[arrayDevice valueForKey:@"peripheral"]indexOfObject:peripheral];
            if (indexID != NSNotFound)
            {
                if (arrayDevice.count > indexID)
                {
                    if ([[[arrayDevice objectAtIndex:indexID]valueForKey:@"is_active"]isEqualToString:@"1"])
                    {
                        NSLog(@"Retrying");
                        if (peripheral.state != CBPeripheralStateConnected)
                        {
                            [self.centralManager connectPeripheral:peripheral options:nil];
                        }
                    }
                }
            }
        }
    }
}
-(void)startLocalNotification:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    notification.alertBody = message;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 10;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    });
}
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    BOOL gotService = NO;
    for(CBService* svc in peripheral.services)
    {
        NSLog(@"Discovered services(%@)",svc);

        gotService = YES;
        if(svc.characteristics)
            [self peripheral:peripheral didDiscoverCharacteristicsForService:svc error:nil]; //already discovered characteristic before, DO NOT do it again
        else
            [peripheral discoverCharacteristics:nil forService:svc]; //need to discover characteristics
    }
    if (gotService == NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHud" object:nil];
    }
}
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for(CBCharacteristic* c in service.characteristics)
    {
        NSLog(@"Discovered characteristic %@(%@)",c.description,c.UUID.UUIDString);
    }
    [[BLEService sharedInstance] sendNotifications:peripheral withType:NO withUUID:@"0000AB01-0143-0800-0008-E5F9B34FB000"];
    [[BLEService sharedInstance] EnableNotificationsForCommand:peripheral withType:YES];
    [[BLEService sharedInstance] EnableNotificationsForDATA:peripheral withType:YES];
    [[BLEService sharedInstance] SendCommandWithPeripheral:peripheral withValue:@"5"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidConnectNotification" object:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidConnectNotificationHome" object:peripheral];
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSString *manf=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{});
}


-(void)timeOutConnection
{
    [APP_DELEGATE endHudProcess];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEConnectionErrorPopup" object:nil];
}
-(void)delayToCheckAutoConnect:(CBPeripheral*)peripheral
{
    NSString * strRingTone;
    if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults]valueForKey:@"selectedRingtone"]]isEqualToString:@"NA"])
    {
        NSString * strTmp = [[NSUserDefaults standardUserDefaults]valueForKey:@"selectedRingtone"];
        strRingTone = [NSString stringWithFormat:@"%@.mp3",strTmp];
    }
//    NSString * strRingTone = [NSString stringWithFormat:@"/ringtone%ld.mp3",[sender tag]+1];

    NSURL * songUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath],strRingTone]];
    
    playerWhenDisconnect = [[AVAudioPlayer alloc]initWithContentsOfURL: songUrl error:nil];
    AVAudioSession *audioSession1 = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession1 setCategory :AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&err];
    [audioSession1 setActive:YES error:&err];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [audioSession1 addObserver:self
                   forKeyPath:@"outputVolume"
                      options:0
                      context:nil];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    [playerWhenDisconnect prepareToPlay];
    if ([IS_REPEAT_ALERT isEqualToString:@"ON"] ||[IS_REPEAT_ALERT isEqualToString:@"1"])
    {
        playerWhenDisconnect.numberOfLoops = -1;
    }
    [playerWhenDisconnect play];
    
    [songalarmTimer invalidate];

    songalarmTimer=nil;
    
    disconnectedPeripheral = peripheral;
    long tmp = [[[NSUserDefaults standardUserDefaults]valueForKey:@"alertDuration"]integerValue];
    if ([IS_REPEAT_ALERT isEqualToString:@"ON"] ||[IS_REPEAT_ALERT isEqualToString:@"1"])
    {
        songalarmTimer=[NSTimer scheduledTimerWithTimeInterval:tmp target:self selector:@selector(continuouslyPlaying) userInfo:nil repeats:YES];
    }
    else
    {
//        songalarmTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(continuouslyPlaying) userInfo:nil repeats:YES];

    }}
-(void)continuouslyPlaying
{
    [playerWhenDisconnect stop];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 8000)
    {
        [[BLEService sharedInstance] SendCommandWithPeripheral:disconnectedPeripheral withValue:@"14"];

        if (playerWhenDisconnect.isPlaying)
        {
            [playerWhenDisconnect stop];
            [songalarmTimer invalidate];
            songalarmTimer = nil;
        }
    }
}
-(void)updateDatatoServer:(NSMutableDictionary *)deviceDetail
{
    NSString * strBleAddress = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"ble_address"]];
    NSString * strLat = [NSString stringWithFormat:@"%f", currentLatitude];
    NSString * strLong = [NSString stringWithFormat:@"%f", currentLongitude];
    NSString * strDeviceName = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"device_name"]];
    NSString * strOwnerName = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_name"]];
    NSString * strOwnerEmail = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_email"]];
    NSString * strMobile = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"contact_mobile"]];
    NSString * strConnectionStatus = [APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"correction_status"]];
    NSString * strCurrentTime = [self checkforValidString:[self getCurrentTime]];
    if ([[APP_DELEGATE checkforValidString:[deviceDetail valueForKey:@"marked_lost"]]isEqualToString:@"NA"])
    {
        [deviceDetail setValue:@"0" forKey:@"marked_lost"];
    }
    [[NSUserDefaults standardUserDefaults] setValue:strLat forKey:[NSString stringWithFormat:@"lat_%@",strBleAddress]];
    [[NSUserDefaults standardUserDefaults] setValue:strLong forKey:[NSString stringWithFormat:@"long_%@",strBleAddress]];
    [[NSUserDefaults standardUserDefaults] setValue:strConnectionStatus forKey:[NSString stringWithFormat:@"status_%@",strBleAddress]];
    [[NSUserDefaults standardUserDefaults] setValue:strCurrentTime forKey:[NSString stringWithFormat:@"time_%@",strBleAddress]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([[self checkforValidString:[deviceDetail valueForKey:@"is_active"]] isEqualToString:@"1"])
    {
        if ([self isNetworkreachable])
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"CURRENT_USER_ID"] forKey:@"user_id"];
            [dict setValue:strBleAddress forKey:@"ble_address"];
            [dict setValue:@"2" forKey:@"device_type"];
            [dict setValue:strLat forKey:@"latitude"];
            [dict setValue:strLong forKey:@"longitude"];
            [dict setValue:[deviceDetail valueForKey:@"tracker_device_alert"] forKey:@"tracker_device_alert"];
            [dict setValue:[deviceDetail valueForKey:@"marked_lost"] forKey:@"marked_lost"];
            [dict setValue:@"1" forKey:@"is_active"];
            [dict setValue:strOwnerName forKey:@"contact_name"];
            [dict setValue:strOwnerEmail forKey:@"contact_email"];
            [dict setValue:strMobile forKey:@"contact_mobile"];
            [dict setValue:strDeviceName forKey:@"device_name"];
            [dict setValue:[deviceDetail valueForKey:@"correction_status"] forKey:@"correction_status"];
            [dict setValue:[deviceDetail valueForKey:@"server_id"] forKey:@"device_id"];
            
            URLManager *manager = [[URLManager alloc] init];
            manager.commandName = @"adddevice";
            manager.delegate = self;
            NSString *strServerUrl = @"http://kuurvtrackerapp.com/mobile/adddevice";
            [manager urlCall:strServerUrl withParameters:dict];
            NSLog(@"sent info for Update Device BLE Manager is %@",dict);
        }
    }
}

#pragma mark - UrlManager Delegate
- (void)onResult:(NSDictionary *)result
{
//    [APP_DELEGATE endHudProcess];
    NSLog(@"The result is...%@", result);
    
}
- (void)onError:(NSError *)error
{
//    [APP_DELEGATE endHudProcess];
    
    NSLog(@"The error is...%@", error);
    
    
    NSInteger ancode = [error code];
    
    NSMutableDictionary * errorDict = [error.userInfo mutableCopy];
    NSLog(@"errorDict===%@",errorDict);
    
    if (ancode == -1001 || ancode == -1004 || ancode == -1005 || ancode == -1009) {
//        [APP_DELEGATE ShowErrorPopUpWithErrorCode:ancode andMessage:@""];
    } else {
    }
    
    
    NSString * strLoginUrl = [NSString stringWithFormat:@"%@%@",WEB_SERVICE_URL,@"token.json"];
    if ([[errorDict valueForKey:@"NSErrorFailingURLStringKey"] isEqualToString:strLoginUrl])
    {
        NSLog(@"NSErrorFailingURLStringKey===%@",[errorDict valueForKey:@"NSErrorFailingURLStringKey"]);
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

-(NSString *)getCurrentTime
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    [DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString * currentDateAndTime = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    return currentDateAndTime;
}
-(BOOL)isNetworkreachable
{
    Reachability *networkReachability = [[Reachability alloc] init];
    NetworkStatus networkStatus = [networkReachability internetConnectionStatus];
    if (networkStatus == NotReachable)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    [playerWhenDisconnect stop];

    if ([keyPath isEqual:@"outputVolume"]) {
        NSLog(@"volume changed!");
    }
}
@end
//    kCBAdvDataManufacturerData = <0a00640b 00009059 22590161 00007f0c 09fb0069 00>;
//0a00 0002 32ac 6057 26
//  329a00cc090000ea761800010001787878

